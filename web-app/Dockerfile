FROM python:3.11-slim
WORKDIR /

COPY app/ ./app
COPY app/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

COPY frontend/index.html ./app/static/index.html

ENV FLASK_APP=app.py
WORKDIR /app
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
EXPOSE 5000
