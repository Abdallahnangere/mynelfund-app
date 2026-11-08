enum SaukiStorePlatform { ios, android }

/// Offline-first configuration model for the Sauki Go companion app promotion.
class SaukiPromoConfig {
  static const String defaultAppStoreUrl =
      'https://apps.apple.com/app/id6815456102';
  static const String defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.saukimart.go';

  final bool enabled;
  final bool modalEnabled;
  final int cooldownDays;
  final String appName;
  final String badgeEn;
  final String badgeHa;
  final String headlineEn;
  final String headlineHa;
  final String subtitleEn;
  final String subtitleHa;
  final String monthlyTagEn;
  final String monthlyTagHa;
  final String plan1Data;
  final String plan1Price;
  final String plan1PeriodEn;
  final String plan1PeriodHa;
  final String plan2Data;
  final String plan2Price;
  final String plan2PeriodEn;
  final String plan2PeriodHa;
  final String appStoreUrl;
  final String playStoreUrl;

  const SaukiPromoConfig({
    this.enabled = true,
    this.modalEnabled = true,
    this.cooldownDays = 7,
    this.appName = 'Sauki Go',
    this.badgeEn = 'TRUSTED APP • SAUKI GO',
    this.badgeHa = 'AMINTACCIYAR MANHAJA • SAUKI GO',
    this.headlineEn = 'Get affordable data and airtime from our trusted app',
    this.headlineHa =
        'Samu data da katin waya mai sauƙi daga amintacciyar manhajarmu',
    this.subtitleEn =
        'Stay connected for lectures, research & NELFUND portal updates.',
    this.subtitleHa =
        'Kasance cikin haɗin yanar gizo don karatu da sabuntawar shafin NELFUND.',
    this.monthlyTagEn = 'All Monthly',
    this.monthlyTagHa = 'Duka na Wata-Wata',
    this.plan1Data = '1GB',
    this.plan1Price = '₦400',
    this.plan1PeriodEn = 'Monthly',
    this.plan1PeriodHa = 'Na Wata',
    this.plan2Data = '5GB',
    this.plan2Price = '₦1,500',
    this.plan2PeriodEn = 'Monthly',
    this.plan2PeriodHa = 'Na Wata',
    this.appStoreUrl = defaultAppStoreUrl,
    this.playStoreUrl = defaultPlayStoreUrl,
  });

  static const SaukiPromoConfig defaults = SaukiPromoConfig();

  String badge(bool isHausa) => isHausa ? badgeHa : badgeEn;
  String headline(bool isHausa) => isHausa ? headlineHa : headlineEn;
  String subtitle(bool isHausa) => isHausa ? subtitleHa : subtitleEn;
  String monthlyTag(bool isHausa) => isHausa ? monthlyTagHa : monthlyTagEn;
  String plan1Period(bool isHausa) => isHausa ? plan1PeriodHa : plan1PeriodEn;
  String plan2Period(bool isHausa) => isHausa ? plan2PeriodHa : plan2PeriodEn;

  factory SaukiPromoConfig.fromMap(Map<String, dynamic> map) {
    String nonEmpty(dynamic val, String fallback) {
      if (val is String && val.trim().isNotEmpty) {
        return val.trim();
      }
      return fallback;
    }

    int parseCooldown(dynamic val) {
      if (val is int && val >= 0) return val;
      if (val is num && val >= 0) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val.trim());
        if (parsed != null && parsed >= 0) return parsed;
      }
      return defaults.cooldownDays;
    }

    return SaukiPromoConfig(
      enabled: map['enabled'] is bool ? map['enabled'] as bool : defaults.enabled,
      modalEnabled: map['modalEnabled'] is bool
          ? map['modalEnabled'] as bool
          : defaults.modalEnabled,
      cooldownDays: parseCooldown(map['cooldownDays']),
      appName: nonEmpty(map['appName'], defaults.appName),
      badgeEn: nonEmpty(map['badgeEn'], defaults.badgeEn),
      badgeHa: nonEmpty(map['badgeHa'], defaults.badgeHa),
      headlineEn: nonEmpty(map['headlineEn'], defaults.headlineEn),
      headlineHa: nonEmpty(map['headlineHa'], defaults.headlineHa),
      subtitleEn: nonEmpty(map['subtitleEn'], defaults.subtitleEn),
      subtitleHa: nonEmpty(map['subtitleHa'], defaults.subtitleHa),
      monthlyTagEn: nonEmpty(
        map['monthlyTagEn'] ?? map['cycleEn'],
        defaults.monthlyTagEn,
      ),
      monthlyTagHa: nonEmpty(
        map['monthlyTagHa'] ?? map['cycleHa'],
        defaults.monthlyTagHa,
      ),
      plan1Data: nonEmpty(map['plan1Data'], defaults.plan1Data),
      plan1Price: nonEmpty(map['plan1Price'], defaults.plan1Price),
      plan1PeriodEn: nonEmpty(map['plan1PeriodEn'], defaults.plan1PeriodEn),
      plan1PeriodHa: nonEmpty(map['plan1PeriodHa'], defaults.plan1PeriodHa),
      plan2Data: nonEmpty(map['plan2Data'], defaults.plan2Data),
      plan2Price: nonEmpty(map['plan2Price'], defaults.plan2Price),
      plan2PeriodEn: nonEmpty(map['plan2PeriodEn'], defaults.plan2PeriodEn),
      plan2PeriodHa: nonEmpty(map['plan2PeriodHa'], defaults.plan2PeriodHa),
      appStoreUrl: nonEmpty(map['appStoreUrl'], defaults.appStoreUrl),
      playStoreUrl: nonEmpty(map['playStoreUrl'], defaults.playStoreUrl),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'modalEnabled': modalEnabled,
      'cooldownDays': cooldownDays,
      'appName': appName,
      'badgeEn': badgeEn,
      'badgeHa': badgeHa,
      'headlineEn': headlineEn,
      'headlineHa': headlineHa,
      'subtitleEn': subtitleEn,
      'subtitleHa': subtitleHa,
      'monthlyTagEn': monthlyTagEn,
      'monthlyTagHa': monthlyTagHa,
      'cycleEn': monthlyTagEn,
      'cycleHa': monthlyTagHa,
      'plan1Data': plan1Data,
      'plan1Price': plan1Price,
      'plan1PeriodEn': plan1PeriodEn,
      'plan1PeriodHa': plan1PeriodHa,
      'plan2Data': plan2Data,
      'plan2Price': plan2Price,
      'plan2PeriodEn': plan2PeriodEn,
      'plan2PeriodHa': plan2PeriodHa,
      'appStoreUrl': appStoreUrl,
      'playStoreUrl': playStoreUrl,
    };
  }
}
