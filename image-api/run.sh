#!/bin/bash -e
 
# image-api:
#     image: flashcard/image-api
#     volumes:
#       - /home/supra/Chatgpt/debug/image-api/main.py:/app/main.py
#     ports:
#       - "8000:8000"
#     runtime: nvidia

docker run -d \
       --gpus all \
       -p 8000:8000 \
       --name flashcard-image-api \
       -v /home/supra/Chatgpt/debug/image-api/main.py:/app/main.py \
       flashcard/image-api
