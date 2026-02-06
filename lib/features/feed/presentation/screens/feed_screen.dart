import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/feed_provider.dart';
import '../widgets/job_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/news_ticker.dart';

/// Feed screen showing available government jobs
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobFeedProvider);
    final categories = ref.watch(jobCategoriesProvider);
    final urgentJobs = ref.watch(urgentJobsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(jobFeedProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // News Ticker
            SliverToBoxAdapter(
              child: NewsTicker(
                messages: const [
                  "📢 SSC CGL 2024 Notification Out - Apply Now!",
                  "🔥 UPSC Prelims Admit Card Released",
                  "⚡ Railway NTPC Phase 2 Dates Announced",
                  "check out new jobs",
                ],
              ),
            ),

            // Urgent jobs banner
            if (urgentJobs.isNotEmpty)
              SliverToBoxAdapter(child: _UrgentJobsBanner(jobs: urgentJobs)),

            // Category filter chips
            SliverToBoxAdapter(
              child: _CategoryFilter(
                categories: categories,
                selected: _selectedCategory,
                onSelected: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
            ),

            // Job list
            jobsAsync.when(
              data: (jobs) {
                final filtered =
                    _selectedCategory == null
                        ? jobs
                        : jobs
                            .where((j) => j.category == _selectedCategory)
                            .toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.briefcase(),
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No jobs found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = filtered[index];
                      return JobCard(
                        job: job,
                        onApply: () {
                          if (job.applyUrl != null) {
                            context.push('/browser', extra: job.applyUrl);
                          }
                        },
                        onViewNotification: () {
                          if (job.notificationUrl != null) {
                            context.push(
                              '/browser',
                              extra: job.notificationUrl,
                            );
                          }
                        },
                        onBookmark: () {
                          ref
                              .read(jobFeedProvider.notifier)
                              .toggleBookmark(job.id);
                        },
                      );
                    }, childCount: filtered.length),
                  ),
                );
              },
              loading:
                  () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIcons.warning(),
                            size: 64,
                            color: AppTheme.urgentColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading jobs',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed:
                                () =>
                                    ref
                                        .read(jobFeedProvider.notifier)
                                        .refresh(),
                            icon: Icon(PhosphorIcons.arrowClockwise()),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/browser');
        },
        child: Icon(PhosphorIcons.globe()),
      ),
    );
  }
}

/// Banner for urgent jobs
class _UrgentJobsBanner extends StatelessWidget {
  final List jobs;

  const _UrgentJobsBanner({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.urgentColor,
            AppTheme.urgentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.alarm(PhosphorIconsStyle.fill),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deadline Approaching!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${jobs.length} job(s) closing within 3 days',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(PhosphorIcons.caretRight(), color: Colors.white),
        ],
      ),
    );
  }
}

/// Category filter chips
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          // Category chips
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat),
                selected: selected == cat,
                onSelected: (_) => onSelected(cat),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
