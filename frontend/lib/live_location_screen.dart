import 'package:flutter/material.dart';
import 'sos_alert_screen.dart';
import 'profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationScreen extends StatefulWidget {
  final String email;

  const LiveLocationScreen({super.key, required this.email});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  GoogleMapController? mapController;
  StreamSubscription<Position>? positionStream;

  double lat = 0.0;
  double lon = 0.0;

  @override
  void initState() {
    super.initState();
    startTracking();
  }

  // ✅ CLEAN LOCATION TRACKING (NO API CALL)
  void startTracking() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        lat = position.latitude;
        lon = position.longitude;
      });

      print("LIVE: $lat, $lon");
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6EE),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            const Text(
              "Confirm Your Location",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5FA2),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Lat: $lat\nLon: $lon",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Expanded(
              child: lat == 0
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, lon),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId("user"),
                          position: LatLng(lat, lon),
                        ),
                      },
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                    ),
            ),

            // ✅ CONFIRM LOCATION BUTTON (IMPORTANT)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5FA2),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: lat == 0
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SosAlertScreen(
                              email: widget.email,
                              lat: lat,
                              lng: lon,
                            ),
                          ),
                        );
                      },
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            // 🔻 Bottom Navigation (UNCHANGED)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomIcon(
                    icon: Icons.location_on,
                    label: "Location",
                    active: true,
                    onTap: () {},
                  ),
                  BottomIcon(
                    icon: Icons.warning_rounded,
                    label: "SOS",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SosAlertScreen(
                            email: widget.email,
                            lat: lat,
                            lng: lon,
                          ),
                        ),
                      );
                    },
                  ),
                  BottomIcon(
                    icon: Icons.person,
                    label: "Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            email: widget.email,
                          ),
                        ),
                      );
                    },
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

// 🔻 Bottom Icon Widget (UNCHANGED)
class BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const BottomIcon({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFF5FA2) : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}