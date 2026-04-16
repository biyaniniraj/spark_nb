from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import subjects, topics, careers, quiz, certs, bookmarks

app = FastAPI(title="Spark API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(subjects.router,  prefix="/api/subjects",  tags=["subjects"])
app.include_router(topics.router,    prefix="/api/topics",    tags=["topics"])
app.include_router(careers.router,   prefix="/api/careers",   tags=["careers"])
app.include_router(quiz.router,      prefix="/api/quiz",      tags=["quiz"])
app.include_router(certs.router,     prefix="/api/certs",     tags=["certs"])
app.include_router(bookmarks.router, prefix="/api/bookmarks", tags=["bookmarks"])

@app.get("/health")
def health():
    return {"status": "ok"}
