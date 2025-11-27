// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorialStateDataAdapter extends TypeAdapter<TutorialStateData> {
  @override
  final int typeId = 20;

  @override
  TutorialStateData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TutorialStateData(
      introCompleted: fields[0] as bool? ?? false,
      seenTutorials: (fields[1] as List?)?.cast<String>(),
      seenHints: (fields[2] as List?)?.cast<String>(),
      hintsEnabled: fields[3] as bool? ?? true,
      lastHintTime: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TutorialStateData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.introCompleted)
      ..writeByte(1)
      ..write(obj.seenTutorials)
      ..writeByte(2)
      ..write(obj.seenHints)
      ..writeByte(3)
      ..write(obj.hintsEnabled)
      ..writeByte(4)
      ..write(obj.lastHintTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialStateDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
