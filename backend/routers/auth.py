from pathlib import Path
import shutil

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    UploadFile,
    status,
)
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.database import get_db
from app.security import (
    hash_password,
    verify_password,
    create_access_token,
)
from models.user import User

router = APIRouter(tags=["Authentication"])

# Create uploads directory if it doesn't exist
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post("/signup", status_code=status.HTTP_201_CREATED)
async def signup(
    first_name: str = Form(...),
        last_name: str = Form(...),

   
    username: str = Form(...),
 
    mobile_number: str = Form(...),
    gender: str = Form(...),
    email: str = Form(...),

    password: str = Form(...),
    profile_image: UploadFile | None = File(None),
    db: Session = Depends(get_db),
):
    # Check duplicate email
    existing_email = (
        db.query(User)
        .filter(User.email == email)
        .first()
    )

    if existing_email:
        raise HTTPException(
            status_code=400,
            detail="Email already exists",
        )

    # Check duplicate username
    existing_username = (
        db.query(User)
        .filter(User.username == username)
        .first()
    )

    if existing_username:
        raise HTTPException(
            status_code=400,
            detail="Username already exists",
        )

    image_path = None

    # Save uploaded image
    if profile_image is not None:
        filename = profile_image.filename
        destination = UPLOAD_DIR / filename

        with destination.open("wb") as buffer:
            shutil.copyfileobj(profile_image.file, buffer)

        image_path = str(destination)

    # Create user
    new_user = User(
        first_name=first_name,
        last_name=last_name,
        username=username,
        mobile_number=mobile_number,
        gender=gender,
        email=email,
        password=hash_password(password),
        profile_image=image_path,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "Account created successfully",
        "user_id": new_user.id,
    }


@router.post("/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    user = (
        db.query(User)
        .filter(User.username == form_data.username)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password",
        )

    if not verify_password(form_data.password, user.password):
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password",
        )

    access_token = create_access_token(
        {
            "sub": user.username,
            "user_id": user.id,
        }
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }


@router.get("/users")
def get_users(db: Session = Depends(get_db)):
    users = db.query(User).all()

    return users


@router.get("/users/{user_id}")
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
):
    user = (
        db.query(User)
        .filter(User.id == user_id)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    return user