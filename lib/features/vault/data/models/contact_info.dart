import 'package:hive/hive.dart';

/// Contact information for government job applications
class ContactInfo extends HiveObject {
  String? email;
  String? mobile;
  String? addressLine1;
  String? addressLine2;
  String? addressLine3;
  String? state;
  String? pinCode;

  ContactInfo({
    this.email,
    this.mobile,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.state,
    this.pinCode,
  });

  /// Get full address as single string
  String get fullAddress {
    final parts = [
      addressLine1,
      addressLine2,
      addressLine3,
      state,
      pinCode,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get all fields as a Map for the Sidekick Panel
  Map<String, String> toFieldsMap() {
    return {
      'Email': email ?? '',
      'Mobile': mobile ?? '',
      'Address Line 1': addressLine1 ?? '',
      'Address Line 2': addressLine2 ?? '',
      'Address Line 3': addressLine3 ?? '',
      'State': state ?? '',
      'Pin Code': pinCode ?? '',
      'Full Address': fullAddress,
    };
  }

  @override
  String toString() {
    return 'ContactInfo(email: $email, mobile: $mobile, state: $state)';
  }
}

/// Hive TypeAdapter for ContactInfo
class ContactInfoAdapter extends TypeAdapter<ContactInfo> {
  @override
  final int typeId = 2;

  @override
  ContactInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactInfo(
      email: fields[0] as String?,
      mobile: fields[1] as String?,
      addressLine1: fields[2] as String?,
      addressLine2: fields[3] as String?,
      addressLine3: fields[4] as String?,
      state: fields[5] as String?,
      pinCode: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContactInfo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.mobile)
      ..writeByte(2)
      ..write(obj.addressLine1)
      ..writeByte(3)
      ..write(obj.addressLine2)
      ..writeByte(4)
      ..write(obj.addressLine3)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.pinCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
