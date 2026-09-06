import 'package:flutter/foundation.dart';
import '../models/faq_model.dart';

class FaqProvider extends ChangeNotifier {
  FaqCategory _selectedCategory = FaqCategory.all;
  String _searchQuery = '';
  final Set<String> _expandedIds = {};

  FaqCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

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
    return FaqItem.defaultList.where((item) {
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
        final matchesRef =
            item.statutoryReference.toLowerCase().contains(query);
        if (!matchesQuestion && !matchesAnswer && !matchesRef) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
