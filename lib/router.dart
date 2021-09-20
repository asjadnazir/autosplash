import 'package:autosplash/screens/auth/auth_screen.dart';
import 'package:autosplash/screens/home/home_screen.dart';
import 'package:autosplash/screens/upload/upload_screen.dart';
import 'package:autosplash/screens/welcome/welcome_screen.dart';
import 'package:autosplash/screens/wrapper.dart';
import 'package:flutter/widgets.dart';

final Map<String, WidgetBuilder> routes = {
  Wrapper.routName: (context) => Wrapper(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  AuthScreen.routeName: (context) => AuthScreen(),
  UploadWrapper.routeName: (context) => UploadWrapper(),
  UploadScreen.routeName: (context) => UploadScreen(),
};
