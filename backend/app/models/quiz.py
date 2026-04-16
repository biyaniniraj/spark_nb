from pydantic import BaseModel
from typing import Optional

class QuizQuestion(BaseModel):
    question_id: str
    subject_id: str
    question_text: str
    correct_option_index: int
    feedback_text: Optional[str]
    difficulty: Optional[str]
    sort_order: int

class QuizOption(BaseModel):
    option_id: str
    question_id: str
    option_index: int
    option_text: str

class QuizSubmission(BaseModel):
    subject_id: str
    answers: list[int]      # list of selected option indexes, one per question

class QuizResult(BaseModel):
    score: int
    total: int
    passed: bool
    correct_indexes: list[int]
    feedback: list[str]
