class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isBlocked;
  final int balance;
  final String levelId;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isBlocked,
    required this.balance,
    required this.levelId,
  });

  static const empty = UserModel(
    id: 0,
    username: '',
    email: '',
    role: '',
    isBlocked: false,
    balance: 0,
    levelId: '',
  );

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    bool? isBlocked,
    int? balance,
    String? levelId,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      balance: balance ?? this.balance,
      levelId: levelId ?? this.levelId,
    );
  }
} 