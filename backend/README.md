# TaskFlow API

Express + TypeScript + MongoDB (Mongoose) with a layered structure.

Flow: route → (validate) → controller → service → model

## Run
```
npm install
# edit .env (MONGODB_URI, JWT_SECRET, ...)
npm run dev
```

## Endpoints
All routes except login require `Authorization: Bearer <token>`.

| Method | Path | Notes |
|---|---|---|
| POST | /api/auth/login | `{ email, password }` |
| GET | /api/dashboard | totals, task stats, recent projects, upcoming deadlines |
| GET | /api/projects | `?archived=false\|true\|all&search=` (default: active only) |
| POST | /api/projects | `{ name, description? }` |
| GET | /api/projects/:id | project with progress |
| PATCH | /api/projects/:id | `{ name?, description?, archived? }` (archive = `archived: true`) |
| GET | /api/tasks | `?projectId&status&priority&search&sortBy&order&page&limit` |
| POST | /api/tasks | `{ projectId, title, description?, status?, priority?, dueDate? }` |
| GET | /api/tasks/:id | |
| PATCH | /api/tasks/:id | any of the create fields; `dueDate: null` clears it |
| DELETE | /api/tasks/:id | |

Task `status`: `pending | in_progress | completed`. Task `priority`: `low | medium | high`.
