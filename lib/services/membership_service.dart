import 'dart:async';
import 'package:flutter/foundation.dart';

/// Membership tier
enum MembershipTier {
  free,
  cosmic,
}

/// Membership benefits configuration
class MembershipBenefits {
  final double dailyRewardMultiplier;
  final int bonusDailyChallenges;
  final double offlineEfficiencyBonus;
  final int maxOfflineHours;
  final int freeTimeWarpsPerDay;
  final int maxExpeditions;
  final int monthlyDarkMatter;
  final String? exclusiveBorder;
  final bool prioritySupport;
  
  const MembershipBenefits({
    this.dailyRewardMultiplier = 1.0,
    this.bonusDailyChallenges = 0,
    this.offlineEfficiencyBonus = 0.0,
    this.maxOfflineHours = 3,
    this.freeTimeWarpsPerDay = 0,
    this.maxExpeditions = 3,
    this.monthlyDarkMatter = 0,
    this.exclusiveBorder,
    this.prioritySupport = false,
  });
}

/// Free tier benefits
const MembershipBenefits freeBenefits = MembershipBenefits(
  dailyRewardMultiplier: 1.0,
  bonusDailyChallenges: 0,
  offlineEfficiencyBonus: 0.0,
  maxOfflineHours: 3,
  freeTimeWarpsPerDay: 0,
  maxExpeditions: 3,
  monthlyDarkMatter: 0,
  exclusiveBorder: null,
  prioritySupport: false,
);

/// Cosmic membership benefits
const MembershipBenefits cosmicBenefits = MembershipBenefits(
  dailyRewardMultiplier: 2.0,
  bonusDailyChallenges: 1,
  offlineEfficiencyBonus: 0.5, // +50%
  maxOfflineHours: 24,
  freeTimeWarpsPerDay: 1,
  maxExpeditions: 4,
  monthlyDarkMatter: 500,
  exclusiveBorder: 'cosmic_member',
  prioritySupport: true,
);

/// Membership status
class MembershipStatus {
  final MembershipTier tier;
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final bool isActive;
  final int daysRemaining;
  final MembershipBenefits benefits;
  
  const MembershipStatus({
    required this.tier,
    this.expiresAt,
    this.startedAt,
    required this.isActive,
    this.daysRemaining = 0,
    required this.benefits,
  });
  
  factory MembershipStatus.free() => const MembershipStatus(
    tier: MembershipTier.free,
    isActive: false,
    benefits: freeBenefits,
  );
  
  factory MembershipStatus.cosmic({
    required DateTime expiresAt,
    required DateTime startedAt,
  }) {
    final now = DateTime.now();
    final isActive = expiresAt.isAfter(now);
    final daysRemaining = isActive 
        ? expiresAt.difference(now).inDays 
        : 0;
    
    return MembershipStatus(
      tier: MembershipTier.cosmic,
      expiresAt: expiresAt,
      startedAt: startedAt,
      isActive: isActive,
      daysRemaining: daysRemaining,
      benefits: isActive ? cosmicBenefits : freeBenefits,
    );
  }
}

/// Service for managing membership subscriptions
class MembershipService {
  static final MembershipService _instance = MembershipService._internal();
  factory MembershipService() => _instance;
  MembershipService._internal();
  
  // Membership state
  MembershipStatus _status = MembershipStatus.free();
  int _freeTimeWarpsUsedToday = 0;
  DateTime? _lastTimeWarpResetDate;
  
  // Monthly DM tracking
  DateTime? _lastMonthlyDMClaimDate;
  
  // Callbacks
  Function(MembershipStatus)? onStatusChanged;
  
  /// Get current membership status
  MembershipStatus get status => _status;
  
  /// Check if player has active membership
  bool get isCosmicMember => _status.tier == MembershipTier.cosmic && _status.isActive;
  
  /// Get current benefits
  MembershipBenefits get benefits => _status.benefits;
  
  /// Get max offline hours based on membership
  int get maxOfflineHours => benefits.maxOfflineHours;
  
  /// Get max expeditions based on membership
  int get maxExpeditions => benefits.maxExpeditions;
  
  /// Get daily reward multiplier
  double get dailyRewardMultiplier => benefits.dailyRewardMultiplier;
  
  /// Get offline efficiency bonus
  double get offlineEfficiencyBonus => benefits.offlineEfficiencyBonus;
  
  /// Initialize membership service
  Future<void> initialize() async {
    // In production: Check subscription status with store
    // Load saved membership data
    _resetDailyTimeWarpsIfNeeded();
    
    if (kDebugMode) {
      debugPrint('MembershipService initialized');
    }
  }
  
  /// Load membership data from storage
  void loadMembershipData({
    DateTime? expiresAt,
    DateTime? startedAt,
    int freeTimeWarpsUsedToday = 0,
    DateTime? lastTimeWarpResetDate,
    DateTime? lastMonthlyDMClaimDate,
  }) {
    if (expiresAt != null && startedAt != null) {
      _status = MembershipStatus.cosmic(
        expiresAt: expiresAt,
        startedAt: startedAt,
      );
    } else {
      _status = MembershipStatus.free();
    }
    
    _freeTimeWarpsUsedToday = freeTimeWarpsUsedToday;
    _lastTimeWarpResetDate = lastTimeWarpResetDate;
    _lastMonthlyDMClaimDate = lastMonthlyDMClaimDate;
    
    _resetDailyTimeWarpsIfNeeded();
  }
  
  /// Activate membership (after successful purchase)
  void activateMembership({int durationDays = 30}) {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: durationDays));
    
    _status = MembershipStatus.cosmic(
      expiresAt: expiresAt,
      startedAt: now,
    );
    
    onStatusChanged?.call(_status);
    
    if (kDebugMode) {
      debugPrint('Membership activated until: $expiresAt');
    }
  }
  
  /// Extend membership
  void extendMembership({int durationDays = 30}) {
    if (_status.tier != MembershipTier.cosmic) {
      activateMembership(durationDays: durationDays);
      return;
    }
    
    final currentExpiry = _status.expiresAt ?? DateTime.now();
    final startDate = currentExpiry.isAfter(DateTime.now()) 
        ? currentExpiry 
        : DateTime.now();
    final newExpiry = startDate.add(Duration(days: durationDays));
    
    _status = MembershipStatus.cosmic(
      expiresAt: newExpiry,
      startedAt: _status.startedAt ?? DateTime.now(),
    );
    
    onStatusChanged?.call(_status);
  }
  
  /// Cancel membership (will expire at end of period)
  void cancelMembership() {
    // Membership remains active until expiry
    if (kDebugMode) {
      debugPrint('Membership cancelled, expires at: ${_status.expiresAt}');
    }
  }
  
  /// Check if free time warp is available today
  bool get canUseFreeTimeWarp {
    if (!isCosmicMember) return false;
    
    _resetDailyTimeWarpsIfNeeded();
    return _freeTimeWarpsUsedToday < benefits.freeTimeWarpsPerDay;
  }
  
  /// Get remaining free time warps today
  int get remainingFreeTimeWarps {
    if (!isCosmicMember) return 0;
    
    _resetDailyTimeWarpsIfNeeded();
    return (benefits.freeTimeWarpsPerDay - _freeTimeWarpsUsedToday)
        .clamp(0, benefits.freeTimeWarpsPerDay);
  }
  
  /// Use a free time warp
  bool useFreeTimeWarp() {
    if (!canUseFreeTimeWarp) return false;
    
    _freeTimeWarpsUsedToday++;
    return true;
  }
  
  /// Check if monthly dark matter can be claimed
  bool get canClaimMonthlyDarkMatter {
    if (!isCosmicMember) return false;
    if (benefits.monthlyDarkMatter <= 0) return false;
    
    if (_lastMonthlyDMClaimDate == null) return true;
    
    // Check if it's a new month since last claim
    final now = DateTime.now();
    return now.year > _lastMonthlyDMClaimDate!.year ||
           now.month > _lastMonthlyDMClaimDate!.month;
  }
  
  /// Claim monthly dark matter
  int claimMonthlyDarkMatter() {
    if (!canClaimMonthlyDarkMatter) return 0;
    
    _lastMonthlyDMClaimDate = DateTime.now();
    return benefits.monthlyDarkMatter;
  }
  
  /// Reset daily time warps at midnight
  void _resetDailyTimeWarpsIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastTimeWarpResetDate == null || 
        _lastTimeWarpResetDate!.isBefore(today)) {
      _freeTimeWarpsUsedToday = 0;
      _lastTimeWarpResetDate = today;
    }
  }
  
  /// Get membership data for saving
  Map<String, dynamic> getMembershipData() {
    return {
      'tier': _status.tier.index,
      'expiresAt': _status.expiresAt?.millisecondsSinceEpoch,
      'startedAt': _status.startedAt?.millisecondsSinceEpoch,
      'freeTimeWarpsUsedToday': _freeTimeWarpsUsedToday,
      'lastTimeWarpResetDate': _lastTimeWarpResetDate?.millisecondsSinceEpoch,
      'lastMonthlyDMClaimDate': _lastMonthlyDMClaimDate?.millisecondsSinceEpoch,
    };
  }
  
  /// Get membership comparison for UI
  List<Map<String, dynamic>> getMembershipComparison() {
    return [
      {
        'feature': 'Daily Rewards',
        'free': '1x',
        'cosmic': '2x',
      },
      {
        'feature': 'Offline Earnings',
        'free': '3 hours max',
        'cosmic': '24 hours max',
      },
      {
        'feature': 'Offline Efficiency',
        'free': 'Base rate',
        'cosmic': '+50% bonus',
      },
      {
        'feature': 'Daily Challenges',
        'free': '3 per day',
        'cosmic': '4 per day',
      },
      {
        'feature': 'Active Expeditions',
        'free': '3 max',
        'cosmic': '4 max',
      },
      {
        'feature': 'Free Daily Time Warp',
        'free': '—',
        'cosmic': '1 hour/day',
      },
      {
        'feature': 'Monthly Dark Matter',
        'free': '—',
        'cosmic': '500 DM',
      },
      {
        'feature': 'Exclusive Border',
        'free': '—',
        'cosmic': '✓',
      },
    ];
  }
  
  /// Dispose resources
  void dispose() {
    // Cleanup if needed
  }
}
