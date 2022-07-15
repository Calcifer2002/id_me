import 'package:flutter/material.dart';

enum NumberVerification {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
final phoneController = TextEditingController();
final otpController = TextEditingController();

getOTPwidget(context){
  return Column(
    children: [
      Spacer(),
      TextField(
        controller: otpController,
        decoration: InputDecoration(hintText: "OTP"),
      ),
      SizedBox(height: 24),
      TextButton(
        onPressed: () {},
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
        onPressed: () {},
        child: Text("Send OTP"),
      ),
      Spacer(),
    ],
  );
}

class _LoginScreenState extends State<LoginScreen> {
  final presentState = NumberVerification.SHOW_MOBILE_FORM_STATE;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child : presentState == NumberVerification.SHOW_MOBILE_FORM_STATE
            ? getphnumberwidget(context)
            : getOTPwidget(context),
        padding: const EdgeInsets.all(24),));
  }
}
