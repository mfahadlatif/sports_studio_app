enum UserRole { user, owner, admin }

class AppSession {
  static UserRole role = UserRole.user; // Default role
}
