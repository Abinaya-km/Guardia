import 'package:flutter/material.dart';
import 'api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌸 SAME GRADIENT (UNCHANGED)
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
                    "Register",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _inputBox(
                    label: "Full Name",
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name cannot be empty";
                      }
                      if (value.length < 3) {
                        return "Enter valid name";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    label: "Age",
                    controller: ageController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Age cannot be empty";
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 10 || age > 100) {
                        return "Enter valid age";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _inputBox(
                    label: "Email",
                    controller: emailController,
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

                  const SizedBox(height: 15),

                  _inputBox(
                    label: "Password",
                    controller: passwordController,
                    isPassword: true,
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

                  const SizedBox(height: 25),

                ElevatedButton(
  onPressed: () async {

    if (_formKey.currentState!.validate()) {

      var result = await ApiService.register(
        nameController.text,
        ageController.text,
        emailController.text,
        passwordController.text,
      );

      print(result);

      if (result["status"] == "success") {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful")),
        );

        Navigator.pop(context);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email already exists")),
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
                      "Register",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Login",
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

  // 🔹 ORIGINAL DESIGN RESTORED
  static Widget _inputBox({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFF5FA2),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Text(
            "$label:",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFFFEBF2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}