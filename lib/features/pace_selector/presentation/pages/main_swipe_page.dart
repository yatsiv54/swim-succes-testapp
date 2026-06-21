import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pace_entity.dart';
import '../bloc/swim_pace_bloc.dart';
import 'pace_selection_page.dart';
import '../../../user_list/presentation/pages/user_list_page.dart';

class MainSwipePage extends StatefulWidget {
  const MainSwipePage({super.key});

  @override
  State<MainSwipePage> createState() => _MainSwipePageState();
}

class _MainSwipePageState extends State<MainSwipePage> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_pageController.hasClients) {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch SwimPaceBloc state to resolve active indicator color dynamically
    final swimState = context.watch<SwimPaceBloc>().state;
    final swimmerLevel = swimState.isSkipped ? SwimmerLevel.intermediate : swimState.level;
    final Color activeColor = AppTheme.getLevelColor(swimmerLevel);
    const Color inactiveColor = Color(0xFF1E293B);

    // Calculate colors using interpolation based on scroll offset
    final double t0 = (1.0 - _currentPage).clamp(0.0, 1.0);
    final double t1 = _currentPage.clamp(0.0, 1.0);

    final Color color0 = Color.lerp(inactiveColor, activeColor, t0)!;
    final Color color1 = Color.lerp(inactiveColor, activeColor, t1)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundCard, AppTheme.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Shared screen indicator bars
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: color0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: color1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    PaceSelectionPage(pageController: _pageController),
                    const UserListPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
