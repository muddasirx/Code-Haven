import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/SignUp/checkEmailVerification.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSendingVerification = false;

  void _sendVerificationEmail() async {
    setState(() {
      _isSendingVerification = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: "AsecurePassword123!", // This should be more secure and managed
      );

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Verification email sent to ${_emailController.text.trim()}'),
        ));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send verification email: ${e.message}'),
      ));
    } finally {
      setState(() {
        _isSendingVerification = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CheckEmailVerificationPage()), // Replace with your home page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isSendingVerification
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _sendVerificationEmail,
              child: Text('Send Verification Email'),
            ),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: (){
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => CheckEmailVerificationPage()), // Replace with your home page
              );
            },
                child: Text("Done"))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
