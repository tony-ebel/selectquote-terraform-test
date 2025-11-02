from flask import Flask, Response
import requests
import os

internal_endpoint = f'http://{os.getenv("INTERNAL_ENDPOINT")}:{os.getenv("INTERNAL_PORT")}'

app = Flask(__name__)

def stream_response():
    yield "Initial connection established. Backend handshake pending...\n"
    print("LOG: Sent initial handshake response to client.")

    try:
        print(f"LOG: Initiating connection to internal rl server: {internal_endpoint}")

        internal_response = requests.get(internal_endpoint, timeout=10)

        if internal_response.status_code == 200:
            print("LOG: Internal connection check successful (HTTP 200).")
            yield "Internal connection successful (HTTP 200). Sending final data payload.\n"
            yield "Final status: READY.\n"
        else:
            print(f"LOG: Internal connection check failed (HTTP {internal_response.status_code}).")
            yield f"Backend service check failed. Received unexpected status code: {internal_response.status_code}.\n"
            yield "Final status: FAILED.\n"

    except requests.exceptions.Timeout:
        error_message = f"Request timed out connecting to {internal_endpoint}."
        print(f"ERROR: {error_message}")
        yield f"ERROR: Backend connection failed (Timeout). Details: {error_message}\n"
    except requests.exceptions.RequestException as e:
        error_message = f"An error occurred during the request: {e}"
        print(f"ERROR: {error_message}")
        yield f"ERROR: Backend connection failed (Request Exception). Details: {e}\n"
    except Exception as e:
        print(f"ERROR: An unexpected error occurred: {e}")
        yield f"ERROR: An unexpected error occurred. Details: {e}\n"


@app.route("/")
def index():
    return Response(stream_response(), mimetype='text/plain')

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
