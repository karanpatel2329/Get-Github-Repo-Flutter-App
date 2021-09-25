import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jakes_git/main.dart';
import 'package:local_auth/local_auth.dart';

import 'local_auth_api.dart';

class SignIn extends StatefulWidget {
  late final String title;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  late User _firebaseUser;
  String _status = "";
  bool otp = false;
  late AuthCredential _phoneAuthCredential;
  late String _verificationId;
  late int _code;
  late bool isAvailable=false;
  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
    _getFirebaseUser();
  }

  void _handleError(e) {
    print(e.message);
    setState(() {
      _status += e.message + '\n';
    });
  }

  Future<void> _getFirebaseUser() async {
    isAvailable = await LocalAuthApi.hasBiometrics();

    this._firebaseUser = (await FirebaseAuth.instance.currentUser)!;
    setState(() {
      _status =
          (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
    });
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(this._phoneAuthCredential)
          .then((UserCredential authRes) {
        _firebaseUser = authRes.user!;
        print(_firebaseUser.toString());
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }).catchError((e) => _handleError(e));
      setState(() {
        _status += 'Signed In\n';
      });
    } catch (e) {
      print("HERE");
      _handleError(e);
    }
  }



  Future<void> _submitPhoneNumber() async {
    String phoneNumber = "+91 " + _phoneNumberController.text.toString().trim();
    print(phoneNumber);

    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      setState(() {
        _status += 'verificationCompleted\n';
      });
      this._phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
      print("***");
    }

    void verificationFailed(error) {
      print('verificationFailed');
      _handleError(error);
    }

    void codeSent(String verificationId, [int? code]) {
      print('codeSent');
      this._verificationId = verificationId;
      print(verificationId);
      this._code = code!;
      print(code.toString());
      setState(() {
        _status += 'Code Sent\n';
        otp = true;
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      setState(() {
        _status += 'codeAutoRetrievalTimeout\n';
      });
      print(verificationId);
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }

  void _submitOTP() {
    String smsCode = _otpController.text.toString().trim();

    this._phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: this._verificationId, smsCode: smsCode);
    _login();
    _phoneNumberController.clear();
    _otpController.clear();
    otp=false;
    _status="";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('assets/github.png'),
            ),
          ),
          SizedBox(height: 24),
          Container(
              height: MediaQuery.of(context).size.width*0.30,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                Spacer(),
               !otp? MaterialButton(
                 minWidth: MediaQuery.of(context).size.width*70,
                 color: Colors.blueGrey,
                 onPressed: _submitPhoneNumber,
                 child: Padding(
                   padding: const EdgeInsets.all(15.0),
                   child: Text('Send Otp', style: TextStyle(color: Colors.white),),
                 ),
               ):Container(),
              ],
            ),
          ),
          !otp?SizedBox(height: 48):Container(),
          otp
              ? Container(
            height: MediaQuery.of(context).size.width*0.35,
                child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          hintText: 'OTP',
                          labelText: 'OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Spacer(),
                      MaterialButton(
                        minWidth: MediaQuery.of(context).size.width*70,
                        color: Colors.blueGrey,
                        onPressed: _submitOTP,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text('Submit',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
              )
              : Container(),
          buildAuthenticate(context),
        ],
      ),
    );
  }
  Widget buildAuthenticate(BuildContext context) => buildButton(
    text: 'Biometric Login',
    icon: Icons.lock_open,
    onClicked: () async {
      final isAuthenticated = await LocalAuthApi.authenticate();

      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    },
  );
  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );

}
