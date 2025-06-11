FROM nvidia/cuda:12.2.0-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata software-properties-common curl git libsndfile1 && \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "Etc/UTC" > /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-distutils python3.10-venv python3-pip && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    apt-get clean

RUN pip install fastapi uvicorn

RUN pip install TTS==0.22.0 torch==2.2.2 transformers==4.39.3

## for Japanese TTS
RUN apt-get update && \
    apt-get install -y mecab libmecab-dev mecab-ipadic-utf8 && \
    pip install mecab-python3 unidic-lite cutlet

COPY download_models.py /download_models.py
RUN export COQUI_TOS_AGREED=1 && python3 /download_models.py

# COPY preload.py /preload.py
# RUN export COQUI_TOS_AGREED=1 && python3 /preload.py

COPY app /app
WORKDIR /app

EXPOSE 8002
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]