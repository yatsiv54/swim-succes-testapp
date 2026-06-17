import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pace_entity.dart';
import '../bloc/swim_pace_bloc.dart';
import '../bloc/swim_pace_event.dart';
import '../bloc/swim_pace_state.dart';
import '../../../training_plan/presentation/pages/training_plan_page.dart';

class PaceSelectionPage extends StatefulWidget {
  const PaceSelectionPage({super.key});

  @override
  State<PaceSelectionPage> createState() => _PaceSelectionPageState();
}

class _PaceSelectionPageState extends State<PaceSelectionPage> {
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late FocusNode _minutesFocusNode;
  late FocusNode _secondsFocusNode;

  @override
  void initState() {
    super.initState();
    final blocState = context.read<SwimPaceBloc>().state;
    _minutesController = TextEditingController(
      text: blocState.minutes.toString(),
    );
    _secondsController = TextEditingController(
      text: blocState.seconds.toString().padLeft(2, '0'),
    );

    _minutesFocusNode = FocusNode();
    _secondsFocusNode = FocusNode();

    _minutesFocusNode.addListener(_onMinutesFocusChange);
    _secondsFocusNode.addListener(_onSecondsFocusChange);
  }

  void _onMinutesFocusChange() {
    if (!_minutesFocusNode.hasFocus) {
      final val = int.tryParse(_minutesController.text) ?? 0;
      final clamped = val.clamp(0, 5);
      _minutesController.text = clamped.toString();
      _syncBlocPace();
    }
  }

  void _onSecondsFocusChange() {
    if (!_secondsFocusNode.hasFocus) {
      final val = int.tryParse(_secondsController.text) ?? 0;
      final clamped = val.clamp(0, 59);
      _secondsController.text = clamped.toString().padLeft(2, '0');
      _syncBlocPace();
    }
  }

  void _syncBlocPace() {
    final mins = int.tryParse(_minutesController.text) ?? 0;
    final secs = int.tryParse(_secondsController.text) ?? 0;
    context.read<SwimPaceBloc>().add(UpdatePace(minutes: mins, seconds: secs));
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _minutesFocusNode.removeListener(_onMinutesFocusChange);
    _secondsFocusNode.removeListener(_onSecondsFocusChange);
    _minutesFocusNode.dispose();
    _secondsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          _minutesFocusNode.unfocus();
          _secondsFocusNode.unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.backgroundCard, AppTheme.backgroundDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: BlocConsumer<SwimPaceBloc, SwimPaceState>(
              listenWhen: (prev, curr) =>
                  prev.minutes != curr.minutes ||
                  prev.seconds != curr.seconds ||
                  prev.status != curr.status ||
                  prev.isSkipped != curr.isSkipped,
              listener: (context, state) {
                if (!_minutesFocusNode.hasFocus) {
                  if (int.tryParse(_minutesController.text) != state.minutes) {
                    _minutesController.text = state.minutes.toString();
                  }
                }
                if (!_secondsFocusNode.hasFocus) {
                  if (int.tryParse(_secondsController.text) != state.seconds) {
                    _secondsController.text = state.seconds.toString().padLeft(
                      2,
                      '0',
                    );
                  }
                }

                if (state.status == SwimPaceStatus.success || state.isSkipped) {
                  final swimBloc = context.read<SwimPaceBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingPlanPage(),
                    ),
                  ).then((_) {
                    swimBloc.add(ResetPaceSelection());
                  });
                } else if (state.status == SwimPaceStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ??
                            'Submission failed. Please try again.',
                        style: AppTheme.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final double sliderValue = _getSliderValue(
                  state.minutes,
                  state.seconds,
                );
                final isLoading = state.status == SwimPaceStatus.loading;

                final Color targetColor = AppTheme.getLevelColor(state.level);

                // TweenAnimationBuilder translates color snaps into smooth transition sweeps
                return TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: targetColor),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  builder: (context, animatedColor, child) {
                    final Color levelColor = animatedColor ?? targetColor;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          _buildTopHeader(),
                          const SizedBox(height: 24),

                          Text(
                            "What's your fastest\n100m freestyle?",
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "This helps us build a more accurate plan\nfor you.",
                            style: AppTheme.subtitle,
                          ),

                          const SizedBox(height: 36),

                          Center(
                            child: Text(
                              "YOUR PACE",
                              style: AppTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(height: 4),

                          _buildTimePickerFields(context, state, levelColor),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "MIN   :   SEC   /   100M",
                              style: AppTheme.labelSmall.copyWith(
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Text(
                              "THAT PUTS YOU AT",
                              style: AppTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Center(
                            child: Text(
                              state.level.displayName,
                              style: AppTheme.subtitle.copyWith(
                                color: levelColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildLevelsAndSlider(
                            context,
                            state,
                            sliderValue,
                            levelColor,
                          ),

                          const SizedBox(height: 10),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: levelColor.withValues(
                                    alpha: isLoading ? 0.08 : 0.35,
                                  ),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _minutesFocusNode.unfocus();
                                      _secondsFocusNode.unfocus();
                                      context.read<SwimPaceBloc>().add(
                                        SubmitPace(),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: levelColor,
                                disabledBackgroundColor: levelColor.withValues(
                                  alpha: 0.3,
                                ),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Continue",
                                          style: AppTheme.subtitle.copyWith(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                      _minutesFocusNode.unfocus();
                                      _secondsFocusNode.unfocus();
                                      context.read<SwimPaceBloc>().add(
                                        SkipPaceSelection(),
                                      );
                                    },
                              child: Text(
                                "I don't know my pace, skip this",
                                style: AppTheme.subtitle.copyWith(
                                  color: isLoading
                                      ? AppTheme.textSlate
                                      : AppTheme.textGrey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: List.generate(2, (index) {
        final isActive = index == 0;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == 1 ? 0 : 4,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive ? AppTheme.primaryTeal : const Color(0xFF1E293B),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimePickerFields(
    BuildContext context,
    SwimPaceState state,
    Color activeColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 15,
      children: [
        _buildPickerColumn(
          context: context,
          controller: _minutesController,
          focusNode: _minutesFocusNode,
          width: 100,
          onIncrement: () {
            context.read<SwimPaceBloc>().add(IncrementMinutes());
          },
          onDecrement: () {
            context.read<SwimPaceBloc>().add(DecrementMinutes());
          },
          onChanged: (value) {
            final parsed = int.tryParse(value) ?? 0;
            if (parsed > 5) {
              _minutesController.text = '5';
              _minutesController.selection = TextSelection.fromPosition(
                const TextPosition(offset: 1),
              );
              context.read<SwimPaceBloc>().add(
                UpdatePace(minutes: 5, seconds: state.seconds),
              );
            } else {
              context.read<SwimPaceBloc>().add(
                UpdatePace(minutes: parsed, seconds: state.seconds),
              );
            }
          },
          isLoading: state.status == SwimPaceStatus.loading,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 36),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 45, 202, 194),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 45, 202, 194),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),

        _buildPickerColumn(
          context: context,
          controller: _secondsController,
          focusNode: _secondsFocusNode,
          width: 160,
          onIncrement: () {
            context.read<SwimPaceBloc>().add(IncrementSeconds());
          },
          onDecrement: () {
            context.read<SwimPaceBloc>().add(DecrementSeconds());
          },
          onChanged: (value) {
            final parsed = int.tryParse(value) ?? 0;
            if (parsed > 59) {
              _secondsController.text = '59';
              _secondsController.selection = TextSelection.fromPosition(
                const TextPosition(offset: 2),
              );
              context.read<SwimPaceBloc>().add(
                UpdatePace(minutes: state.minutes, seconds: 59),
              );
            } else {
              context.read<SwimPaceBloc>().add(
                UpdatePace(minutes: state.minutes, seconds: parsed),
              );
            }
          },
          isLoading: state.status == SwimPaceStatus.loading,
        ),
      ],
    );
  }

  Widget _buildPickerColumn({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required double width,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required ValueChanged<String> onChanged,
    required bool isLoading,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: isLoading ? null : onIncrement,
          icon: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: AppTheme.textWhite,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 2),

        SizedBox(
          width: width,
          height: 100,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            cursorColor: AppTheme.primaryTeal,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            style: AppTheme.paceNumberStyle,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 10),

        IconButton(
          onPressed: isLoading ? null : onDecrement,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textWhite,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(height: 8),

        Text(
          "TAP TO EDIT",
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textSlate,
            fontSize: 8,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLevelsAndSlider(
    BuildContext context,
    SwimPaceState state,
    double sliderValue,
    Color activeColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return Stack(
                children: [
                  const SizedBox(height: 20, width: double.infinity),
                  Positioned(
                    left: trackWidth * 0.05 - 40,
                    child: _buildLevelLabel(SwimmerLevel.elite, state),
                  ),
                  Positioned(
                    left: trackWidth * 0.225 - 40,
                    child: _buildLevelLabel(SwimmerLevel.advanced, state),
                  ),
                  Positioned(
                    left: trackWidth * 0.525 - 40,
                    child: _buildLevelLabel(SwimmerLevel.intermediate, state),
                  ),
                  Positioned(
                    left: trackWidth * 0.85 - 40,
                    child: _buildLevelLabel(SwimmerLevel.beginner, state),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 0),

        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.0,
            activeTrackColor: activeColor,
            inactiveTrackColor: AppTheme.textWhite.withValues(alpha: 0.08),
            overlayColor: activeColor.withValues(alpha: 0.12),
            thumbShape: GlowSliderThumbShape(
              thumbRadius: 10,
              color: activeColor,
            ),
            trackShape: CustomSliderTrackShape(activeColor: activeColor),
          ),
          child: Slider(
            value: sliderValue,
            min: 0.0,
            max: 1.0,
            onChanged: state.status == SwimPaceStatus.loading
                ? null
                : (val) {
                    _minutesFocusNode.unfocus();
                    _secondsFocusNode.unfocus();

                    final pace = _getPaceFromSlider(val);
                    context.read<SwimPaceBloc>().add(
                      UpdatePace(
                        minutes: pace['minutes']!,
                        seconds: pace['seconds']!,
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(height: 4),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  const SizedBox(height: 20, width: double.infinity),
                  Positioned(
                    left: width * 0.10 - 12,
                    child: _buildTickText("1:10"),
                  ),
                  Positioned(
                    left: width * 0.35 - 12,
                    child: _buildTickText("1:30"),
                  ),
                  Positioned(
                    left: width * 0.70 - 12,
                    child: _buildTickText("2:00"),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTickText(String text) {
    return Text(
      text,
      style: AppTheme.labelSmall.copyWith(
        color: AppTheme.tickGrey,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLevelLabel(SwimmerLevel lvl, SwimPaceState state) {
    final isSelected = state.level == lvl;
    return SizedBox(
      width: 90,
      child: Text(
        lvl.displayName,
        textAlign: TextAlign.center,
        style: AppTheme.labelSmall.copyWith(
          color: isSelected ? AppTheme.textWhite : AppTheme.textSlate,
          fontSize: isSelected ? 10 : 9,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  double _getSliderValue(int minutes, int seconds) {
    final int total = minutes * 60 + seconds;
    if (total < 70) {
      final double val = 0.10 * (total - 45) / 25.0;
      return val.clamp(0.0, 0.10);
    } else if (total < 90) {
      return 0.10 + 0.25 * (total - 70) / 20.0;
    } else if (total < 120) {
      return 0.35 + 0.35 * (total - 90) / 30.0;
    } else {
      final double val = 0.70 + 0.30 * (total - 120) / 120.0;
      return val.clamp(0.70, 1.0);
    }
  }

  Map<String, int> _getPaceFromSlider(double t) {
    int totalSeconds;
    if (t < 0.10) {
      totalSeconds = (45 + 25 * (t / 0.10)).round();
    } else if (t < 0.35) {
      totalSeconds = (70 + 20 * ((t - 0.10) / 0.25)).round();
    } else if (t < 0.70) {
      totalSeconds = (90 + 30 * ((t - 0.35) / 0.35)).round();
    } else {
      totalSeconds = (120 + 120 * ((t - 0.70) / 0.30)).round();
    }
    return {'minutes': totalSeconds ~/ 60, 'seconds': totalSeconds % 60};
  }
}

class GlowSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final Color? color;
  const GlowSliderThumbShape({this.thumbRadius = 10.0, this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final activeColor = color ?? AppTheme.primaryTeal;

    final Paint glowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, thumbRadius + 5, glowPaint);

    final Paint borderPaint = Paint()
      ..color = AppTheme.textWhite
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, borderPaint);

    final Paint thumbPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius - 2.5, thumbPaint);
  }
}

class CustomSliderTrackShape extends RoundedRectSliderTrackShape {
  final Color? activeColor;
  const CustomSliderTrackShape({this.activeColor});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final double trackLeft = offset.dx + 16.0;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 32.0;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2.0,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint backgroundPaint = Paint()
      ..color =
          sliderTheme.inactiveTrackColor ??
          AppTheme.textWhite.withValues(alpha: 0.08);

    final Paint activePaint = Paint()
      ..color = activeColor ?? AppTheme.primaryTeal;

    final double x0 = trackRect.left;
    final double w = trackRect.width;
    final double x1 = x0 + w * 0.10;
    final double x2 = x0 + w * 0.35;
    final double x3 = x0 + w * 0.70;
    final double x4 = trackRect.right;

    final double thumbX = thumbCenter.dx;

    // Determine current sector
    double startXSector = x0;
    double endXSector = x4;
    int currentSector = 0;

    if (thumbX < x1) {
      currentSector = 0;
      startXSector = x0;
      endXSector = x1;
    } else if (thumbX < x2) {
      currentSector = 1;
      startXSector = x1;
      endXSector = x2;
    } else if (thumbX < x3) {
      currentSector = 2;
      startXSector = x2;
      endXSector = x3;
    } else {
      currentSector = 3;
      startXSector = x3;
      endXSector = x4;
    }

    canvas.save();

    // Clip to the rounded track rectangle to keep ends rounded nicely
    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(trackRect.height / 2),
    );
    canvas.clipRRect(trackRRect);

    // 1. Draw entire background (inactive track)
    canvas.drawRect(trackRect, backgroundPaint);

    // 2. Draw highlighted current active sector (entire sector width)
    final Rect activeRect = Rect.fromLTRB(
      startXSector,
      trackRect.top,
      endXSector,
      trackRect.bottom,
    );
    canvas.drawRect(activeRect, activePaint);

    canvas.restore();

    // Draw the dot ticks
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;
    final double y = trackRect.center.dy;

    final dotPositions = [0.10, 0.35, 0.70];
    for (final pos in dotPositions) {
      final double x = x0 + w * pos;

      // Determine if the dot should be active based on current sector boundaries
      bool isDotActive = false;
      if (pos == 0.10) {
        isDotActive = (currentSector == 0 || currentSector == 1);
      } else if (pos == 0.35) {
        isDotActive = (currentSector == 1 || currentSector == 2);
      } else if (pos == 0.70) {
        isDotActive = (currentSector == 2 || currentSector == 3);
      }

      dotPaint.color = isDotActive
          ? (activeColor ?? AppTheme.primaryTeal)
          : AppTheme.textWhite.withValues(alpha: 0.15);

      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
    }
  }
}
