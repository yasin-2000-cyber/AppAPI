import os
from typing import Any, Dict

import psycopg2
import redis
from fastapi import FastAPI
from fastapi.responses import JSONResponse


app = FastAPI(title="AppAPI", version="1.0.0")


def get_env(name: str, default: str | None = None) -> str:
    value = os.getenv(name, default)
    if value is None:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def check_postgres() -> Dict[str, Any]:
    conn = None
    try:
        conn = psycopg2.connect(
            host=get_env("DB_HOST"),
            port=int(get_env("DB_PORT", "5432")),
            dbname=get_env("DB_NAME"),
            user=get_env("DB_USER"),
            password=get_env("DB_PASSWORD"),
            connect_timeout=5,
        )
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            result = cur.fetchone()
        return {"ok": result == (1,), "details": "postgres reachable"}
    finally:
        if conn is not None:
            conn.close()


def check_redis() -> Dict[str, Any]:
    client = redis.Redis(
        host=get_env("REDIS_HOST"),
        port=int(get_env("REDIS_PORT", "6379")),
        db=int(get_env("REDIS_DB", "0")),
        password=os.getenv("REDIS_PASSWORD"),
        socket_connect_timeout=5,
        socket_timeout=5,
        decode_responses=True,
    )
    pong = client.ping()
    return {"ok": bool(pong), "details": "redis reachable"}


@app.get("/")
def root() -> JSONResponse:
    try:
        db_status = check_postgres()
        redis_status = check_redis()
        message = os.getenv("APP_MESSAGE", "connected successfully")

        return JSONResponse(
            status_code=200,
            content={
                "message": message,
                "database": db_status,
                "redis": redis_status,
            },
        )
    except Exception as exc:
        return JSONResponse(
            status_code=500,
            content={
                "message": "connection failed",
                "error": str(exc),
            },
        )


@app.get("/health")
def health() -> JSONResponse:
    try:
        db_status = check_postgres()
        redis_status = check_redis()
        return JSONResponse(
            status_code=200,
            content={
                "status": "ok",
                "database": db_status,
                "redis": redis_status,
            },
        )
    except Exception as exc:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "error": str(exc),
            },
        )
