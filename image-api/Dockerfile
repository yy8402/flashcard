FROM nvidia/cuda:12.2.0-base-ubuntu20.04

RUN apt-get update && apt-get install -y python3 python3-pip git curl libsndfile1 libegl1 && \
    pip3 install --upgrade pip && \
    apt-get clean

RUN pip install diffusers transformers accelerate fastapi uvicorn torch torchvision

COPY preload.py /app/preload.py
RUN python3 /app/preload.py

COPY app /app
WORKDIR /app

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]