import 'package:flutter/material.dart';
import 'reset_password_screen.dart';
class OtpVerificationScreen extends StatefulWidget {

  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {

  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌸 Slightly stronger pink than Forgot Password
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD6E6),
              Color(0xFFFF8FB8),
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

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔐 Title
                const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Enter the OTP sent to your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 30),

                _otpInput(),

                const SizedBox(height: 30),

                // 🔹 VERIFY → RESET PASSWORD
                ElevatedButton(
  onPressed: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(
          email: widget.email,
          otp: otpController.text,
        ),
      ),
    );

  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6FA1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 RESEND OTP → BACK
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: Color(0xFFFF6FA1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 OTP Input Box (UNCHANGED)
 Widget _otpInput() {
  return TextField(
    controller: otpController,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    maxLength: 6,
    decoration: InputDecoration(
      counterText: "",
      hintText: "Enter OTP",
      filled: true,
      fillColor: Colors.pinkAccent.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
}
