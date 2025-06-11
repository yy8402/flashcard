from flask import Flask, jsonify, request, send_from_directory
import json
import os

from db_vocab import (
    insert_vocab_record,
    insert_lang_record,
    fetch_vocab_by_lang,
    fetch_image_path,
    fetch_audio_path,
    fetch_random_vocab,
    remove_existing_record,
)

from api import (
    generate_image,
    generate_audio,
    translate,
)

app = Flask(__name__, static_folder='static', static_url_path='')

@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/settings')
def get_config():
    with open('config.json', 'r') as f:
        config = json.load(f)
    return jsonify(config)

@app.route('/set', methods=['POST'])
def set_config():
    with open('config.json', 'r') as f:
        config = json.load(f)
    updates = request.get_json(force=True)
    if not isinstance(updates, dict):
        return jsonify({"error": "Invalid input"}), 400
    updated = False
    for key, value in updates.items():
        if key in config:
            config[key] = value
            updated = True
    if updated:
        with open('config.json', 'w') as f:
            json.dump(config, f, indent=4)
        return jsonify({"status": "ok"})
    return jsonify({"error": "Invalid key(s)"}), 400

@app.route('/api/data')
def get_data():
    lang = request.args.get("lang", "en")
    rows = fetch_vocab_by_lang(lang)
    grouped = {}
    for row in rows:
        if row["id"] not in grouped:
            grouped[row["id"]] = row["word"]
    return jsonify(list(grouped.values()))

@app.route('/api/image')
def get_image():
    word = request.args.get("word")
    lang = request.args.get("lang", "en")
    image_path = fetch_image_path(word, lang)
    if image_path and os.path.exists(image_path):
        return send_from_directory(os.path.dirname(image_path), os.path.basename(image_path))
    return jsonify({"error": "Image not found"}), 404

@app.route('/api/audio')
def get_audio():
    word = request.args.get("word")
    lang = request.args.get("lang", "en")
    audio_path = fetch_audio_path(word, lang)
    if audio_path and os.path.exists(audio_path):
        return send_from_directory(os.path.dirname(audio_path), os.path.basename(audio_path))
    return jsonify({"error": "Audio not found"}), 404

@app.route('/api/random')
def get_random():
    lang = request.args.get("lang", "en")
    rows = fetch_random_vocab(lang)
    grouped = {}
    for row in rows:
        if row["id"] not in grouped:
            grouped[row["id"]] = {"image": row["image"], "languages": {}}
        grouped[row["id"]]["languages"][row["lang"]] = {
            "word": row["word"],
            "audio": row["audio"]
        }
    return jsonify(list(grouped.values()))

@app.route('/update', methods=['POST'])
def update():
    data = request.json
    source_lang = data.get("language")
    words = data.get("words", [])
    results = []

    for word in words:
        # delete any existing records for this word
        existing_vocab = fetch_vocab_by_lang(source_lang)
        for vocab in existing_vocab:
            if vocab["word"] == word:
                remove_existing_record(word, source_lang, vocab["id"])

        # generate new records
        english_word = word if source_lang == "en" else translate(word, source_lang, "en")
        image_path = generate_image(english_word)
        vocab_id = insert_vocab_record(image_path)

        translations = {
            lang: translate(english_word, "en", lang) for lang in ["en", "zh", "ja", "es"]
        }

        for lang, lang_word in translations.items():
            audio_path = generate_audio(lang, lang_word)
            insert_lang_record(vocab_id, lang, lang_word, audio_path)
            results.append((lang, lang_word, audio_path))

    return jsonify({"status": "ok", "details": results})