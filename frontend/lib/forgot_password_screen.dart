import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import 'api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌸 Soft contrasting pink gradient (UNCHANGED)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE1EC),
              Color(0xFFFF9FC9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),

            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // 🔐 Title (UNCHANGED)
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Enter your registered email.\nWe’ll send you an OTP.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ EMAIL FIELD WITH VALIDATION
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle:
                          const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor:
                          Colors.pinkAccent.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email cannot be empty";
                      }
                      if (!value.contains("@")) {
                        return "Enter valid email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // 🔹 SEND OTP (VALIDATION ADDED)
                 ElevatedButton(
  onPressed: () async {

    if (_formKey.currentState!.validate()) {

      String email = emailController.text;

      var result = await ApiService.sendOTP(email);

      print(result);

      if (result["status"] == "success") {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent to your email")),
        );

       Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OtpVerificationScreen(
      email: email,
    ),
  ),
);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"])),
        );

      }

    }

  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFF7FA8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Send OTP",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 BACK TO LOGIN (UNCHANGED)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(
                        color: Color(0xFFFF7FA8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}