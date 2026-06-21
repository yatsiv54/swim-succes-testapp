import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/pace_selector/data/datasources/pace_remote_data_source.dart';
import 'features/pace_selector/data/repositories/pace_repository_impl.dart';
import 'features/pace_selector/domain/usecases/submit_pace_usecase.dart';
import 'features/pace_selector/presentation/bloc/swim_pace_bloc.dart';
import 'features/pace_selector/presentation/pages/main_swipe_page.dart';
import 'features/user_list/data/datasources/user_remote_data_source.dart';
import 'features/user_list/data/repositories/user_repository_impl.dart';
import 'features/user_list/domain/usecases/get_users_usecase.dart';
import 'features/user_list/presentation/bloc/user_list_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI styling to match the dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppTheme.backgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Instantiate dependencies (Clean Architecture injection)
  final apiClient = ApiClient();
  final remoteDataSource = PaceRemoteDataSourceImpl(apiClient);
  final repository = PaceRepositoryImpl(remoteDataSource);
  final submitPaceUseCase = SubmitPaceUseCase(repository);

  final userRemoteDataSource = UserRemoteDataSourceImpl(apiClient);
  final userRepository = UserRepositoryImpl(userRemoteDataSource);
  final getUsersUseCase = GetUsersUseCase(userRepository);

  runApp(SwimProgressApp(
    submitPaceUseCase: submitPaceUseCase,
    getUsersUseCase: getUsersUseCase,
  ));
}

class SwimProgressApp extends StatelessWidget {
  final SubmitPaceUseCase _submitPaceUseCase;
  final GetUsersUseCase _getUsersUseCase;

  const SwimProgressApp({
    super.key,
    required SubmitPaceUseCase submitPaceUseCase,
    required GetUsersUseCase getUsersUseCase,
  })  : _submitPaceUseCase = submitPaceUseCase,
        _getUsersUseCase = getUsersUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SwimPaceBloc(submitPaceUseCase: _submitPaceUseCase),
        ),
        BlocProvider(
          create: (context) => UserListBloc(getUsersUseCase: _getUsersUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'Swim Progress',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainSwipePage(),
      ),
    );
  }
}
