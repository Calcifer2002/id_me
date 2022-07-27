import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:id_me/pages/home_page.dart';
enum NumberVerification {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  NumberVerification presentState = NumberVerification.SHOW_MOBILE_FORM_STATE;
  final phoneController = TextEditingController();
  String? verificationID;
  bool showloading = false;

  void signInAuthCreds(PhoneAuthCredential phoneAuthCreds) async{
    setState(() {
      showloading= true;
    });
     try{
       final authCred = await _auth.signInWithCredential(phoneAuthCreds);
       setState(() {
         showloading = false;
       });
       if(authCred?.user != null){
         Navigator.push(context, MaterialPageRoute(builder: (context)=>Homepage()));
       }
     } on FirebaseAuthException catch(e){
       setState(() {
         showloading= false;
       });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((e.message).toString())));
     }
  }

  final otpController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  getOTPwidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: otpController,
          decoration: InputDecoration(hintText: "OTP"),
        ),
        SizedBox(height: 24),
        TextButton(
          onPressed: () async{
            PhoneAuthCredential phoneAuthCreds = PhoneAuthProvider.credential(verificationId: (verificationID).toString(), smsCode: otpController.text);
            signInAuthCreds(phoneAuthCreds);
          },
          child: Text("verify"),
        ),
        Spacer(),
      ],
    );
  }

  getphnumberwidget(context) {
    return Column(
      children: [
        Spacer(),
        TextField(
          controller: phoneController,
          decoration: InputDecoration(hintText: "Mobile Number"),
        ),
        SizedBox(height: 24),

        TextButton(
          onPressed: () async {
            setState(() {
              showloading = true;
            });
            await _auth.verifyPhoneNumber(
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCreds) async {
                  setState(() {
                    showloading= false;
                  });
                  //signInAuthCreds(phoneAuthCreds);
                },
                verificationFailed: (verificationFailed) async {
                  setState(() {
                    showloading= false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((verificationFailed.message).toString())));

                },
                codeSent: (verificationID, resendingToken) async {

                  setState(() {
                    showloading= false;

                  presentState = NumberVerification.SHOW_OTP_FORM_STATE;
                  this.verificationID = verificationID;
                });},
                codeAutoRetrievalTimeout: (verificationID) async {


                });
          },
          child: Text("Send OTP"),
        ),
        Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Container(
          child: showloading? Center(child: CircularProgressIndicator(),):presentState == NumberVerification.SHOW_MOBILE_FORM_STATE
              ? getphnumberwidget(context)
              : getOTPwidget(context),
          padding: const EdgeInsets.all(24),
        ));
  }

 }