import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../widgets/credential_input_field.dart';
import '../../widgets/user_image_container.dart';
import '../auth_screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _userProfileImage;
  late MainScreenProvider provider;

  @override
  void initState() {
    super.initState();
    provider = MainScreenProvider();
    provider.initializeData();
  }

  Future<void> getProfileImage() async {
    if (provider.isEditable) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      setState(() {
        _userProfileImage = pickedFile != null ? File(pickedFile.path) : null;
        if (_userProfileImage != null) {
          provider.imageUrl = _userProfileImage!.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Main Screen'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text("Log Out"),
                  )
                ];
              },
              onSelected: (value) {
                if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: provider == null
            ? Container()
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),
                      Consumer<MainScreenProvider>(
                        builder: (context, provider, child) =>
                            UserImageContainer(
                          getGalleryImage: getProfileImage,
                          image: provider.isEditable ? _userProfileImage : null,
                          imageUrl: provider.imageUrl,
                          validateText: 'Please choose profile picture',
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Consumer<MainScreenProvider>(
                        builder: (context, provider, child) =>
                            CredentialInputField(
                          keyboardType: TextInputType.text,
                          hintText: 'User name',
                          prefixIcon: Icon(Icons.person),
                          controller: provider.nameController,
                          enabled: provider.isEditable,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your phone number";
                            }
                            return null;
                          },
                          inputFormatter:
                              FilteringTextInputFormatter.singleLineFormatter,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Consumer<MainScreenProvider>(
                        builder: (context, provider, child) =>
                            CredentialInputField(
                          keyboardType: TextInputType.number,
                          hintText: 'Phone number',
                          prefixIcon: Icon(Icons.call),
                          controller: provider.phoneNumberController,
                          enabled: provider.isEditable,
                          minLength: 11,
                          maxLength: 11,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your phone number";
                            }
                            if (value.length < 10) {
                              return "Phone Number must be at least 10 characters long";
                            }
                            return null;
                          },
                          inputFormatter:
                              FilteringTextInputFormatter.singleLineFormatter,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: () {
                          provider.setIsEditable(true);
                        },
                        child: Text('Edit Profile'),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Visibility(
                        visible: provider.isEditable,
                        child: ElevatedButton(
                          onPressed: () async {
                            await provider.updatedData();
                            provider.setIsEditable(false);
                            if (_userProfileImage != null) {
                              await provider
                                  .uploadImageToFirebase(_userProfileImage!);
                            }
                          },
                          child: Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class MainScreenProvider with ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  bool isEditable = false;
  String? imageUrl;

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> initializeData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await databaseRef.doc(currentUser!.uid).get();
    nameController.text = snapshot.data()?['name'] ?? '';
    phoneNumberController.text = snapshot.data()?['phone_number'] ?? '';
    imageUrl = snapshot.data()?['profile_image_url'] ?? '';
  }

  Future<void> updatedData() async {
    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final User? currentUser = FirebaseAuth.instance.currentUser;

    await databaseRef.doc(currentUser!.uid).update({
      'uid': currentUser!.uid,
      'name': nameController.text,
      'phone_number': phoneNumberController.text,
      'profile_image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void setIsEditable(bool value) {
    isEditable = value;
    notifyListeners();
  }

  Future<void> uploadImageToFirebase(File image) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final Reference storageReference =
        storage.ref().child('user_images/${currentUser!.uid}');
    await storageReference.putFile(image);
    imageUrl = await storageReference.getDownloadURL();
    notifyListeners();
  }
}
