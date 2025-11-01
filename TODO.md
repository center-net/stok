# TODO: Link User Permissions to Roles Table

## Completed Tasks
- [x] Updated database version to 3 and modified upgrade logic to handle versions up to 3.
- [x] Update schema.sql: Change Users.role to role_id INTEGER REFERENCES Roles(id), remove CHECK constraint.
- [x] Update User model in models.dart: Change role to roleId (int?), add method to get role name.
- [x] Update database_helper.dart: Modify CRUD operations for Users to use role_id, add migration in _onUpgrade to convert existing role data.
- [x] Update user_management_screen.dart: Load roles from database, use role names in dropdown, store role_id.

## Pending Tasks
- [ ] Test user creation, editing, and authentication with new role system.
