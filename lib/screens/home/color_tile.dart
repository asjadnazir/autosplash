import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ColorTile extends StatelessWidget {
  final String imgUrl, name;
  ColorTile({@required this.imgUrl, @required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 6),
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: Container(
            color: Colors.grey[300],
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: imgUrl,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) =>
                        Container(color: Colors.grey[300]),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    name.toUpperCase() ?? "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Overpass'),
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
