from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Table
from sqlalchemy.orm import relationship

from app.database import Base


ride_passengers = Table(
    "ride_passengers",
    Base.metadata,
    Column("ride_id", Integer, ForeignKey("rides.id"), primary_key=True),
    Column("user_id", Integer, ForeignKey("users.id"), primary_key=True),
)


class Ride(Base):
    __tablename__ = "rides"

    id = Column(Integer, primary_key=True, index=True)
    driver_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    vehicle_type = Column(String(100), nullable=False)
    vehicle_model = Column(String(100), nullable=False)
    vehicle_plate = Column(String(50), nullable=False)
    departure_location = Column(String(255), nullable=False)
    destination = Column(String(255), nullable=False, index=True)
    departure_time = Column(DateTime, nullable=False)
    available_seats = Column(Integer, nullable=False)
    price_per_seat = Column(Integer, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    driver = relationship("User", back_populates="rides_offered")
    passengers = relationship(
        "User",
        secondary=ride_passengers,
        back_populates="booked_rides",
    )
