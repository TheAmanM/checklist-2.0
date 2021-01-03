import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/notes_page.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool keyboardOpen = false;
  bool logInPage = true;
  bool invalidText = false;
  bool loading = false;
  AuthServices _auth = new AuthServices();
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();
  TextEditingController registerEmailController = new TextEditingController();
  TextEditingController registerPasswordController =
      new TextEditingController();
  TextEditingController registerNameController = new TextEditingController();

  GlobalKey<ScaffoldState> authScaffoldKey = new GlobalKey();

  signIn() async {
    if (loginEmailController.text == null) {
      loginEmailController.text = '';
    }
    if (loginPasswordController.text == null) {
      loginPasswordController.text = '';
    }

    if (!loginEmailController.text.contains('@') ||
        loginPasswordController.text.length < 8) {
      setState(() {
        print('login unsuccessful');
        invalidText = true;
      });
    } else {
      setState(() {
        invalidText = false;
        loading = true;
      });
      var result = await _auth.signIn(
        loginEmailController.text,
        loginPasswordController.text,
      );
      if (result["data"] == null) {
        PlatformException exception = result["error"];
        print(exception.message);
        authScaffoldKey.currentState.showSnackBar(
          CustomSnackBar(
            Text(exception.message),
            Duration(seconds: 1),
          ),
        );
        setState(() {
          loading = false;
        });
      } else {
        print('successful login!');
        setState(() {
          loading = false;
        });
      }
    }
  }

  registerMe() async {
    if (registerEmailController.text == null) {
      registerEmailController.text = '';
    }
    if (registerPasswordController.text == null) {
      registerPasswordController.text = '';
    }
    if (registerNameController.text == null) {
      registerNameController.text = '';
    }

    if (!registerEmailController.text.contains('@') ||
        registerPasswordController.text.length < 8 ||
        registerNameController.text == '') {
      setState(() {
        print('registration unsuccessful');
        invalidText = true;
      });
    } else {
      setState(() {
        invalidText = false;
        loading = true;
      });
      FirebaseUser result = await _auth.register(
        registerEmailController.text,
        registerPasswordController.text,
        registerNameController.text,
      );
      if (result == null) {
        setState(() {
          loading = false;
          authScaffoldKey.currentState.showSnackBar(
            CustomSnackBar(
              Text('An unexpected error occured'),
              Duration(seconds: 1),
            ),
          );
        });
      } else {
        print('successful registration!');
        setState(() {
          loading = false;
        });
      }
    }
  }

  /* 
  register() {
    if (registerEmailController.text == null) {
      registerEmailController.text = '';
    }
    if (registerPasswordController.text == null) {
      registerPasswordController.text = '';
    }
    if (registerNameController.text == null) {
      registerNameController.text = '';
    }
    if (!registerEmailController.text.contains('@') ||
        registerPasswordController.text.length < 8 ||
        registerNameController.text == '') {
      setState(() {
        invalidText = true;
        print('registration unsuccessful');
      });
    } else {
      setState(() async {
        invalidText = false;
        //loading = true;
      });
      print('successful register!');
    }
  }
 */

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerEmailController.dispose();
    registerNameController.dispose();
    registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    keyboardOpen = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
        backgroundColor: backColor,
        key: authScaffoldKey,
        body: !loading
            ? Padding(
                padding: const EdgeInsets.only(
                  right: 30,
                  left: 30,
                  top: 30,
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: Colors.lime,
                        alignment: Alignment.center,
                        child: FractionallySizedBox(
                          heightFactor: keyboardOpen ? 0.75 : 1,
                          widthFactor: 0.75,
                          alignment: Alignment.center,
                          child: Container(
                            //color: Colors.deepPurple,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Image(
                                    image: AssetImage('assets/appicon.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                if (keyboardOpen)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 20),
                                      Flexible(
                                        flex: 1,
                                        child: Image(
                                          image: AssetImage(
                                              'assets/Checklist 2.0.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!logInPage)
                      TextField(
                        onChanged: (String v) {
                          setState(() {
                            invalidText = false;
                          });
                        },
                        style: TextStyle(color: Colors.white),
                        controller: registerNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          errorText: invalidText
                              ? registerNameController.text == ''
                                  ? 'Please enter a valid name'
                                  : null
                              : null,
                          hintText: 'Your display name',
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: mainColor.withBlue(255),
                            ),
                          ),
                        ),
                      ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (String v) {
                        setState(() {
                          invalidText = false;
                        });
                      },
                      style: TextStyle(color: Colors.white),
                      controller: logInPage
                          ? loginEmailController
                          : registerEmailController,
                      decoration: InputDecoration(
                        errorText: invalidText
                            ? logInPage
                                ? loginEmailController.text.contains('@') ==
                                        false
                                    ? 'Please enter a valid email'
                                    : null
                                : registerEmailController.text.contains('@') ==
                                        false
                                    ? 'Please enter a valid email'
                                    : null
                            : null,
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: mainColor.withBlue(255),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      style: TextStyle(color: Colors.white),
                      obscureText: true,
                      controller: logInPage
                          ? loginPasswordController
                          : registerPasswordController,
                      decoration: InputDecoration(
                        errorText: invalidText
                            ? logInPage
                                ? loginPasswordController.text.length < 8
                                    ? 'Please enter a valid password'
                                    : null
                                : registerPasswordController.text.length < 8
                                    ? 'Please enter a valid password (8+ characters)'
                                    : null
                            : null,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: mainColor.withBlue(255),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        logInPage ? signIn() : registerMe();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 50,
                        child: Text(logInPage ? 'Sign In' : 'Register',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [mainColor, accentColor],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(75),
                        ),
                      ),
                    ),
                    keyboardOpen
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                invalidText = false;
                                if (logInPage) {
                                  logInPage = false;
                                } else {
                                  logInPage = true;
                                }
                                print(logInPage);
                              });
                            },
                            child: Container(
                              color: backColor,
                              alignment: Alignment.centerRight,
                              height: 50,
                              child: RichText(
                                text: TextSpan(
                                  text: logInPage
                                      ? "Don't have an account?  "
                                      : "Already have an account?  ",
                                  children: [
                                    TextSpan(
                                      text: logInPage
                                          ? "Register Here"
                                          : "Login Here",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox(height: 20),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
