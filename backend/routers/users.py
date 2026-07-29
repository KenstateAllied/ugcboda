from pathlib import Path
import shutil, json

from fastapi import APIRouter, Depends, Form, File, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db
from app.security import get_current_user
from models.user import User

router = APIRouter(tags=["Users"])

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


class UserProfileOut(BaseModel):
    id: int
    first_name: str
    last_name: str
    username: str
    email: str
    mobile_number: str
    home_address: str | None = None
    work_address: str | None = None
    facebook_handle: str | None = None
    instagram_handle: str | None = None
    twitter_handle: str | None = None
    bio: str | None = None
    profile_image: str | None = None
    date_joined: str

    class Config:
        from_attributes = True


def profile_response(user: User) -> dict:
    """Return the field names and value types expected by the Flutter app."""
    return {
        "id": user.id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "username": user.username,
        "email": user.email,
        "mobile_number": user.mobile_number,
        "home_address": getattr(user, "home_address", None),
        "work_address": getattr(user, "work_address", None),
        "facebook_handle": getattr(user, "facebook_handle", None),
        "instagram_handle": getattr(user, "instagram_handle", None),
        "twitter_handle": getattr(user, "twitter_handle", None),
        "bio": getattr(user, "bio", None),
        "profile_image": user.profile_image,
        "date_joined": user.created_at.isoformat() if user.created_at else "",
    }


@router.get("/profile", response_model=UserProfileOut)
def profile(current_user: User = Depends(get_current_user)):
    return profile_response(current_user)


@router.put("/profile/edit", response_model=UserProfileOut)
async def edit_profile(
    profile_data: str = Form(...),
    profile_pic: UploadFile | None = File(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    data = json.loads(profile_data)

    for field in [
        "username", "mobile_number", "home_address", "work_address",
        "facebook_handle", "instagram_handle", "twitter_handle", "bio",
    ]:
        if field in data and data[field] is not None:
            setattr(current_user, field, data[field])

    if profile_pic is not None:
        destination = UPLOAD_DIR / profile_pic.filename
        with destination.open("wb") as buffer:
            shutil.copyfileobj(profile_pic.file, buffer)
        current_user.profile_image = str(destination)

    db.commit()
    db.refresh(current_user)
    return profile_response(current_user)
