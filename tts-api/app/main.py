from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
from TTS.api import TTS
import uuid
import os

audio_dir = "/app/output"
if not os.path.exists(audio_dir):
    os.makedirs(audio_dir)

sample_dir = "/app/samples"
if not os.path.exists(sample_dir):
    os.makedirs(sample_dir)

app = FastAPI()

model = TTS("tts_models/multilingual/multi-dataset/xtts_v2")
model.to("cuda")

class Request(BaseModel):
    text: str
    language: str
    speaker: str = None  # Optional speaker parameter, not used in this example


def get_speaker_wav(language: str, speaker: str = None) -> str:
    if speaker == 'Default':
        # get the first available speaker in the sample directory
        speakers = [f for f in os.listdir(sample_dir) if f.startswith(language) and f.endswith('.wav')]
        if speakers:
            return f"{sample_dir}/{speakers[0]}"
        
        return f"{sample_dir}/{language}_default.wav"
    
    return f"{sample_dir}/{language}_{speaker}.wav"

@app.post("/tts")
def synthesize(req: Request):
    available_languages = model.languages if hasattr(model, "languages") else []
    if req.language not in available_languages:
        return {"error": f"Language '{req.language}' is not supported. Available languages: {available_languages}"}

    speaker = req.speaker if req.speaker else 'Default'
    sample_wav_path = get_speaker_wav(req.language, speaker)
    if not os.path.exists(sample_wav_path):
        return {"error": f"Sample wav file for language '{req.language}' from speaker '{speaker}' is not available."}
    
    audio_id = str(uuid.uuid4())
    output_path = f"{audio_dir}/{req.language}_{audio_id}.wav"
    model.tts_to_file(text=req.text, speaker_wav=sample_wav_path, language=req.language, file_path=output_path)
    return {"audio_file_id": f"{req.language}_{audio_id}"}

@app.get("/audio")
def get_audio(id: str):
    audio_path = f"{audio_dir}/{id}.wav"
    if os.path.exists(audio_path):
        return FileResponse(audio_path, media_type="audio/wav", filename=os.path.basename(audio_path))
    else:
        return {"error": "Audio file not found."}