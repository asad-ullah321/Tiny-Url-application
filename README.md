# Tiny URL Application

A basic Rails application that provides URL shortening with:
- optional custom alias support
- deterministic hash-based alias generation
- redirect endpoint using query param alias
- ERB frontend (home page + invalid URL page)

## Stack

- Ruby `3.4.7`
- Rails `7.2.3`
- MySQL

## Setup

1. Install gems:

```bash
bundle install
```

2. Configure environment variables in `.env`:

```bash
BASE_URL=http://localhost:3000
GET_ENDPOINT=tiny
```

3. Configure DB credentials in `config/database.yml` for your local MySQL.

4. Create and migrate database:

```bash
bin/rails db:create
bin/rails db:migrate
```

5. Start server:

```bash
bin/rails server
```

Open: `http://localhost:3000`

## Routes

- `GET /` -> home form
- `POST /tiny_url/create` -> create tiny URL
- `GET /tiny?alias=...` -> redirect to original URL (or invalid page)

`GET_ENDPOINT` changes the retrieval path (`/tiny` by default).

## Tiny URL Rules

- Table: `tiny_urls` with `alias`, `original_url`, timestamps.
- `alias` is unique at model/database level.
- User-entered alias:
  - max 40 chars enforced in controller
  - if already exists, show error on same page
- Alias not entered:
  - if `original_url` already exists, reuse existing alias
  - else generate alias from SHA256 hash (128-bit hex substring)

## Notes

- `.env` is ignored by git. Do not commit secrets.
- `Gemfile.lock` should be committed for app consistency.
- `vendor/bundle` should not be committed.
