import 'package:autosplash/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:autosplash/models/img.dart';

import '../screens/image/image_screen.dart';

List<Img> _getImgFromIndex(Img img) {
  List<Img> i = [];
  i.add(img);
  return i;
}

Widget wallPaper(
  List<Img> imgsList,
  BuildContext context,
) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        mainAxisSpacing: 6.0,
        crossAxisSpacing: 6.0,
      ),
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(4.0),
      itemCount: imgsList.length,
      itemBuilder: (context, index) {
        return GridTile(
          child: GestureDetector(
            onTap: () {
              // Close Keyboard
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageScreen(
                    _getImgFromIndex(imgsList[index]),
                  ),
                ),
              );
            },
            child: Hero(
              tag: Text('searchHeroTag'),
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: kIsWeb
                      ? Image.network(
                          imgsList[index].thumbImage,
                          height: 50,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: imgsList[index].thumbImage?.length == 0
                              ? imgsList[index].imageUrl
                              : imgsList[index].thumbImage,
                          placeholder: (context, url) => Container(
                            color: Color(0xfff5f8fd),
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget brandName() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        "Auto",
        style: TextStyle(color: Colors.black87, fontFamily: 'Overpass'),
      ),
      Text(
        "Splash",
        style: TextStyle(color: kPrimaryColor, fontFamily: 'Overpass'),
      )
    ],
  );
}

// Custom class AnimatedClipRRect for homeScreen menu animations
class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    @required this.duration,
    this.curve = Curves.linear,
    @required this.borderRadius,
    @required this.child,
  })  : assert(duration != null),
        assert(curve != null),
        assert(borderRadius != null),
        assert(child != null);

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: BorderRadiusTween(begin: BorderRadius.zero, end: borderRadius),
      builder: _builder,
      child: child,
    );
  }
}
