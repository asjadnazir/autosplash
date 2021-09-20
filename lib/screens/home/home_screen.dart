import 'package:autosplash/constants.dart';
import 'package:autosplash/models/category_tag.dart';
import 'package:autosplash/models/color_tag.dart';
import 'package:autosplash/models/user.dart';
import 'package:autosplash/screens/auth/auth_screen.dart';
import 'package:autosplash/screens/home/categories_tab.dart';
import 'package:autosplash/screens/home/home_tab.dart';
import 'package:autosplash/screens/search/search_screen.dart';
import 'package:autosplash/screens/upload/upload_screen.dart';
import 'package:autosplash/services/auth.dart';
import 'package:autosplash/services/database.dart';
import 'package:autosplash/shared/widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:flutter/gestures.dart';

class HomePageController {
  void Function() refresh;
}

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isCollpassed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;
  BorderRadiusGeometry _borderRadiusAnimation;
  final AuthService _auth = AuthService();
  TabController _tabController;

  ////////////////////to make tabview scroll after colors
  // ScrollController _listScrollController = new ScrollController();
  // ScrollController _activeScrollController;
  // Drag _drag;
  // PageController _pageController;

  final DatabaseService _database = new DatabaseService();
  List<CategoryTag> categories = List();
  List<ColorTag> colors = List();

  final HomePageController refreshController = HomePageController();

  Future<bool> _onBackPressed() {
    if (!isCollpassed) {
      animate();
      return null;
    } else if (_tabController.index == 1) {
      _tabController.animateTo(0);
      return null;
    } else
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit an App'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: SizedBox(width: 40, height: 25, child: Text("NO")),
                ),
                SizedBox(height: 16),
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: SizedBox(width: 40, height: 25, child: Text("YES")),
                ),
              ],
            ),
          ) ??
          false;
  }

  getCategories() async {
    print('Started @Home: getCategories');
    categories = await _database.getCategories;
    if (mounted) {
      setState(() {});
    }
  }

  getColors() async {
    print('Started @Home: getColors');
    colors = await _database.getColors;
    if (mounted) {
      setState(() {});
    }
  }

  animate() {
    print('Started @Home: Animate');
    if (mounted) {
      setState(() {
        if (isCollpassed) {
          _controller.forward();
          _borderRadiusAnimation = BorderRadius.circular(25);
        } else {
          _controller.reverse();
          _borderRadiusAnimation = BorderRadius.circular(0);
        }
        isCollpassed = !isCollpassed;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.7).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _borderRadiusAnimation = BorderRadius.circular(0);
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );

    getCategories();
    getColors();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    Size _screenSize = MediaQuery.of(context).size;
    screenHeight = _screenSize.height;
    screenWidth = _screenSize.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Stack(
          children: <Widget>[
            slideMenu(context, user),
            homeSecreen(context, user),
          ],
        ),
      ),
    );
  }

  Widget homeSecreen(context, MyUser user) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollpassed ? 0 : 0.6 * screenWidth,
      right: isCollpassed ? 0 : -0.6 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedClipRRect(
          duration: duration,
          borderRadius: _borderRadiusAnimation,
          child: Material(
            animationDuration: duration,
            borderRadius: _borderRadiusAnimation,
            elevation: 12,
            child: SafeArea(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowGlow();
                  return true;
                },
                child: DefaultTabController(
                  length: 2,
                  child: GestureDetector(
                    // onHorizontalDragStart: (DragStartDetails dragStartDetails) {
                    //   animate();
                    // },
                    onTap: () {
                      animate();
                    },
                    child: AbsorbPointer(
                      absorbing: !isCollpassed,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => {
                          // Close Keyboard
                          FocusScope.of(context).unfocus()
                        },
                        child: Scaffold(
                          appBar: AppBar(
                            backgroundColor: Colors.white,
                            elevation: 0.0,
                            leading: InkWell(
                              splashColor: Colors.transparent,
                              child: Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Icon(
                                        FontAwesomeIcons.minus,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Icon(
                                        FontAwesomeIcons.minus,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                // Close Keyboard
                                FocusScope.of(context).unfocus();
                                animate();
                              },
                            ),
                            actions: <Widget>[
                              InkWell(
                                splashColor: Colors.transparent,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                                  child: Icon(
                                    // FontAwesomeIcons.plusCircle,
                                    Icons.add_circle_outline,
                                    color: kPrimaryColor,
                                    size: 27,
                                  ),
                                ),
                                onTap: () {
                                  // Close Keyboard
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    if (user.isAnonymous) {
                                      Navigator.pushNamed(
                                          context, AuthScreen.routeName,
                                          arguments: UploadScreen.routeName);
                                    } else {
                                      Navigator.pushNamed(
                                          context, UploadScreen.routeName);
                                    }
                                  });
                                },
                              ),
                            ],
                            title: brandName(),
                          ),
                          bottomNavigationBar: Material(
                            elevation: 12.0,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: new TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.transparent,
                              unselectedLabelColor: Colors.grey,
                              labelColor: kPrimaryColor,
                              tabs: <Widget>[
                                new Tab(
                                  icon: new Icon(FontAwesomeIcons.home),
                                ),
                                new Tab(
                                  icon: new Icon(FontAwesomeIcons.solidImages),
                                )
                              ],
                            ),
                          ),
                          body: NotificationListener(
                            onNotification: (scrollNotification) {
                              if (scrollNotification
                                  is ScrollUpdateNotification) {
                                // Close Keyboard
                                FocusScope.of(context).unfocus();
                              }
                              return true;
                            },
                            // child: RawGestureDetector(
                            //   gestures: <Type, GestureRecognizerFactory>{
                            //     HorizontalDragGestureRecognizer:
                            //         GestureRecognizerFactoryWithHandlers<
                            //                 HorizontalDragGestureRecognizer>(
                            //             () => HorizontalDragGestureRecognizer(),
                            //             (HorizontalDragGestureRecognizer
                            //                 instance) {
                            //       instance
                            //         ..onStart = _handleDragStart
                            //         ..onUpdate = _handleDragUpdate
                            //         ..onEnd = _handleDragEnd
                            //         ..onCancel = _handleDragCancel;
                            //     })
                            //   },
                            //   behavior: HitTestBehavior.opaque,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                HomeTab(refreshController),
                                CategoriesTab(colors, categories),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget slideMenu(context, MyUser user) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20),
                  width: 130,
                  height: 130,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: Container(
                        child: Stack(
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 1,
                              // child: CachedNetworkImage(
                              //   fit: BoxFit.cover,
                              //   imageUrl: null,
                              //   placeholder: (context, url) =>
                              //       Container(color: Colors.grey[300]),
                              //   errorWidget: (context, url, error) =>
                              //       Container(color: Colors.grey[300]),
                              // ),
                              child: Image.asset(
                                'assets/images/profile_avatar.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FlatButton(
                  onPressed: () {
                    animate();
                    if (_tabController.index == 1)
                      _tabController.animateTo(0);
                    else
                      refreshController.refresh();
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.home),
                      Text(
                        '   Home',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    animate();
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.cog),
                      Text(
                        '   Settings',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    animate();
                    _tabController.animateTo(1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          search: '',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.searchPlus),
                      Text(
                        '   Search',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    animate();
                    setState(() {
                      if (user.isAnonymous) {
                        Navigator.pushNamed(context, AuthScreen.routeName,
                            arguments: UploadScreen.routeName);
                      } else {
                        Navigator.pushNamed(context, UploadScreen.routeName);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.upload),
                      Text(
                        '   Upload',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                user.isAnonymous
                    ? FlatButton(
                        onPressed: () {
                          animate();
                          Navigator.pushNamed(context, AuthScreen.routeName,
                              arguments: HomeScreen.routeName);
                        },
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.signInAlt),
                            Text(
                              '   LogIn',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : FlatButton(
                        onPressed: () {
                          _auth.signOut();
                        },
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.signOutAlt),
                            Text(
                              '   Log out',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
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

// void _handleDragStart(DragStartDetails details) {
//   if (_listScrollController.hasClients &&
//       _listScrollController.position.context.storageContext != null) {
//     final RenderBox renderBox = _listScrollController
//         .position.context.storageContext
//         .findRenderObject();
//     if (renderBox.paintBounds
//         .shift(renderBox.localToGlobal(Offset.zero))
//         .contains(details.globalPosition)) {
//       _activeScrollController = _listScrollController;
//       _drag = _activeScrollController.position.drag(details, _disposeDrag);
//       return;
//     }
//   }
//   _activeScrollController = _pageController;
//   _drag = _tabController.position.drag(details, _disposeDrag);
// }

// void _handleDragUpdate(DragUpdateDetails details) {
//   if (_activeScrollController == _listScrollController &&
//       details.primaryDelta > 0 &&
//       _activeScrollController.position.pixels ==
//           _activeScrollController.position.minScrollExtent) {
//     _activeScrollController = _pageController;
//     _drag?.cancel();
//     _drag = _pageController.position.drag(
//         DragStartDetails(
//             globalPosition: details.globalPosition,
//             localPosition: details.localPosition),
//         _disposeDrag);
//   }
//   _drag?.update(details);
// }

// void _handleDragEnd(DragEndDetails details) {
//   _drag?.end(details);
// }

// void _handleDragCancel() {
//   _drag?.cancel();
// }

// void _disposeDrag() {
//   _drag = null;
// }
