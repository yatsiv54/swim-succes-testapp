import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum UserListStatus { initial, loading, success, failure }

class UserListState extends Equatable {
  final UserListStatus status;
  final List<UserEntity> users;
  final List<UserEntity> filteredUsers;
  final String searchQuery;
  final String? errorMessage;

  const UserListState({
    required this.status,
    required this.users,
    required this.filteredUsers,
    required this.searchQuery,
    this.errorMessage,
  });

  factory UserListState.initial() {
    return const UserListState(
      status: UserListStatus.initial,
      users: [],
      filteredUsers: [],
      searchQuery: '',
      errorMessage: null,
    );
  }

  UserListState copyWith({
    UserListStatus? status,
    List<UserEntity>? users,
    List<UserEntity>? filteredUsers,
    String? searchQuery,
    String? errorMessage,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, filteredUsers, searchQuery, errorMessage];
}
