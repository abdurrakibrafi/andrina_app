// lib/models/communicator_models/communicator_content_model.dart

class CommunicatorContentModel {
  final List<CommCategoryModel> categories;
  final List<CommQuickSpeakModel> quickSpeaks;
  final int totalCategories;
  final int totalQuickSpeaks;

  CommunicatorContentModel({
    required this.categories,
    required this.quickSpeaks,
    required this.totalCategories,
    required this.totalQuickSpeaks,
  });

  factory CommunicatorContentModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommunicatorContentModel(
      categories: (json['categories'] as List? ?? [])
          .map((e) => CommCategoryModel.fromJson(e, lang: lang))
          .where((c) => !c.isDeleted && c.isActive)
          .toList(),
      quickSpeaks: (json['quickspeaks'] as List? ?? [])
          .map((e) => CommQuickSpeakModel.fromJson(e, lang: lang))
          .where((q) => !q.isDeleted && q.isActive)
          .toList(),
      totalCategories: json['total_categories'] ?? 0,
      totalQuickSpeaks: json['total_quickspeaks'] ?? 0,
    );
  }
}

// ─── Helper: translations থেকে name/speak বের করা ───────────────────────────
String _resolveName(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final t = translations[lang];
    if (t is Map && t['name'] != null && (t['name'] as String).isNotEmpty) {
      return t['name'] as String;
    }
  }
  return json['name'] ?? '';
}

String? _resolveSpeak(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final t = translations[lang];
    if (t is Map && t['speak'] != null) {
      return t['speak'] as String?;
    }
  }
  return json['speak'];
}

// ✅ সঠিক — এইটা দিয়ে replace করো
String? _resolveWord(Map<String, dynamic> json, String lang) {
  final translations = json['translations'];
  if (translations is Map) {
    final langData = translations[lang];
    if (langData is Map) {
      // 'word' key আগে চেক, তারপর fallback হিসেবে 'name'
      final word = langData['word'];
      if (word != null && (word as String).isNotEmpty) return word;
      final name = langData['name'];
      if (name != null && (name as String).isNotEmpty) return name as String;
    }
    // lang না পাইলে 'en' তে fallback
    final enData = translations['en'];
    if (enData is Map) {
      return (enData['word'] ?? enData['name']) as String?;
    }
  }
  return json['word'] ?? json['name'];
}

// ── Category ──────────────────────────────────────────────────────────────────

class CommCategoryModel {
  final int id;
  final String name;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;
  final List<CommSubCategoryModel> subCategories;
  final int subCategoriesCount;

  CommCategoryModel({
    required this.id,
    required this.name,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
    required this.subCategories,
    required this.subCategoriesCount,
  });

  factory CommCategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommCategoryModel(
      id: json['id'] ?? 0,
      name: _resolveName(json, lang),
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      subCategoriesCount: json['sub_categories_count'] ?? 0,
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((e) => CommSubCategoryModel.fromJson(e, lang: lang))
          .where((s) => !s.isDeleted && s.isActive)
          .toList(),
    );
  }
}

// ── SubCategory ───────────────────────────────────────────────────────────────

class CommSubCategoryModel {
  final int id;
  final int? mainCategory;
  final String name;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;
  final List<CommItemModel> items;
  final int itemsCount;

  CommSubCategoryModel({
    required this.id,
    this.mainCategory,
    required this.name,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
    required this.items,
    required this.itemsCount,
  });

  factory CommSubCategoryModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommSubCategoryModel(
      id: json['id'] ?? 0,
      mainCategory: json['main_category'],
      name: _resolveName(json, lang),
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      itemsCount: json['items_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => CommItemModel.fromJson(e, lang: lang))
          .where((i) => !i.isDeleted && i.isActive)
          .toList(),
    );
  }
}

// ── Item ──────────────────────────────────────────────────────────────────────

class CommItemModel {
  final int id;
  final int? category;
  final String? word;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;

  CommItemModel({
    required this.id,
    this.category,
    this.word,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
  });

  factory CommItemModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommItemModel(
      id: json['id'] ?? 0,
      category: json['category'],
      word: _resolveWord(json, lang) ?? json['word'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}

// ── QuickSpeak ────────────────────────────────────────────────────────────────

class CommQuickSpeakModel {
  final int id;
  final String? word;
  final String? speak;
  final String color;
  final String? imageIcon;
  final int order;
  final bool isActive;
  final bool isDeleted;

  CommQuickSpeakModel({
    required this.id,
    this.word,
    this.speak,
    required this.color,
    this.imageIcon,
    required this.order,
    required this.isActive,
    required this.isDeleted,
  });

  factory CommQuickSpeakModel.fromJson(Map<String, dynamic> json, {String lang = 'en'}) {
    return CommQuickSpeakModel(
      id: json['id'] ?? 0,
      word: _resolveWord(json, lang) ?? json['word'],
      speak: _resolveSpeak(json, lang),
      color: json['color'] ?? '#FFD700',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}