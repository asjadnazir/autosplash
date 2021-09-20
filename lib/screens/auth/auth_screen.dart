import 'package:animations/animations.dart';
import 'package:autosplash/screens/auth/background_painter.dart';
import 'package:autosplash/screens/auth/register.dart';
import 'package:autosplash/screens/auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthScreen extends StatefulWidget {
  static String routeName = "/auth";
  const AuthScreen({Key key}) : super(key: key);

  static MaterialPageRoute get route => MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      );

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  bool isSubmitting = false;

  ValueNotifier<bool> showSignInPage = ValueNotifier<bool>(true);

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    @required
    final String nextRoute = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: BackgroundPainter(
                animation: _controller,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ValueListenableBuilder<bool>(
                valueListenable: showSignInPage,
                builder: (context, value, child) {
                  return SizedBox.expand(
                    child: PageTransitionSwitcher(
                      reverse: !value,
                      duration: const Duration(milliseconds: 800),
                      transitionBuilder:
                          (child, animation, secondaryAnimation) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      child: value
                          ? SignIn(
                              key: const ValueKey('SignIn'),
                              onRegisterClicked: () {
                                // context.resetSignInForm();
                                showSignInPage.value = false;
                                _controller.forward(from: 0.0);
                              },
                              isSubmitting: isSubmitting,
                              nextRoute: nextRoute,
                            )
                          : Register(
                              key: const ValueKey('Register'),
                              onSignInPressed: () {
                                // context.resetSignInForm();
                                showSignInPage.value = true;
                                _controller.reverse(from: 1.0);
                              },
                              isSubmitting: isSubmitting,
                              nextRoute: nextRoute,
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
