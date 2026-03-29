import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for returning data
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController ageController = TextEditingController();

    String selectedGender = "Female";

    return Scaffold(
      backgroundColor: const Color(0xFFFFEEF4),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEEF4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👩 Avatar (UNCHANGED)
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB6C1),
                    Color(0xFFFF69B4),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.face_6,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 📦 Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _inputField("Name", nameController),
                  _inputField("Email", emailController),
                  _inputField("Location", locationController),
                  _inputField("Phone", phoneController),
                  _inputField("Age", ageController),

                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedGender,
                    decoration: _inputDecoration("Gender"),
                    items: const [
                      DropdownMenuItem(
                        value: "Female",
                        child: Text("Female"),
                      ),
                      DropdownMenuItem(
                        value: "Male",
                        child: Text("Male"),
                      ),
                      DropdownMenuItem(
                        value: "Other",
                        child: Text("Other"),
                      ),
                    ],
                    onChanged: (value) {
                      selectedGender = value!;
                    },
                  ),

                  const SizedBox(height: 30),

                  // 💾 Save → SEND DATA BACK TO PROFILE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          "Name": nameController.text,
                          "Email": emailController.text,
                          "Location": locationController.text,
                          "Phone": phoneController.text,
                          "Age": ageController.text,
                          "Gender": selectedGender,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5FA2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Text Field Widget (UNCHANGED STYLE)
  Widget _inputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: _inputDecoration(hint),
      ),
    );
  }

  // 🔹 Input Decoration (UNCHANGED)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFFF2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
