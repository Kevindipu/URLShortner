import logging
import os
import sqlite3
from contextlib import closing

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, HttpUrl


# --------------------------------------------------
# Configuration
# --------------------------------------------------

load_dotenv()

DB_PATH = os.getenv("DB_PATH")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
LOG_FILE = os.getenv("LOG_FILE")
BASE_URL = os.getenv("BASE_URL")
ALPHABET = os.getenv("SHORT_CODE_ALPHABET")


def validate_config():
    required = {
        "DB_PATH": DB_PATH,
        "LOG_FILE": LOG_FILE,
        "BASE_URL": BASE_URL,
        "SHORT_CODE_ALPHABET": ALPHABET,
    }

    missing = [key for key, value in required.items() if not value]

    if missing:
        raise RuntimeError(f"Missing environment variables: {', '.join(missing)}")

    if len(set(ALPHABET)) != len(ALPHABET):
        raise RuntimeError("SHORT_CODE_ALPHABET must contain unique characters")


validate_config()


# --------------------------------------------------
# Logging
# --------------------------------------------------

log_directory = os.path.dirname(LOG_FILE)

if log_directory:
    os.makedirs(log_directory, exist_ok=True)

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL.upper(), logging.INFO),
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(),
    ],
)

logger = logging.getLogger(__name__)


# --------------------------------------------------
# Application
# --------------------------------------------------

app = FastAPI(
    title="URL Shortener",
    version="1.0.0",
)


# --------------------------------------------------
# Database
# --------------------------------------------------


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    directory = os.path.dirname(DB_PATH)

    if directory:
        os.makedirs(directory, exist_ok=True)

    with closing(get_db()) as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS urls (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                long_url TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
            """
        )

        conn.commit()

    logger.info("Database initialized")


init_db()


# --------------------------------------------------
# Short-code encoding
# --------------------------------------------------


def encode(number: int) -> str:
    """
    Convert an integer ID into a short base-N string.

    N is determined by the alphabet configured in .env.
    """

    base = len(ALPHABET)

    if number == 0:
        return ALPHABET[0]

    characters = []

    while number > 0:
        number, remainder = divmod(number, base)
        characters.append(ALPHABET[remainder])

    return "".join(reversed(characters))


def decode(code: str) -> int:
    """
    Convert a short base-N string back into an integer ID.
    """

    base = len(ALPHABET)
    number = 0

    for character in code:
        try:
            value = ALPHABET.index(character)

        except ValueError:
            raise ValueError(f"Invalid character in short code: {character}")

        number = number * base + value

    return number


# --------------------------------------------------
# Request models
# --------------------------------------------------


class ShortenRequest(BaseModel):
    url: HttpUrl


# --------------------------------------------------
# API endpoints
# --------------------------------------------------


@app.post("/shorten")
def shorten_url(request: ShortenRequest):

    long_url = str(request.url)

    logger.info("Creating short URL")

    try:
        with closing(get_db()) as conn:
            cursor = conn.execute(
                """
                INSERT INTO urls (long_url)
                VALUES (?)
                """,
                (long_url,),
            )

            conn.commit()

            url_id = cursor.lastrowid

    except sqlite3.Error:
        logger.exception("Failed to store URL")
        raise HTTPException(
            status_code=500,
            detail="Failed to create short URL",
        )

    code = encode(url_id)

    short_url = f"{BASE_URL.rstrip('/')}/{code}"

    logger.info(
        "Short URL created: code=%s",
        code,
    )

    return {
        "short_url": short_url,
        "code": code,
    }


@app.get("/health")
def health_check():

    try:
        with closing(get_db()) as conn:
            conn.execute("SELECT 1")

        return {"status": "ok"}

    except sqlite3.Error:
        logger.exception("Health check failed")

        raise HTTPException(
            status_code=503,
            detail="Database unavailable",
        )


@app.get("/{code}")
def redirect_to_url(code: str):

    logger.info(
        "Redirect requested: code=%s",
        code,
    )

    try:
        url_id = decode(code)

    except ValueError:
        logger.warning(
            "Invalid short code: %s",
            code,
        )

        raise HTTPException(
            status_code=404,
            detail="Not found",
        )

    try:
        with closing(get_db()) as conn:
            row = conn.execute(
                """
                SELECT long_url
                FROM urls
                WHERE id = ?
                """,
                (url_id,),
            ).fetchone()

    except sqlite3.Error:
        logger.exception("Database lookup failed")

        raise HTTPException(
            status_code=500,
            detail="Database unavailable",
        )

    if row is None:
        logger.warning(
            "Short code not found: %s",
            code,
        )

        raise HTTPException(
            status_code=404,
            detail="Not found",
        )

    logger.info(
        "Redirecting short code: %s",
        code,
    )

    return RedirectResponse(
        url=row["long_url"],
        status_code=302,
    )
