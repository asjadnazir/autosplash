import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:autosplash/models/img.dart';
import 'package:autosplash/shared/widget.dart';
import 'package:autosplash/services/database.dart';
import 'package:autosplash/shared/loading.dart';

import '../../size_config.dart';

class SearchScreen extends StatefulWidget {
  final String search;
  SearchScreen({@required this.search});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Img> images = List();
  List<String> _searchArray = List();

  TextEditingController searchController = new TextEditingController();
  CollectionReference imageReference = Firestore.instance.collection('images');
  List<DocumentSnapshot> _imagesSnapshots = [];
  bool _gettingMoreImages = false;
  bool _moreImagesAvailable = true;
  bool _isSearching = false;
  bool _loadingImages = true;
  int _perPage = 8;
  DocumentSnapshot _lastImage;
  DatabaseService database;
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

  getSearchImages() {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      _searchArray = searchController.text.toLowerCase().split(' ');
      if (_searchArray.isEmpty) {
        setState(() {
          _isSearching = false;
        });
      } else {
        getImages();
        if (_moreImagesAvailable == false) {
          _moreImagesAvailable = true;
        }
      }
    } else {
      setState(() {
        _isSearching = false;
      });
    }
  }

  getImages() async {
    print('getImages called');
    setState(() {
      _loadingImages = true;
    });

    Query q = imageReference
        .where('tags', arrayContainsAny: _searchArray)
        //  .where('name', isEqualTo: 'name')
        .orderBy('timeStamp')
        .limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments();
    if (!mounted) return;
    // List<Img> imgs = _imageListFromSnapshot(querySnapshot);
    // List<Img> imgs = q.snapshots().map(database.imageListFromSnapshot);

    if (querySnapshot.documents.length == -1)
      _imagesSnapshots = _imagesSnapshots;
    else {
      _imagesSnapshots = querySnapshot.documents;
      if (_imagesSnapshots.isNotEmpty)
        _lastImage =
            querySnapshot.documents[querySnapshot.documents.length - 1];
    }
    setState(() {
      _loadingImages = false;
    });
  }

  getMoreImages() async {
    print('getMoreImages called');

    if (_moreImagesAvailable == false) {
      print("No More Images");
      return;
    }

    if (_gettingMoreImages == true) {
      return;
    }

    _gettingMoreImages = true;

    Query q = imageReference
        .where('tags', arrayContainsAny: _searchArray)
        .orderBy('timeStamp')
        .startAfter([_lastImage.data['timeStamp']]).limit(_perPage);
    QuerySnapshot querySnapshot = await q.getDocuments();
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

    setState(() {});

    _gettingMoreImages = false;
  }

  @override
  void initState() {
    super.initState();

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

    if (widget.search.trim().length != 0) {
      searchController.text = widget.search;
      getSearchImages();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close Keyboard
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: new IconButton(
            splashColor: Colors.transparent,
            icon: new Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(34, 8, 30, 8),
            ),
          ],
          title: brandName(),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xfff5f8fd),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            getSearchImages();
                          },
                          controller: searchController,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                              hintText: "Search", border: InputBorder.none),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // Close Keyboard
                          FocusScope.of(context).unfocus();
                          getSearchImages();
                        },
                        child: Container(
                          child: Icon(Icons.search),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                _isSearching == false
                    ? Container(
                        height: 400,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Icon(
                                  Icons.wallpaper,
                                  size: 70,
                                  color: Colors.black26,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Search wallpapers with Keywords',
                                style: TextStyle(color: Colors.black38),
                              ),
                            ),
                          ],
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
                                    height: 400,
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Icon(
                                                Icons.wallpaper,
                                                size: 70,
                                                color: Colors.black26,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'No Images to show',
                                              style: TextStyle(
                                                  color: Colors.black38),
                                            ),
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
      ),
    );
  }
}
