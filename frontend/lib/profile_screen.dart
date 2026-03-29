import 'package:flutter/material.dart';
import 'live_location_screen.dart';
import 'sos_screen.dart';
import 'edit_profile_screen.dart';
import 'api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> profileData = {
    "Name": "",
    "Email": "",
    "Location": "",
    "Phone": "",
    "Age": "",
    "Gender": "",
  };

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // 🔹 Load profile from backend
  loadProfile() async {
    var result = await ApiService.getProfile(widget.email);

    print(result); // 🔥 debug

    if (result["status"] == "success") {
      var data = result["data"];

      setState(() {
        profileData = {
          "Name": data["name"] ?? "",
          "Email": data["email"] ?? "",
          "Location": data["location"] ?? "",
          "Phone": data["phone"] ?? "",
          "Age": data["age"]?.toString() ?? "",
          "Gender": data["gender"] ?? "",
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEF4),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 25),

              // 👩 Avatar
              Container(
                width: 120,
                height: 120,
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
                  child: Icon(Icons.face_6, size: 65, color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    _profileRow(Icons.person, "Name"),
                    _profileRow(Icons.email, "Email"),
                    _profileRow(Icons.location_on, "Location"),
                    _profileRow(Icons.phone, "Phone"),
                    _profileRow(Icons.cake, "Age"),
                    _profileRow(Icons.female, "Gender"),

                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EditProfileScreen(),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            profileData =
                                Map<String, String>.from(result);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5FA2),
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Navigation (FIXED)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFFFF5FA2),
        unselectedItemColor: Colors.grey,

        onTap: (index) {

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LiveLocationScreen(email: widget.email), // ✅ FIXED
              ),
            );
          }

          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SosScreen(email: widget.email), // ✅ FIXED
              ),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Location",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_rounded),
            label: "SOS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFFE0EB),
            child: Icon(icon, size: 18, color: const Color(0xFFFF5FA2)),
          ),
          const SizedBox(width: 15),
          Text(
            profileData[label]?.isNotEmpty == true
                ? profileData[label]!
                : label,
          ),
        ],
      ),
    );
  }
}