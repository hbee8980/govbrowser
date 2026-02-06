import 'package:hive/hive.dart';

/// Represents a government job listing from the feed
class JobItem extends HiveObject {
  String id;
  String title;
  String organization;
  DateTime? deadline;
  String? applyUrl;
  String? notificationUrl;
  String? category; // SSC, UPSC, Railway, Banking, State PSC, etc.
  int? vacancies;
  String? eligibility;
  bool isBookmarked;

  JobItem({
    required this.id,
    required this.title,
    required this.organization,
    this.deadline,
    this.applyUrl,
    this.notificationUrl,
    this.category,
    this.vacancies,
    this.eligibility,
    this.isBookmarked = false,
  });

  /// Create from JSON (for API/mock data)
  factory JobItem.fromJson(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      organization: json['organization'] as String? ?? '',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      applyUrl: json['apply_url'] as String?,
      notificationUrl: json['notification_url'] as String?,
      category: json['category'] as String?,
      vacancies: json['vacancies'] as int?,
      eligibility: json['eligibility'] as String?,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organization': organization,
      'deadline': deadline?.toIso8601String(),
      'apply_url': applyUrl,
      'notification_url': notificationUrl,
      'category': category,
      'vacancies': vacancies,
      'eligibility': eligibility,
      'is_bookmarked': isBookmarked,
    };
  }

  /// Get formatted deadline
  String get formattedDeadline {
    if (deadline == null) return 'No deadline';
    final now = DateTime.now();
    final diff = deadline!.difference(now);

    if (diff.isNegative) {
      return 'Expired';
    } else if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days left';
    } else {
      return '${deadline!.day}/${deadline!.month}/${deadline!.year}';
    }
  }

  /// Check if deadline is approaching (within 3 days)
  bool get isUrgent {
    if (deadline == null) return false;
    final diff = deadline!.difference(DateTime.now());
    return diff.inDays <= 3 && !diff.isNegative;
  }

  /// Check if expired
  bool get isExpired {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'JobItem($title - $organization)';
  }
}

/// Hive TypeAdapter for JobItem
class JobItemAdapter extends TypeAdapter<JobItem> {
  @override
  final int typeId = 10;

  @override
  JobItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobItem(
      id: fields[0] as String,
      title: fields[1] as String,
      organization: fields[2] as String,
      deadline: fields[3] as DateTime?,
      applyUrl: fields[4] as String?,
      notificationUrl: fields[5] as String?,
      category: fields[6] as String?,
      vacancies: fields[7] as int?,
      eligibility: fields[8] as String?,
      isBookmarked: fields[9] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, JobItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.organization)
      ..writeByte(3)
      ..write(obj.deadline)
      ..writeByte(4)
      ..write(obj.applyUrl)
      ..writeByte(5)
      ..write(obj.notificationUrl)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.vacancies)
      ..writeByte(8)
      ..write(obj.eligibility)
      ..writeByte(9)
      ..write(obj.isBookmarked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
