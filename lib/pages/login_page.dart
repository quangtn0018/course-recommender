import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home_page.dart';
import '../widgets/loading_indicator.dart';
import '../util/authentication.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Authentication _auth = Authentication();
  bool _isLoading;

  @override
  void initState() {
    super.initState();

    _isLoading = false;

    // Listen for our auth event (on reload or start)
    // Go to our homepage page once logged in
    _auth.firebaseAuth.onAuthStateChanged
        .firstWhere((user) => user != null)
        .then((user) {
      final userRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');

      userRef.once().then((snapshot) {
        final value = snapshot.value;

        if (value == null) {
          final newUserVal = {'email': user.email};

          userRef
              .set(newUserVal)
              .then((_) => Navigator.of(context).pushNamed(HomePage.tag));
        } else {
          Navigator.of(context).pushNamed(HomePage.tag);
        }
      });
    });

    // Give the navigation animations, etc, some time to finish
    // new Future.delayed(new Duration(seconds: 1)).then((_) => auth.signInWithGoogle());
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signInWithGoogle();
    } catch (error) {
      // if user select cancel
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTitleLabel = Text(
      'CourseRecommender',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
    );

    final loginWithGoogleButton = Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: _handleLogin,
          color: Colors.lightBlueAccent,
          child:
              Text('Log In With Google', style: TextStyle(color: Colors.white)),
        ),
      ),
    );

    if (_isLoading) {
      return LoadingIndicator();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            appTitleLabel,
            SizedBox(height: 20.0),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    loginWithGoogleButton,
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
