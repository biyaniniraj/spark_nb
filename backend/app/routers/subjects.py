from fastapi import APIRouter, Header
from typing import Optional
from app.database import supabase
from app.models.subject import Subject

router = APIRouter()

def _get_plan_info(user_id: str):
    """Returns (plan_code, selected_subject_ids) for a user."""
    plan_res = (
        supabase.table("user_plan")
        .select("plan_id, enrollment_plans(plan_code)")
        .eq("user_id", user_id)
        .eq("is_current", True)
        .maybe_single()
        .execute()
    )
    if not plan_res.data:
        return None, set()

    plan_code = (plan_res.data.get("enrollment_plans") or {}).get("plan_code", "")

    sel_res = supabase.table("user_subject_selections").select("subject_id").eq("user_id", user_id).execute()
    selected = {r["subject_id"] for r in (sel_res.data or [])}

    return plan_code, selected


@router.get("/", response_model=list[Subject])
def list_subjects(x_user_id: Optional[str] = Header(None)):
    res = supabase.table("subjects").select("*").eq("is_active", True).order("sort_order").execute()
    subjects = res.data

    if not x_user_id:
        # Unauthenticated — only free preview subjects visible, rest locked
        for s in subjects:
            s["is_locked"] = not s["is_free_preview"]
        return subjects

    plan_code, selected_subject_ids = _get_plan_info(x_user_id)

    for s in subjects:
        if plan_code and plan_code.upper() == "PAID_FULL":
            s["is_locked"] = False
        elif plan_code and plan_code.upper() == "PAID_LIMITED":
            # is_free_preview subjects always accessible; others only if explicitly selected
            s["is_locked"] = not (s["is_free_preview"] or s["subject_id"] in selected_subject_ids)
        else:
            # FREE or no plan — only is_free_preview subjects
            s["is_locked"] = not s["is_free_preview"]

    return subjects


@router.get("/{subject_id}", response_model=Subject)
def get_subject(subject_id: str):
    res = supabase.table("subjects").select("*").eq("subject_id", subject_id).single().execute()
    return res.data
