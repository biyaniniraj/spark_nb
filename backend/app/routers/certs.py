from fastapi import APIRouter, Header
from app.database import supabase
from app.models.cert import Certificate

router = APIRouter()

@router.get("/", response_model=list[Certificate])
def my_certs(x_user_id: str = Header(...)):
    res = (
        supabase.table("certificates")
        .select("*")
        .eq("user_id", x_user_id)
        .order("issued_at", desc=True)
        .execute()
    )
    return res.data
