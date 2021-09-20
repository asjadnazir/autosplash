import 'package:autosplash/constants.dart';
import 'package:autosplash/models/user.dart';
import 'package:autosplash/router.dart';
import 'package:autosplash/services/auth.dart';
import 'package:autosplash/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Prevent device orientation changes and force portrait.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StreamProvider<MyUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Flutter Demo',
        //Hide debug watermark from secreen.
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
          accentColor: kPrimaryColor,
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.

          // primarySwatch: Colors.blue,

          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // darkTheme: ThemeData(
        //   brightness: Brightness.dark,
        // ),
        // builder: (context, child) {
        //   return ScrollConfiguration(
        //     behavior: ScrollBehavior(),
        //     child: child,
        //   );
        // },
        // themeMode: ThemeMode.dark,
        // home: Wrapper(),
        initialRoute: Wrapper.routName,
        routes: routes,
      ),
    );
  }
}
