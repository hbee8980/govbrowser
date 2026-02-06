import 'package:hive/hive.dart';

/// Personal information for government job applications
class PersonalInfo extends HiveObject {
  String? name;
  String? fatherName;
  DateTime? dob;
  String? category; // OBC, SC, ST, General, EWS
  String? gender; // Male, Female, Other
  String? aadhaarNo;

  PersonalInfo({
    this.name,
    this.fatherName,
    this.dob,
    this.category,
    this.gender,
    this.aadhaarNo,
  });

  /// Get formatted date of birth
  String get formattedDob {
    if (dob == null) return '';
    return '${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}';
  }

  /// Get all fields as a Map for the Sidekick Panel
  Map<String, String> toFieldsMap() {
    return {
      'Name': name ?? '',
      'Father\'s Name': fatherName ?? '',
      'Date of Birth': formattedDob,
      'Category': category ?? '',
      'Gender': gender ?? '',
      'Aadhaar No.': aadhaarNo ?? '',
    };
  }

  @override
  String toString() {
    return 'PersonalInfo(name: $name, fatherName: $fatherName, dob: $dob, category: $category, gender: $gender)';
  }
}

/// Hive TypeAdapter for PersonalInfo
class PersonalInfoAdapter extends TypeAdapter<PersonalInfo> {
  @override
  final int typeId = 1;

  @override
  PersonalInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalInfo(
      name: fields[0] as String?,
      fatherName: fields[1] as String?,
      dob: fields[2] as DateTime?,
      category: fields[3] as String?,
      gender: fields[4] as String?,
      aadhaarNo: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.fatherName)
      ..writeByte(2)
      ..write(obj.dob)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.aadhaarNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
