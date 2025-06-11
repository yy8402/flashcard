# Flashcard API Services (Offline, GPU-Accelerated)

This project provides three Docker-based API services to support a flashcard application that works entirely offline with GPU acceleration via CUDA.

## 🚀 Services

| Service        | Port | Description                          |
|----------------|------|--------------------------------------|
| `image-api`    | 8000 | Generate images from text prompts    |
| `translate-api`| 8001 | Translate vocabulary between languages |
| `tts-api`      | 8002 | Generate pronunciation audio from text |

---

## 🛠 Build All Images

```bash
chmod +x build-all.sh
./build-all.sh
```

Alternatively, use Docker Compose:

```bash
docker-compose build
```

---

## ▶️ Run All Services

```bash
docker-compose up
```

> Make sure you have an NVIDIA GPU and `nvidia-container-toolkit` installed.

---

## ✅ API Test Scripts

### 1. Test Image Generation

```bash
curl -X POST http://localhost:8000/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt": "A red apple on a table"}'
```

Returns:
```json
{"image_id": "A_red_apple_on_a_table"}
```

### 2. Test Translation

```bash
curl -X POST http://localhost:8001/translate \
    -H "Content-Type: application/json" \
    -d '{"text": "apple", "source_lang": "en", "target_lang": "ja"}'
```

Returns:
```json
{"translated_text": "りんご"}
```

### 3. Test TTS

```bash
curl -X POST http://localhost:8002/tts \
    -H "Content-Type: application/json" \
    -d '{"text": "りんご", "language": "ja"}'
```

Returns:
```json
{"audio_file_id":"ja_30dbabd6-b2f1-4666-9cf2-0cd87ca9ab47"}
```

> Use `language` code as speaker ID (e.g. `en`, `fr`, `es`, etc. depending on model support).

---

## 📦 Folder Structure

```
flashcard-services/
├── build-all.sh
├── docker-compose.yml
├── image-api/
│   ├── Dockerfile
│   ├── preload.py
│   └── app/main.py
├── translate-api/
│   ├── Dockerfile
│   └── app/main.py
└── tts-api/
    ├── Dockerfile
    ├── preload.py
    └── app/main.py
```

---

## 📋 Notes

- All models are downloaded during build time; no internet access is required at runtime.
- GPU is required for image generation and TTS services.

---

## 🧠 Credits

- [Hugging Face diffusers](https://github.com/huggingface/diffusers)
- [Argos Translate](https://github.com/argosopentech/argos-translate)
- [Coqui TTS](https://github.com/coqui-ai/TTS)