from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "✅ Secure Alpine image, non-root, multi-stage, scanned."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)











# from flask import Flask
# app = Flask(__name__)

# @app.route('/')
# def home():
#     return "🚀 Secure Docker Image Demo by Priyanshu - Industry Best Practices Followed"

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)
