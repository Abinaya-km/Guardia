import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_mail import Mail, Message
import random
import requests
from twilio.rest import Client
from dotenv import load_dotenv

# ---------------- LOAD ENV ----------------
load_dotenv()

# ---------------- INIT ----------------
app = Flask(__name__)
CORS(app)

# ---------------- CONFIG ----------------
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

account_sid = os.getenv("TWILIO_ACCOUNT_SID")
auth_token = os.getenv("TWILIO_AUTH_TOKEN")
twilio_number = os.getenv("TWILIO_PHONE")

# ---------------- TWILIO ----------------
client = None
if account_sid and auth_token:
    try:
        client = Client(account_sid, auth_token)
    except Exception as e:
        print("Twilio init error:", e)
else:
    print("Twilio not configured")

# ---------------- MAIL ----------------
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv("EMAIL_USER")
app.config['MAIL_PASSWORD'] = os.getenv("EMAIL_PASS")

mail = None
try:
    mail = Mail(app)
except Exception as e:
    print("Mail error:", e)

# ---------------- DATABASE ----------------
db = None
cursor = None

def connect_db():
    global db, cursor
    try:
        db = mysql.connector.connect(
            host=os.getenv("MYSQLHOST"),
            user=os.getenv("MYSQLUSER"),
            password=os.getenv("MYSQLPASSWORD"),
            database=os.getenv("MYSQLDATABASE"),
            port=int(os.getenv("MYSQLPORT", 3306))
        )
        cursor = db.cursor(dictionary=True)
        print("Connected to Railway DB")
    except Exception as e:
        print("DB ERROR:", e)
        db = None
        cursor = None

connect_db()

# ---------------- HOME (VERY IMPORTANT) ----------------
@app.route("/")
def home():
    return jsonify({
        "status": "OK",
        "message": "Backend Running 🚀"
    })

# ---------------- GOOGLE ----------------
def get_nearest_police(lat, lon):
    if not GOOGLE_API_KEY:
        return "Police Station Nearby"

    try:
        url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=5000&type=police&key={GOOGLE_API_KEY}"
        response = requests.get(url, timeout=5)
        data = response.json()

        if "results" in data and data["results"]:
            return data["results"][0]["name"]

    except Exception as e:
        print("Google API error:", e)

    return "Police Station Nearby"

# ---------------- SEND ALERT ----------------
@app.route("/send_alert", methods=["POST"])
def send_alert():
    global db, cursor

    if not db or not cursor:
        connect_db()
        if not cursor:
            return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json(silent=True) or {}

        user_id = data.get("user_id")
        latitude = float(data.get("latitude", 0))
        longitude = float(data.get("longitude", 0))

        if not user_id:
            return jsonify({"status": "error", "message": "Missing user_id"}), 400

        station_name = get_nearest_police(latitude, longitude)

        cursor.execute("SELECT phone FROM police_stations LIMIT 1")
        result = cursor.fetchone()

        police_phone = result["phone"] if result and result.get("phone") else "+919000000000"

        cursor.execute(
            "INSERT INTO alerts (user_id, latitude, longitude, timestamp) VALUES (%s,%s,%s,%s)",
            (user_id, latitude, longitude, datetime.now())
        )
        db.commit()

        if not client:
            return jsonify({"status": "error", "message": "Twilio not configured"}), 500

        msg = client.messages.create(
            body=f"EMERGENCY ALERT\nUser: {user_id}\nLocation: https://maps.google.com/?q={latitude},{longitude}\nNearest Police: {station_name}",
            from_=twilio_number,
            to=police_phone
        )

        return jsonify({"status": "success", "sid": msg.sid})

    except Exception as e:
        print("SEND ALERT ERROR:", e)
        return jsonify({"status": "error", "message": str(e)}), 500

# ---------------- REGISTER ----------------
@app.route("/register", methods=["POST"])
def register():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json(silent=True) or {}

        cursor.execute(
            "INSERT INTO users (name, age, email, password) VALUES (%s,%s,%s,%s)",
            (
                data.get("name"),
                data.get("age"),
                data.get("email"),
                generate_password_hash(data.get("password", ""))
            )
        )
        db.commit()

        return jsonify({"status": "success"})

    except Exception as e:
        print("REGISTER ERROR:", e)
        return jsonify({"status": "error", "message": "Registration failed"})

# ---------------- LOGIN ----------------
@app.route("/login", methods=["POST"])
def login():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json(silent=True) or {}

        cursor.execute("SELECT * FROM users WHERE email=%s", (data.get("email"),))
        user = cursor.fetchone()

        if user and check_password_hash(user["password"], data.get("password")):
            return jsonify({"status": "success"})

        return jsonify({"status": "error", "message": "Invalid credentials"})

    except Exception as e:
        print("LOGIN ERROR:", e)
        return jsonify({"status": "error", "message": "Login failed"})

# ---------------- GLOBAL ERROR HANDLER ----------------
@app.errorhandler(Exception)
def handle_exception(e):
    print("GLOBAL ERROR:", e)
    return jsonify({"error": str(e)}), 500

# ---------------- PORT FIX (CRITICAL) ----------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)