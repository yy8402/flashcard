# Now safe to import TTS
from TTS.api import TTS

# Load the XTTS model
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", progress_bar=False)
