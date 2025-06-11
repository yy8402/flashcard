FROM nvidia/cuda:12.2.0-base-ubuntu20.04

RUN apt-get update && apt-get install -y python3 python3-pip curl libegl1 && \
    pip3 install --upgrade pip && \
    apt-get clean

RUN pip install fastapi uvicorn argostranslate

WORKDIR /models
COPY preload.py /preload.py
RUN python3 /preload.py

COPY app /app
WORKDIR /app

EXPOSE 8001
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]