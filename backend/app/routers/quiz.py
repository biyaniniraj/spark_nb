from fastapi import APIRouter, Header, HTTPException
from app.database import supabase
from app.models.quiz import QuizQuestion, QuizOption, QuizSubmission, QuizResult

router = APIRouter()

@router.get("/{subject_id}/questions", response_model=list[QuizQuestion])
def get_questions(subject_id: str):
    res = (
        supabase.table("quiz_questions")
        .select("*")
        .eq("subject_id", subject_id)
        .eq("is_active", True)
        .order("sort_order")
        .execute()
    )
    return res.data

@router.get("/options/{question_id}", response_model=list[QuizOption])
def get_options(question_id: str):
    res = (
        supabase.table("quiz_options")
        .select("*")
        .eq("question_id", question_id)
        .order("option_index")
        .execute()
    )
    return res.data

@router.post("/{subject_id}/submit", response_model=QuizResult)
def submit_quiz(subject_id: str, submission: QuizSubmission, x_user_id: str = Header(...)):
    questions = (
        supabase.table("quiz_questions")
        .select("question_id, correct_option_index, feedback_text")
        .eq("subject_id", subject_id)
        .eq("is_active", True)
        .order("sort_order")
        .execute()
    ).data

    if len(submission.answers) != len(questions):
        raise HTTPException(status_code=400, detail="Answer count does not match question count")

    correct_indexes = [q["correct_option_index"] for q in questions]
    feedback = [q["feedback_text"] or "" for q in questions]
    score = sum(a == c for a, c in zip(submission.answers, correct_indexes))
    passed = score / len(questions) >= 0.7

    # Record attempt
    attempt = supabase.table("cert_attempts").insert({
        "user_id": x_user_id,
        "subject_id": subject_id,
        "score": score,
        "passed": passed,
    }).execute().data[0]

    # Issue certificate if passed
    if passed:
        supabase.table("certificates").insert({
            "attempt_id": attempt["attempt_id"],
            "user_id": x_user_id,
            "subject_id": subject_id,
            "score": score,
        }).execute()

    return QuizResult(
        score=score,
        total=len(questions),
        passed=passed,
        correct_indexes=correct_indexes,
        feedback=feedback,
    )
