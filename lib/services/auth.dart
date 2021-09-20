import 'package:autosplash/models/user.dart';
import 'package:autosplash/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyUser _userFromFirebaseUser(FirebaseUser user) {
    return user != null
        ? MyUser(
            uid: user.uid,
            isAnonymous: user.isAnonymous,
            isEmailVerified: user.isEmailVerified)
        : null;
  }

  Stream<MyUser> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      await DatabaseService(uid: user.uid, isAnonymous: user.isAnonymous)
          .updateUserData(user.uid, '', '', '', '', '', '', Timestamp.now(),
              null, user.isAnonymous, user.isEmailVerified);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    String errorMessage;
    try {
      // AuthResult result =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // FirebaseUser user = result.user;
      // return _userFromFirebaseUser(user);
      return null;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Your password is too weak";
          break;
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          errorMessage = "Wrong email/password combination.";
          break;
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          errorMessage = "User disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          errorMessage = "Too many requests to log into this account.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          errorMessage = "Server error, please try again later.";
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          errorMessage = "Email address is invalid.";
          break;
        default:
          errorMessage = "SignIn failed. Please try again.";
          break;
      }
    }
    if (errorMessage != null) {
      print('Exception @LoginAccount: $errorMessage');
      // return Future.error(errorMessage);
      return errorMessage;
    }
  }

  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    FirebaseUser user;
    String errorMessage;
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      await DatabaseService(uid: user.uid, isAnonymous: user.isAnonymous)
          .updateUserData(user.uid, name, '', '', email, '', '',
              Timestamp.now(), null, user.isAnonymous, user.isEmailVerified);
      // return _userFromFirebaseUser(user);
      return null;
    } catch (error) {
      switch (error.code) {
        case "ERROR_WEAK_PASSWORD":
          errorMessage = "Your password is too weak";
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          errorMessage = "Email already used. Go to login page.";
          break;
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          errorMessage = "Wrong email/password combination.";
          break;
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          errorMessage = "No user found with this email.";
          break;
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          errorMessage = "User disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          errorMessage = "Too many requests to log into this account.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
        case "operation-not-allowed":
          errorMessage = "Server error, please try again later.";
          break;
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          errorMessage = "Email address is invalid.";
          break;
        default:
          errorMessage = "SignUp failed. Please try again.";
          break;
      }
    }

    if (errorMessage != null) {
      print('Exception @createAccount: $errorMessage');
      // return Future.error(errorMessage);
      return errorMessage;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
