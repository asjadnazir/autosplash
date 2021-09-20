import 'package:autosplash/screens/auth/sign_in_up_bar.dart';
import 'package:autosplash/screens/auth/title.dart';
import 'package:autosplash/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../constants.dart';
import 'decoration_functions.dart';

class SignIn extends StatefulWidget {
  bool isSubmitting;
  final String nextRoute;
  SignIn(
      {Key key,
      @required this.onRegisterClicked,
      this.isSubmitting,
      this.nextRoute})
      : super(key: key);

  final VoidCallback onRegisterClicked;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  String _email, _password;
  String error = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final focus = FocusNode();

  onSubmit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        widget.isSubmitting = true;
      });
      dynamic result =
          await _auth.signInWithEmailAndPassword(_email, _password);
      if (result == null) {
        print('Completed @LoginAccount: Successfully login into your account');
        // Flushbar(
        //   title: "Hey Ninja",
        //   message:
        //       "Successfully login into your account",
        //   duration: Duration(seconds: 3),
        // )..show(context);
        Navigator.pushReplacementNamed(context, widget.nextRoute);
      } else {
        print('Error @LoginAccount: $result');
        if (mounted)
          setState(() {
            widget.isSubmitting = false;
            error = result;
          });
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  keyboardPress(String text) async {
    await onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    // final isSubmitting = context.isSubmitting();
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.topLeft,
                child: LoginTitle(
                  title: 'Welcome\nBack',
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                body: widget.isSubmitting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (v) {
                                FocusScope.of(context).requestFocus(focus);
                              },
                              onChanged: (input) => _email = input.trim(),
                              decoration: signInInputDecoration(
                                  hintText: 'Email', icon: Icons.email),
                              validator: MultiValidator(
                                [
                                  RequiredValidator(errorText: 'Required *'),
                                  EmailValidator(
                                      errorText: 'Not a valid Email'),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: TextFormField(
                              focusNode: focus,
                              onFieldSubmitted: keyboardPress,
                              onChanged: (input) => _password = input.trim(),
                              obscureText: true,
                              decoration: signInInputDecoration(
                                  hintText: 'Password', icon: Icons.vpn_key),
                              validator: MultiValidator(
                                [
                                  RequiredValidator(errorText: 'Required *'),
                                  MinLengthValidator(6,
                                      errorText:
                                          'Should be at least six characters'),
                                  MaxLengthValidator(15,
                                      errorText:
                                          'Should not be greater than fifteen characters'),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            error,
                            style: TextStyle(color: Palette.darkBlue),
                          ),
                          SignInBar(
                            label: 'Sign in',
                            isLoading: widget.isSubmitting,
                            onPressed: onSubmit,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Don\'t have an account? '),
                              InkWell(
                                splashColor: Colors.black12,
                                onTap: () {
                                  widget.onRegisterClicked?.call();
                                },
                                child: const Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
