from fastapi import APIRouter, Query
from app.database import supabase
from app.models.topic import Topic, TopicContent, RealWorldApp, Expert

router = APIRouter()

@router.get("/", response_model=list[Topic])
def list_topics(subject_id: str = Query(...), grade: str = Query(None)):
    q = supabase.table("topics").select("*").eq("subject_id", subject_id).eq("is_active", True)
    if grade:
        q = q.eq("grade", grade)
    res = q.order("sort_order").execute()
    return res.data

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
