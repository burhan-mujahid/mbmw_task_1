import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamw_task_1/ui/user_screens/details_screen.dart';
import 'package:provider/provider.dart';

import '../../widgets/credential_input_field.dart';
import '../auth_screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _userProfileImage;
  late MainScreenProvider provider;

  @override
  void initState() {
    super.initState();
    provider = MainScreenProvider();
    provider.initializeData();
  }

  // Future<void> getProfileImage() async {
  //   if (provider.isEditable) {
  //     final pickedFile = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //       imageQuality: 80,
  //     );
  //     setState(() {
  //       _userProfileImage = pickedFile != null ? File(pickedFile.path) : null;
  //       if (_userProfileImage != null) {
  //         provider.imageUrl = _userProfileImage!.path;
  //       }
  //     });
  //   }
  // }

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
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailsScreen()));
              },
              icon: Icon(Icons.person)),
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Logout"),
                        content: Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            child: Text("No"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Yes"),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        ],
                      );
                    },
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        // Consumer<MainScreenProvider>(
                        //   builder: (context, provider, child) =>
                        //       UserImageContainer(
                        //     getGalleryImage: getProfileImage,
                        //     image: provider.isEditable ? _userProfileImage : null,
                        //     imageUrl: provider.imageUrl,
                        //     validateText: 'Please choose profile picture',
                        //   ),
                        // ),
                        SizedBox(height: screenHeight * 0.02),
                        Consumer<MainScreenProvider>(
                          builder: (context, provider, child) =>
                              CredentialInputField(
                            keyboardType: TextInputType.text,
                            hintText: 'First name',
                            prefixIcon: Icon(Icons.person),
                            controller: provider.firstnameController,
                            enabled: provider.isEditable,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your first name";
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
                            keyboardType: TextInputType.text,
                            hintText: 'Last Name',
                            prefixIcon: Icon(Icons.person),
                            controller: provider.lastnameController,
                            enabled: provider.isEditable,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your last number";
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
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            controller: provider.emailController,
                            enabled: provider.isEditable,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            inputFormatter:
                                FilteringTextInputFormatter.singleLineFormatter,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),
                        Visibility(
                          visible: !provider.isEditable,
                          child: ElevatedButton(
                            onPressed: () {
                              provider.setIsEditable(true);
                            },
                            child: Text('Edit Profile'),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Visibility(
                          visible: provider.isEditable,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await provider.updatedData();
                                provider.setIsEditable(false);
                              }
                              // if (_userProfileImage != null) {
                              //   await provider
                              //       .uploadImageToFirebase(_userProfileImage!);
                              // }
                            },
                            child: Text('Done'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class MainScreenProvider with ChangeNotifier {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  //final TextEditingController phoneNumberController = TextEditingController();
  bool isEditable = false;

  // String? imageUrl;

  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> initializeData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await databaseRef.doc(currentUser!.uid).get();
    firstnameController.text = snapshot.data()?['first_name'] ?? '';
    lastnameController.text = snapshot.data()?['last_name'] ?? '';
    emailController.text = snapshot.data()?['email'] ?? '';
    // phoneNumberController.text = snapshot.data()?['phone_number'] ?? '';
    // imageUrl = snapshot.data()?['profile_image_url'] ?? '';
  }

  Future<void> updatedData() async {
    final CollectionReference<Map<String, dynamic>> databaseRef =
        FirebaseFirestore.instance.collection('Users');

    final User? currentUser = FirebaseAuth.instance.currentUser;

    await databaseRef.doc(currentUser!.uid).update({
      'uid': currentUser!.uid,
      'first_name': firstnameController.text,
      'last_name': lastnameController.text,
      'email': emailController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void setIsEditable(bool value) {
    isEditable = value;
    notifyListeners();
  }

}
