import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Model for a single job listing with full details
class JobListing {
  final String title;
  final String url;
  final String type;
  final String category;
  final JobDates dates;
  final Map<String, int> fees;
  final AgeLimit ageLimit;
  final Map<String, dynamic> vacancies;
  final List<String> eligibility;
  final String scrapedAt;

  JobListing({
    required this.title,
    required this.url,
    required this.type,
    required this.category,
    required this.dates,
    required this.fees,
    required this.ageLimit,
    required this.vacancies,
    required this.eligibility,
    required this.scrapedAt,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) {
    return JobListing(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'Recruitment',
      category: json['category'] ?? 'Other',
      dates: JobDates.fromJson(json['dates'] ?? {}),
      fees: Map<String, int>.from(
        (json['fees'] ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
        ),
      ),
      ageLimit: AgeLimit.fromJson(json['age_limit'] ?? {}),
      vacancies: Map<String, dynamic>.from(json['vacancies'] ?? {}),
      eligibility: List<String>.from(json['eligibility'] ?? []),
      scrapedAt: json['scraped_at'] ?? '',
    );
  }

  /// Get total vacancies
  int get totalVacancies => vacancies['total'] ?? 0;

  /// Get general category fee
  int get generalFee => fees['general'] ?? 0;

  /// Check if application is open
  bool get isApplicationOpen {
    if (dates.lastDate == null) return true;
    // Simple check - you can improve with actual date parsing
    return true;
  }
}

/// Model for important dates
class JobDates {
  final String? applicationBegin;
  final String? lastDate;
  final String? examDate;
  final String? admitCard;
  final String? resultDate;

  JobDates({
    this.applicationBegin,
    this.lastDate,
    this.examDate,
    this.admitCard,
    this.resultDate,
  });

  factory JobDates.fromJson(Map<String, dynamic> json) {
    return JobDates(
      applicationBegin: json['application_begin'],
      lastDate: json['last_date'],
      examDate: json['exam_date'],
      admitCard: json['admit_card'],
      resultDate: json['result_date'],
    );
  }

  Map<String, String> toDisplayMap() {
    final map = <String, String>{};
    if (applicationBegin != null) map['Apply Start'] = applicationBegin!;
    if (lastDate != null) map['Last Date'] = lastDate!;
    if (examDate != null) map['Exam Date'] = examDate!;
    if (admitCard != null) map['Admit Card'] = admitCard!;
    if (resultDate != null) map['Result'] = resultDate!;
    return map;
  }
}

/// Model for age limit
class AgeLimit {
  final int? min;
  final int? max;
  final String? asOn;

  AgeLimit({this.min, this.max, this.asOn});

  factory AgeLimit.fromJson(Map<String, dynamic> json) {
    return AgeLimit(min: json['min'], max: json['max'], asOn: json['as_on']);
  }

  String get displayText {
    if (min == null && max == null) return 'Not Specified';
    return '${min ?? 0} - ${max ?? 0} Years';
  }
}

/// Response model for jobs data
class JobsData {
  final String lastUpdated;
  final int totalJobs;
  final String source;
  final List<JobListing> jobs;

  JobsData({
    required this.lastUpdated,
    required this.totalJobs,
    required this.source,
    required this.jobs,
  });

  factory JobsData.fromJson(Map<String, dynamic> json) {
    final jobsList =
        (json['jobs'] as List?)?.map((j) => JobListing.fromJson(j)).toList() ??
        [];

    return JobsData(
      lastUpdated: json['last_updated'] ?? '',
      totalJobs: json['total_jobs'] ?? jobsList.length,
      source: json['source'] ?? 'sarkariresult.com',
      jobs: jobsList,
    );
  }

  /// Get jobs by category
  List<JobListing> getByCategory(String category) {
    return jobs.where((j) => j.category == category).toList();
  }

  /// Get jobs by type
  List<JobListing> getByType(String type) {
    return jobs.where((j) => j.type == type).toList();
  }

  /// Get unique categories
  List<String> get categories {
    return jobs.map((j) => j.category).toSet().toList();
  }
}

/// Service to fetch and manage job listings
class JobsService {
  static JobsData? _cachedData;

  /// Fetch jobs from local JSON file (bundled with app)
  static Future<JobsData> getJobs() async {
    if (_cachedData != null) return _cachedData!;

    try {
      final jsonString = await rootBundle.loadString('scraper/jobs.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _cachedData = JobsData.fromJson(jsonData);
      return _cachedData!;
    } catch (e) {
      print('Error loading jobs: $e');
      return JobsData(lastUpdated: '', totalJobs: 0, source: '', jobs: []);
    }
  }

  /// Clear cache to force refresh
  static void clearCache() {
    _cachedData = null;
  }

  /// Format fee display
  static String formatFees(Map<String, int> fees) {
    if (fees.isEmpty) return 'Free';
    final gen = fees['general'] ?? 0;
    if (gen == 0) return 'Free';
    return '₹$gen';
  }

  /// Get category icon
  static String getCategoryEmoji(String category) {
    switch (category) {
      case 'SSC':
        return '📋';
      case 'UPSC':
        return '🏛️';
      case 'Banking':
        return '🏦';
      case 'Railway':
        return '🚂';
      case 'Defence':
        return '🎖️';
      case 'Police':
        return '👮';
      default:
        return '📄';
    }
  }
}
