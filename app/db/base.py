from app.db.session import Base
from app.models.user import User

# Import all models here for Alembic
__all__ = ["Base", "User"]
