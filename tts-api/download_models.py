from TTS.utils.manage import ModelManager

model_name = "tts_models/multilingual/multi-dataset/xtts_v2"
manager = ModelManager()
model_path, config_path, speaker_path = manager.download_model(model_name)
print("Downloaded to:", model_path)
print("Config path:", config_path)
print("Speaker path:", speaker_path)