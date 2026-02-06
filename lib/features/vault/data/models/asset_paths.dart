import 'package:hive/hive.dart';

/// Paths to locally stored document images for form uploads
class AssetPaths extends HiveObject {
  String? photoPath;
  String? signaturePath;
  String? thumbImpressionPath;
  String? casteCertificatePath;
  String? incomeCertificatePath;
  String? domicileCertificatePath;
  String? idProofPath;

  AssetPaths({
    this.photoPath,
    this.signaturePath,
    this.thumbImpressionPath,
    this.casteCertificatePath,
    this.incomeCertificatePath,
    this.domicileCertificatePath,
    this.idProofPath,
  });

  /// Get all asset entries with labels
  Map<String, String?> toAssetsMap() {
    return {
      'Photo': photoPath,
      'Signature': signaturePath,
      'Thumb Impression': thumbImpressionPath,
      'Caste Certificate': casteCertificatePath,
      'Income Certificate': incomeCertificatePath,
      'Domicile Certificate': domicileCertificatePath,
      'ID Proof': idProofPath,
    };
  }

  /// Get only assets that have paths set
  Map<String, String> get availableAssets {
    return Map.fromEntries(
      toAssetsMap().entries.where(
        (e) => e.value != null && e.value!.isNotEmpty,
      ),
    ).cast<String, String>();
  }

  /// Check if any assets are configured
  bool get hasAnyAssets {
    return availableAssets.isNotEmpty;
  }

  @override
  String toString() {
    return 'AssetPaths(photo: ${photoPath != null}, signature: ${signaturePath != null})';
  }
}

/// Hive TypeAdapter for AssetPaths
class AssetPathsAdapter extends TypeAdapter<AssetPaths> {
  @override
  final int typeId = 4;

  @override
  AssetPaths read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssetPaths(
      photoPath: fields[0] as String?,
      signaturePath: fields[1] as String?,
      thumbImpressionPath: fields[2] as String?,
      casteCertificatePath: fields[3] as String?,
      incomeCertificatePath: fields[4] as String?,
      domicileCertificatePath: fields[5] as String?,
      idProofPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AssetPaths obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.photoPath)
      ..writeByte(1)
      ..write(obj.signaturePath)
      ..writeByte(2)
      ..write(obj.thumbImpressionPath)
      ..writeByte(3)
      ..write(obj.casteCertificatePath)
      ..writeByte(4)
      ..write(obj.incomeCertificatePath)
      ..writeByte(5)
      ..write(obj.domicileCertificatePath)
      ..writeByte(6)
      ..write(obj.idProofPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetPathsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
