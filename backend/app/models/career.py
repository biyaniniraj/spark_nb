from pydantic import BaseModel
from typing import Optional

class Career(BaseModel):
    career_id: str
    icon: Optional[str]
    bg_color: Optional[str]
    name: str
    name_hi: Optional[str]
    task: Optional[str]
    task_hi: Optional[str]
    description: Optional[str]
    description_hi: Optional[str]
    is_active: bool

class CareerSkill(BaseModel):
    id: str
    career_id: str
    skill: str

class ExpertVideo(BaseModel):
    id: str
    career_id: str
    expert_name: str
    expert_role: str
    quote: Optional[str]
    video_url: Optional[str]
