import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/job_item.dart';

/// Provider for the job feed
final jobFeedProvider =
    StateNotifierProvider<JobFeedNotifier, AsyncValue<List<JobItem>>>((ref) {
      return JobFeedNotifier();
    });

class JobFeedNotifier extends StateNotifier<AsyncValue<List<JobItem>>> {
  JobFeedNotifier() : super(const AsyncValue.loading()) {
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final jobs = await _loadMockFeed();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Load jobs from scraped JSON file
  Future<List<JobItem>> _loadMockFeed() async {
    try {
      // Try loading from scraper first
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('scraper/jobs.json');
      } catch (_) {
        // Fallback to mock data
        jsonString = await rootBundle.loadString('assets/mock/jobs_feed.json');
        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map((j) => JobItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      // Parse scraped jobs format
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> jobsJson = data['jobs'] ?? [];

      final jobs =
          jobsJson.map((j) {
            final dates = j['dates'] as Map<String, dynamic>? ?? {};
            final vacancies = j['vacancies'] as Map<String, dynamic>? ?? {};

            // Parse last date to DateTime
            DateTime? deadline;
            final lastDate = dates['last_date'] as String?;
            if (lastDate != null && lastDate.contains('/')) {
              final parts = lastDate.split('/');
              if (parts.length == 3) {
                deadline = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            }

            return JobItem(
              id:
                  j['url']?.hashCode.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: j['title'] ?? 'Untitled',
              organization: j['category'] ?? 'Government',
              category: j['category'],
              deadline: deadline,
              vacancies: vacancies['total'],
              eligibility:
                  (j['eligibility'] as List?)?.isNotEmpty == true
                      ? (j['eligibility'] as List).first
                      : null,
              applyUrl: j['url'],
              notificationUrl: j['url'],
            );
          }).toList();

      // Sort by deadline (soonest first)
      jobs.sort((a, b) {
        if (a.isExpired && !b.isExpired) return 1;
        if (!a.isExpired && b.isExpired) return -1;
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });

      return jobs;
    } catch (e) {
      print('Error loading feed: $e');
      return [];
    }
  }

  /// Refresh the feed
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _loadMockFeed();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle bookmark status for a job
  void toggleBookmark(String jobId) {
    state.whenData((jobs) {
      final index = jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        jobs[index].isBookmarked = !jobs[index].isBookmarked;
        state = AsyncValue.data([...jobs]);
      }
    });
  }
}

/// Provider for filtered jobs by category
final filteredJobsProvider = Provider.family<List<JobItem>, String?>((
  ref,
  category,
) {
  final feedAsync = ref.watch(jobFeedProvider);

  return feedAsync.when(
    data: (jobs) {
      if (category == null || category.isEmpty) return jobs;
      return jobs.where((j) => j.category == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for bookmarked jobs
final bookmarkedJobsProvider = Provider<List<JobItem>>((ref) {
  final feedAsync = ref.watch(jobFeedProvider);

  return feedAsync.when(
    data: (jobs) => jobs.where((j) => j.isBookmarked).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for urgent jobs (deadline within 3 days)
final urgentJobsProvider = Provider<List<JobItem>>((ref) {
  final feedAsync = ref.watch(jobFeedProvider);

  return feedAsync.when(
    data: (jobs) => jobs.where((j) => j.isUrgent).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for available categories
final jobCategoriesProvider = Provider<List<String>>((ref) {
  final feedAsync = ref.watch(jobFeedProvider);

  return feedAsync.when(
    data: (jobs) {
      final categories =
          jobs
              .map((j) => j.category)
              .where((c) => c != null && c.isNotEmpty)
              .cast<String>()
              .toSet()
              .toList();
      categories.sort();
      return categories;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
