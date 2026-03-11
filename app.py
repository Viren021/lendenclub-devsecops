from flask import Flask, render_template, request, json
from werkzeug.utils import secure_filename
import os
import random
import time

UPLOAD_FOLDER = os.path.join('Uploaded_Files')
app = Flask(__name__, template_folder="templates")
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/', methods=['GET'])
def homepage():
    return render_template('index.html')

@app.route('/Detect', methods=['POST', 'GET'])
def DetectPage():
    if request.method == 'GET':
        return render_template('index.html')
    
    if request.method == 'POST':
        try:
            video = request.files['video']
            print(f"Received file: {video.filename}")
            
            video_filename = secure_filename(video.filename)
            video_path = os.path.join(app.config['UPLOAD_FOLDER'], video_filename)
            
            # Save the file to mimic actual behavior
            video.save(video_path)
            
            if os.path.exists(video_path):
                
                print("Simulating deep learning processing...")
                time.sleep(2) # Fake processing delay
                
                is_real = random.choice([True, False])
                output = "REAL" if is_real else "FAKE"
                confidence = round(random.uniform(75.5, 98.9), 2) 
                
                print(f"Mocked Prediction: {output} ({confidence}%)")
                # -------------------------------
                
                data = {'output': output, 'confidence': confidence}
                data_json = json.dumps(data)
                
                os.remove(video_path)
                
                return render_template('index.html', data=data_json)
            else:
                return "Error: Video file not found."
                
        except Exception as e:
            print(f"Error: {e}")
            return "Error: Internal server error."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, debug=False)