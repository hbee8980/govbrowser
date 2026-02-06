import 'package:hive/hive.dart';

/// Education record for government job applications
class EducationInfo extends HiveObject {
  String? classLevel; // 10th, 12th, Graduation, Post-Graduation, Diploma
  String? boardOrUniversity;
  String? rollNo;
  int? passingYear;
  double? percentageOrCgpa;
  String? certificateNo;
  String? subjectOrStream; // Science, Commerce, Arts, Engineering, etc.

  EducationInfo({
    this.classLevel,
    this.boardOrUniversity,
    this.rollNo,
    this.passingYear,
    this.percentageOrCgpa,
    this.certificateNo,
    this.subjectOrStream,
  });

  /// Get formatted percentage/CGPA
  String get formattedScore {
    if (percentageOrCgpa == null) return '';
    if (percentageOrCgpa! > 10) {
      return '${percentageOrCgpa!.toStringAsFixed(2)}%';
    }
    return '${percentageOrCgpa!.toStringAsFixed(2)} CGPA';
  }

  /// Get display label for this education entry
  String get displayLabel {
    return '$classLevel (${passingYear ?? 'N/A'})';
  }

  /// Get all fields as a Map for the Sidekick Panel
  Map<String, String> toFieldsMap() {
    final prefix = classLevel ?? 'Education';
    return {
      '$prefix - Board/University': boardOrUniversity ?? '',
      '$prefix - Roll No': rollNo ?? '',
      '$prefix - Passing Year': passingYear?.toString() ?? '',
      '$prefix - Percentage/CGPA': formattedScore,
      '$prefix - Certificate No': certificateNo ?? '',
      '$prefix - Subject/Stream': subjectOrStream ?? '',
    };
  }

  @override
  String toString() {
    return 'EducationInfo($classLevel, $boardOrUniversity, $passingYear)';
  }
}

/// Hive TypeAdapter for EducationInfo
class EducationInfoAdapter extends TypeAdapter<EducationInfo> {
  @override
  final int typeId = 3;

  @override
  EducationInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EducationInfo(
      classLevel: fields[0] as String?,
      boardOrUniversity: fields[1] as String?,
      rollNo: fields[2] as String?,
      passingYear: fields[3] as int?,
      percentageOrCgpa: fields[4] as double?,
      certificateNo: fields[5] as String?,
      subjectOrStream: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EducationInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.classLevel)
      ..writeByte(1)
      ..write(obj.boardOrUniversity)
      ..writeByte(2)
      ..write(obj.rollNo)
      ..writeByte(3)
      ..write(obj.passingYear)
      ..writeByte(4)
      ..write(obj.percentageOrCgpa)
      ..writeByte(5)
      ..write(obj.certificateNo)
      ..writeByte(6)
      ..write(obj.subjectOrStream);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EducationInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
