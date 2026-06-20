import 'package:cineverse/app/theme/app_colors.dart';
import 'package:cineverse/core/extensions/l10n_extension.dart';
import 'package:cineverse/presentation/features/home/providers/reminders_provider.dart';
import 'package:cineverse/presentation/widgets/app_back_button.dart';
import 'package:cineverse/presentation/widgets/background_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<AppReminder>> remindersAsync = ref.watch(
      remindersProvider,
    );

    return BackgroundGradient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const AppBackButton(),
          title: Text(
            context.l10n.notifications,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        body: remindersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                context.l10n.couldNotLoadReminders(error.toString()),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          data: (reminders) {
            if (reminders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.noRemindersSetYet,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: reminders.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final AppReminder reminder = reminders[index];
                final bool isOverdue = reminder.isOverdue;
                final String schedule = DateFormat(
                  'EEE, d MMM yyyy • hh:mm a',
                ).format(reminder.notifyAt.toLocal());
                final String subtitle = isOverdue
                    ? context.l10n.wasScheduledFor(schedule)
                    : context.l10n.scheduledFor(schedule);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.cinemaPanelGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOverdue
                          ? Colors.orange.withValues(alpha: 0.4)
                          : AppColors.cinemaBorder.withValues(alpha: 0.26),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: reminder.type == ReminderType.episodeAiring
                                  ? AppColors.cinemaAccent.withValues(
                                      alpha: 0.22,
                                    )
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              reminder.type == ReminderType.episodeAiring
                                  ? context.l10n.episodeAiring
                                  : context.l10n.general,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(remindersProvider.notifier)
                                .dismissReminder(reminder.id),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.white70,
                            ),
                            label: Text(
                              context.l10n.dismiss,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? Colors.orange.shade200
                              : Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
