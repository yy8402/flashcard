from fastapi import FastAPI
from pydantic import BaseModel
import os
import torch
import argostranslate.package, argostranslate.translate

if torch.cuda.is_available():
    os.environ["ARGOS_DEVICE_TYPE"] = "cuda"

app = FastAPI()

class Request(BaseModel):
    text: str
    source_lang: str
    target_lang: str

@app.post("/translate")
async def translate(req: Request):
    # argostranslate.package.load_installed_packages()  # Removed because this function does not exist
    installed_languages = argostranslate.translate.get_installed_languages()
    from_lang = next((lang for lang in installed_languages if lang.code == req.source_lang), None)
    to_lang = next((lang for lang in installed_languages if lang.code == req.target_lang), None)
    if from_lang and to_lang:
        translation = from_lang.get_translation(to_lang)
        result = translation.translate(req.text)
        return {"translated_text": result}
    return {"error": "Language pair not available."}