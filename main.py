# main.py
import sqlite3
import string
from contextlib import closing

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, HttpUrl

DB_PATH = "data/urls.db"
ALPHABET = string.digits + string.ascii_letters  # 62 chars

app = FastAPI()


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    import os
    os.makedirs("data", exist_ok=True)
    with closing(get_db()) as conn:
        conn.execute(
            """CREATE TABLE IF NOT EXISTS urls (
                   id INTEGER PRIMARY KEY AUTOINCREMENT,
                   long_url TEXT NOT NULL,
                   created_at TEXT DEFAULT CURRENT_TIMESTAMP
               )"""
        )
        conn.commit()


init_db()


def encode(n: int) -> str:
    if n == 0:
        return ALPHABET[0]
    out = []
    while n:
        n, r = divmod(n, 62)
        out.append(ALPHABET[r])
    return "".join(reversed(out))


def decode(code: str) -> int:
    n = 0
    for ch in code:
        n = n * 62 + ALPHABET.index(ch)  # raises ValueError on bad char
    return n


class ShortenRequest(BaseModel):
    url: HttpUrl


@app.post("/shorten")
def shorten(body: ShortenRequest, request: Request):
    with closing(get_db()) as conn:
        cur = conn.execute("INSERT INTO urls (long_url) VALUES (?)", (str(body.url),))
        conn.commit()
        code = encode(cur.lastrowid)
    return {"short_url": f"{request.base_url}{code}", "code": code}


@app.get("/health")
def health():
    with closing(get_db()) as conn:
        conn.execute("SELECT 1")
    return {"status": "ok"}


@app.get("/{code}")
def redirect(code: str):
    try:
        url_id = decode(code)
    except ValueError:
        raise HTTPException(404, "Not found")

    with closing(get_db()) as conn:
        row = conn.execute("SELECT long_url FROM urls WHERE id = ?", (url_id,)).fetchone()

    if row is None:
        raise HTTPException(404, "Not found")
    return RedirectResponse(row["long_url"], status_code=302)