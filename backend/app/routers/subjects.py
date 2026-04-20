from fastapi import APIRouter, Header
from typing import Optional
from app.database import supabase
from app.models.subject import Subject

router = APIRouter()

@router.get("/", response_model=list[Subject])
def list_subjects(x_user_id: Optional[str] = Header(None)):
    res = supabase.table("subjects").select("*").eq("is_active", True).order("sort_order").execute()
    subjects = res.data

    # Determine allowed subject_ids for this user
    allowed_subject_ids = None  # None = all allowed

    if x_user_id:
        plan_res = supabase.table("user_plan").select("plan_id").eq("user_id", x_user_id).eq("is_current", True).maybe_single().execute()
        if plan_res.data:
            plan_id = plan_res.data["plan_id"]
            rules_res = supabase.table("plan_access_rules").select("subject_id, is_allowed").eq("plan_id", plan_id).execute()
            rules = rules_res.data or []
            # Null subject_id in a rule = full access to all subjects
            if any(r["subject_id"] is None and r.get("is_allowed") for r in rules):
                allowed_subject_ids = None  # full access
            else:
                allowed_subject_ids = {r["subject_id"] for r in rules if r["subject_id"] is not None and r.get("is_allowed")}
        else:
            allowed_subject_ids = set()  # no plan = lock all non-free subjects

    for s in subjects:
        if s["is_free_preview"]:
            s["is_locked"] = False
        elif allowed_subject_ids is None:
            s["is_locked"] = False
        else:
            s["is_locked"] = s["subject_id"] not in allowed_subject_ids

    return subjects

@router.get("/{subject_id}", response_model=Subject)
def get_subject(subject_id: str):
    res = supabase.table("subjects").select("*").eq("subject_id", subject_id).single().execute()
    return res.data
