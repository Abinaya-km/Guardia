
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


load_dotenv()

# -------- CONFIG --------
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

account_sid = os.getenv("TWILIO_ACCOUNT_SID")
auth_token = os.getenv("TWILIO_AUTH_TOKEN")
twilio_number = os.getenv("TWILIO_PHONE")

# -------- INIT --------
app = Flask(__name__)
CORS(app)

client = Client(account_sid, auth_token)

# -------- MAIL CONFIG --------
app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv("EMAIL_USER")
app.config['MAIL_PASSWORD'] = os.getenv("EMAIL_PASS")

# -------- DATABASE --------
db = mysql.connector.connect(
    host=os.getenv("MYSQLHOST"),
    user=os.getenv("MYSQLUSER"),
    password=os.getenv("MYSQLPASSWORD"),
    database=os.getenv("MYSQLDATABASE"),
    port=int(os.getenv("MYSQLPORT"))
)
cursor = db.cursor(dictionary=True)
print(" Connected to Railway DB")


# ---------------- GOOGLE FUNCTION ----------------
def get_nearest_police(lat, lon):
    try:
        url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={lat},{lon}&radius=5000&type=police&key={GOOGLE_API_KEY}"
        
        response = requests.get(url)
        data = response.json()

        print("GOOGLE RESPONSE:", data)  # DEBUG

        if "results" in data and len(data["results"]) > 0:
            return data["results"][0]["name"]

        return "Police Station Nearby"

    except Exception as e:
        print("GOOGLE ERROR:", e)
        return "Police Station Nearby"

# ---------------- HOME ----------------
@app.route("/")
def home():
    return "Backend Running"

@app.route("/send_alert", methods=["POST"])
def send_alert():
    data = request.get_json()

    user_id = data.get("user_id")
    latitude = float(data.get("latitude"))
    longitude = float(data.get("longitude"))

    if not user_id:
        return jsonify({"status": "error", "message": "Missing data"}), 400

    # STEP 1: GOOGLE → nearest police
    station_name = get_nearest_police(latitude, longitude)

    # ✅ STEP 2: DB → get phone (FIXED INDENTATION)
    cursor.execute("SELECT phone FROM police_stations LIMIT 1")
    result = cursor.fetchone()

    if result and result["phone"]:
        police_phone = result["phone"]
    else:
        police_phone = "+919037716754"

    print("POLICE PHONE:", police_phone)

    # STEP 3: SAVE ALERT
    cursor.execute(
        "INSERT INTO alerts (user_id, latitude, longitude, timestamp) VALUES (%s,%s,%s,%s)",
        (user_id, latitude, longitude, datetime.now())
    )
    db.commit()

    # STEP 4: SEND SMS
    try:
        msg = client.messages.create(
            body=f"EMERGENCY ALERT\nUser: {user_id}\nLocation: https://maps.google.com/?q={latitude},{longitude}\nNearest Police: {station_name}",
            from_=twilio_number,
            to=police_phone
        )

        print("SMS SENT:", msg.sid)

        return jsonify({
            "status": "success",
            "sid": msg.sid
        })

    except Exception as e:
        print("SMS ERROR FULL:", str(e))

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
# ---------------- REGISTER ----------------
@app.route("/register", methods=["POST"])
def register():
    data = request.get_json()

    hashed_password = generate_password_hash(data["password"])

    try:
        cursor.execute(
            "INSERT INTO users (name, age, email, password) VALUES (%s,%s,%s,%s)",
            (data["name"], data["age"], data["email"], hashed_password)
        )
        db.commit()
        return jsonify({"status": "success"})
    except:
        return jsonify({"status": "error", "message": "Email exists"})

# ---------------- LOGIN ----------------
@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    cursor.execute("SELECT * FROM users WHERE email=%s", (data["email"],))
    user = cursor.fetchone()

    if user and check_password_hash(user["password"], data["password"]):
        return jsonify({"status": "success"})
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"})

# ---------------- FORGOT PASSWORD ----------------
@app.route("/forgot_password", methods=["POST"])
def forgot_password():
    data = request.get_json()
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

    # SEND EMAIL
    msg = Message(
        subject="Password Reset OTP",
        sender=app.config['MAIL_USERNAME'],
        recipients=[email]
    )
    msg.body = f"Your OTP is {otp}"

    try:
        mail.send(msg)
        print("EMAIL SENT")
    except Exception as e:
        print("EMAIL ERROR:", e)

    return jsonify({"status": "success"})

# ---------------- RESET PASSWORD ----------------
@app.route("/reset_password", methods=["POST"])
def reset_password():
    data = request.get_json()

    cursor.execute(
        "SELECT * FROM password_resets WHERE email=%s AND otp=%s ORDER BY id DESC LIMIT 1",
        (data["email"], data["otp"])
    )
    record = cursor.fetchone()

    if not record:
        return jsonify({"status": "error", "message": "Invalid OTP"})

    new_password = generate_password_hash(data["new_password"])

    cursor.execute(
        "UPDATE users SET password=%s WHERE email=%s",
        (new_password, data["email"])
    )
    db.commit()

    return jsonify({"status": "success"})

# ---------------- RUN ----------------

port = int(os.environ.get("PORT", 5000))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port)