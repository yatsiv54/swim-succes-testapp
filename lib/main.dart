import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/pace_selector/data/datasources/pace_remote_data_source.dart';
import 'features/pace_selector/data/repositories/pace_repository_impl.dart';
import 'features/pace_selector/domain/usecases/submit_pace_usecase.dart';
import 'features/pace_selector/presentation/bloc/swim_pace_bloc.dart';
import 'features/pace_selector/presentation/pages/pace_selection_page.dart';

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

  runApp(SwimProgressApp(submitPaceUseCase: submitPaceUseCase));
}

class SwimProgressApp extends StatelessWidget {
  final SubmitPaceUseCase _submitPaceUseCase;

  const SwimProgressApp({
    super.key,
    required SubmitPaceUseCase submitPaceUseCase,
  }) : _submitPaceUseCase = submitPaceUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwimPaceBloc(submitPaceUseCase: _submitPaceUseCase),
      child: MaterialApp(
        title: 'Swim Progress',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const PaceSelectionPage(),
      ),
    );
  }
}
