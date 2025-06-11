import sqlite3, os

def get_db():
    db_path = os.path.join('/app/data/', 'vocab.db')
    if not os.path.exists(db_path):
        os.makedirs(os.path.dirname(db_path), exist_ok=True)
        conn = sqlite3.connect(db_path)
        create_tables(conn)
        conn.close()
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn

def create_tables(conn):
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS vocab (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image TEXT
        )
    """)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS vocab_lang (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            vocab_id INTEGER,
            lang TEXT,
            word TEXT,
            audio TEXT,
            FOREIGN KEY(vocab_id) REFERENCES vocab(id)
        )
    """)
    conn.commit()


def insert_vocab_record(image_path):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO vocab (image) VALUES (?)", (image_path,))
    conn.commit()
    return cur.lastrowid

def insert_lang_record(vocab_id, lang, word, audio_path):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO vocab_lang (vocab_id, lang, word, audio) VALUES (?, ?, ?, ?)",
        (vocab_id, lang, word, audio_path)
    )
    conn.commit()

def fetch_vocab_by_lang(lang):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT v.id, v.image, vl.lang, vl.word, vl.audio
        FROM vocab v
        JOIN vocab_lang vl ON v.id = vl.vocab_id
        WHERE vl.lang = ?
    """, (lang,))
    return cur.fetchall()

def fetch_image_path(word, lang):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT v.image
        FROM vocab v
        JOIN vocab_lang vl ON v.id = vl.vocab_id
        WHERE vl.lang = ? AND vl.word = ?
    """, (lang, word))
    row = cur.fetchone()
    return row["image"] if row else None

def fetch_audio_path(word, lang):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT vl.audio
        FROM vocab_lang vl
        WHERE vl.lang = ? AND vl.word = ?
    """, (lang, word))
    row = cur.fetchone()
    return row["audio"] if row else None

def fetch_random_vocab(lang, limit=10):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT v.id, v.image, vl.lang, vl.word, vl.audio
        FROM vocab v
        JOIN vocab_lang vl ON v.id = vl.vocab_id
        WHERE vl.lang = ?
        ORDER BY RANDOM() LIMIT ?
    """, (lang, limit))
    return cur.fetchall()

def remove_existing_record(word, lang, vocab_id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM vocab_lang WHERE word = ? AND lang = ?", (word, lang))
    cur.execute("DELETE FROM vocab WHERE id = ?", (vocab_id,))
    conn.commit()
    