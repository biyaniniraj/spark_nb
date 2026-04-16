from pydantic import BaseModel
from typing import Optional

class Subject(BaseModel):
    subject_id: str
    name: str
    name_hi: Optional[str]
    icon: Optional[str]
    color_hex: Optional[str]
    board_alignment: Optional[str]
    is_free_preview: bool
    sort_order: int
    is_active: bool
