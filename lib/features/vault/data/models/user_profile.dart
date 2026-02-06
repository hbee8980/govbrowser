import 'package:hive/hive.dart';
import 'personal_info.dart';
import 'contact_info.dart';
import 'education_info.dart';
import 'asset_paths.dart';

/// The aggregate root for the User Vault
class UserProfile extends HiveObject {
  PersonalInfo? personal;
  ContactInfo? contact;
  List<EducationInfo>? education;
  AssetPaths? assets;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfile({
    this.personal,
    this.contact,
    this.education,
    this.assets,
    this.createdAt,
    this.updatedAt,
  });

  /// Create an empty profile
  factory UserProfile.empty() {
    return UserProfile(
      personal: PersonalInfo(),
      contact: ContactInfo(),
      education: [],
      assets: AssetPaths(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a demo profile with sample data
  factory UserProfile.demo() {
    return UserProfile(
      personal: PersonalInfo(
        name: 'Rahul Kumar Sharma',
        fatherName: 'Rajesh Kumar Sharma',
        dob: DateTime(1998, 5, 15),
        category: 'OBC',
        gender: 'Male',
        aadhaarNo: '1234 5678 9012',
      ),
      contact: ContactInfo(
        email: 'rahul.sharma@email.com',
        mobile: '9876543210',
        addressLine1: '123, Gandhi Nagar',
        addressLine2: 'Near Shiv Temple',
        addressLine3: 'Lucknow',
        state: 'Uttar Pradesh',
        pinCode: '226001',
      ),
      education: [
        EducationInfo(
          classLevel: '10th',
          boardOrUniversity: 'CBSE',
          rollNo: '1234567',
          passingYear: 2014,
          percentageOrCgpa: 85.5,
          certificateNo: 'CBSE/2014/123456',
        ),
        EducationInfo(
          classLevel: '12th',
          boardOrUniversity: 'CBSE',
          rollNo: '7654321',
          passingYear: 2016,
          percentageOrCgpa: 78.2,
          subjectOrStream: 'Science (PCM)',
          certificateNo: 'CBSE/2016/654321',
        ),
        EducationInfo(
          classLevel: 'Graduation',
          boardOrUniversity: 'Lucknow University',
          rollNo: '2020/BA/1234',
          passingYear: 2020,
          percentageOrCgpa: 7.8,
          subjectOrStream: 'B.Sc. Mathematics',
          certificateNo: 'LU/2020/BSC/1234',
        ),
      ],
      assets: AssetPaths(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get all text fields consolidated for the Sidekick Panel
  Map<String, String> getAllTextFields() {
    final Map<String, String> fields = {};

    // Add personal fields
    if (personal != null) {
      fields.addAll(personal!.toFieldsMap());
    }

    // Add contact fields
    if (contact != null) {
      fields.addAll(contact!.toFieldsMap());
    }

    // Add education fields (all levels)
    if (education != null) {
      for (final edu in education!) {
        fields.addAll(edu.toFieldsMap());
      }
    }

    // Filter out empty values
    fields.removeWhere((key, value) => value.isEmpty);

    return fields;
  }

  /// Get searchable fields (key-value pairs that match a query)
  Map<String, String> searchFields(String query) {
    if (query.isEmpty) return getAllTextFields();

    final lowerQuery = query.toLowerCase();
    return Map.fromEntries(
      getAllTextFields().entries.where(
        (e) =>
            e.key.toLowerCase().contains(lowerQuery) ||
            e.value.toLowerCase().contains(lowerQuery),
      ),
    );
  }

  /// Check if profile has minimum required data
  bool get isComplete {
    return personal?.name != null &&
        personal!.name!.isNotEmpty &&
        contact?.mobile != null &&
        contact!.mobile!.isNotEmpty;
  }

  /// Get completion percentage (0-100)
  int get completionPercentage {
    int filled = 0;
    int total = 0;

    // Personal fields (6 fields)
    if (personal != null) {
      total += 6;
      final pFields = personal!.toFieldsMap();
      filled += pFields.values.where((v) => v.isNotEmpty).length;
    }

    // Contact fields (7 fields)
    if (contact != null) {
      total += 7;
      final cFields = contact!.toFieldsMap();
      filled += cFields.entries
          .where((e) => e.key != 'Full Address' && e.value.isNotEmpty)
          .length;
    }

    // Education (count as 1 if any exists)
    total += 1;
    if (education != null && education!.isNotEmpty) {
      filled += 1;
    }

    // Assets (count as 1 if photo and signature exist)
    total += 1;
    if (assets != null &&
        assets!.photoPath != null &&
        assets!.signaturePath != null) {
      filled += 1;
    }

    if (total == 0) return 0;
    return ((filled / total) * 100).round();
  }

  @override
  String toString() {
    return 'UserProfile(name: ${personal?.name}, completion: $completionPercentage%)';
  }
}

/// Hive TypeAdapter for UserProfile
class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      personal: fields[0] as PersonalInfo?,
      contact: fields[1] as ContactInfo?,
      education: (fields[2] as List?)?.cast<EducationInfo>(),
      assets: fields[3] as AssetPaths?,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.personal)
      ..writeByte(1)
      ..write(obj.contact)
      ..writeByte(2)
      ..write(obj.education)
      ..writeByte(3)
      ..write(obj.assets)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
