import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String uid;
  final bool isAnonymous;
  final bool isEmailVerified;
  MyUser({this.uid, this.isAnonymous, this.isEmailVerified});
}

class UserData {
  final String uid;
  final String name;
  final String lastName;
  final String fname;
  final String email;
  final String imgUrl;
  final String thumbImg;
  final Timestamp timeStamp;
  final Timestamp dateOfBirth;
  final bool isAnonymous;
  final bool isEmailVerified;
  UserData(
      {this.uid,
      this.name,
      this.lastName,
      this.fname,
      this.email,
      this.imgUrl,
      this.thumbImg,
      this.timeStamp,
      this.dateOfBirth,
      this.isAnonymous,
      this.isEmailVerified});
}
