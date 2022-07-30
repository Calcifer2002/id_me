import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:id_me/pages/home_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

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
  late String phoneController;
  String? verificationID;
  bool showloading = false;

  void signInAuthCreds(PhoneAuthCredential phoneAuthCreds) async {
    setState(() {
      showloading = true;
    });
    try {
      final authCred = await _auth.signInWithCredential(phoneAuthCreds);
      setState(() {
        showloading = false;
      });
      if (authCred?.user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Homepage()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showloading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text((e.message).toString())));
    }
  }
   late String OTP;
   final otpController = OtpFieldController();

  FirebaseAuth _auth = FirebaseAuth.instance;
//{
//             PhoneAuthCredential phoneAuthCreds = PhoneAuthProvider.credential(
//                 verificationId: (verificationID).toString(),
//                 smsCode: otpController.text);
//             signInAuthCreds(phoneAuthCreds);
//           }
  getOTPwidget(context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/images/hand-3469618_640.png',
                  height: 200,
                  width: 200,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 40,
                ),
                Text("VERIFICATION",
                    style: GoogleFonts.openSans(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "Please enter the OTP received by SMS.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 14, color: Colors.grey.shade600),
                    )),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: OTPTextField(
                        controller: otpController,
                        length: 6,
                        width: MediaQuery.of(context).size.width,
                        textFieldAlignment: MainAxisAlignment.spaceAround,
                        fieldWidth: 45,
                        fieldStyle: FieldStyle.box,
                        outlineBorderRadius: 15,
                        style: TextStyle(fontSize: 17),
                        onChanged: (pin) {
                          print("Changed: " + pin);
                        },
                        onCompleted: (pin) {
                          print("Completed: " + pin);
                          OTP = pin;
                        })),
                SizedBox(
                  height: 90,
                ),
                ElevatedButton(
                  onPressed: () async {
                    PhoneAuthCredential phoneAuthCreds = PhoneAuthProvider.credential(
                        verificationId: (verificationID).toString(),
                        smsCode: OTP);
                    signInAuthCreds(phoneAuthCreds);
                  },
                  // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                  style: ElevatedButton.styleFrom(
                    elevation: 12.0,
                    primary: Colors.black, // background
                    onPrimary: Colors.white, // foreground

                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  child: const Text('Submit OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getphnumberwidget(context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            child: Column(children: [
              SizedBox(
                height: 40,
              ),
              Image.asset(
                'assets/images/hand-3469618_640.png',
                height: 200,
                width: 200,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 40,
              ),
              Text("LOGIN",
                  style: GoogleFonts.openSans(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Please provide us your mobile number to continue, we will send you an OTP to verify.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                        fontSize: 14, color: Colors.grey.shade600),
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                height: 80,
                child: IntlPhoneField(
                  decoration: const InputDecoration(
                    counter: Offstage(),
                    labelText: 'Mobile Number',
                  ),
                  initialCountryCode: 'IE',
                  showDropdownIcon: true,
                  dropdownIconPosition: IconPosition.trailing,
                  onChanged: (phone) {
                    print(phone.completeNumber);
                    phoneController = phone.completeNumber;
                  },
                ),
              ),
              SizedBox(
                height: 90,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _auth.verifyPhoneNumber(
                      phoneNumber: phoneController,
                      verificationCompleted: (phoneAuthCreds) async {
                        setState(() {
                          showloading = false;
                        });
                        //signInAuthCreds(phoneAuthCreds);
                      },
                      verificationFailed: (verificationFailed) async {
                        setState(() {
                          showloading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text((verificationFailed.message).toString())));
                      },
                      codeSent: (verificationID, resendingToken) async {
                        setState(() {
                          showloading = false;

                          presentState = NumberVerification.SHOW_OTP_FORM_STATE;
                          this.verificationID = verificationID;
                        });
                      },
                      codeAutoRetrievalTimeout: (verificationID) async {});
                },

                // style: ButtonStyle(elevation: MaterialStateProperty(12.0 )),
                style: ElevatedButton.styleFrom(
                  elevation: 12.0,
                  primary: Colors.black, // background
                  onPrimary: Colors.white, // foreground

                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: const Text('Request OTP'),
              ),
            ]),
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: showloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : presentState == NumberVerification.SHOW_MOBILE_FORM_STATE
              ? getphnumberwidget(context)
              : getOTPwidget(context),
      padding: const EdgeInsets.all(24),
    ));
  }
}
