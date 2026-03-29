import 'api_service.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'live_location_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFC1D9),
              Color(0xFFFF5FA2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
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
                    "Login",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // EMAIL FIELD
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Color(0xFFFFEBF2),
                      border: OutlineInputBorder(
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

                  const SizedBox(height: 16),

                  // PASSWORD FIELD
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Color(0xFFFFEBF2),
                      border: OutlineInputBorder(
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

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState!.validate()) {

      String email = emailController.text;
      String password = passwordController.text;

      var result = await ApiService.login(email, password);

      print(result);

      if (result["status"] == "success") {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveLocationScreen(
  email: email,
),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );

      }
    }
  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5FA2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 22),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "New Here? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              color: Color(0xFFFF5FA2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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