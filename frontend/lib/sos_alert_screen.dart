import 'package:flutter/material.dart';
import 'sos_screen.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SosAlertScreen extends StatefulWidget {
final String email;
final double lat;
final double lng;

const SosAlertScreen({
super.key,
required this.email,
required this.lat,
required this.lng,
});

@override
State<SosAlertScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosAlertScreen> {
int selectedIndex = 0;

final List<String> messages = [
"I am in danger. I need immediate help.",
"I am being followed. Please respond urgently.",
"I feel unsafe at my current location.",
"Emergency! Please track my location and help.",
"I am stuck and unable to call. Please send help.",
];

// 🔹 Distance Calculation (optional, kept for future use)
double calculateDistance(lat1, lon1, lat2, lon2) {
const R = 6371;

double dLat = (lat2 - lat1) * pi / 180;
double dLon = (lon2 - lon1) * pi / 180;

double a =
    sin(dLat / 2) * sin(dLat / 2) +
    cos(lat1 * pi / 180) *
        cos(lat2 * pi / 180) *
        sin(dLon / 2) *
        sin(dLon / 2);

return R * 2 * atan2(sqrt(a), sqrt(1 - a));

}

// 🔥 FINAL SOS FUNCTION (BACKEND CALL)
Future<void> sendSOS() async {
try {
final selectedMessage = messages[selectedIndex];

  final response = await http.post(
 Uri.parse("http://127.0.0.1:5000/send_alert"), 
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "user_id": 1,
    "latitude": widget.lat,
    "longitude": widget.lng,
  }),
);

print("STATUS: ${response.statusCode}");
print("BODY: ${response.body}");

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("SOS Sent Successfully")),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => SosScreen(email: widget.email),
    ),
  );
} catch (e) {
  print("ERROR: $e");

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Failed to send SOS")),
  );
}

}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFFFEEF4),

  appBar: AppBar(
    backgroundColor: const Color(0xFFFFEEF4),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.pink),
      onPressed: () => Navigator.pop(context),
    ),
    centerTitle: true,
    title: const Text(
      "Send SOS Alert",
      style: TextStyle(
        color: Colors.pink,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        const Text(
          "Select a message to send with your live location",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: const [
              Icon(Icons.warning_rounded, color: Colors.pink, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your GPS location will be sent to the nearest police station and emergency contacts.",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose an Emergency Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              ...List.generate(messages.length, (index) {
                return RadioListTile<int>(
                  value: index,
                  groupValue: selectedIndex,
                  activeColor: Colors.pink,
                  onChanged: (value) {
                    setState(() => selectedIndex = value!);
                  },
                  title: Text(messages[index]),
                );
              }),

              const SizedBox(height: 15),

              // 🚨 SEND SOS BUTTON
              GestureDetector(
                onTap: sendSOS,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9BBF),
                        Color(0xFFFF5FA2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Send SOS Alert",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  "Once sent, your live location will continue to be shared.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
}