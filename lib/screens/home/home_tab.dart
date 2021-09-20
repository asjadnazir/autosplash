import 'package:autosplash/screens/home/home_screen.dart';
import 'package:autosplash/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autosplash/models/img.dart';
import 'package:autosplash/shared/widget.dart';
import 'package:autosplash/shared/loading.dart';

class HomeTab extends StatefulWidget {
  final HomePageController refreshController;
  HomeTab(this.refreshController);
  @override
  _HomeTabState createState() => _HomeTabState(refreshController);
}

class _HomeTabState extends State<HomeTab> {
  _HomeTabState(HomePageController refreshController) {
    refreshController.refresh = getImages;
  }

  List<Img> images = List();
  TextEditingController searchController = new TextEditingController();
  CollectionReference imageReference = Firestore.instance.collection('images');
  List<DocumentSnapshot> _imagesSnapshots = [];
  bool _gettingMoreImages = false;
  bool _moreImagesAvailable = true;
  bool _isRetrieving = true;
  bool _loadingImages = true;
  int _perPage = 8;
  DocumentSnapshot _lastImage;
  ScrollController _scrollController = ScrollController();

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
    print('Started @Home: getImages');
    setState(() {
      _loadingImages = true;
    });

    Query q = imageReference
        .where('id', isGreaterThan: imageReference.document().documentID)
        .orderBy('id')
        .limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments()
        // .then((value) async {
        //   if (value.documents?.length == -1) {
        //     q = imageReference
        //         .where('id', isGreaterThanOrEqualTo: imageReference.document())
        //         .orderBy('id')
        //         .limit(_perPage);
        //     QuerySnapshot querySnapshot =
        //         await q.getDocuments().catchError((error) {
        //       print('Error: $error');
        //       // Do something to show user
        //     });
        //     return querySnapshot;
        //   }
        // })
        .catchError((error) {
      print('Error: @Home: $error');
      // Do something to show user
    });
    if (!mounted) return;
    // q = imageReference
    //     .where('id', isGreaterThanOrEqualTo: imageReference.document())
    //     .orderBy('id', descending: false)
    //     .limit(_perPage);
    // QuerySnapshot descQuerySnapshot =
    //     await q.getDocuments().catchError((error) {
    //   print('Error: $error');
    //   // Do something to show user
    // });

    // List<Img> imgs = _database.imageListFromSnapshot(querySnapshot);
    // print(imgs.toString());
    // List<Img> imgs = q.snapshots().map(database.imageListFromSnapshot);

    if (querySnapshot.documents.length != -1) {
      _imagesSnapshots = querySnapshot.documents;
      if (_imagesSnapshots.isNotEmpty)
        _lastImage =
            querySnapshot.documents[querySnapshot.documents.length - 1];
    }
    // if (descQuerySnapshot.documents.length == -1) {
    //   _imagesSnapshorts.addAll(descQuerySnapshot.documents);
    // }
    if (mounted) {
      setState(() {
        _loadingImages = false;
      });
    }
  }

  getMoreImages() async {
    print('Started @Home: getMoreImages');

    if (_moreImagesAvailable == false) {
      print("Completed @Home: No More Images");
      return;
    }

    if (_gettingMoreImages == true) {
      return;
    }

    _gettingMoreImages = true;

    Query q = imageReference
        .where('id', isGreaterThan: imageReference.document().documentID)
        .orderBy('id')
        .startAfter([_lastImage.data['id']]).limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments().catchError((error) {
      print('Error @Home:  $error');
      // Do something to show user
    });
    if (!mounted) return;
    if (querySnapshot.documents.length < _perPage) {
      _moreImagesAvailable = false;
    }

    List<DocumentSnapshot> _tempSnapshots = [];

    if (querySnapshot.documents.length != -1) {
      _tempSnapshots = querySnapshot.documents;
      if (_imagesSnapshots.isNotEmpty && _tempSnapshots.isNotEmpty) {
        _lastImage =
            querySnapshot.documents[querySnapshot.documents.length - 1];
        _imagesSnapshots.addAll(_tempSnapshots);
      }
    }

    if (mounted) {
      setState(() {});
    }

    _gettingMoreImages = false;
  }

  Future<Null> refreshGrid() async {
    await Future.delayed(Duration(seconds: 2));
    getImages();
  }

  @override
  void initState() {
    super.initState();
    if (images?.length == 0) getImages();
    _scrollController.addListener(() {
      // Close Keyboard
      FocusScope.of(context).unfocus();
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll < delta && _moreImagesAvailable == true) {
        getMoreImages();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshGrid,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              _isRetrieving == false
                  ? Container(
                      height: 400,
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.wallpaper,
                              size: 70,
                              color: Colors.black26,
                            ),
                            Text(
                              'Ideas you might love',
                              style: TextStyle(color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _loadingImages == true
                      ? Container(
                          height: SizeConfig.screenWidth,
                          child: Center(
                            child: Loading(),
                          ),
                        )
                      : Container(
                          child: _imagesSnapshots.length == -1 ||
                                  _imagesSnapshots.isEmpty
                              ? Container(
                                  height: SizeConfig.screenWidth,
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.wallpaper,
                                          size: 70,
                                          color: Colors.black26,
                                        ),
                                        Text(
                                          'No Images to show',
                                          style:
                                              TextStyle(color: Colors.black38),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : wallPaper(
                                  _imageListFromSnapshot(_imagesSnapshots),
                                  context,
                                ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
