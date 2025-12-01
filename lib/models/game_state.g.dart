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
      unlockedAchievements: (fields[28] as List?)?.cast<String>(),
      claimedAchievements: (fields[29] as List?)?.cast<String>(),
      soundEnabled: fields[30] == null ? true : fields[30] as bool,
      hapticsEnabled: fields[31] == null ? true : fields[31] as bool,
      notificationsEnabled: fields[32] == null ? true : fields[32] as bool,
      lastLoginDate: fields[33] as DateTime?,
      loginStreak: fields[34] == null ? 0 : fields[34] as int,
      totalLoginDays: fields[35] == null ? 0 : fields[35] as int,
      ownedArtifactIds: (fields[36] as List?)?.cast<String>(),
      artifactAcquiredAt: (fields[37] as Map?)?.cast<String, int>(),
      artifactSources: (fields[38] as Map?)?.cast<String, String>(),
      activeLegendaryExpedition: (fields[39] as Map?)?.cast<String, dynamic>(),
      completedLegendaryExpeditions: (fields[40] as List?)?.cast<String>(),
      legendaryExpeditionCooldowns: (fields[41] as Map?)?.cast<String, int>(),
      isMember: fields[42] == null ? false : fields[42] as bool,
      membershipExpiresAt: fields[43] as DateTime?,
      membershipStartedAt: fields[44] as DateTime?,
      purchasedProductIds: (fields[45] as List?)?.cast<String>(),
      dailyAdsWatched: fields[46] == null ? 0 : fields[46] as int,
      lastAdWatchDate: fields[47] as DateTime?,
      freeTimeWarpsUsedToday: fields[48] == null ? 0 : fields[48] as int,
      lastTimeWarpResetDate: fields[49] as DateTime?,
      hasFoundersPack: fields[50] == null ? false : fields[50] as bool,
      activeTheme: fields[51] as String?,
      activeBorder: fields[52] as String?,
      activeParticles: fields[53] as String?,
      ownedCosmetics: (fields[54] as List?)?.cast<String>(),
      lastMonthlyDMClaimed: fields[55] as DateTime?,
      darkEnergy: fields[56] == null ? 0.0 : fields[56] as double,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(57)
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
      ..write(obj.researchTotalPersisted)
      ..writeByte(28)
      ..write(obj.unlockedAchievements)
      ..writeByte(29)
      ..write(obj.claimedAchievements)
      ..writeByte(30)
      ..write(obj.soundEnabled)
      ..writeByte(31)
      ..write(obj.hapticsEnabled)
      ..writeByte(32)
      ..write(obj.notificationsEnabled)
      ..writeByte(33)
      ..write(obj.lastLoginDate)
      ..writeByte(34)
      ..write(obj.loginStreak)
      ..writeByte(35)
      ..write(obj.totalLoginDays)
      ..writeByte(36)
      ..write(obj.ownedArtifactIds)
      ..writeByte(37)
      ..write(obj.artifactAcquiredAt)
      ..writeByte(38)
      ..write(obj.artifactSources)
      ..writeByte(39)
      ..write(obj.activeLegendaryExpedition)
      ..writeByte(40)
      ..write(obj.completedLegendaryExpeditions)
      ..writeByte(41)
      ..write(obj.legendaryExpeditionCooldowns)
      ..writeByte(42)
      ..write(obj.isMember)
      ..writeByte(43)
      ..write(obj.membershipExpiresAt)
      ..writeByte(44)
      ..write(obj.membershipStartedAt)
      ..writeByte(45)
      ..write(obj.purchasedProductIds)
      ..writeByte(46)
      ..write(obj.dailyAdsWatched)
      ..writeByte(47)
      ..write(obj.lastAdWatchDate)
      ..writeByte(48)
      ..write(obj.freeTimeWarpsUsedToday)
      ..writeByte(49)
      ..write(obj.lastTimeWarpResetDate)
      ..writeByte(50)
      ..write(obj.hasFoundersPack)
      ..writeByte(51)
      ..write(obj.activeTheme)
      ..writeByte(52)
      ..write(obj.activeBorder)
      ..writeByte(53)
      ..write(obj.activeParticles)
      ..writeByte(54)
      ..write(obj.ownedCosmetics)
      ..writeByte(55)
      ..write(obj.lastMonthlyDMClaimed)
      ..writeByte(56)
      ..write(obj.darkEnergy);
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
