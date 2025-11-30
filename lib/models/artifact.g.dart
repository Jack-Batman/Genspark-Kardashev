// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artifact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OwnedArtifactAdapter extends TypeAdapter<OwnedArtifact> {
  @override
  final int typeId = 21;

  @override
  OwnedArtifact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OwnedArtifact(
      artifactId: fields[0] as String,
      acquiredAt: fields[1] as DateTime,
      acquiredFrom: fields[2] as String?,
      level: fields[3] as int,
      isEquipped: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OwnedArtifact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.artifactId)
      ..writeByte(1)
      ..write(obj.acquiredAt)
      ..writeByte(2)
      ..write(obj.acquiredFrom)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.isEquipped);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnedArtifactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
