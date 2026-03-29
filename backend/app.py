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
if account_sid and auth_token:
    client = Client(account_sid, auth_token)
else:
    client = None
    print("Twilio not configured")

# ---------------- MAIL ----------------
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv("EMAIL_USER")
app.config['MAIL_PASSWORD'] = os.getenv("EMAIL_PASS")

try:
    mail = Mail(app)
except Exception as e:
    print("Mail error:", e)
    mail = None

# ---------------- DATABASE ----------------
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

# ---------------- HOME ----------------
@app.route("/")
def home():
    return "Backend Running 🚀"

# ---------------- GOOGLE ----------------
def get_nearest_police(lat, lon):
    if not GOOGLE_API_KEY:
        print("Google API key missing")
        return "Police Station Nearby"

    try:
        url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=5000&type=police&key={GOOGLE_API_KEY}"
        response = requests.get(url, timeout=5)
        data = response.json()

        if "results" in data and len(data["results"]) > 0:
            return data["results"][0]["name"]

    except Exception as e:
        print("Google API error:", e)

    return "Police Station Nearby"

# ---------------- SEND ALERT ----------------
@app.route("/send_alert", methods=["POST"])
def send_alert():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json() or {}

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
        data = request.get_json() or {}
        hashed_password = generate_password_hash(data.get("password", ""))

        cursor.execute(
            "INSERT INTO users (name, age, email, password) VALUES (%s,%s,%s,%s)",
            (data.get("name"), data.get("age"), data.get("email"), hashed_password)
        )
        db.commit()

        return jsonify({"status": "success"})

    except Exception as e:
        print("REGISTER ERROR:", e)
        return jsonify({"status": "error", "message": "Email exists or DB error"})

# ---------------- LOGIN ----------------
@app.route("/login", methods=["POST"])
def login():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json() or {}

        cursor.execute("SELECT * FROM users WHERE email=%s", (data.get("email"),))
        user = cursor.fetchone()

        if user and check_password_hash(user["password"], data.get("password")):
            return jsonify({"status": "success"})
        else:
            return jsonify({"status": "error", "message": "Invalid credentials"})

    except Exception as e:
        print("LOGIN ERROR:", e)
        return jsonify({"status": "error", "message": "Login failed"})

# ---------------- FORGOT PASSWORD ----------------
@app.route("/forgot_password", methods=["POST"])
def forgot_password():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json() or {}
        email = data.get("email")

        cursor.execute("SELECT * FROM users WHERE email=%s", (email,))
        user = cursor.fetchone()

        if not user:
            return jsonify({"status": "error", "message": "Email not found"})

        otp = str(random.randint(100000, 999999))

        cursor.execute(
            "INSERT INTO password_resets (email, otp, created_at) VALUES (%s,%s,%s)",
            (email, otp, datetime.now())
        )
        db.commit()

        if mail:
            msg = Message(
                subject="Password Reset OTP",
                sender=app.config['MAIL_USERNAME'],
                recipients=[email]
            )
            msg.body = f"Your OTP is {otp}"
            mail.send(msg)

        return jsonify({"status": "success"})

    except Exception as e:
        print("FORGOT ERROR:", e)
        return jsonify({"status": "error", "message": "Failed"})

# ---------------- RESET PASSWORD ----------------
@app.route("/reset_password", methods=["POST"])
def reset_password():
    if not cursor:
        return jsonify({"status": "error", "message": "DB not connected"}), 500

    try:
        data = request.get_json() or {}

        cursor.execute(
            "SELECT * FROM password_resets WHERE email=%s AND otp=%s ORDER BY id DESC LIMIT 1",
            (data.get("email"), data.get("otp"))
        )
        record = cursor.fetchone()

        if not record:
            return jsonify({"status": "error", "message": "Invalid OTP"})

        new_password = generate_password_hash(data.get("new_password"))

        cursor.execute(
            "UPDATE users SET password=%s WHERE email=%s",
            (new_password, data.get("email"))
        )
        db.commit()

        return jsonify({"status": "success"})

    except Exception as e:
        print("RESET ERROR:", e)
        return jsonify({"status": "error", "message": "Failed"})