import 'package:get/get.dart';
import 'package:hive/hive.dart';

class AutocompleteController extends GetxController {
  final Box _autocompleteBox = Hive.box('autocomplete');

  // Keys for different autocomplete types
  static const String _titlesKey = 'titles';
  static const String _locationsKey = 'locations';
  static const String _tagsKey = 'tags';
  static const String _incomeTitlesKey = 'income_titles';
  static const String _incomeSourcesKey = 'income_sources';

  // Observable lists
  final RxList<String> titles = <String>[].obs;
  final RxList<String> locations = <String>[].obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<String> incomeTitles = <String>[].obs;
  final RxList<String> incomeSources = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _initializeDefaultIncomeSources();
  }

  void _loadData() {
    try {
      titles.value = List<String>.from(_autocompleteBox.get(_titlesKey, defaultValue: []));
      locations.value = List<String>.from(_autocompleteBox.get(_locationsKey, defaultValue: []));
      tags.value = List<String>.from(_autocompleteBox.get(_tagsKey, defaultValue: []));
      incomeTitles.value = List<String>.from(_autocompleteBox.get(_incomeTitlesKey, defaultValue: []));
      incomeSources.value = List<String>.from(_autocompleteBox.get(_incomeSourcesKey, defaultValue: []));
    } catch (e) {
      print('Error loading autocomplete data: $e');
    }
  }

  void _initializeDefaultIncomeSources() {
    final defaultSources = [
      'Salary',
      'Freelance',
      'Investment',
      'Business',
      'Rental Income',
      'Dividends',
      'Bonus',
      'Commission',
      'Gift',
      'Pension',
      'Side Hustle',
      'Part-time Job',
      'Other',
    ];

    if (incomeSources.isEmpty) {
      incomeSources.addAll(defaultSources);
      _autocompleteBox.put(_incomeSourcesKey, incomeSources.toList());
    }
  }

  // Add title suggestion
  Future<void> addTitle(String title) async {
    if (title.trim().isEmpty || titles.contains(title.trim())) return;

    titles.add(title.trim());
    await _autocompleteBox.put(_titlesKey, titles.toList());
  }

  // Add location suggestion
  Future<void> addLocation(String location) async {
    if (location.trim().isEmpty || locations.contains(location.trim())) return;

    locations.add(location.trim());
    await _autocompleteBox.put(_locationsKey, locations.toList());
  }

  // Add tag suggestion
  Future<void> addTag(String tag) async {
    if (tag.trim().isEmpty || tags.contains(tag.trim())) return;

    tags.add(tag.trim());
    await _autocompleteBox.put(_tagsKey, tags.toList());
  }

  // Add income title suggestion
  Future<void> addIncomeTitle(String title) async {
    if (title.trim().isEmpty || incomeTitles.contains(title.trim())) return;

    incomeTitles.add(title.trim());
    await _autocompleteBox.put(_incomeTitlesKey, incomeTitles.toList());
  }

  // Add income source suggestion
  Future<void> addIncomeSource(String source) async {
    if (source.trim().isEmpty || incomeSources.contains(source.trim())) return;

    incomeSources.add(source.trim());
    await _autocompleteBox.put(_incomeSourcesKey, incomeSources.toList());
  }

  // Get filtered suggestions
  List<String> getTitleSuggestions(String query) {
    if (query.isEmpty) return titles.take(5).toList();
    return titles.where((title) =>
        title.toLowerCase().contains(query.toLowerCase())
    ).take(5).toList();
  }

  List<String> getLocationSuggestions(String query) {
    if (query.isEmpty) return locations.take(5).toList();
    return locations.where((location) =>
        location.toLowerCase().contains(query.toLowerCase())
    ).take(5).toList();
  }

  List<String> getTagSuggestions(String query) {
    if (query.isEmpty) return tags.take(10).toList();
    return tags.where((tag) =>
        tag.toLowerCase().contains(query.toLowerCase())
    ).take(10).toList();
  }

  List<String> getIncomeTitleSuggestions(String query) {
    if (query.isEmpty) return incomeTitles.take(5).toList();
    return incomeTitles.where((title) =>
        title.toLowerCase().contains(query.toLowerCase())
    ).take(5).toList();
  }

  List<String> getIncomeSourceSuggestions(String query) {
    if (query.isEmpty) return incomeSources.take(10).toList();
    return incomeSources.where((source) =>
        source.toLowerCase().contains(query.toLowerCase())
    ).take(10).toList();
  }
}