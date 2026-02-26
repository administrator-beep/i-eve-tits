from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime, Text

Base = declarative_base()


class EsiToken(Base):
    __tablename__ = "esi_tokens"
    id = Column(Integer, primary_key=True, index=True)
    character_id = Column(Integer, nullable=True)
    # encrypted token fields
    access_token_enc = Column(Text, nullable=False)
    refresh_token_enc = Column(Text, nullable=True)
    scope = Column(String, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    # optional plain legacy fields kept for compatibility
    access_token = Column(Text, nullable=True)
    refresh_token = Column(Text, nullable=True)
