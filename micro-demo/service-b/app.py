# service-b/app.py
from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/hello')
def hello():
    return jsonify({"message": "hello from b"}), 200

@app.route('/health')
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
