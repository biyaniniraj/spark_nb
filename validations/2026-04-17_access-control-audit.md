# Access Control Verification Report
**Date:** 2026-04-17  
**Audited by:** verify-access-rules skill

---

## 1. Database Integrity

**`plan_access_rules` table:**
- ✅ FK constraints with `ON DELETE CASCADE` prevent orphaned `subject_id`/`topic_id` records
- ❌ **No `UNIQUE(plan_id, subject_id, topic_id)` constraint** — conflicting rules (same plan + subject + topic with opposite `is_allowed` values) can exist silently with no DB-level rejection
- ⚠️ Cannot verify whether any rules are actually seeded without querying live data

**`subjects` table:**
- ✅ `is_free_preview boolean not null default false` column exists
- ⚠️ Cannot verify which subjects (if any) have `is_free_preview = true` without live data

**`enrollment_plans` table:**
- ⚠️ `plan_code` is `varchar(50) unique not null` — no `CHECK` constraint enforcing only the 3 valid codes (`FREE_LIMITED`, `PAID_LIMITED`, `PAID_FULL`)
- ⚠️ Cannot verify all 3 plan rows are seeded without querying live data
- ⚠️ No constraint ensures every user has a `user_plan` with `is_current = true`

---

## 2. Backend Enforcement

### subjects.py
- ❌ `GET /subjects/` — no authentication, no plan lookup, returns ALL active subjects to any caller
- ❌ `GET /subjects/{id}` — no authentication, returns any subject to any caller

### topics.py
- ❌ `GET /topics/` — no authentication, no plan check, returns all topics for a subject
- ❌ `GET /topics/{id}` — no authentication
- ❌ `GET /topics/{id}/content` — no authentication, full content exposed
- ❌ `GET /topics/{id}/apps` — no authentication
- ❌ `GET /topics/{id}/expert` — no authentication

### careers.py
- ❌ `GET /careers/by-topic/{id}` — no authentication, no plan check
- ❌ `GET /careers/{id}` and sub-routes — no authentication

### bookmarks.py
- ⚠️ Uses `x_user_id: str = Header(...)` — **this is a client-supplied HTTP header, not a verified JWT token.** Any caller can set `X-User-ID` to any UUID and impersonate any user. This is a **critical spoofing vulnerability**.
- ❌ No check that the topic being bookmarked is accessible to the user's plan
- ❌ No check that `x_user_id` matches a real user in the `users` table

### services/
- ❌ `backend/app/services/` directory is **empty** — there is no centralized access control service. The `plan_access_rules` table is **never queried anywhere** in the codebase.

---

## 3. Frontend Protection

### router/index.js
- ✅ All non-landing routes have `meta: { requiresAuth: true }` — unauthenticated users are redirected to `/auth`
- ✅ Teacher-only routes (`/teacher`, `/certify`, `/certs`, `/quiz/:id`) are guarded by `meta: { role: 'Teacher' }`
- ❌ **No plan-based route guards exist** — no check on whether a user's plan allows access to a subject/topic before navigating

### stores/auth.js
- ❌ **No plan information is fetched or stored** — `init()` and `signIn()` only store `user` and `role` from Supabase Auth metadata. The `user_plan` table is never queried.
- ❌ No `canAccess(subjectId)` or similar helper anywhere

### SubjectsPage.vue
- ❌ Calls `api.get('/subjects')` and renders every result with no access filtering
- ❌ No conditional rendering based on plan (no `v-if="canAccess(s)"`)

### TopicsPage.vue
- ❌ Calls `api.get('/topics?subject_id=${id}')` and renders every result
- ❌ No plan check before navigation or rendering

---

## 4. Business Logic Analysis

**Centralized or scattered?** Neither — **access control logic does not exist at all.** The `plan_access_rules` table is schema-only; it is never read by any router, service, or frontend component.

**Expected logic vs. actual:**

| Step | Expected | Actual |
|------|----------|--------|
| Authenticate request | Verify JWT, extract `user_id` | Not done (except bookmarks, which uses a spoofable header) |
| Fetch user plan | Query `user_plan` table | Never done |
| Check `is_free_preview` | Allow if true, skip plan check | Never done |
| Consult `plan_access_rules` | Evaluate rule hierarchy | Never done |
| Default deny | Block if no rule found | N/A — everything is open |

---

## 5. Summary

✅ **Strengths:**
- DB schema is correctly designed — FKs, nullable wildcards in `plan_access_rules`, `is_free_preview` flag, and `user_plan.is_current` are all correct architectural choices
- Frontend router correctly gates by authentication and teacher role

⚠️ **Partial:**
- Frontend authentication guard works but has no plan dimension
- Bookmarks router attempts user identification but via a spoofable header, not JWT

❌ **Critical Gaps:**
1. **All content APIs are fully public** — no authentication or authorization on `/subjects`, `/topics`, `/careers`
2. **`plan_access_rules` table is never consulted** — plan-gating is completely inoperative
3. **`bookmarks.py` identity is spoofable** — `X-User-ID` header has no cryptographic backing
4. **Auth store has no plan state** — frontend has no data to even render access indicators

---

## 6. Recommended Actions

**Priority 1 — Security Critical**

Add a JWT-based dependency to all routers (`backend/app/routers/subjects.py` line 6):
```python
from fastapi import Depends, HTTPException
from app.auth import get_current_user  # create this

@router.get("/", response_model=list[Subject])
def list_subjects(user=Depends(get_current_user)):
    # 1. Fetch user's current plan
    plan = supabase.table("user_plan").select("plan_id").eq("user_id", user.id).eq("is_current", True).single().execute()
    # 2. Fetch allowed subject_ids for this plan
    rules = supabase.table("plan_access_rules").select("subject_id").eq("plan_id", plan.data["plan_id"]).eq("is_allowed", True).execute()
    allowed_ids = [r["subject_id"] for r in rules.data if r["subject_id"]]
    # 3. Also include free_preview subjects
    res = supabase.table("subjects").select("*").eq("is_active", True).execute()
    return [s for s in res.data if s["is_free_preview"] or s["subject_id"] in allowed_ids]
```

Create `backend/app/auth.py` to verify Supabase JWTs — replace `X-User-ID` header with token verification:
```python
from fastapi import Header, HTTPException
from app.database import supabase

async def get_current_user(authorization: str = Header(...)):
    token = authorization.removeprefix("Bearer ")
    res = supabase.auth.get_user(token)
    if not res.user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return res.user
```

Add a `UNIQUE` constraint to prevent conflicting rules (`database/schema.sql`):
```sql
ALTER TABLE plan_access_rules
  ADD CONSTRAINT uq_plan_access UNIQUE (plan_id, subject_id, topic_id);
```

**Priority 2 — UX/Consistency**

In `frontend/src/stores/auth.js`, fetch and store the user's plan during `init()`:
```js
const plan = ref(null)
// inside init():
const { data } = await supabase.from('user_plan').select('plan_id, enrollment_plans(plan_code)').eq('user_id', data.user.id).eq('is_current', true).single()
plan.value = data?.enrollment_plans?.plan_code
```

Then use it in `SubjectsPage.vue` to show lock indicators on inaccessible subjects (frontend is UX only; backend is the security boundary).

**Priority 3 — Schema Hardening**

Add a `CHECK` constraint on plan codes:
```sql
ALTER TABLE enrollment_plans
  ADD CONSTRAINT chk_plan_code CHECK (plan_code IN ('FREE_LIMITED','PAID_LIMITED','PAID_FULL'));
```

---

## 7. Test Commands

```bash
# 1. Verify content is currently open (should return data without any auth)
curl http://localhost:8000/api/subjects
curl http://localhost:8000/api/topics?subject_id=<any-uuid>

# 2. Verify bookmark spoofing vulnerability (should fail after fix)
curl -X POST http://localhost:8000/api/bookmarks \
  -H "X-User-ID: 00000000-0000-0000-0000-000000000000" \
  -H "Content-Type: application/json" \
  -d '{"topic_id": "<any-uuid>"}'

# 3. After fixes — test that unauthenticated request is rejected
curl http://localhost:8000/api/subjects
# Expected: 401 Unauthorized

# 4. After fixes — test FREE plan cannot access PAID subjects
# Create a FREE_LIMITED user, get JWT, and call:
curl http://localhost:8000/api/subjects \
  -H "Authorization: Bearer <free-user-jwt>"
# Expected: only free_preview=true subjects returned
```
