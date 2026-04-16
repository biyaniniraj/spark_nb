from fastapi import APIRouter
from app.database import supabase
from app.models.subject import Subject

router = APIRouter()

@router.get("/", response_model=list[Subject])
def list_subjects():
    res = supabase.table("subjects").select("*").eq("is_active", True).order("sort_order").execute()
    return res.data

@router.get("/{subject_id}", response_model=Subject)
def get_subject(subject_id: str):
    res = supabase.table("subjects").select("*").eq("subject_id", subject_id).single().execute()
    return res.data
