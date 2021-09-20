import 'package:cloud_firestore/cloud_firestore.dart';

class Img {
  final String id;
  final String uid;
  final String title;
  final String desc;
  final List<dynamic> tags;
  final String imageUrl;
  final String thumbImage;
  final Timestamp timeStamp;
  final String uploadUser;
  final int downloads;
  final int likes;
  Img(
      this.id,
      this.uid,
      this.title,
      this.desc,
      this.tags,
      this.imageUrl,
      this.thumbImage,
      this.timeStamp,
      this.uploadUser,
      this.downloads,
      this.likes);

  factory Img.fromMap(Map<String, dynamic> parsedJson) {
    return Img(
        parsedJson["id"],
        parsedJson["uid"],
        parsedJson["title"],
        parsedJson["desc"],
        parsedJson["tags"],
        parsedJson["imageUrl"],
        parsedJson["thumbImage"],
        parsedJson["timeStamp"],
        parsedJson["uploadUser"],
        parsedJson["downloads"],
        parsedJson["likes"]);
  }
}
