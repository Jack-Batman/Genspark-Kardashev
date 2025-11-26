// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 0;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      energy: fields[0] as double,
      darkMatter: fields[1] as double,
      kardashevLevel: fields[2] as double,
      currentEra: fields[3] as int,
      generators: (fields[4] as Map?)?.cast<String, int>(),
      generatorLevels: (fields[5] as Map?)?.cast<String, int>(),
      unlockedResearch: (fields[6] as List?)?.cast<String>(),
      ownedArchitects: (fields[7] as List?)?.cast<String>(),
      assignedArchitects: (fields[8] as Map?)?.cast<String, String>(),
      lastOnlineTime: fields[9] as DateTime?,
      totalTaps: fields[10] as int,
      totalEnergyEarned: fields[11] as double,
      playTimeSeconds: fields[12] as int,
      energyMultiplier: fields[13] as double,
      productionBonus: fields[14] as double,
      tutorialCompleted: fields[15] as bool,
      prestigeCount: fields[16] as int,
      prestigeBonus: fields[17] as double,
      prestigeTier: fields[18] as int,
      unlockedEras: (fields[19] as List?)?.cast<int>(),
      autoTapPerSecond: fields[20] as double,
      costReductionBonus: fields[21] as double,
      offlineBonus: fields[22] as double,
      researchSpeedBonus: fields[23] as double,
      darkMatterBonus: fields[24] as double,
      researchStartTime: fields[25] as DateTime?,
      currentResearchIdPersisted: fields[26] as String?,
      researchTotalPersisted: fields[27] == null ? 0 : fields[27] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(28)
      ..writeByte(0)
      ..write(obj.energy)
      ..writeByte(1)
      ..write(obj.darkMatter)
      ..writeByte(2)
      ..write(obj.kardashevLevel)
      ..writeByte(3)
      ..write(obj.currentEra)
      ..writeByte(4)
      ..write(obj.generators)
      ..writeByte(5)
      ..write(obj.generatorLevels)
      ..writeByte(6)
      ..write(obj.unlockedResearch)
      ..writeByte(7)
      ..write(obj.ownedArchitects)
      ..writeByte(8)
      ..write(obj.assignedArchitects)
      ..writeByte(9)
      ..write(obj.lastOnlineTime)
      ..writeByte(10)
      ..write(obj.totalTaps)
      ..writeByte(11)
      ..write(obj.totalEnergyEarned)
      ..writeByte(12)
      ..write(obj.playTimeSeconds)
      ..writeByte(13)
      ..write(obj.energyMultiplier)
      ..writeByte(14)
      ..write(obj.productionBonus)
      ..writeByte(15)
      ..write(obj.tutorialCompleted)
      ..writeByte(16)
      ..write(obj.prestigeCount)
      ..writeByte(17)
      ..write(obj.prestigeBonus)
      ..writeByte(18)
      ..write(obj.prestigeTier)
      ..writeByte(19)
      ..write(obj.unlockedEras)
      ..writeByte(20)
      ..write(obj.autoTapPerSecond)
      ..writeByte(21)
      ..write(obj.costReductionBonus)
      ..writeByte(22)
      ..write(obj.offlineBonus)
      ..writeByte(23)
      ..write(obj.researchSpeedBonus)
      ..writeByte(24)
      ..write(obj.darkMatterBonus)
      ..writeByte(25)
      ..write(obj.researchStartTime)
      ..writeByte(26)
      ..write(obj.currentResearchIdPersisted)
      ..writeByte(27)
      ..write(obj.researchTotalPersisted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
