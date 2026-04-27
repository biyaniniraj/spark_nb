from pydantic import BaseModel
from typing import Optional

class Topic(BaseModel):
    topic_id: str
    subject_id: str
    name: str
    name_hi: Optional[str]
    grade: str          # '9', '10', or 'All'
    sort_order: int
    is_active: bool
    is_locked: bool = False
    simply_put_title: Optional[str] = None

class TopicContent(BaseModel):
    topic_id: str
    lang: str           # 'en' or 'hi'
    title: str
    body: str
    version: int
    video_url: Optional[str] = None

class RealWorldApp(BaseModel):
    id: str
    topic_id: str
    icon: Optional[str]
    bg_color: Optional[str]
    title: str
    title_hi: Optional[str]
    description: str
    description_hi: Optional[str]
    sort_order: int
    video_url: Optional[str] = None

class Expert(BaseModel):
    expert_id: str
    topic_id: str
    name: str
    role: str
    initials: str

class ProfessionVoice(BaseModel):
    id: str
    topic_id: str
    profession_title: str
    profession_title_hi: Optional[str] = None
    quote_text: str
    quote_text_hi: Optional[str] = None
    subtopic_link: Optional[str] = None
    video_url: Optional[str] = None
    sort_order: int
