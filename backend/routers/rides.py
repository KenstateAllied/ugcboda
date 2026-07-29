from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.security import get_current_user
from models.ride import Ride
from models.user import User

router = APIRouter(tags=["Rides"])


class RideCreate(BaseModel):
    vehicle_type: str = Field(min_length=1, max_length=100)
    vehicle_model: str = Field(min_length=1, max_length=100)
    vehicle_plate: str = Field(min_length=1, max_length=50)
    departure_location: str = Field(min_length=1, max_length=255)
    destination: str = Field(min_length=1, max_length=255)
    departure_time: datetime
    available_seats: int = Field(gt=0, le=20)
    price_per_seat: int = Field(ge=0)


def ride_to_dict(ride: Ride) -> dict:
    """Keep the API shape aligned with the Flutter Ride model."""
    return {
        "id": str(ride.id),
        "driver_name": f"{ride.driver.first_name} {ride.driver.last_name}".strip(),
        "driver_profile_image": ride.driver.profile_image or "",
        "vehicle_type": ride.vehicle_type,
        "vehicle_model": ride.vehicle_model,
        "vehicle_plate": ride.vehicle_plate,
        "available_seats": ride.available_seats,
        "departure_location": ride.departure_location,
        "destination": ride.destination,
        "departure_time": ride.departure_time.isoformat(),
        "price_per_seat": ride.price_per_seat,
        "passengers": [
            {
                "name": f"{passenger.first_name} {passenger.last_name}".strip(),
                "profile_image": passenger.profile_image or "",
                "departure_location": ride.departure_location,
            }
            for passenger in ride.passengers
        ],
    }


@router.get("")
def get_rides(
    destination: str = "",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    query = (
        db.query(Ride)
        .options(joinedload(Ride.driver), joinedload(Ride.passengers))
        .filter(Ride.available_seats > 0, Ride.driver_id != current_user.id)
    )
    if destination.strip():
        query = query.filter(Ride.destination.ilike(f"%{destination.strip()}%"))
    return [ride_to_dict(ride) for ride in query.order_by(Ride.departure_time).all()]


@router.get("/booked")
def get_booked_rides(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rides = (
        db.query(Ride)
        .join(Ride.passengers)
        .options(joinedload(Ride.driver), joinedload(Ride.passengers))
        .filter(User.id == current_user.id)
        .order_by(Ride.departure_time)
        .all()
    )
    return [ride_to_dict(ride) for ride in rides]


@router.post("/new-ride", status_code=status.HTTP_201_CREATED)
def create_ride(
    payload: RideCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # ``dict`` works with both Pydantic v1 and v2, which keeps this endpoint
    # compatible with the FastAPI versions used by the project.
    ride = Ride(driver_id=current_user.id, **payload.dict())
    db.add(ride)
    db.commit()
    db.refresh(ride)
    db.refresh(current_user)
    return ride_to_dict(ride)


@router.post("/{ride_id}/book", status_code=status.HTTP_200_OK)
def book_ride(
    ride_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    ride = (
        db.query(Ride)
        .options(joinedload(Ride.driver), joinedload(Ride.passengers))
        .filter(Ride.id == ride_id)
        .first()
    )
    if ride is None:
        raise HTTPException(status_code=404, detail="Ride not found")
    if ride.driver_id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot book your own ride")
    if any(passenger.id == current_user.id for passenger in ride.passengers):
        raise HTTPException(status_code=409, detail="Ride already booked")
    if ride.available_seats < 1:
        raise HTTPException(status_code=409, detail="No seats are available")

    ride.passengers.append(current_user)
    ride.available_seats -= 1
    db.commit()
    db.refresh(ride)
    return ride_to_dict(ride)
