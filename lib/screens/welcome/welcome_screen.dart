import 'package:autosplash/screens/welcome/welcome_content.dart';
import 'package:autosplash/services/auth.dart';
import 'package:autosplash/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:autosplash/constants.dart';
import 'package:autosplash/size_config.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/welcome";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentPage = 0;
  bool isLoading = false;

  final AuthService _auth = AuthService();

  final _controller = new PageController();
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to AutoSplash,\nLet’s Splash some Colors!",
      "image": "assets/images/undraw_Photograph_re_up3b.png"
    },
    {
      "text": "Splash wallpapers phone's \nLogin or Home Page",
      "image": "assets/images/undraw_mobile_photos_psm5.png"
    },
    {
      "text": "Ligin with your email",
      "image": "assets/images/undraw_personal_email_t7nw.png"
    },
    {
      "text": "Upload your own Wallpapers.",
      "image": "assets/images/undraw_edit_photo_2m6o.png"
    },
  ];
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: isLoading
          ? Center(
              child: Loading(
              radius: 50.0,
            ))
          : SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (value) {
                          setState(() {
                            currentPage = value;
                          });
                        },
                        itemCount: splashData.length,
                        itemBuilder: (context, index) => WelcomeContent(
                          image: splashData[index]["image"],
                          text: splashData[index]['text'],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(20)),
                        child: Column(
                          children: <Widget>[
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                splashData.length,
                                (index) => buildDot(index: index),
                              ),
                            ),
                            Spacer(flex: 3),
                            Row(
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    _controller.previousPage(
                                        duration: kAnimationDuration,
                                        curve: Curves.ease);
                                  },
                                  child: Text('Previous'),
                                ),
                                Expanded(child: SizedBox()),
                                FlatButton(
                                  onPressed: () {
                                    _controller.nextPage(
                                        duration: kAnimationDuration,
                                        curve: Curves.ease);
                                  },
                                  child: Text('Next'),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: getProportionateScreenHeight(56),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: kPrimaryColor,
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  dynamic result = await _auth.signInAnon();
                                  if (result == null) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    print('error');
                                  } else {
                                    print('signIn');
                                  }
                                },
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: getProportionateScreenWidth(18),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
