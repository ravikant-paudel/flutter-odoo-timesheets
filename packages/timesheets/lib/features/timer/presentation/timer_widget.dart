import 'package:djangoflow_app/djangoflow_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timesheets/configurations/configurations.dart';
import 'package:timesheets/features/activity/activity.dart';
import 'package:timesheets/features/app/app.dart';
import 'package:timesheets/features/timer/timer.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  final _iconSize = 40.0;

  @override
  void initState() {
    final timerBloc = context.read<TimerBloc>();

    ///Checking for active timer when app opened from killed state
    if (timerBloc.state.status == TimerStatus.pausedByForce) {
      _resumeTimerOnAppForeground(context: context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final timerBloc = context.read<TimerBloc>();
    final activityCubit = context.read<ActivityCubit>();

    return AppLifeCycleListener(
      onLifeCycleStateChanged: (AppLifecycleState? state) {
        if (timerBloc.state.status == TimerStatus.pausedByForce) {
          ///Checking for active timer when app opened from background state
          _resumeTimerOnAppForeground(context: context);
        } else if (timerBloc.state.status == TimerStatus.running) {
          if (state == AppLifecycleState.paused ||
              state == AppLifecycleState.detached) {
            timerBloc.add(TimerEvent.paused(lastTicked: DateTime.now()));
          }
        }
      },
      child: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          Duration duration = Duration(seconds: state.duration);
          TimerStatus status = state.status;
          return Padding(
            padding: const EdgeInsets.all(kPadding * 3),
            child: Column(
              children: [
                Text(
                  _format(duration: duration),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(
                  height: kPadding * 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (status != TimerStatus.running)
                      IconButton(
                        onPressed: () {
                          if (status == TimerStatus.paused) {
                            timerBloc.add(const TimerEvent.resumed());
                          } else if (status == TimerStatus.initial) {
                            timerBloc.add(const TimerEvent.started());
                          }
                        },
                        icon: Icon(
                          Icons.play_arrow_rounded,
                          size: _iconSize,
                        ),
                      ),
                    if (status == TimerStatus.running)
                      IconButton(
                        onPressed: () {
                          timerBloc.add(const TimerEvent.paused());
                        },
                        icon: Icon(
                          Icons.pause_circle,
                          size: _iconSize,
                        ),
                      ),
                    if (status != TimerStatus.initial)
                      IconButton(
                        onPressed: () async {
                          timerBloc.add(const TimerEvent.reset());
                          DateTime startTime = activityCubit.state.startTime!;
                          DateTime endTime = startTime.add(duration);

                          final DateFormat formatter =
                              DateFormat('yyyy-MM-dd HH:mm:ss');

                          Activity activity = Activity(
                            name: activityCubit.state.description!,
                            projectId: activityCubit.state.project!.id,
                            taskId: activityCubit.state.task!.id,
                            startTime: formatter.format(startTime),
                            endTime: formatter.format(endTime),
                          );
                          await activityCubit.syncActivity(
                            activity: activity,
                          );

                          DjangoflowAppSnackbar.showInfo('Activity Synced!');
                        },
                        icon: Icon(
                          Icons.square_rounded,
                          size: _iconSize,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _format({required Duration duration}) =>
      duration.toString().split('.').first.padLeft(8, '0');

  _resumeTimerOnAppForeground({required BuildContext context}) {
    final timerBloc = context.read<TimerBloc>();
    final lastTicked = timerBloc.state.lastTicked;
    if (lastTicked != null) {
      final now = DateTime.now();
      final elapsedSinceLastTicked = now.difference(lastTicked).inSeconds;
      final timerDuration = elapsedSinceLastTicked + timerBloc.state.duration;
      timerBloc.add(TimerEvent.resumed(duration: timerDuration));
    } else {
      timerBloc.add(const TimerEvent.resumed());
    }
  }
}
