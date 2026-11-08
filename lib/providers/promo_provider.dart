import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/analytics_service.dart';
import '../models/promo_model.dart';

typedef StoreUrlLauncher = Future<bool> Function(Uri uri);

class PromoProvider extends ChangeNotifier {
  static bool isTesting = false;
  static const String cacheKey = 'cached_sauki_promo_v1';
  static const String prefLastShownMs = 'sauki_promo_last_shown_ms';
  static const String prefStoreClicked = 'sauki_promo_store_clicked';

  SaukiPromoConfig _config = SaukiPromoConfig.defaults;
  bool _sessionModalChecked = false;
  bool _wasOffline = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _firestoreSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  StoreUrlLauncher? _customLauncher;

  PromoProvider({StoreUrlLauncher? customLauncher})
      : _customLauncher = customLauncher {
    _initialize();
  }

  SaukiPromoConfig get config => _config;

  @visibleForTesting
  void setCustomLauncherForTesting(StoreUrlLauncher? launcher) {
    _customLauncher = launcher;
  }

  @visibleForTesting
  void setConfigForTesting(SaukiPromoConfig config) {
    _config = config;
    notifyListeners();
  }

  @visibleForTesting
  void resetSessionModalCheckForTesting() {
    _sessionModalChecked = false;
  }

  Future<void> _initialize() async {
    await _loadFromLocalCache();
    _initConnectivityListener();
    _attachFirestoreListener();
    unawaited(refresh());
  }

  void _initConnectivityListener() {
    if (isTesting ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }
    try {
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((results) {
        final isOffline = results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        if (!isOffline && _wasOffline) {
          syncRemote();
        }
        _wasOffline = isOffline;
      });
    } catch (e) {
      debugPrint('[PromoProvider] Connectivity listener note: $e');
    }
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _config = SaukiPromoConfig.fromMap(decoded);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[PromoProvider] Local cache read note: $e');
    }
  }

  Future<void> _saveToLocalCache(SaukiPromoConfig updated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(updated.toMap()));
    } catch (e) {
      debugPrint('[PromoProvider] Local cache save note: $e');
    }
  }

  void _attachFirestoreListener() {
    if (Firebase.apps.isEmpty) {
      if (isTesting ||
          WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
        return;
      }
      _retryTimer?.cancel();
      _retryTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
        if (Firebase.apps.isNotEmpty) {
          t.cancel();
          _attachFirestoreListener();
        }
        if (t.tick > 25) {
          t.cancel();
        }
      });
      return;
    }

    try {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = FirebaseFirestore.instance
          .collection('app_config')
          .doc('sauki_promo')
          .snapshots(includeMetadataChanges: true)
          .listen(
        (snapshot) {
          final data = snapshot.data();
          if (snapshot.exists && data != null) {
            final updated = SaukiPromoConfig.fromMap(data);
            _config = updated;
            _saveToLocalCache(updated);
            _wasOffline = false;
            notifyListeners();
          }
        },
        onError: (error) {
          _wasOffline = true;
          debugPrint('[PromoProvider] Firestore stream note: $error');
        },
      );
    } catch (e) {
      _wasOffline = true;
      debugPrint('[PromoProvider] Firebase note: $e');
    }
  }

  void syncRemote() {
    _attachFirestoreListener();
    unawaited(refresh());
  }

  Future<void> refresh() async {
    if (Firebase.apps.isEmpty) return;
    try {
      DocumentSnapshot<Map<String, dynamic>> doc;
      try {
        doc = await FirebaseFirestore.instance
            .collection('app_config')
            .doc('sauki_promo')
            .get(const GetOptions(source: Source.serverAndCache));
      } catch (_) {
        doc = await FirebaseFirestore.instance
            .collection('app_config')
            .doc('sauki_promo')
            .get();
      }
      final data = doc.data();
      if (doc.exists && data != null) {
        final updated = SaukiPromoConfig.fromMap(data);
        _config = updated;
        await _saveToLocalCache(updated);
        _wasOffline = false;
        notifyListeners();
      }
    } catch (e) {
      _wasOffline = true;
      debugPrint('[PromoProvider] Refresh note: $e');
    }
  }

  /// Evaluates whether the startup dismissable modal should automatically appear.
  /// Shows once on first launch/update, then at most once every [cooldownDays]
  /// until the user clicks either store badge.
  Future<bool> shouldAutoShowModal() async {
    if (_sessionModalChecked) return false;
    _sessionModalChecked = true;

    await _loadFromLocalCache();
    if (!_config.enabled || !_config.modalEnabled) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasClickedStore = prefs.getBool(prefStoreClicked) ?? false;
      if (hasClickedStore) return false;

      final lastShownMs = prefs.getInt(prefLastShownMs) ?? 0;
      if (lastShownMs > 0) {
        final elapsedMs = DateTime.now().millisecondsSinceEpoch - lastShownMs;
        final cooldownMs =
            Duration(days: _config.cooldownDays).inMilliseconds;
        if (elapsedMs < cooldownMs) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markModalShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        prefLastShownMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<void> markStoreClicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefStoreClicked, true);
    } catch (_) {}
  }

  Future<bool> openStore(
    SaukiStorePlatform platform, {
    required String placement,
  }) async {
    final isIos = platform == SaukiStorePlatform.ios;
    final urlString = isIos ? _config.appStoreUrl : _config.playStoreUrl;
    final storeName = isIos ? 'app_store' : 'play_store';

    await markStoreClicked();
    unawaited(
      AnalyticsService.instance.logSaukiPromoStoreClick(
        store: storeName,
        placement: placement,
        url: urlString,
      ),
    );

    final uri = Uri.parse(urlString);
    try {
      if (_customLauncher != null) {
        return await _customLauncher!(uri);
      }
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[PromoProvider] Store launch error: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _firestoreSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
