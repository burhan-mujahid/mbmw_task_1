import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/utils.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/credential_input_field.dart';
import '../../widgets/image_picker_container.dart';
import '../../widgets/page_heading.dart';
import '../user_screens/main_screen.dart';

class AddUserInfoFirestore extends StatefulWidget {
  const AddUserInfoFirestore({Key? key}) : super(key: key);

  @override
  State<AddUserInfoFirestore> createState() => _AddUserInfoFirestoreState();
}

class _AddUserInfoFirestoreState extends State<AddUserInfoFirestore> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  File? _userProfileImage;
  final userProfileImagePicker = ImagePicker();

  final CollectionReference<Map<String, dynamic>> databaseRef =
      FirebaseFirestore.instance.collection('Users');

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> getProfileImage() async {
    final pickedFile = await userProfileImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      _userProfileImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> addUserInfoToFirestore(String profileImageUrl) async {
    try {
      await databaseRef.doc(currentUser!.uid).set({
        'uid': currentUser!.uid,
        'name': nameController.text.trim(),
        'phone_number': phoneNumberController.text.trim(),
        'profile_image_url': profileImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Utils().toastMessage('User information added successfully');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      Utils().toastMessage('Error: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Add User Information',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(currentUser!.uid),
            PageHeading(
              title: "Personal Details",
              subtitle: 'Finalizing Sign-Up',
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    Center(
                      child: ImagePickerContainer(
                        getGalleryImage: getProfileImage,
                        image: _userProfileImage,
                        validateText: 'Please choose a profile picture',
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CredentialInputField(
                      keyboardType: TextInputType.text,
                      hintText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                      inputFormatter:
                          FilteringTextInputFormatter.singleLineFormatter,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CredentialInputField(
                      keyboardType: TextInputType.phone,
                      hintText: 'Phone number',
                      prefixIcon: Icon(Icons.phone),
                      controller: phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }
                        return null;
                      },
                      inputFormatter: FilteringTextInputFormatter.digitsOnly,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: AuthButton(
                title: 'Submit',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });

                    firebase_storage.Reference userProfileImageRef =
                        firebase_storage.FirebaseStorage.instance.ref(
                            'userimagesfolder/${currentUser?.uid}/profile_image');

                    firebase_storage.UploadTask uploadTask =
                        userProfileImageRef.putFile(
                      _userProfileImage!,
                    );

                    try {
                      await uploadTask;
                      var profileImageUrl =
                          await userProfileImageRef.getDownloadURL();

                      await addUserInfoToFirestore(profileImageUrl);
                    } catch (e) {
                      Utils().toastMessage('Error: $e');
                    }
                  }
                },
                loading: loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
