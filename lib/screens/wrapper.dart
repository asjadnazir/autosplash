import 'package:autosplash/models/user.dart';
import 'package:autosplash/screens/auth/auth_screen.dart';
import 'package:autosplash/screens/home/home_screen.dart';
import 'package:autosplash/screens/upload/upload_screen.dart';
import 'package:autosplash/screens/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  static String routName = '/wrapper';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    if (user == null) {
      return WelcomeScreen();
    } else {
      return HomeScreen();
    }
  }
}

class UploadWrapper extends StatelessWidget {
  static String routeName = '/UploadWrapper';
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    if (user.isAnonymous) {
      return AuthScreen();
    } else {
      return UploadScreen();
    }
  }
}
