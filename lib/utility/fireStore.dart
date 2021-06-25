import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class GetUserName extends StatelessWidget {
  final String documentId;

  GetUserName(this.documentId);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
         // return Text("Something went wrong");
          print('Something went wrong');
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          //return Text("Document does not exist");
          print('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
         // return Text("Full Name: ${data['uid']} ${data['email']}");
          print('Something went wrong');
        }

        return Text("loading");
        print('loading');
      },
    );
  }
}