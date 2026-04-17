# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spark is a bilingual (English/Hindi) educational platform connecting students with subjects, topics, career insights, and teachers with certification opportunities. The app has distinct workflows for Students (browse, explore, bookmark) and Teachers (quiz, certify, track credentials).
If the program is taken up schools then the teachers shall cover these subjects/topics to explain the real world applications and how these link to real world professions, even before they actually start teaching the subject/topic.

**Tech Stack:**
- **Frontend:** Vue 3, Vite, Vue Router, Pinia (state), Supabase client
- **Backend:** FastAPI, Supabase Python client, Pydantic
- **Database:** Supabase (PostgreSQL) with 21-table schema supporting multi-tenancy (schools), role-based access, and plan-based content gating

## Development Commands

### Backend (FastAPI)
```bash
cd backend
uvicorn app.main:app --reload              # Dev server on :8000
uvicorn app.main:app --reload --port 8001  # Custom port
```

### Frontend (Vue 3 + Vite)
```bash
cd frontend
npm run dev      # Dev server on :5173
npm run build    # Production build
npm run preview  # Preview production build
```

### Database
- Schema: `database/schema.sql` (21 tables)
- Apply in Supabase SQL Editor
- Both frontend and backend connect directly to Supabase (no ORM)

## Architecture

### Backend Structure (`backend/app/`)
- `main.py` — FastAPI app with CORS, router registration, health check
- `config.py` — Environment variables (SUPABASE_URL, SUPABASE_SERVICE_KEY, SUPABASE_ANON_KEY)
- `database.py` — Supabase client singleton
- `routers/` — API routes: subjects, topics, careers, quiz, certs, bookmarks
- `models/` — Pydantic models for validation/serialization
- `services/` — Business logic layer (if needed)
- `scripts/` — Utilities like `import_excel.py`

All API routes prefixed `/api/{resource}`.

### Frontend Structure (`frontend/src/`)
- `main.js` — App entry: Vue + Pinia + Router + global CSS
- `App.vue` — Root component
- `router/index.js` — Route definitions with auth guards (`requiresAuth`, `role: 'Teacher'`)
- `pages/` — Top-level views (LandingPage, AuthPage, SubjectsPage, TopicsPage, QuizPage, etc.)
- `components/` — Reusable UI components
- `stores/` — Pinia stores: `auth.js` (user session), `bookmarks.js`, `lang.js` (i18n)
- `i18n/` — `en.js` and `hi.js` for bilingual content (English/Hindi)
- `lib/` — Supabase client + utilities
- `assets/` — Static assets, global CSS

**Routing:** All authenticated routes protected by `router.beforeEach`. Teacher-only routes guarded with `meta: { role: 'Teacher' }`.

### Database Schema (`database/schema.sql`)
21 tables organized in logical groups:
- **Institution & Plans:** `schools`, `enrollment_plans`, `plan_access_rules` (multi-school, plan-gated content)
- **Users:** `users`, `user_plan`, `teacher_subjects` (Student/Teacher/Parent roles)
- **Content:** `subjects`, `topics`, `topic_content`, `topic_careers` (bilingual name/description fields)
- **Careers:** `careers`, `career_skills`, `career_educational_paths`
- **Teacher Certification:** `quizzes`, `quiz_questions`, `quiz_attempts`, `certification_badges`, `user_badges`
- **Engagement:** `bookmarks`, `topic_progress`

Key patterns:
- Bilingual fields: `name` + `name_hi`, `description` + `description_hi`
- All tables use UUID primary keys and include `inserted_at`/`updated_at` timestamps
- Plan-based access control via `plan_access_rules`
- Teacher certification flow: take quiz → pass → earn badge

### Bilingual Support
- Frontend uses Pinia store (`stores/lang.js`) to toggle between English (`en`) and Hindi (`hi`)
- All content tables have dual columns: `name`/`name_hi`, `description`/`description_hi`
- User preference stored in `users.preferred_lang`
- i18n files: `frontend/src/i18n/en.js` and `hi.js` for UI text

## Key Workflows

### Student Flow
1. Land on `/` → sign in/up via Supabase Auth → select role
2. Browse subjects → explore topics → view topic detail with career insights
3. Bookmark topics for later (stored in `bookmarks` table)
4. Content access gated by `user_plan` + `plan_access_rules`

### Teacher Flow
1. Authenticate → select subjects they teach (stored in `teacher_subjects`)
2. Access `/teacher` hub → choose subject → take quiz (`/quiz/:subjectId`)
3. Pass quiz (score ≥ threshold) → earn certification badge
4. View earned badges on `/certs` (MyCertsPage)

## Environment Configuration

Both `/backend/.env` and `/frontend/.env` required:

**Backend (.env):**
```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbG...
SUPABASE_ANON_KEY=eyJhbG...
```

**Frontend (.env):**
```
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbG...
```

Frontend uses ANON_KEY (client-side auth), backend uses SERVICE_KEY (server-side operations).

## Notes

- Frontend dev server runs on `:5173`, backend on `:8000`. CORS configured in `backend/app/main.py`.
- Authentication handled by Supabase Auth (both client-side and server-side).
- No direct database migrations; schema applied manually via Supabase SQL Editor.
- Python ≥3.11 required for backend, Node.js/npm for frontend.
