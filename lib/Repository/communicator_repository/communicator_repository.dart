// lib/Repository/communicator_repository/communicator_repository.dart

import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/models/communicator_models/communicator_content_model.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:flutter/material.dart';

class CommunicatorRepository {
  final ApiClient _client = ApiClient();

  /// GET /api/communicator/content/
  /// Bearer Token — ApiClient interceptor automatically adds it
  Future<ApiResponse<CommunicatorContentModel>> getContent() async {
    try {
      // response.data = full JSON body: { success, message, data: {...} }
      final response = await _client.get<Map<String, dynamic>>(
        AppUrl.getCommunicatorContent,
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        // API response এর ভেতরে 'data' key তে actual content থাকে
        if (body['success'] == true && body['data'] != null) {
          final model = CommunicatorContentModel.fromJson(
              body['data'] as Map<String, dynamic>);

          return ApiResponse.success(
            data: model,
            statusCode: response.statusCode,
            message: body['message'] ?? 'Success',
          );
        }

        return ApiResponse.error(
          statusCode: response.statusCode,
          message: body['message'] ?? 'Failed to load content',
        );
      }

      // HTTP level error (4xx/5xx) — ApiClient already handled
      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
        errorType: response.errorType,
      );
    } catch (e) {
      debugPrint('CommunicatorRepository.getContent error: $e');
      return ApiResponse.error(
        statusCode: 500,
        message: 'Something went wrong. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }
}