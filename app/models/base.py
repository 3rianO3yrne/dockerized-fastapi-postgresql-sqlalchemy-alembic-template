import pydantic
from pydantic.dataclasses import dataclass
from sqlalchemy import Column, ForeignKey, Integer, String, Table
from sqlalchemy.orm import DeclarativeBase, Mapped, MappedAsDataclass, mapped_column
from typing_extensions import Annotated


class Base(
    MappedAsDataclass,
    DeclarativeBase,
    dataclass_callable=pydantic.dataclasses.dataclass,
):
    pass


intpk = Annotated[int, mapped_column(Integer, primary_key=True)]
str30 = Annotated[str, mapped_column(String(30))]
user_fk = Annotated[int, mapped_column(ForeignKey("user_account.id"))]
