from fastapi import APIRouter, Query, Header
from typing import Optional
from app.database import supabase
from app.models.topic import Topic, TopicContent, RealWorldApp, Expert

router = APIRouter()

def _get_allowed_topic_ids(user_id: str, subject_id: str) -> Optional[set]:
    """
    Returns a set of allowed topic_ids for this user+subject, or None if all are allowed.
    Returns an empty set if the subject is fully locked.
    """
    # Get user's current plan
    plan_res = supabase.table("user_plan").select("plan_id").eq("user_id", user_id).eq("is_current", True).maybe_single().execute()
    if not plan_res.data:
        return set()  # no plan = lock everything

    plan_id = plan_res.data["plan_id"]

    # Check if subject itself is free_preview (always accessible)
    subj_res = supabase.table("subjects").select("is_free_preview").eq("subject_id", subject_id).single().execute()
    if subj_res.data and subj_res.data["is_free_preview"]:
        return None  # all topics accessible

    # Get all rules for this plan
    rules_res = supabase.table("plan_access_rules").select("subject_id, topic_id, is_allowed").eq("plan_id", plan_id).execute()
    rules = rules_res.data or []

    # Rule with null subject_id AND null topic_id = global full access
    if any(r["subject_id"] is None and r["topic_id"] is None and r.get("is_allowed") for r in rules):
        return None

    # Rule with this subject_id AND null topic_id = all topics in this subject allowed
    if any(r["subject_id"] == subject_id and r["topic_id"] is None and r.get("is_allowed") for r in rules):
        return None

    # Collect specific allowed topic_ids for this subject
    allowed = {r["topic_id"] for r in rules if r["subject_id"] == subject_id and r["topic_id"] is not None and r.get("is_allowed")}
    return allowed

@router.get("/", response_model=list[Topic])
def list_topics(subject_id: str = Query(...), grade: str = Query(None), x_user_id: Optional[str] = Header(None)):
    q = supabase.table("topics").select("*").eq("subject_id", subject_id).eq("is_active", True)
    if grade:
        q = q.eq("grade", grade)
    res = q.order("sort_order").execute()
    topics = res.data

    # Trim char(2) padding from grade field
    for t in topics:
        if t.get("grade"):
            t["grade"] = t["grade"].strip()

    # Attach simply_put_title from topic_content (en) for the preview subtitle
    topic_ids = [t["topic_id"] for t in topics]
    if topic_ids:
        content_res = supabase.table("topic_content").select("topic_id, title").eq("lang", "en").in_("topic_id", topic_ids).execute()
        title_map = {c["topic_id"]: c["title"] for c in (content_res.data or [])}
        for t in topics:
            t["simply_put_title"] = title_map.get(t["topic_id"])

    if not x_user_id:
        # No user — lock everything except free preview subjects
        subj_res = supabase.table("subjects").select("is_free_preview").eq("subject_id", subject_id).single().execute()
        is_free = subj_res.data and subj_res.data["is_free_preview"]
        for t in topics:
            t["is_locked"] = not is_free
        return topics

    allowed_ids = _get_allowed_topic_ids(x_user_id, subject_id)
    for t in topics:
        t["is_locked"] = False if allowed_ids is None else (t["topic_id"] not in allowed_ids)
    return topics

@router.get("/{topic_id}", response_model=Topic)
def get_topic(topic_id: str):
    res = supabase.table("topics").select("*").eq("topic_id", topic_id).single().execute()
    return res.data

@router.get("/{topic_id}/content", response_model=list[TopicContent])
def get_topic_content(topic_id: str):
    res = supabase.table("topic_content").select("*").eq("topic_id", topic_id).execute()
    return res.data

@router.get("/{topic_id}/apps", response_model=list[RealWorldApp])
def get_topic_apps(topic_id: str):
    res = supabase.table("real_world_apps").select("*").eq("topic_id", topic_id).order("sort_order").execute()
    return res.data

@router.get("/{topic_id}/expert", response_model=Expert)
def get_topic_expert(topic_id: str):
    res = supabase.table("experts").select("*").eq("topic_id", topic_id).single().execute()
    return res.data
