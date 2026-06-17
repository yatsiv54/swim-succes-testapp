import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pace_selector/domain/entities/pace_entity.dart';
import '../../../pace_selector/presentation/bloc/swim_pace_bloc.dart';
import '../../../pace_selector/presentation/bloc/swim_pace_state.dart';

class TrainingPlanPage extends StatefulWidget {
  const TrainingPlanPage({super.key});

  @override
  State<TrainingPlanPage> createState() => _TrainingPlanPageState();
}

class _TrainingPlanPageState extends State<TrainingPlanPage> {
  final Map<String, bool> _completedSets = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundCard,
              AppTheme.backgroundDark,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<SwimPaceBloc, SwimPaceState>(
            builder: (context, state) {
              final String levelName = state.isSkipped ? "Evaluation" : state.level.displayName;
              final String paceStr = state.isSkipped
                  ? "Not specified"
                  : "${state.minutes}:${state.seconds.toString().padLeft(2, '0')} / 100m";

              final swimmerLevel = state.isSkipped ? SwimmerLevel.intermediate : state.level;
              final planData = _getPlanData(swimmerLevel);
              
              // Dynamic level color matching choice from Screen 1
              final Color levelColor = AppTheme.getLevelColor(swimmerLevel);

              final workoutKeys = planData.workouts.expand((w) => w.sets).map((s) => s.id).toList();
              final completedCount = workoutKeys.where((key) => _completedSets[key] == true).length;
              final double progressPct = workoutKeys.isEmpty ? 0.0 : completedCount / workoutKeys.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(context, levelColor),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPaceDashboardCard(levelName, paceStr, planData, levelColor),
                          const SizedBox(height: 24),

                          _buildTargetsGrid(planData),
                          const SizedBox(height: 24),

                          if (workoutKeys.isNotEmpty) ...[
                            _buildProgressTracker(completedCount, workoutKeys.length, progressPct, levelColor),
                            const SizedBox(height: 24),
                          ],

                          Text(
                            "WEEK 1 WORKOUTS",
                            style: AppTheme.labelSmall,
                          ),
                          const SizedBox(height: 12),

                          ...planData.workouts.map((workout) => _buildWorkoutCard(workout, levelColor)),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  _buildBottomBar(completedCount, workoutKeys.length, levelColor),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color levelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: levelColor,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textWhite.withValues(alpha: 0.06),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.textWhite,
                    size: 22,
                  ),
                ),
              ),

              Text(
                "TRAINING PLAN",
                style: AppTheme.labelSmall.copyWith(color: AppTheme.textWhite, fontSize: 14),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.textWhite.withValues(alpha: 0.06),
                ),
                child: Icon(
                  Icons.blur_on_rounded,
                  color: levelColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaceDashboardCard(String levelName, String paceStr, _PlanData planData, Color levelColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
        gradient: LinearGradient(
          colors: [
            AppTheme.textWhite.withValues(alpha: 0.04),
            AppTheme.textWhite.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        levelName,
                        style: AppTheme.labelSmall.copyWith(
                          color: levelColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Target Pace",
                  style: AppTheme.subtitle.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  paceStr,
                  style: AppTheme.titleLarge.copyWith(fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: levelColor.withValues(alpha: 0.05),
              border: Border.all(color: levelColor.withValues(alpha: 0.1)),
            ),
            child: Center(
              child: Icon(
                Icons.waves_rounded,
                color: levelColor,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetsGrid(_PlanData planData) {
    return Row(
      children: [
        Expanded(
          child: _buildGridItem(
            title: "WEEKLY TARGET",
            value: planData.weeklyVolume,
            icon: Icons.directions_run_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGridItem(
            title: "SESSIONS",
            value: planData.weeklySessions,
            icon: Icons.calendar_today_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textWhite.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textWhite.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.labelSmall.copyWith(fontSize: 10, letterSpacing: 1.0),
              ),
              Icon(icon, size: 14, color: AppTheme.textGrey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker(int completed, int total, double percentage, Color levelColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: levelColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOUR WORKOUT PROGRESS",
                style: AppTheme.labelSmall.copyWith(color: AppTheme.textGrey, fontSize: 10, letterSpacing: 1.0),
              ),
              Text(
                "$completed/$total Sets",
                style: AppTheme.labelSmall.copyWith(
                  color: levelColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: AppTheme.textWhite.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(levelColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(_WorkoutSession workout, Color levelColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.textWhite.withValues(alpha: 0.015),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.textWhite.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: levelColor,
          collapsedIconColor: AppTheme.textGrey,
          title: Text(
            workout.title,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textWhite,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            "${workout.totalDistance} • ${workout.difficulty}",
            style: AppTheme.subtitle.copyWith(fontSize: 12),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: workout.sets.map((set) => _buildSetItem(set, levelColor)).toList(),
        ),
      ),
    );
  }

  Widget _buildSetItem(_WorkoutSet set, Color levelColor) {
    final isDone = _completedSets[set.id] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _completedSets[set.id] = !isDone;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDone ? levelColor : AppTheme.textSlate,
                  width: 1.5,
                ),
                color: isDone ? levelColor.withValues(alpha: 0.1) : Colors.transparent,
              ),
              child: isDone
                  ? Icon(Icons.check, size: 14, color: levelColor)
                  : null,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      set.type.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: _getSetTypeColor(set.type),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      set.distance,
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textWhite,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  set.description,
                  style: AppTheme.subtitle.copyWith(
                    color: isDone ? AppTheme.textSlate : AppTheme.textGrey,
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSetTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'warm-up':
        return const Color(0xFF60A5FA);
      case 'main set':
        return const Color(0xFFF87171);
      case 'cool-down':
        return const Color(0xFF34D399);
      default:
        return AppTheme.textGrey;
    }
  }

  Widget _buildBottomBar(int completed, int total, Color levelColor) {
    final allDone = completed == total && total > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border.all(color: AppTheme.textWhite.withValues(alpha: 0.04)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                allDone
                    ? "🎉 Incredible! You completed this week's workout program!"
                    : "💪 Session started! Turn on your waterproof smart watch and jump in!",
                style: AppTheme.subtitle.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              backgroundColor: levelColor,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: allDone ? const Color(0xFF34D399) : levelColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Text(
          allDone ? "Workout Week Complete!" : "Start Today's Workout",
          style: AppTheme.labelSmall.copyWith(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  _PlanData _getPlanData(SwimmerLevel level) {
    switch (level) {
      case SwimmerLevel.elite:
        return _PlanData(
          weeklyVolume: "12.5 km",
          weeklySessions: "5 / week",
          workouts: [
            _WorkoutSession(
              title: "Threshold Endurance",
              totalDistance: "3,200m",
              difficulty: "Hard",
              sets: [
                _WorkoutSet("e1", "warm-up", "800m", "800m easy mixed strokes with kicking drills"),
                _WorkoutSet("e2", "main set", "10x100m", "10x100m Freestyle @ 1:20 pace. Focus on stroke length."),
                _WorkoutSet("e3", "main set", "8x150m", "8x150m Pull/Buoy progressive speed. Rest 15s."),
                _WorkoutSet("e4", "cool-down", "400m", "400m choice easy kick/backstroke"),
              ],
            ),
            _WorkoutSession(
              title: "VO2 Max Speed Intervals",
              totalDistance: "2,800m",
              difficulty: "Very Hard",
              sets: [
                _WorkoutSet("e5", "warm-up", "600m", "Progression warmup. Increase speed every 200m."),
                _WorkoutSet("e6", "main set", "20x50m", "20x50m sprint @ 45s interval. Max effort."),
                _WorkoutSet("e7", "main set", "4x300m", "4x300m Aerobic recovery. Focus on breathing rhythm."),
                _WorkoutSet("e8", "cool-down", "200m", "200m choice active recovery"),
              ],
            ),
          ],
        );
      case SwimmerLevel.advanced:
        return _PlanData(
          weeklyVolume: "8.2 km",
          weeklySessions: "4 / week",
          workouts: [
            _WorkoutSession(
              title: "Aerobic Threshold",
              totalDistance: "2,400m",
              difficulty: "Moderate-Hard",
              sets: [
                _WorkoutSet("a1", "warm-up", "500m", "Warm-up choice, 100m kick, 100m pull"),
                _WorkoutSet("a2", "main set", "6x200m", "6x200m Freestyle @ 3:10 pace. Consistent splits."),
                _WorkoutSet("a3", "main set", "4x100m", "4x100m Individual Medley. Rest 20s."),
                _WorkoutSet("a4", "cool-down", "300m", "300m easy choice recovery"),
              ],
            ),
            _WorkoutSession(
              title: "Pacing & Speed Play",
              totalDistance: "2,000m",
              difficulty: "Medium",
              sets: [
                _WorkoutSet("a5", "warm-up", "400m", "400m easy choice"),
                _WorkoutSet("a6", "main set", "12x50m", "12x50m at target 100m pace. Rest 15s."),
                _WorkoutSet("a7", "main set", "600m", "600m Pull/Buoy breathing 3/5/7 pattern."),
                _WorkoutSet("a8", "cool-down", "200m", "200m backstroke/breaststroke easy"),
              ],
            ),
          ],
        );
      case SwimmerLevel.intermediate:
        return _PlanData(
          weeklyVolume: "4.8 km",
          weeklySessions: "3 / week",
          workouts: [
            _WorkoutSession(
              title: "Aerobic Endurance Base",
              totalDistance: "1,600m",
              difficulty: "Medium",
              sets: [
                _WorkoutSet("i1", "warm-up", "400m", "400m easy freestyle with breathing every 3 strokes"),
                _WorkoutSet("i2", "main set", "6x100m", "6x100m Freestyle @ 2:15 interval. Focus on smooth glides."),
                _WorkoutSet("i3", "main set", "4x100m", "4x100m Pull/Buoy. Focus on core rotation."),
                _WorkoutSet("i4", "cool-down", "200m", "200m easy backstroke / breaststroke choice"),
              ],
            ),
            _WorkoutSession(
              title: "Pacing Development",
              totalDistance: "1,500m",
              difficulty: "Moderate",
              sets: [
                _WorkoutSet("i5", "warm-up", "300m", "300m choice warm-up"),
                _WorkoutSet("i6", "main set", "8x50m", "8x50m progressive pace (1-4, 5-8). Rest 20s."),
                _WorkoutSet("i7", "main set", "4x150m", "4x150m steady aerobic pace. Focus on stroke rate."),
                _WorkoutSet("i8", "cool-down", "200m", "200m easy recovery"),
              ],
            ),
          ],
        );
      case SwimmerLevel.beginner:
        return _PlanData(
          weeklyVolume: "2.2 km",
          weeklySessions: "2 / week",
          workouts: [
            _WorkoutSession(
              title: "Breathing & Mechanics",
              totalDistance: "1,000m",
              difficulty: "Light-Medium",
              sets: [
                _WorkoutSet("b1", "warm-up", "200m", "200m easy choice. Take breaks as needed."),
                _WorkoutSet("b2", "main set", "8x50m", "8x50m Freestyle. Focus on lateral breathing, rest 30s."),
                _WorkoutSet("b3", "main set", "4x50m", "4x50m Kick with kickboard. Focus on ankle flexibility."),
                _WorkoutSet("b4", "cool-down", "200m", "200m easy breaststroke / slow freestyle"),
              ],
            ),
            _WorkoutSession(
              title: "Endurance Building",
              totalDistance: "900m",
              difficulty: "Easy",
              sets: [
                _WorkoutSet("b5", "warm-up", "150m", "150m easy choice"),
                _WorkoutSet("b6", "main set", "4x100m", "4x100m steady pace. Rest 45s between laps."),
                _WorkoutSet("b7", "main set", "4x50m", "4x50m Pull with pull buoy. Float and glide."),
                _WorkoutSet("b8", "cool-down", "150m", "150m slow choice recovery"),
              ],
            ),
          ],
        );
    }
  }
}

class _PlanData {
  final String weeklyVolume;
  final String weeklySessions;
  final List<_WorkoutSession> workouts;

  _PlanData({
    required this.weeklyVolume,
    required this.weeklySessions,
    required this.workouts,
  });
}

class _WorkoutSession {
  final String title;
  final String totalDistance;
  final String difficulty;
  final List<_WorkoutSet> sets;

  _WorkoutSession({
    required this.title,
    required this.totalDistance,
    required this.difficulty,
    required this.sets,
  });
}

class _WorkoutSet {
  final String id;
  final String type;
  final String distance;
  final String description;

  _WorkoutSet(this.id, this.type, this.distance, this.description);
}
