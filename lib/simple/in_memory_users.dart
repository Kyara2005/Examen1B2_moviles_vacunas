class UserSimple {
  final String id;
  final String cedula;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role; // 'coordinator', 'brigade_coordinator', 'vaccinator'

  UserSimple({
    required this.id,
    required this.cedula,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
  });

  String get fullName => '$firstName $lastName';
}

class InMemoryUsers {
  static final List<UserSimple> _users = [
    UserSimple(
      id: '1',
      cedula: '1721234567',
      firstName: 'Juan',
      lastName: 'Pérez',
      email: 'juan@example.com',
      phone: '0991234567',
      role: 'vaccinator',
    ),
    UserSimple(
      id: '2',
      cedula: '1721234568',
      firstName: 'María',
      lastName: 'García',
      email: 'maria@example.com',
      phone: '0992234567',
      role: 'vaccinator',
    ),
  ];

  static List<UserSimple> all() => List.unmodifiable(_users);

  static UserSimple? byId(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<UserSimple> byRole(String role) {
    return _users.where((u) => u.role == role).toList();
  }

  static void add(UserSimple u) {
    if (_users.any((existing) => existing.id == u.id)) {
      final index = _users.indexWhere((existing) => existing.id == u.id);
      _users[index] = u;
    } else {
      _users.add(u);
    }
  }

  static void remove(String id) => _users.removeWhere((u) => u.id == id);

  static void clear() => _users.clear();
}
