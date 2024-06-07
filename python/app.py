import asyncio
import websockets
import base64
import cv2
import numpy as np
import mediapipe as mp
from arabic_reshaper import reshape
from bidi.algorithm import get_display
from tashaphyne.stemming import ArabicLightStemmer
import arabic_reshaper
import pickle
import nltk
from sklearn.naive_bayes import MultinomialNB
import json
from flask import Flask, render_template, request, send_from_directory, jsonify
import time
from PIL import Image
import os
import threading

# Download NLTK data
nltk.download('punkt')

# Initialize MediaPipe hands and drawing utilities
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

hands = mp_hands.Hands(static_image_mode=True, min_detection_confidence=0.3)

labels_dict = {
    0: 'ا', 1: 'ب', 2: 'ت', 3: 'ث', 4: 'ج', 5: 'ح', 6: 'خ', 7: 'د', 8: 'ذ', 9: 'ر',
    10: 'ز', 11: 'س', 12: 'ش', 13: 'ص', 14: 'ض', 15: 'ط', 16: 'ظ', 17: 'ع', 18: 'غ',
    19: 'ف', 20: 'ق', 21: 'ك', 22: 'ل', 23: 'م', 24: 'ن', 25: 'ه', 26: 'و', 27: 'ي', 28: ' ', 29: 'لا', 30: 'لا'
}

# Initialize Arabic stemmer
stemmer = ArabicLightStemmer()

# Load the model
model_dict = pickle.load(open('model.p', 'rb'))
model = model_dict['model']

# WebSocket server global variables
connected_clients = set()

# Flask application setup
app = Flask(__name__)


# Function to display sign language images (modified for Flask)
def display_images(text):
    img_dir = "images/"
    image_paths = []
    for char in text:
        if char.isalpha():
            img_path = os.path.join(img_dir, f"{char}.png")
        elif char == ' ':
            img_path = os.path.join(img_dir, "space.png")
        image_paths.append(img_path)
    return image_paths


# Function to serve image based on its path
@app.route('/get_image', methods=['GET'])
def get_image():
    image_path = request.args.get('image_path')
    return send_from_directory('static', image_path)


@app.route('/', methods=['POST'])
def index():
    if request.method == 'POST':
        text = request.form['text'].lower()
        image_paths = display_images(text)
        return jsonify({
            'image_paths': image_paths,
        })


# Function to send data to all connected clients
async def send_to_clients(message):
    if connected_clients:  # asyncio.wait doesn't accept an empty list
        tasks = [asyncio.create_task(client.send(json.dumps(message))) for client in connected_clients]
        try:
            await asyncio.gather(*tasks)
        except asyncio.CancelledError:
            print("Task was cancelled")
        except websockets.exceptions.ConnectionClosedError as e:
            print(f"ConnectionClosedError: {e}")
        except Exception as e:
            print(f"Unexpected error: {e}")


async def process_image(image_data):
    nparr = np.frombuffer(base64.b64decode(image_data), np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    H, W, _ = image.shape
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(image_rgb)

    if results.multi_hand_landmarks:
        data_aux = []
        x_ = []
        y_ = []

        for hand_landmarks in results.multi_hand_landmarks:
            for i in range(len(hand_landmarks.landmark)):
                x = hand_landmarks.landmark[i].x
                y = hand_landmarks.landmark[i].y

                x_.append(x)
                y_.append(y)

            min_x = min(x_)
            min_y = min(y_)

            for i in range(len(hand_landmarks.landmark)):
                x = hand_landmarks.landmark[i].x
                y = hand_landmarks.landmark[i].y
                data_aux.append(x - min_x)
                data_aux.append(y - min_y)

        if len(data_aux) == 42:
            prediction = model.predict([data_aux])
            predicted_character = labels_dict[int(prediction[0])]

            words = nltk.word_tokenize(predicted_character)
            stemmed_word = ' '.join([stemmer.light_stem(word) for word in words])
            reshaped_text = arabic_reshaper.reshape(stemmed_word)
            bidi_text = get_display(reshaped_text)

            response_data = {
                'predicted_character': bidi_text,
                'bounding_box': {'x1': int(min(x_) * W) - 10, 'y1': int(min(y_) * H) - 10,
                                 'x2': int(max(x_) * W) - 10, 'y2': int(max(y_) * H) - 10}
            }
            return response_data
        else:
            return {
                'predicted_character': '',
                'bounding_box': {'x1': 0, 'y1': 0,
                                 'x2': 0, 'y2': 0}
            }
    else:
        return {
            'predicted_character': '',
            'bounding_box': {'x1': 0, 'y1': 0,
                             'x2': 0, 'y2': 0}
        }


async def handler(websocket, path):
    # Register client
    connected_clients.add(websocket)
    try:
        async for message in websocket:
            response_data = await process_image(message)
            print(response_data)
            await send_to_clients(response_data)
    except Exception as e:
        print(f"Handler error: {e}")
    finally:
        connected_clients.remove(websocket)


async def websocket_server():
    async with websockets.serve(handler, '127.0.0.1', 8000):
        await asyncio.Future()  # Run forever


def start_flask():
    app.run(port=5000, debug=False)


if __name__ == '__main__':
    flask_thread = threading.Thread(target=start_flask)
    flask_thread.start()

    asyncio.run(websocket_server())
