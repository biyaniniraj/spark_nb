---
name: verify-access-rules
description: Verify plan-based access control implementation in Spark (database rules, backend enforcement, frontend guards)
---

# Access Rules Verification for Spark

Perform a comprehensive audit of the plan-based access control system in the Spark educational platform.

## Overview

Spark uses a 3-tier plan system (FREE_LIMITED, PAID_LIMITED, PAID_FULL) with content access controlled via `plan_access_rules` table. Subjects can also be marked as `is_free_preview` to bypass restrictions.

## Verification Steps

### 1. Database Integrity Check

Read and analyze the database schema and rules:

**a) Check `plan_access_rules` table:**
- Query for orphaned records (subject_id/topic_id that don't exist)
- Find conflicting rules (same plan + subject + topic with different is_allowed)
- Verify all active plans have at least one rule defined

**b) Check `subjects` table:**
- List subjects with `is_free_preview = true`
- Identify subjects with no access rules AND not marked as free preview (access undefined)

**c) Check `enrollment_plans` table:**
- Verify all 3 plan codes exist (FREE_LIMITED, PAID_LIMITED, PAID_FULL)
- Check for any users without a current plan (user_plan.is_current = true)

**Report findings:** List any orphaned rules, conflicts, or undefined access.

### 2. Backend Router Implementation Audit

Read all router files and check for access control enforcement:

**Files to inspect:**
- `backend/app/routers/subjects.py`
- `backend/app/routers/topics.py`
- `backend/app/routers/careers.py` (if topics have career links)
- `backend/app/routers/bookmarks.py` (can users bookmark restricted content?)

**For each router, verify:**

**a) User Authentication:**
- Is user_id extracted from request (token/session)?
- Are endpoints protected (require authentication)?

**b) Plan Retrieval:**
- Does the code fetch user's current plan from `user_plan` table?
- Pattern to look for: 
  ```python
  .table("user_plan")
  .select("plan_id")
  .eq("user_id", user_id)
  .eq("is_current", True)
  ```

**c) Access Rules Enforcement:**
- Does the code check `plan_access_rules` before returning content?
- Pattern to look for:
  ```python
  .table("plan_access_rules")
  .select("*")
  .eq("plan_id", plan_id)
  ```

**d) Free Preview Handling:**
- Does the code allow `is_free_preview = true` subjects for all plans?
- Is this check done BEFORE or AFTER plan rules?

**e) Response Filtering:**
- Are results filtered based on access rules?
- Or does it return all data (security issue)?

**Report findings:** For each router, state:
- ✅ "Properly enforces access control" with code reference
- ⚠️ "Missing access control checks" with file:line
- ❌ "Returns unfiltered data" with file:line

### 3. Frontend Protection Audit

Check if the UI respects access restrictions:

**Files to inspect:**
- `frontend/src/router/index.js` (route guards)
- `frontend/src/stores/auth.js` (user plan storage)
- `frontend/src/pages/SubjectsPage.vue` (subject listing)
- `frontend/src/pages/TopicsPage.vue` (topic listing)
- `frontend/src/components/` (any subject/topic cards)

**Verify:**

**a) Plan Storage:**
- Does auth store include user's plan information?
- Is it fetched during login/session init?

**b) UI Rendering:**
- Does the UI hide/disable inaccessible content?
- Or does it show everything and rely on backend to block?
- Check for conditional rendering: `v-if="canAccess(subject)"` or similar

**c) API Calls:**
- When fetching subjects/topics, does frontend send plan info?
- Or does it rely on backend to filter based on authenticated user?

**d) Client-Side Validation:**
- Are there checks before navigating to restricted content?
- Pattern: checking plan in route guards or component beforeRouteEnter

**Report findings:**
- Note if frontend has client-side access checks (good UX, but backend is source of truth)
- Flag if frontend makes no attempt to respect access (confusing UX)

### 4. Business Logic Verification

Analyze the actual access control logic:

**a) Identify Access Check Function:**
- Look for a centralized function/service that determines access
- Common locations:
  - `backend/app/services/access_control.py`
  - Helper function in `backend/app/database.py`
  - Inline in each router (less ideal)

**b) Verify Logic Correctness:**

The expected logic should be:
```
1. If subject.is_free_preview == true → ALLOW (all plans)
2. If user has no plan → DENY (or default to FREE)
3. Check plan_access_rules for (user_plan, subject, topic)
   - Exact match (plan + subject + topic) takes precedence
   - Subject-level match (plan + subject + NULL topic) is fallback
   - Plan-level match (plan + NULL subject + NULL topic) is default
4. If no rule found → DENY (secure by default) or ALLOW (open by default)?
```

**c) Check Rule Hierarchy:**
- Does the code correctly handle NULL subject/topic (wildcard rules)?
- Which rule wins if there are multiple matches?

**Report findings:**
- Document the actual logic flow found in code
- Flag any deviations from expected secure behavior
- Note if there's no centralized access control (scattered logic = maintenance risk)

### 5. Security Gaps & Recommendations

After completing steps 1-4, provide:

**Summary of Findings:**
- ✅ What's correctly implemented
- ⚠️ What's partially implemented (e.g., backend enforces but frontend doesn't)
- ❌ What's missing or insecure

**Security Risks:**
- Can users access restricted content by guessing URLs?
- Can API endpoints be called directly to bypass checks?
- Are there race conditions (e.g., plan expires mid-session)?

**Recommendations:**
1. Prioritized list of issues to fix (file:line references)
2. Suggested code changes for critical gaps
3. Architectural improvements if logic is scattered

**Testing Suggestions:**
- Specific curl commands to test API endpoints
- User scenarios to manually test (e.g., "Create FREE user, try to access paid topic")
- Automated test cases to add

## Output Format

Provide a structured report:

```
# Access Control Verification Report

## 1. Database Integrity
[Findings...]

## 2. Backend Enforcement
### subjects.py
[Analysis...]

### topics.py
[Analysis...]

[etc...]

## 3. Frontend Protection
[Findings...]

## 4. Business Logic Analysis
[Centralized or scattered?]
[Logic flow diagram/description]
[Correctness assessment]

## 5. Summary
✅ Strengths: [...]
⚠️ Partial: [...]
❌ Critical Gaps: [...]

## 6. Recommended Actions
1. [Priority 1 - Security Critical]
2. [Priority 2 - UX/Consistency]
3. [Priority 3 - Enhancement]

## 7. Test Commands
```bash
# Test cases to verify fixes
[...]
```
```

## Important Notes

- **Read code, don't assume:** Actually open and read router files, don't guess implementation
- **Source of truth:** Backend is the security boundary; frontend checks are UX only
- **Be specific:** Always provide file:line references for issues found
- **Suggest fixes:** Include code snippets for how to implement missing checks
- **Consider performance:** Flag if access checks cause N+1 queries or other inefficiencies
