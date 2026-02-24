
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

  factory CommunicatorContentModel.fromJson(Map<String, dynamic> json) {
    return CommunicatorContentModel(
      categories: (json['categories'] as List? ?? [])
          .map((e) => CommCategoryModel.fromJson(e))
          .where((c) => !c.isDeleted && c.isActive)
          .toList(),
      quickSpeaks: (json['quickspeaks'] as List? ?? [])
          .map((e) => CommQuickSpeakModel.fromJson(e))
          .where((q) => !q.isDeleted && q.isActive)
          .toList(),
      totalCategories: json['total_categories'] ?? 0,
      totalQuickSpeaks: json['total_quickspeaks'] ?? 0,
    );
  }
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

  factory CommCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      speak: json['speak'],
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      subCategoriesCount: json['sub_categories_count'] ?? 0,
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((e) => CommSubCategoryModel.fromJson(e))
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

  factory CommSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommSubCategoryModel(
      id: json['id'] ?? 0,
      mainCategory: json['main_category'],
      name: json['name'] ?? '',
      speak: json['speak'],
      color: json['color'] ?? '#B5CFD1',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      itemsCount: json['items_count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => CommItemModel.fromJson(e))
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

  factory CommItemModel.fromJson(Map<String, dynamic> json) {
    return CommItemModel(
      id: json['id'] ?? 0,
      category: json['category'],
      word: json['word'],
      speak: json['speak'],
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

  factory CommQuickSpeakModel.fromJson(Map<String, dynamic> json) {
    return CommQuickSpeakModel(
      id: json['id'] ?? 0,
      word: json['word'],
      speak: json['speak'],
      color: json['color'] ?? '#FFD700',
      imageIcon: json['image_icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}