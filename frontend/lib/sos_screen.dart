import 'package:flutter/material.dart';
import 'live_location_screen.dart';
import 'profile_screen.dart';

class SosScreen extends StatelessWidget {
  final String email;

  const SosScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEF5),

      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 🔴 BIG SOS BUTTON → START FLOW
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveLocationScreen(
                      email: email,
                    ),
                  ),
                );
              },
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D6D),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "SOS",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Tap in Emergency",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFF4D6D),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "💗 Stay Strong",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            // 🔻 Bottom Navigation
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // 📍 Location
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LiveLocationScreen(email: email),
                        ),
                      );
                    },
                    child: _bottomIcon(
                      icon: Icons.location_on_outlined,
                      label: "Location",
                      isActive: false,
                    ),
                  ),

                  // 🚨 SOS
                  _bottomIcon(
                    icon: Icons.warning_rounded,
                    label: "SOS",
                    isActive: true,
                  ),

                  // 👤 Profile
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(email: email),
                        ),
                      );
                    },
                    child: _bottomIcon(
                      icon: Icons.person_outline,
                      label: "Profile",
                      isActive: false,
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

  Widget _bottomIcon({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFFFF4D6D) : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFFFF4D6D) : Colors.grey,
          ),
        ),
      ],
    );
  }
}