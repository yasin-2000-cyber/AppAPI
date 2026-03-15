# AppAPI

A small FastAPI application that checks connectivity to PostgreSQL and Redis.

## Behavior

- `GET /`
  - Connects to PostgreSQL
  - Connects to Redis
  - Returns the value of `APP_MESSAGE` when both are reachable

Example success response:

```json
{
  "message": "connected successfully",
  "database": {
    "ok": true,
    "details": "postgres reachable"
  },
  "redis": {
    "ok": true,
    "details": "redis reachable"
  }
}
```

If you set:

```bash
APP_MESSAGE="app is connected"
```

then the response message becomes:

```json
{
  "message": "app is connected"
}
```

## Required environment variables

- `APP_MESSAGE` (optional, default: `connected successfully`)
- `DB_HOST`
- `DB_PORT` (optional, default: `5432`)
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `REDIS_HOST`
- `REDIS_PORT` (optional, default: `6379`)
- `REDIS_DB` (optional, default: `0`)
- `REDIS_PASSWORD` (optional)

## Run locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export $(grep -v '^#' .env.example | xargs)
uvicorn app:app --host 0.0.0.0 --port 8000
```

Then open:

```bash
curl http://localhost:8000/
curl http://localhost:8000/health
```

## Docker build

```bash
docker build -t appapi:local .
docker run --rm -p 8000:8000 --env-file .env.example appapi:local
```
