import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_users_usecase.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final GetUsersUseCase _getUsersUseCase;

  UserListBloc({required GetUsersUseCase getUsersUseCase})
      : _getUsersUseCase = getUsersUseCase,
        super(UserListState.initial()) {
    on<FetchUsers>(_onFetchUsers);
    on<RefreshUsers>(_onRefreshUsers);
    on<SearchUsers>(_onSearchUsers);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserListState> emit) async {
    emit(state.copyWith(status: UserListStatus.loading, errorMessage: null));
    await _fetchUsersData(emit);
  }

  Future<void> _onRefreshUsers(RefreshUsers event, Emitter<UserListState> emit) async {
    await _fetchUsersData(emit);
  }

  Future<void> _fetchUsersData(Emitter<UserListState> emit) async {
    try {
      final users = await _getUsersUseCase();
      
      final filtered = users.where((user) {
        return user.name.toLowerCase().contains(state.searchQuery.toLowerCase());
      }).toList();

      emit(state.copyWith(
        status: UserListStatus.success,
        users: users,
        filteredUsers: filtered,
        errorMessage: null,
      ));
    } catch (failure) {
      final String errorMsg = failure is Failure
          ? failure.message
          : 'An unexpected error occurred. Please try again.';
      emit(state.copyWith(
        status: UserListStatus.failure,
        errorMessage: errorMsg,
      ));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserListState> emit) {
    final query = event.query.trim();
    final filtered = state.users.where((user) {
      return user.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredUsers: filtered,
    ));
  }
}
