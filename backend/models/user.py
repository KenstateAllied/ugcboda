from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)

    username = Column(String(100), unique=True, index=True, nullable=False)

    email = Column(String(255), unique=True, index=True, nullable=False)

    mobile_number = Column(String(30), nullable=False)

    gender = Column(String(20), nullable=False)

    password = Column(String(255), nullable=False)

    profile_image = Column(String(255), nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    rides_offered = relationship("Ride", back_populates="driver")
    booked_rides = relationship(
        "Ride",
        secondary="ride_passengers",
        back_populates="passengers",
    )
