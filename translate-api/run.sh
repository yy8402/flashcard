#!/bin/bash -e

docker run -d \
       --gpus all \
       -p 8001:8001 \
       --name flashcard-translate-api \
       -v /home/supra/Chatgpt/debug/translate-api/main.py:/app/main.py \
       flashcard/translate-api
