import 'package:flutter/material.dart';
import 'api_service.dart';
class ResetPasswordScreen extends StatefulWidget {

  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController =
      TextEditingController();
  final TextEditingController confirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌸 Gradient (UNCHANGED)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFC1D9),
              Color(0xFFFF5FA2),
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

                  const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Create a new password for your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔐 New Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "New Password",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password cannot be empty";
                      }
                      if (value.length < 6) {
                        return "Minimum 6 characters required";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // 🔐 Confirm Password
                  TextFormField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm your password";
                      }
                      if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {

  if (_formKey.currentState!.validate()) {

    var result = await ApiService.resetPassword(
      widget.email,
      widget.otp,
      passwordController.text,
    );

    print(result);

    if (result["status"] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );

    }

  }

},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5FA2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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