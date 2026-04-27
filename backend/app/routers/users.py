from fastapi import APIRouter, Header, HTTPException
from typing import Optional
from pydantic import BaseModel
from app.database import supabase

router = APIRouter()

class PlanUpgradeRequest(BaseModel):
    plan_code: str                    # FREE_LIMITED | PAID_LIMITED | PAID_FULL
    subject_ids: list[str] = []       # only used for PAID_LIMITED

@router.get("/me/plan")
def get_my_plan(x_user_id: Optional[str] = Header(None)):
    if not x_user_id:
        raise HTTPException(status_code=401, detail="Not authenticated")

    plan_res = (
        supabase.table("user_plan")
        .select("plan_id, enrollment_plans(plan_code, plan_name)")
        .eq("user_id", x_user_id)
        .eq("is_current", True)
        .maybe_single()
        .execute()
    )

    plan_code = None
    if plan_res.data:
        plan_code = (plan_res.data.get("enrollment_plans") or {}).get("plan_code")

    # Get selected subjects (for PAID_LIMITED)
    sel_res = supabase.table("user_subject_selections").select("subject_id").eq("user_id", x_user_id).execute()
    selected_subject_ids = [r["subject_id"] for r in (sel_res.data or [])]

    return {"plan_code": plan_code, "selected_subject_ids": selected_subject_ids}


@router.post("/me/plan")
def upgrade_plan(body: PlanUpgradeRequest, x_user_id: Optional[str] = Header(None)):
    if not x_user_id:
        raise HTTPException(status_code=401, detail="Not authenticated")

    valid_codes = {"FREE_LIMITED", "PAID_LIMITED", "PAID_FULL"}
    if body.plan_code not in valid_codes:
        raise HTTPException(status_code=400, detail=f"Invalid plan_code. Must be one of {valid_codes}")

    # Look up the plan
    plan_res = supabase.table("enrollment_plans").select("plan_id").eq("plan_code", body.plan_code).maybe_single().execute()
    if not plan_res.data:
        raise HTTPException(status_code=404, detail=f"Plan '{body.plan_code}' not found in enrollment_plans table")
    plan_id = plan_res.data["plan_id"]

    # Mark all existing user_plan rows as not current
    supabase.table("user_plan").update({"is_current": False}).eq("user_id", x_user_id).execute()

    # Insert new current plan
    supabase.table("user_plan").insert({
        "user_id": x_user_id,
        "plan_id": plan_id,
        "is_current": True,
    }).execute()

    # Update subject selections
    supabase.table("user_subject_selections").delete().eq("user_id", x_user_id).execute()
    if body.plan_code == "PAID_LIMITED" and body.subject_ids:
        rows = [{"user_id": x_user_id, "subject_id": sid} for sid in body.subject_ids]
        supabase.table("user_subject_selections").insert(rows).execute()

    return {"ok": True, "plan_code": body.plan_code}
