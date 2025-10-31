from flask import Flask

app = Flask(__name__)

@app.route("/")
def index():
    return "Connected to the web Rocket League server!"

@app.route("/status.html")
def status():
    health_check_response = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Service Status</title>
    </head>
    <body>
        <h1>Health Check</h1>
        <p><strong>Status:</strong> OK</p>
        <p>The Rocket League web service is up and running.</p>
    </body>
    </html>
    """

    return health_check_response
