from typing import List

from sqlalchemy import Column, ForeignKey, Integer, String, Table
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, intpk, str30, user_fk


class User(Base):
    __tablename__ = "user_account"

    id: Mapped[intpk] = mapped_column(init=False)
    name: Mapped[str30] = mapped_column(nullable=False)
    addresses: Mapped[List["Address"]] = relationship(
        back_populates="user", default_factory=list
    )


class Address(Base):
    __tablename__ = "address"

    id: Mapped[intpk] = mapped_column(init=False)
    email_address: Mapped[str]
    user_id: Mapped[user_fk] = mapped_column(ForeignKey("user_account.id"), init=False)
    user: Mapped["User"] = relationship(back_populates="addresses", default=None)
