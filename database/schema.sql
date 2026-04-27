-- ═══════════════════════════════════════════════════════
-- Spark — Supabase PostgreSQL Schema
-- 21 tables | Run in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ──────────────────────────────────────────
-- 🏫 INSTITUTION & PLANS
-- ──────────────────────────────────────────

create table schools (
  school_id        uuid primary key default gen_random_uuid(),
  name             varchar(200) not null,
  city             varchar(100),
  state            varchar(100),
  board_type       varchar(50),   -- CBSE / ICSE / State Board
  subscription_tier varchar(50),  -- Free / Paid-Limited / Paid-Full
  subscribed_at    timestamptz,
  expires_at       timestamptz,
  is_active        boolean not null default true,
  inserted_at      timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table enrollment_plans (
  plan_id    uuid primary key default gen_random_uuid(),
  plan_code  varchar(50) unique not null,  -- FREE_LIMITED / PAID_LIMITED / PAID_FULL
  plan_name  varchar(100) not null,
  inserted_at timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table plan_access_rules (
  rule_id     uuid primary key default gen_random_uuid(),
  plan_id     uuid not null references enrollment_plans(plan_id) on delete cascade,
  subject_id  uuid,  -- null = all subjects
  topic_id    uuid,  -- null = all topics in subject
  is_allowed  boolean not null default true,
  inserted_at timestamptz not null default now()
);

-- ──────────────────────────────────────────
-- 👤 USERS
-- ──────────────────────────────────────────

create table users (
  user_id        uuid primary key default gen_random_uuid(),
  email          varchar(200) unique not null,
  name           varchar(200),
  role           varchar(20) not null check (role in ('Student','Teacher','Parent')),
  auth_provider  varchar(30),   -- google / facebook / twitter / email
  school_id      uuid references schools(school_id) on delete set null,
  preferred_lang char(2) not null default 'en' check (preferred_lang in ('en','hi')),
  is_active      boolean not null default true,
  inserted_at    timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table user_plan (
  user_plan_id uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(user_id) on delete cascade,
  plan_id      uuid not null references enrollment_plans(plan_id),
  grade        char(2) check (grade in ('9','10')),  -- null = All
  is_current   boolean not null default true,
  inserted_at  timestamptz not null default now()
);

create table teacher_subjects (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(user_id) on delete cascade,
  subject_id uuid not null,   -- FK added after subjects table
  inserted_at timestamptz not null default now()
);

-- ──────────────────────────────────────────
-- 📚 CONTENT
-- ──────────────────────────────────────────

create table subjects (
  subject_id      uuid primary key default gen_random_uuid(),
  name            varchar(100) not null,
  name_hi         varchar(100),
  icon            varchar(10),        -- emoji
  color_hex       char(7),            -- e.g. #0EA5A0
  board_alignment varchar(50),        -- CBSE / ICSE / State / All
  is_free_preview boolean not null default false,
  sort_order      int not null default 0,
  is_active       boolean not null default true,
  inserted_at     timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Add FK now that subjects exists
alter table teacher_subjects
  add constraint fk_teacher_subjects_subject foreign key (subject_id) references subjects(subject_id) on delete cascade;

alter table plan_access_rules
  add constraint fk_access_rules_subject foreign key (subject_id) references subjects(subject_id) on delete cascade;

create table topics (
  topic_id    uuid primary key default gen_random_uuid(),
  subject_id  uuid not null references subjects(subject_id) on delete cascade,
  name        varchar(200) not null,
  name_hi     varchar(200),
  grade       char(2) check (grade in ('9','10')),  -- null = both
  sort_order  int not null default 0,
  is_active   boolean not null default true,
  inserted_at timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Add FK for plan_access_rules topic
alter table plan_access_rules
  add constraint fk_access_rules_topic foreign key (topic_id) references topics(topic_id) on delete cascade;

create table topic_content (
  id          uuid primary key default gen_random_uuid(),
  topic_id    uuid not null references topics(topic_id) on delete cascade,
  lang        char(2) not null check (lang in ('en','hi')),
  title       varchar(300) not null,
  body        text not null,
  version     int not null default 1,
  inserted_at timestamptz not null default now(),
  unique (topic_id, lang, version)
);

create table real_world_apps (
  id             uuid primary key default gen_random_uuid(),
  topic_id       uuid not null references topics(topic_id) on delete cascade,
  icon           varchar(10),
  bg_color       char(7),
  title          varchar(200) not null,
  title_hi       varchar(200),
  description    text not null,
  description_hi text,
  sort_order     int not null default 0,
  inserted_at    timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table experts (
  expert_id   uuid primary key default gen_random_uuid(),
  topic_id    uuid not null unique references topics(topic_id) on delete cascade,
  name        varchar(200) not null,
  role        varchar(200),
  initials    varchar(5),
  inserted_at timestamptz not null default now()
);

-- ── Careers (master table — many-to-many with topics) ──

create table careers (
  career_id      uuid primary key default gen_random_uuid(),
  icon           varchar(10),
  bg_color       char(7),
  name           varchar(200) not null,
  name_hi        varchar(200),
  task           varchar(300),
  task_hi        varchar(300),
  description    text,
  description_hi text,
  is_active      boolean not null default true,
  inserted_at    timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create table topic_careers (
  topic_id   uuid not null references topics(topic_id) on delete cascade,
  career_id  uuid not null references careers(career_id) on delete cascade,
  sort_order int not null default 0,
  primary key (topic_id, career_id)
);

create table career_skills (
  id          uuid primary key default gen_random_uuid(),
  career_id   uuid not null references careers(career_id) on delete cascade,
  skill       varchar(100) not null,
  sort_order  int not null default 0
);

create table expert_videos (
  id           uuid primary key default gen_random_uuid(),
  career_id    uuid not null unique references careers(career_id) on delete cascade,
  expert_name  varchar(200),
  expert_role  varchar(200),
  quote        text,
  video_url    text,
  inserted_at  timestamptz not null default now()
);

-- ──────────────────────────────────────────
-- 🎓 CERTIFICATION
-- ──────────────────────────────────────────

create table quiz_questions (
  question_id          uuid primary key default gen_random_uuid(),
  subject_id           uuid not null references subjects(subject_id) on delete cascade,
  question_text        text not null,
  correct_option_index int not null check (correct_option_index between 0 and 3),
  feedback_text        text,
  difficulty           varchar(20) check (difficulty in ('Easy','Medium','Hard')),
  sort_order           int not null default 0,
  is_active            boolean not null default true,
  inserted_at          timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create table quiz_options (
  option_id    uuid primary key default gen_random_uuid(),
  question_id  uuid not null references quiz_questions(question_id) on delete cascade,
  option_index int not null check (option_index between 0 and 3),
  option_text  varchar(300) not null,
  unique (question_id, option_index)
);

create table cert_attempts (
  attempt_id  uuid primary key default gen_random_uuid(),
  user_id     uuid not null references users(user_id) on delete cascade,
  subject_id  uuid not null references subjects(subject_id),
  score       int not null,
  passed      boolean not null,
  attempted_at timestamptz not null default now()
);

create table certificates (
  cert_id     uuid primary key default gen_random_uuid(),
  attempt_id  uuid not null unique references cert_attempts(attempt_id) on delete cascade,
  user_id     uuid not null references users(user_id) on delete cascade,
  subject_id  uuid not null references subjects(subject_id),
  score       int not null,
  issued_at   timestamptz not null default now()
);

-- ──────────────────────────────────────────
-- 📊 ENGAGEMENT
-- ──────────────────────────────────────────

create table bookmarks (
  bookmark_id uuid primary key default gen_random_uuid(),
  user_id     uuid not null references users(user_id) on delete cascade,
  topic_id    uuid not null references topics(topic_id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (user_id, topic_id)
);

create table activity_logs (
  log_id          uuid primary key default gen_random_uuid(),
  user_id         uuid not null references users(user_id) on delete cascade,
  activity_type   varchar(50) not null,
  -- Subject_Visit / Topic_Visit / SimplyPut / RealWorldApp / Careers /
  -- Career_Detail / Bookmarked / Quiz_Start / Quiz_Complete / Video_Play
  subject_id      uuid references subjects(subject_id) on delete set null,
  topic_id        uuid references topics(topic_id) on delete set null,
  career_id       uuid references careers(career_id) on delete set null,
  content_detail  varchar(100),
  time_spent_sec  int default 0,
  lang            char(2) not null default 'en',
  created_at      timestamptz not null default now()
);

-- ──────────────────────────────────────────
-- INDEXES
-- ──────────────────────────────────────────

create index idx_topics_subject      on topics(subject_id);
create index idx_topic_content_topic on topic_content(topic_id, lang);
create index idx_rwa_topic           on real_world_apps(topic_id);
create index idx_topic_careers_topic on topic_careers(topic_id);
create index idx_topic_careers_career on topic_careers(career_id);
create index idx_career_skills       on career_skills(career_id);
create index idx_quiz_subject        on quiz_questions(subject_id);
create index idx_bookmarks_user      on bookmarks(user_id);
create index idx_activity_user       on activity_logs(user_id);
create index idx_activity_type       on activity_logs(activity_type);
create index idx_cert_user           on certificates(user_id);

-- ──────────────────────────────────────────
-- MIGRATIONS (applied post initial schema)
-- ──────────────────────────────────────────

-- Add video support to topic_content and real_world_apps
ALTER TABLE topic_content ADD COLUMN IF NOT EXISTS video_url text;
ALTER TABLE real_world_apps ADD COLUMN IF NOT EXISTS video_url text;

-- Expert profession voices (many per topic, with optional video)
CREATE TABLE IF NOT EXISTS topic_profession_voices (
  id                  uuid primary key default gen_random_uuid(),
  topic_id            uuid not null references topics(topic_id) on delete cascade,
  profession_title    varchar(200) not null,
  profession_title_hi varchar(200),
  quote_text          text not null,
  quote_text_hi       text,
  subtopic_link       varchar(300),
  video_url           text,
  sort_order          int not null default 0,
  inserted_at         timestamptz not null default now()
);

CREATE INDEX IF NOT EXISTS idx_profession_voices_topic ON topic_profession_voices(topic_id);

-- Per-user subject selections for PAID_LIMITED plan users
CREATE TABLE IF NOT EXISTS user_subject_selections (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references users(user_id) on delete cascade,
  subject_id uuid not null references subjects(subject_id) on delete cascade,
  inserted_at timestamptz not null default now(),
  unique (user_id, subject_id)
);

CREATE INDEX IF NOT EXISTS idx_user_subject_sel_user ON user_subject_selections(user_id);
