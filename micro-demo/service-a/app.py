# service-a/app.py
from flask import Flask, jsonify
import requests, time

app = Flask(__name__)

# simple retry with exponential backoff
def call_service_b():
    url = "http://service-b:5001/hello"
    backoff = 1
    for attempt in range(4):  # try up to 4 times
        try:
            r = requests.get(url, timeout=2)
            r.raise_for_status()
            return r.json()
        except Exception as e:
            if attempt == 3:
                raise
            time.sleep(backoff)
            backoff *= 2

@app.route('/call')
def call_b():
    try:
        b_resp = call_service_b()
        return jsonify({"from":"a", "b": b_resp}), 200
    except Exception as e:
        return jsonify({"error": "could not reach service-b", "details": str(e)}), 500

@app.route('/health')
def health():
    return jsonify({"status":"ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
