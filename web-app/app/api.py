import requests
import os
import logging

image_api_server = "http://image-api:8000"
image_dir = "/app/data/image"
os.makedirs(image_dir, exist_ok=True)

translate_api_server = "http://translate-api:8001"

tts_api_server = "http://tts-api:8002"
audio_dir = "/app/data/audio"
os.makedirs(audio_dir, exist_ok=True)

# save logs to a file
log_file = '/app/logs/api.log'
if not os.path.exists(os.path.dirname(log_file)):
    os.makedirs(os.path.dirname(log_file))

log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(
    filename=log_file,
    filemode='a',
    level=getattr(logging, log_level, logging.INFO)
)

# curl -X POST http://localhost:8000/generate \
#     -H "Content-Type: application/json" \
#     -d '{"prompt": "{word}, sketch style, white background"'
# {"image_id": image_id}
#
# curl -X GET http://localhost:8000/image?id=<image_id> 
def generate_image(word):
    logging.info(f"Generating image for word: {word}")
    response = requests.post(
        f"{image_api_server}/generate",
        json={"prompt": f"{word}, sketch style, white background"}
    )
    if response.status_code == 200:
        image_id = response.json().get("image_id")
        image_file = requests.get(f"{image_api_server}/image?id={image_id}")
        if image_file.status_code == 200:
            image_path = f"{image_dir}/{image_id}.png"
            with open(image_path, 'wb') as f:
                f.write(image_file.content)
            logging.info(f"Image saved at: {image_path}")
            return image_path
        else:
            logging.error(f"Failed to retrieve image: {image_file.text}")
            raise Exception(f"Image retrieval failed: {image_file.text}")
    else:
        logging.error(f"Image generation failed: {response.text}")
        raise Exception(f"Image generation failed: {response.text}")

# curl -X POST http://localhost:8001/translate \
#     -H "Content-Type: application/json" \
#     -d '{"text": "apple", "source_lang": "en", "target_lang": "ja"}'
# {"translated_text": result}
def translate(word, from_lang, to_lang):
    logging.info(f"Translating '{word}' from {from_lang} to {to_lang}")
    response = requests.post(
        f"{translate_api_server}/translate",
        json={"text": word, "source_lang": from_lang, "target_lang": to_lang}
    )
    if response.status_code == 200:
        logging.info(f"Translation successful: {response.json().get('translated_text')}")
        return response.json().get("translated_text")
    else:
        logging.error(f"Translation failed: {response.text}")
        raise Exception(f"Translation failed: {response.text}")

# curl -X POST http://localhost:8002/tts \
#     -H "Content-Type: application/json" \
#     -d '{"text": "りんご", "language": "ja"}'
#
# {"audio_file_id": f"{req.language}_{audio_id}"}
# curl -X GET http://localhost:8002/audio?id=<audio_file_id>
def generate_audio(lang, word):
    logging.info(f"Generating audio for word: {word} in language: {lang}")
    if lang == "zh": # Use zh-cn for Chinese
        lang = "zh-cn"  
        
    response = requests.post(
        f"{tts_api_server}/tts",
        json={"text": word, "language": lang}
    )
    if response.status_code == 200:
        audio_file_id = response.json().get("audio_file_id")
        audio_file = requests.get(f"{tts_api_server}/audio?id={audio_file_id}")
        if audio_file.status_code == 200:
            audio_path = f"{audio_dir}/{audio_file_id}.wav"
            with open(audio_path, 'wb') as f:
                f.write(audio_file.content)
            logging.info(f"Audio saved at: {audio_path}")
            return audio_path
        else:
            logging.error(f"Failed to retrieve audio: {audio_file.text}")
            raise Exception(f"Audio retrieval failed: {audio_file.text}")
    else:
        logging.error(f"Audio generation failed: {response.text}")
        raise Exception(f"Audio generation failed: {response.text}")