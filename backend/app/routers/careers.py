from fastapi import APIRouter
from app.database import supabase
from app.models.career import Career, CareerSkill, ExpertVideo

router = APIRouter()

@router.get("/by-topic/{topic_id}", response_model=list[Career])
def careers_by_topic(topic_id: str):
    # Join through topic_careers junction table
    res = (
        supabase.table("topic_careers")
        .select("careers(*)")
        .eq("topic_id", topic_id)
        .order("sort_order")
        .execute()
    )
    return [row["careers"] for row in res.data]

@router.get("/{career_id}", response_model=Career)
def get_career(career_id: str):
    res = supabase.table("careers").select("*").eq("career_id", career_id).single().execute()
    return res.data

@router.get("/{career_id}/skills", response_model=list[CareerSkill])
def get_career_skills(career_id: str):
    res = supabase.table("career_skills").select("*").eq("career_id", career_id).execute()
    return res.data

@router.get("/{career_id}/video", response_model=ExpertVideo)
def get_expert_video(career_id: str):
    res = supabase.table("expert_videos").select("*").eq("career_id", career_id).single().execute()
    return res.data
