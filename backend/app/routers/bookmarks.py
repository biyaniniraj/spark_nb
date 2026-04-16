from fastapi import APIRouter, Header
from pydantic import BaseModel
from app.database import supabase

router = APIRouter()

class BookmarkIn(BaseModel):
    topic_id: str

@router.get("/")
def get_bookmarks(x_user_id: str = Header(...)):
    res = (
        supabase.table("bookmarks")
        .select("*, topics(topic_id, name, name_hi, subject_id)")
        .eq("user_id", x_user_id)
        .order("created_at", desc=True)
        .execute()
    )
    return res.data

@router.post("/")
def add_bookmark(body: BookmarkIn, x_user_id: str = Header(...)):
    res = supabase.table("bookmarks").upsert({
        "user_id": x_user_id,
        "topic_id": body.topic_id,
    }).execute()
    return res.data[0]

@router.delete("/{topic_id}")
def remove_bookmark(topic_id: str, x_user_id: str = Header(...)):
    supabase.table("bookmarks").delete().eq("user_id", x_user_id).eq("topic_id", topic_id).execute()
    return {"ok": True}
