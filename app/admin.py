from sqladmin import Admin, ModelView

from app.models.user import User


class UserAdmin(ModelView, model=User):
    column_list = [User.id, User.email, User.is_active, User.is_superuser, User.is_verified]
    column_searchable_list = [User.email]
    column_sortable_list = [User.id, User.email]
    can_create = True
    can_edit = True
    can_delete = False
    can_view_details = True
    name = "User"
    name_plural = "Users"
    icon = "fa-solid fa-user"


def setup_admin(app, engine):
    admin = Admin(app, engine)
    admin.add_view(UserAdmin)
    return admin
