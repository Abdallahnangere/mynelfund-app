import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/faq_model.dart';

class FaqProvider extends ChangeNotifier {
  static bool isTesting = false;
  static const String _cacheKey = 'cached_faqs_v1';
  static FaqProvider? current;

  FaqCategory _selectedCategory = FaqCategory.all;
  String _searchQuery = '';
  final Set<String> _expandedIds = {};

  List<FaqItem> _items = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _firestoreSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _wasOffline = false;

  FaqProvider() {
    current = this;
    _initialize();
  }

  FaqCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<FaqItem> get allItems => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    // 1. Immediately load local cache for 0ms offline startup
    await _loadFromLocalCache();

    // 2. Initialize connectivity listener for auto-sync on network resumption
    _initConnectivityListener();

    // 3. Attach live Firestore listener
    _attachFirestoreListener();

    // 4. Actively fetch from remote
    unawaited(refresh());
  }

  void _initConnectivityListener() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        results,
      ) {
        final isOffline =
            results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        if (!isOffline && (_wasOffline || _items.isEmpty)) {
          debugPrint(
            '[FaqProvider] Active network detected! Syncing FAQs from Firestore...',
          );
          syncRemote();
        }
        _wasOffline = isOffline;
      });
    } catch (e) {
      debugPrint('[FaqProvider] Connectivity listener note: $e');
    }
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        if (decoded.isNotEmpty) {
          _items = decoded
              .map((e) => FaqItem.fromMap(e as Map<String, dynamic>))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[FaqProvider] Local cache read note: $e');
    }
  }

  Future<void> _saveToLocalCache(List<FaqItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(items.map((e) => e.toMap()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (e) {
      debugPrint('[FaqProvider] Local cache save note: $e');
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
          .collection('faqs')
          .snapshots(includeMetadataChanges: true)
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                final remoteItems = snapshot.docs.map((doc) {
                  return FaqItem.fromMap(doc.data(), doc.id);
                }).toList();

                _items = remoteItems;
                _saveToLocalCache(remoteItems);
                _wasOffline = false;
                notifyListeners();
                debugPrint(
                  '[FaqProvider] Synced ${remoteItems.length} FAQs from Cloud Firestore.',
                );
              }
            },
            onError: (error) {
              _wasOffline = true;
              debugPrint(
                '[FaqProvider] Firestore stream error (using cache): $error',
              );
            },
          );
    } catch (e) {
      _wasOffline = true;
      debugPrint('[FaqProvider] Firebase error: $e');
    }
  }

  /// Manually trigger remote reconnection / refresh
  void syncRemote() {
    _attachFirestoreListener();
    refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (Firebase.apps.isNotEmpty) {
        QuerySnapshot<Map<String, dynamic>> snapshot;
        try {
          snapshot = await FirebaseFirestore.instance
              .collection('faqs')
              .get(const GetOptions(source: Source.serverAndCache));
        } catch (_) {
          snapshot = await FirebaseFirestore.instance.collection('faqs').get();
        }
        if (snapshot.docs.isNotEmpty) {
          final remoteItems = snapshot.docs.map((doc) {
            return FaqItem.fromMap(doc.data(), doc.id);
          }).toList();
          _items = remoteItems;
          await _saveToLocalCache(remoteItems);
          _wasOffline = false;
          debugPrint(
            '[FaqProvider] Refreshed ${remoteItems.length} FAQs directly from Cloud Firestore.',
          );
        }
      }
    } catch (e) {
      _wasOffline = true;
      debugPrint('[FaqProvider] Refresh note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(FaqCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleExpansion(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  bool isExpanded(String id) => _expandedIds.contains(id);

  void resetFilters() {
    _selectedCategory = FaqCategory.all;
    _searchQuery = '';
    _expandedIds.clear();
    notifyListeners();
  }

  List<FaqItem> get filteredItems {
    return _items.where((item) {
      // Category filter
      if (_selectedCategory != FaqCategory.all &&
          item.category != _selectedCategory) {
        return false;
      }

      // Keyword query search
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchesQuestion = item.question.toLowerCase().contains(query);
        final matchesAnswer = item.answer.toLowerCase().contains(query);
        final matchesRef = item.statutoryReference.toLowerCase().contains(
          query,
        );
        final matchesQuestionHa = item.questionHa.toLowerCase().contains(query);
        final matchesAnswerHa = item.answerHa.toLowerCase().contains(query);
        if (!matchesQuestion &&
            !matchesAnswer &&
            !matchesRef &&
            !matchesQuestionHa &&
            !matchesAnswerHa) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @visibleForTesting
  void setItemsForTesting(List<FaqItem> items) {
    _items = List.from(items);
    notifyListeners();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _firestoreSubscription?.cancel();
    _connectivitySubscription?.cancel();
    if (current == this) {
      current = null;
    }
    super.dispose();
  }
}
