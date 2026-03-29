import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

static Future sendAlert(String email, double lat, double lon) async {
  try {
    var url = Uri.parse("$baseUrl/send_alert");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": email,
        "latitude": lat,
        "longitude": lon
      }),
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      "status": "error",
      "message": "Failed to send alert"
    };
  }
}
static String baseUrl = "http://127.0.0.1:5000";

  // LOGIN
  static Future login(String email, String password) async {
    try {

      var url = Uri.parse("$baseUrl/login");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password
        }),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {
        "status": "error",
        "message": "Server connection failed"
      };

    }
  }

  // REGISTER
static Future register(String name, String age, String email, String password) async {

  var url = Uri.parse("$baseUrl/register");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "age": age,
      "email": email,
      "password": password
    }),
  );

  return jsonDecode(response.body);
}

   //update location
   static Future updateLocation(
  String email,
  double lat,
  double lon,
) async {

  var url = Uri.parse("$baseUrl/update_location");

  await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "latitude": lat,
      "longitude": lon
    }),
  );
}
  // SEND OTP
  static Future sendOTP(String email) async {
    try {

      var url = Uri.parse("$baseUrl/forgot_password");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email
        }),
      );

      return jsonDecode(response.body);

    } catch (e) {

      return {
        "status": "error",
        "message": "Server connection failed"
      };

    }
  }
static Future resetPassword(
  String email,
  String otp,
  String newPassword,
) async {

  var url = Uri.parse("$baseUrl/reset_password");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
      "new_password": newPassword
    }),
  );

  return jsonDecode(response.body);
}
static Future getProfile(String email) async {

  var url = Uri.parse("$baseUrl/get_profile");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email
    }),
  );

  return jsonDecode(response.body);
}
}