// lib/Repository/caregiver_repository/caregiver_customization_repository.dart

import 'dart:io';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:dio/dio.dart';

class CaregiverCustomizationRepository {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // GET USER CONTENT
  // ============================================================
  Future<ApiResponse<UserContentModel>> getUserContent(int communicatorId) async {
    try {
      final response = await _apiClient.get(AppUrl.getUserContent(communicatorId));
      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(
            data: UserContentModel.fromJson(response.data!),
            statusCode: 200,
            message: 'Success');
      }
      return ApiResponse.error(
          statusCode: response.statusCode ?? 500, message: response.message);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // CREATE MAIN CATEGORY
  // POST form-data: name, color, communicator_id, image_icon?
  // NO speak/audio for category
  // ============================================================
  Future<ApiResponse<dynamic>> createCategory({
    required String name,
    required String color,
    required int communicatorId,
    required int order,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'communicator_id': communicatorId.toString(),
        'order': order.toString(),
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPost(AppUrl.createCategory,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // UPDATE MAIN CATEGORY
  // PUT form-data: name, color, image_icon?
  // NO speak/audio for category
  // ============================================================
  Future<ApiResponse<dynamic>> updateCategory({
    required int categoryId,
    required String name,
    required String color,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      // ✅ CORRECT endpoint: updateUserCategory (not updateUserItem!)
      return await _apiClient.multipartPut(
          AppUrl.updateUserCategory(categoryId),
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // CREATE SUB CATEGORY
  // POST form-data: name, color, communicator_id, main_category_id, image_icon?
  // NO speak/audio for subcategory
  // ============================================================
  Future<ApiResponse<dynamic>> createSubCategory({
    required String name,
    required String color,
    required int order,
    required int communicatorId,
    required int mainCategoryId,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        'order': order.toString(),
        'communicator_id': communicatorId.toString(),
        'main_category_id': mainCategoryId.toString(),
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      return await _apiClient.multipartPost(AppUrl.createSubCategory,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // UPDATE SUB CATEGORY
  // PUT form-data: name, color, image_icon?
  // NO speak/audio for subcategory
  // ============================================================
  Future<ApiResponse<dynamic>> updateSubCategory({
    required int subCategoryId,
    required String name,
    required String color,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'color': color,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
      });
      // Uses same /category/{id}/ endpoint but with subcategory's own id
      return await _apiClient.multipartPut(
          AppUrl.updateUserSubCategory(subCategoryId),
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // CREATE ITEM
  // POST form-data: category_id, word, color, communicator_id, image_icon?, speak?
  // ✅ HAS audio (speak)
  // ============================================================
  Future<ApiResponse<dynamic>> createItem({
    required int categoryId,
    required String word,
    required String color,
    required int communicatorId,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'category_id': categoryId.toString(),
        'word': word,
        'color': color,
        'communicator_id': communicatorId.toString(),
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: audioFile.path.split('/').last,
              contentType: DioMediaType('audio', 'mpeg')),
      });
      return await _apiClient.multipartPost(AppUrl.createItem,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // UPDATE ITEM
  // PUT form-data: word, color, image_icon?, speak?
  // ✅ HAS audio (speak)
  // ============================================================
  Future<ApiResponse<dynamic>> updateItem({
    required int itemId,
    required String word,
    required String color,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: audioFile.path.split('/').last,
              contentType: DioMediaType('audio', 'mpeg')),
      });
      return await _apiClient.multipartPut(AppUrl.updateUserItem(itemId),
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // CREATE QUICK SPEAK
  // POST form-data: word, color, communicator_id, image_icon?, speak?
  // ✅ HAS audio (speak)
  // ============================================================
  Future<ApiResponse<dynamic>> createQuickSpeak({
    required String word,
    required String color,
    required int communicatorId,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        'communicator_id': communicatorId.toString(),
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: audioFile.path.split('/').last,
              contentType: DioMediaType('audio', 'mpeg')),
      });
      return await _apiClient.multipartPost(AppUrl.createQuickSpeak,
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }

  // ============================================================
  // UPDATE QUICK SPEAK
  // PUT form-data: word, color, image_icon?, speak?
  // ✅ HAS audio (speak)
  // ============================================================
  Future<ApiResponse<dynamic>> updateQuickSpeak({
    required int quickSpeakId,
    required String word,
    required String color,
    File? imageFile,
    File? audioFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'word': word,
        'color': color,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        if (audioFile != null)
          'speak': await MultipartFile.fromFile(audioFile.path,
              filename: audioFile.path.split('/').last,
              contentType: DioMediaType('audio', 'mpeg')),
      });
      return await _apiClient.multipartPut(
          AppUrl.updateUserQuickSpeak(quickSpeakId),
          formData: formData);
    } catch (e) {
      return ApiResponse.error(statusCode: 500, message: e.toString());
    }
  }
}