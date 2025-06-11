#!/bin/bash -e

docker run -d \
       --gpus all \
       -p 8002:8002 \
       --name flashcard-tts-api \
       -v /home/supra/Chatgpt/debug/tts-api/main.py:/app/main.py \
       flashcard/tts-api
