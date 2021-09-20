import 'package:autosplash/models/category_tag.dart';
import 'package:autosplash/models/color_tag.dart';
import 'package:autosplash/models/img.dart';
import 'package:autosplash/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  final bool isAnonymous;
  DatabaseService({this.uid, this.isAnonymous});

  // collection reference
  final CollectionReference userReference =
      Firestore.instance.collection('users');

  final CollectionReference imageReference =
      Firestore.instance.collection('images');

  final CollectionReference categoryReference =
      Firestore.instance.collection('categories');

  final CollectionReference colorReference =
      Firestore.instance.collection('colors');

  Future updateUserData(
    String uid,
    String name,
    String lastName,
    String fname,
    String email,
    String imgUrl,
    String thumbImg,
    Timestamp timeStamp,
    Timestamp dateOfBirth,
    bool isAnonymous,
    bool isEmailVerified,
  ) async {
    return await userReference.document(uid).setData({
      'uid': uid,
      'name': name,
      'lastName': lastName,
      'fname': fname,
      'email': email,
      'imgUrl': imgUrl,
      'thumbImg': thumbImg,
      'timeStamp': timeStamp,
      'dateOfBirth': dateOfBirth,
      'isAnonymous': isAnonymous,
      'isEmailVerified': isEmailVerified,
    });
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: snapshot.data['uid'],
      name: snapshot.data['name'],
      lastName: snapshot.data['lastName'],
      fname: snapshot.data['fname'],
      imgUrl: snapshot.data['imgUrl'],
      thumbImg: snapshot.data['thumbImg'],
      timeStamp: snapshot.data['timeStamp'],
      dateOfBirth: snapshot.data['dateOfBirth'],
      isAnonymous: snapshot.data['isAnonymous'],
      isEmailVerified: snapshot.data['isEmailVerified'],
    );
  }

  Stream<UserData> get userData {
    return userReference.document(uid).snapshots().map(_userDataFromSnapshot);
  }

  List<ColorTag> _colorsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return ColorTag(doc.data['id'] ?? '', doc.data['name'] ?? '',
          doc.data['imgUrl'] ?? '', doc.data['order'] ?? 0);
    }).toList();
  }

  Future<List<ColorTag>> get getColors async {
    QuerySnapshot q = await colorReference.orderBy("order").getDocuments();
    return _colorsFromSnapshot(q);
  }

  List<CategoryTag> _categoriesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return CategoryTag(
          doc.data['id'] ?? '',
          doc.data['name'] ?? '',
          doc.data['imgUrl'] ?? '',
          doc.data['views'] ?? 0,
          doc.data['order'] ?? 0);
    }).toList();
  }

  Future<List<CategoryTag>> get getCategories async {
    QuerySnapshot q = await categoryReference.orderBy("order").getDocuments();
    return _categoriesFromSnapshot(q);
  }

  Future uploadImg(
    final String id,
    final String uid,
    final String title,
    final String desc,
    final List<dynamic> tags,
    final String imageUrl,
    final String thumbImage,
    final Timestamp timeStamp,
    final String uploadUser,
    final int downloads,
    final int likes,
  ) async {
    var genId = imageReference.document();
    return await imageReference.document(genId.documentID).setData({
      'id': genId.documentID,
      'uid': uid,
      'title': title,
      'desc': desc,
      'tags': tags,
      'imageUrl': imageUrl,
      'thumbImage': thumbImage,
      'timeStamp': Timestamp.now(),
      'uploadUser': uploadUser,
      'downloads': downloads,
      'likes': likes,
    });
  }

  List<Img> imageListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Img(
          doc.data['id'] ?? '',
          doc.data['uid'] ?? '',
          doc.data['title'] ?? '',
          doc.data['desc'] ?? '',
          doc.data['tags'] ?? '',
          doc.data['imageUrl'] ?? '',
          doc.data['thumbImage'] ?? '',
          doc.data['timeStamp'] ?? null,
          doc.data['uploadUser'] ?? '',
          doc.data['downloads'] ?? 0,
          doc.data['likes'] ?? 0);
    }).toList();
  }

  Stream<List<Img>> get image {
    Query q = imageReference.orderBy('timeStamp').limit(2);
    return q.snapshots().map(imageListFromSnapshot);
  }
}
