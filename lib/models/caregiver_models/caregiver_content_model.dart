// lib/models/caregiver_models/caregiver_content_model.dart

class UserContentModel {
  final bool isCustomized;
  final List<CategoryModel> categories;
  final List<QuickSpeakModel> quickSpeaks;

  UserContentModel({
    required this.isCustomized,
    required this.categories,
    required this.quickSpeaks,
  });

  factory UserContentModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return UserContentModel(
      isCustomized: data['is_customized'] ?? false,
      categories: (data['categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      quickSpeaks: (data['quickspeaks'] as List? ?? [])
          .map((e) => QuickSpeakModel.fromJson(e))
          .toList(),
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;
  final List<SubCategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageIcon: json['image_icon'],
      speak: json['speak'],
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      subCategories: (json['sub_categories'] as List? ?? [])
          .map((e) => SubCategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class SubCategoryModel {
  final int id;
  final int mainCategory;
  final String name;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;
  final List<ItemModel> items;

  SubCategoryModel({
    required this.id,
    required this.mainCategory,
    required this.name,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
    required this.items,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      mainCategory: json['main_category'] ?? 0,
      name: json['name'] ?? '',
      imageIcon: json['image_icon'],
      speak: json['speak'],
      color: json['color'] ?? '#B5CFD1',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      items: (json['items'] as List? ?? [])
          .map((e) => ItemModel.fromJson(e))
          .toList(),
    );
  }
}

class ItemModel {
  final int id;
  final int category;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;

  ItemModel({
    required this.id,
    required this.category,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? 0,
      category: json['category'] ?? 0,
      word: json['word'],
      imageIcon: json['image_icon'],
      speak: json['speak'],
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class QuickSpeakModel {
  final int id;
  final String? word;
  final String? imageIcon;
  final String? speak;
  final String color;
  final int order;
  final bool isActive;

  QuickSpeakModel({
    required this.id,
    this.word,
    this.imageIcon,
    this.speak,
    required this.color,
    required this.order,
    required this.isActive,
  });

  factory QuickSpeakModel.fromJson(Map<String, dynamic> json) {
    return QuickSpeakModel(
      id: json['id'] ?? 0,
      word: json['word'],
      imageIcon: json['image_icon'],
      speak: json['speak'],
      color: json['color'] ?? '#FFD700',
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}