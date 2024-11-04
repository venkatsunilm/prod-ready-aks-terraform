import os
import subprocess
import time
import logging
from flask import Flask, request, render_template, jsonify

app = Flask(__name__)

UPLOAD_FOLDER = '/tmp/uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Environment variables for storage account and container
STORAGE_ACCOUNT = os.environ.get('AZURE_STORAGE_ACCOUNT')
CONTAINER_NAME = os.environ.get('AZURE_STORAGE_CONTAINER')

@app.route('/')
def upload_form():
    return render_template('upload.html')

@app.route('/upload_chunk', methods=['POST'])
def upload_chunk():
    start_time = time.time()  # Start time
    try:
        chunk_index = int(request.form['chunk_index'])
        total_chunks = int(request.form['total_chunks'])
        sas_token = request.form['sas_token']
        file = request.files['file']
        filename = request.form['filename']  # Get the original filename from the client
        chunk_filename = f"{filename}.part{chunk_index}"

        chunk_path = os.path.join(UPLOAD_FOLDER, chunk_filename)
        file.save(chunk_path)

        logging.info(f"Received chunk {chunk_index + 1}/{total_chunks} for {filename}")

        if chunk_index == total_chunks - 1:
            logging.info(f"All chunks received for {filename}. Assembling file...")

            # Assemble chunks
            assembled_file_path = os.path.join(UPLOAD_FOLDER, filename)
            with open(assembled_file_path, 'wb') as assembled_file:
                for i in range(total_chunks):
                    chunk_path = os.path.join(UPLOAD_FOLDER, f"{filename}.part{i}")
                    with open(chunk_path, 'rb') as chunk_file:
                        assembled_file.write(chunk_file.read())
                    os.remove(chunk_path)

            logging.info(f"File assembled at {assembled_file_path}. Uploading to Azure Blob Storage...")

            # Call your script to upload to Azure Blob Storage
            script_path = os.path.join(os.path.dirname(__file__), 'data_export.sh')
            try:
                result = subprocess.run(['bash', script_path, assembled_file_path, sas_token, STORAGE_ACCOUNT, CONTAINER_NAME],
                                        capture_output=True,
                                        text=True,
                                        check=True)
                os.remove(assembled_file_path)
                logging.info("File uploaded successfully.")
                end_time = time.time()  # End time
                duration = (end_time - start_time) / 60  # Duration in minutes

                # Ensure clean JSON response
                response = {
                    'status': 'success',
                    'message': 'File uploaded successfully!',
                    'duration': duration,
                    'start_time': start_time,
                    'end_time': end_time
                }
                logging.info(f"Returning response: {response}")
                return jsonify(response)
            except subprocess.CalledProcessError as e:
                logging.error(f"Failed to upload file: {e.stderr}")
                return jsonify({'status': 'error', 'message': f"Failed to upload file: {e.stderr}"})
        
        return jsonify({'status': 'success', 'message': 'Chunk uploaded successfully!'})
    except Exception as e:
        error_message = f"Error processing chunk: {str(e)}"
        logging.error(error_message)
        return jsonify({'status': 'error', 'message': error_message})

# No need for app.run() as Azure App Service will handle it

# if __name__ == '__main__':
#     app.run(debug=True, port=5000, host='0.0.0.0')
