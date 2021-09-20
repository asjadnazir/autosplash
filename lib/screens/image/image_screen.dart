import 'package:autosplash/models/img.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_downloader/image_downloader.dart';

class ImageScreen extends StatefulWidget {
  List<Img> imgsList;
  ImageScreen(
    this.imgsList,
  );
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen>
    with SingleTickerProviderStateMixin {
  bool _isSystemUIOverlays;

  List<Img> _images = List();
  CollectionReference imageReference = Firestore.instance.collection('images');
  List<DocumentSnapshot> _imagesSnapshots = [];
  bool _gettingMoreImages = false;
  bool _moreImagesAvailable = true;
  // bool _loadingImages = true;
  int _perPage = 2;
  DocumentSnapshot _lastImage;
  PageController _pageController;
  int _currentPage = 0;

  // PermissionStatus _status;

  final Duration duration = const Duration(milliseconds: 500);
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<Offset> _slideCloseAnimation;
  ProgressDialog _progressDialog;

  Firestore _firestore = Firestore.instance;
  bool _clap = false;

  // void _updatePermissionStatus(PermissionStatus status) {
  //   if (status != _status) {
  //     setState(() {
  //       _status = status;
  //     });
  //   }
  // }

  // void _askPermission() async {
  //   var status = await Permission.storage.status;
  //   if (status.isUndetermined) {
  //     // We didn't ask for permission yet.
  //   }

  //   // You can can also directly ask the permission about its status.
  //   if (await Permission.location.isRestricted) {
  //     // The OS restricts access, for example because of parental controls.
  //   }

  //   if (await Permission.contacts.request().isGranted) {
  //     // Either the permission was already granted before or the user just granted it.
  //   }

  //   // You can request multiple permissions at once.
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.location,
  //     Permission.storage,
  //   ].request();
  //   print(statuses[Permission.location]);
  // }

  _clapPressed(String id) {
    print('Started @Image: Clap Pressed');
    if (_clap)
      return;
    else {
      setState(() {
        _clap = true;
      });
      incrementLike(id);
    }
  }

  void incrementLike(String id) async {
    print('Started @Image: Increment Like');
    await _firestore.runTransaction((transaction) async {
      DocumentReference postRef = _firestore.collection('images').document(id);
      DocumentSnapshot snapshot = await transaction.get(postRef);
      int likesCount = snapshot.data['likes'];
      await transaction.update(postRef, {'likes': likesCount + 1});
    }, timeout: Duration(seconds: 2));
  }

  Future _downlordWallpaper(String url, String id) async {
    print('Started @Image: Image Downloading');
    try {
      var imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }
      _progressDialog.hide();
      Flushbar(
        message: "Wallpaper is successfully downloaded",
        duration: Duration(seconds: 3),
      )..show(context);

      var fileName = await ImageDownloader.findName(imageId);
      var path = await ImageDownloader.findPath(imageId);
      var size = await ImageDownloader.findByteSize(imageId);
      var mimeType = await ImageDownloader.findMimeType(imageId);
      print(fileName.toString());
      print(path.toString());
      print(size.toString());
      print(mimeType.toString());
    } on PlatformException catch (error) {
      print('Error @Image: Image Downloading error: $error');
      _progressDialog.hide();
      Flushbar(
        message: "Something went wrong. try again",
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  Future<bool> _showDownloadDialog(String url, String id) async {
    _progressDialog.style(message: 'Downding Wallpaper...');
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Downlord Wallpaper'),
            content:
                new Text('Do you want to save wallpaper in device storage?'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: SizedBox(width: 40, height: 25, child: Text("NO")),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                  _progressDialog.show();
                  _downlordWallpaper(url, id)
                      .then((value) => _progressDialog.hide());
                },
                child: SizedBox(width: 40, height: 25, child: Text("YES")),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future _setWallpaper(String url, int location) async {
    // _progressDialog.show();
    print('Started @Image: Setting Wallpaper');
    String result;
    try {
      var file = await DefaultCacheManager().getSingleFile(url);
      result = await WallpaperManager.setWallpaperFromFile(file.path, location);
    } catch (e) {
      print(e.toString());
      _progressDialog.hide();
    }

    // _progressDialog.hide();
    if (!mounted) return;
    // print('Error @Image: Setting Wallpaper error: $result');
    return result;
  }

  Future<bool> _showSetOptions(String url) async {
    // if (false) {
    //   // permission not granted
    //   return null;
    // } else {
    _progressDialog.style(message: 'Setting Wallpaper...');
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Set Wallpaper'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                    _progressDialog.show();
                    _setWallpaper(url, WallpaperManager.HOME_SCREEN)
                        .then((value) {
                      _progressDialog.hide();
                      Flushbar(
                        message: "Wallpaper is successfully updated",
                        duration: Duration(seconds: 3),
                      )..show(context);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.home),
                      Text(
                        '   Home Screen',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                    _progressDialog.show();
                    _setWallpaper(url, WallpaperManager.LOCK_SCREEN)
                        .then((value) {
                      _progressDialog.hide();
                      Flushbar(
                        message: "Wallpaper is successfully updated",
                        duration: Duration(seconds: 3),
                      )..show(context);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.lock),
                      Text(
                        '   Lock Screen',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                    _progressDialog.show();
                    _setWallpaper(url, WallpaperManager.BOTH_SCREENS)
                        .then((value) {
                      _progressDialog.hide();
                      Flushbar(
                        message: "Wallpaper is successfully updated",
                        duration: Duration(seconds: 3),
                      )..show(context);
                    });
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.mobileAlt),
                      Text(
                        '   Both Screen',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) ??
        false;
    // }
  }

  List<Img> _imageListFromSnapshot(List<DocumentSnapshot> snapshots) {
    return snapshots.map((doc) {
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

  getImages() async {
    print('Started @Image: getImages');
    // setState(() {
    //   _loadingImages = true;
    // });

    Query q = imageReference
        .where('tags', arrayContainsAny: _images.first.tags)
        .orderBy('timeStamp')
        .limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments().catchError((error) {
      print('Error: @Image $error');
      // Do something to show user
    });

    if (querySnapshot.documents.length != -1) {
      _imagesSnapshots = querySnapshot.documents;
      if (_imagesSnapshots.isNotEmpty) {
        _lastImage =
            querySnapshot.documents[querySnapshot.documents.length - 1];
        _imagesSnapshots
            .removeWhere((image) => image.data['id'] == _images[0].id);
        if (_imagesSnapshots.isNotEmpty) {
          _images.addAll(_imageListFromSnapshot(_imagesSnapshots));
        }
      }
    }
    if (mounted) {
      setState(() {
        // _loadingImages = false;
      });
    }
  }

  getMoreImages() async {
    print('Started @Image: getMoreImages');

    if (_moreImagesAvailable == false) {
      print("No More Images");
      return;
    }

    if (_gettingMoreImages == true) {
      return;
    }

    _gettingMoreImages = true;

    Query q = imageReference
        .where('tags', arrayContainsAny: _images.first.tags)
        .orderBy('timeStamp')
        .startAfter([_lastImage.data['timeStamp']]).limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments().catchError((error) {
      print('Error: @Image: $error');
      // Do something to show user
    });
    if (querySnapshot.documents.length < _perPage) {
      _moreImagesAvailable = false;
    }

    List<DocumentSnapshot> _tempSnapshots = [];

    if (querySnapshot.documents.length != -1) {
      _tempSnapshots = querySnapshot.documents;
      if (_imagesSnapshots.isNotEmpty && _tempSnapshots.isNotEmpty) {
        _lastImage =
            querySnapshot.documents[querySnapshot.documents.length - 1];
        _tempSnapshots
            .removeWhere((image) => image.data['id'] == _images[0].id);
        if (_tempSnapshots.isNotEmpty) {
          _imagesSnapshots.addAll(_tempSnapshots);
          _images.addAll(_imageListFromSnapshot(_tempSnapshots));
        }
      }
    }

    if (mounted) {
      setState(() {});
    }

    _gettingMoreImages = false;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _isSystemUIOverlays = false;
    _images = widget.imgsList;
    print(_images[0].id.toString());
    _pageController = PageController();
    _controller = AnimationController(vsync: this, duration: duration);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -2))
        .animate(_controller);
    _slideCloseAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(1, 0))
        .animate(_controller);
    getImages();
  }

  @override
  void dispose() {
    if (_isSystemUIOverlays == false) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      _isSystemUIOverlays = true;
    }
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = ProgressDialog(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Hero(
        tag: Text('searchHeroTag'),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            InkWell(
              onTap: () {
                if (_isSystemUIOverlays == true) {
                  SystemChrome.setEnabledSystemUIOverlays([]);
                  _controller.reverse();
                  _isSystemUIOverlays = false;
                } else {
                  SystemChrome.setEnabledSystemUIOverlays(
                      SystemUiOverlay.values);
                  _controller.forward();
                  _isSystemUIOverlays = true;
                }
              },
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        CachedNetworkImageProvider(_images[index].imageUrl),
                    initialScale: PhotoViewComputedScale.contained * 1.0,
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    // heroAttributes: HeroAttributes(tag: _images[index].id),
                  );
                },
                itemCount: _images.length,
                loadingBuilder: (context, progress, index) => Center(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: _images[index].thumbImage,
                    placeholder: (context, url) => Center(
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        FontAwesomeIcons.image,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                pageController: _pageController,
                onPageChanged: (page) {
                  _currentPage = page;
                  if (page < _images.length - 1) {
                    getMoreImages();
                  }
                },
              ),
            ),
            // PageView.builder(
            //   controller: _pageController,
            //   itemCount: _images.length,
            //   onPageChanged: (page) {
            //     _currentPage = page;
            //     if (page < _images.length - 1) {
            //       getMoreImages();
            //     }
            //   },
            //   itemBuilder: (context, index) {
            //     return InkWell(
            //       onTap: () {
            //         if (_isSystemUIOverlays == true) {
            //           SystemChrome.setEnabledSystemUIOverlays([]);
            //           _controller.reverse();
            //           _isSystemUIOverlays = false;
            //         } else {
            //           SystemChrome.setEnabledSystemUIOverlays(
            //               SystemUiOverlay.values);
            //           _controller.forward();
            //           _isSystemUIOverlays = true;
            //         }
            //       },
            //       child: Container(
            //         height: MediaQuery.of(context).size.height,
            //         width: MediaQuery.of(context).size.width,
            //         child: kIsWeb
            //             ? Image.network(
            //                 _images[index].imageUrl,
            //                 height: 50,
            //                 width: 100,
            //                 fit: BoxFit.cover,
            //               )
            //             : PhotoView(
            //                 imageProvider: CachedNetworkImageProvider(
            //                     _images[index].imageUrl),
            //                 minScale: PhotoViewComputedScale.contained * 0.8,
            //                 maxScale: PhotoViewComputedScale.covered * 2,
            //                 loadingBuilder: (context, event) => Center(
            //                   child: CachedNetworkImage(
            //                     fit: BoxFit.cover,
            //                     imageUrl: _images[index].thumbImage,
            //                     placeholder: (context, url) =>
            //                         CircularProgressIndicator(),
            //                     errorWidget: (context, url, error) => Center(
            //                       child: Icon(
            //                         FontAwesomeIcons.image,
            //                         size: 40,
            //                         color: Colors.white,
            //                       ),
            //                     ),
            //                   ),
            //                   // CircularProgressIndicator(
            //                   //   value: event == null
            //                   //       ? 0
            //                   //       : event.cumulativeBytesLoaded /
            //                   //           event.expectedTotalBytes,
            //                   // ),
            //                 ),
            //               ),
            //         //     CachedNetworkImage(
            //         //   fit: BoxFit.cover,
            //         //   imageUrl: _images[index].imageUrl,
            //         //   // placeholder: (context, url) =>
            //         //   // CachedNetworkImage(
            //         //   //   fit: BoxFit.cover,
            //         //   //   imageUrl: _images[index].thumbImage,
            //         //   //   placeholder: (context, url) =>
            //         //   //       Center(child: CircularProgressIndicator()),
            //         //   //   errorWidget: (context, url, error) => Center(
            //         //   //     child: Icon(
            //         //   //       FontAwesomeIcons.image,
            //         //   //       size: 40,
            //         //   //     ),
            //         //   //   ),
            //         //   // ),
            //         //   // Image.network(_images[index].thumbImage),
            //         //   errorWidget: (context, url, error) => Center(
            //         //     child: Icon(
            //         //       FontAwesomeIcons.image,
            //         //       size: 40,
            //         //     ),
            //         //   ),
            //         // ),
            //       ),
            //     );
            //   },
            // ),
            Stack(children: <Widget>[
              _bottomControllers(),
              _cancelButton(),
            ]),
          ],
        ),
      ),
    );
  }

  Container _cancelButton() {
    return Container(
      child: Positioned(
        left: -100,
        // width: MediaQuery.of(context).size.width,
        child: SlideTransition(
          position: _slideCloseAnimation,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xfff5f8fd).withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Icon(
                FontAwesomeIcons.times,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _bottomControllers() {
    return Container(
      child: Positioned(
        bottom: -80,
        width: MediaQuery.of(context).size.width,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xfff5f8fd).withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () => _clapPressed(_images[_currentPage].id),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.thumbsUp,
                        color: _clap ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 3,
                  color: Colors.black,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        _showSetOptions(_images[_currentPage].imageUrl),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.image,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 3,
                  color: Colors.black,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _showDownloadDialog(
                        _images[_currentPage].imageUrl,
                        _images[_currentPage].id),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.download,
                      ),
                    ),
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
