from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    kickoff_message = """
    Connected to the internal Rocket League server!

    Reminder of the unwritten rules:
    Rule 0: try and keep the ball up when game clock is 0
    Rule 1: do not break a deadlock between two cars
    """
    return kickoff_message


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
        <p>The rl-internal service is up and running.</p>
    </body>
    </html>
    """

    return health_check_response
