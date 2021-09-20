import 'package:autosplash/services/auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../size_config.dart';

class ContinueButton extends StatelessWidget {
  const ContinueButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);
  final String text;
  final Function press;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: kPrimaryColor,
        onPressed: () async {
          dynamic result = await _auth.signInAnon();
          if (result == null) {
            print('Error @Welcome $result');
            Flushbar(
              message: "Network Error",
              duration: Duration(seconds: 3),
            )..show(context);
          } else {
            print(result.uid);
          }
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
