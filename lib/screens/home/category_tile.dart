import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryTile extends StatelessWidget {
  final String imgUrl, name;
  CategoryTile({@required this.imgUrl, @required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.75,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: Colors.grey[300]),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imgUrl,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              name ?? "",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Overpass'),
            ),
          ),
        ],
      ),
    );
  }
}
