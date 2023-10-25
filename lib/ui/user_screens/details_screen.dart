import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({Key? key}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Details Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View User Details',
              style: TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(currentUser!.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return ListView(
                    children: [
                      buildListTile('First Name', data['first_name']),
                      buildListTile('Last Name', data['last_name']),
                      buildListTile('Email', data['email']),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildListTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w200),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
