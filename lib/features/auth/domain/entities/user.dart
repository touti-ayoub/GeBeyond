import 'package:equatable/equatable.dart';

/// Domain entity representing a user
class User extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? profilePhoto;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final SyncStatus syncStatus;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.profilePhoto,
    this.role = UserRole.user,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.syncStatus = SyncStatus.synced,
  });

  /// Get user initials
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? profilePhoto,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    SyncStatus? syncStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        phone,
        profilePhoto,
        role,
        createdAt,
        updatedAt,
        isDeleted,
        syncStatus,
      ];
}

enum UserRole {
  user,
  admin;

  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}

enum SyncStatus {
  synced,
  pending,
  conflict;

  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.conflict:
        return 'conflict';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'conflict':
        return SyncStatus.conflict;
      default:
        return SyncStatus.synced;
    }
  }
}
