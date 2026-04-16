from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CertAttempt(BaseModel):
    attempt_id: str
    user_id: str
    subject_id: str
    score: int
    passed: bool
    attempted_at: datetime

class Certificate(BaseModel):
    cert_id: str
    attempt_id: str
    user_id: str
    subject_id: str
    score: int
    issued_at: datetime
