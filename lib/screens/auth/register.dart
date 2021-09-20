import 'package:autosplash/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'decoration_functions.dart';
import 'sign_in_up_bar.dart';
import 'title.dart';

class Register extends StatefulWidget {
  bool isSubmitting;
  final String nextRoute;
  Register({Key key, this.onSignInPressed, this.isSubmitting, this.nextRoute})
      : super(key: key);

  final VoidCallback onSignInPressed;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();

  String _email, _password, _name = '';
  String error = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final focus = FocusNode();

  onSubmit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        widget.isSubmitting = true;
      });
      dynamic result =
          await _auth.registerWithEmailAndPassword(_email, _password, _name);
      if (result == null) {
        print('Completed @createAccount: Successfully created your account');
        Navigator.pushReplacementNamed(context, widget.nextRoute);
      } else {
        print('Error @createAccount: $result');
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
    // final isSubmitting = context.isSubmitting;
    return Form(
      key: _formKey,
      autovalidate: true,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  title: 'Create\nAccount',
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
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              decoration: registerInputDecoration(
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
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              decoration: registerInputDecoration(
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
                            style: TextStyle(color: Colors.white),
                          ),
                          SignUpBar(
                            label: 'Sign up',
                            isLoading: widget.isSubmitting,
                            onPressed: onSubmit,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Already have an account? '),
                              InkWell(
                                splashColor: Colors.black12,
                                onTap: () {
                                  widget.onSignInPressed?.call();
                                },
                                child: const Text(
                                  'SIGN IN',
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
