import 'dart:io';
import 'package:chatter_bee/models/activity/activity_models.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:dio/dio.dart';
import '../../../config/app_url.dart';

class ActivityRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch activities list.
  /// Bug fix: date_from/date_to পাঠালে API-র days filter conflict করে।
  /// শুধু [days] পাঠালে সব ঠিকঠাক কাজ করে।
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int days = 30,
    int limit = 100,
    String? dateFrom,  // optional — শুধু দরকার হলে পাঠাও
    String? dateTo,    // optional — শুধু দরকার হলে পাঠাও
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'days': days,
        'limit': limit,
        // শুধু null না হলেই যোগ করো
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      };

      final response = await _apiClient.get<dynamic>(
        AppUrl.activities,
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> rawList = data['data'] ?? [];
        final activityList = rawList
            .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          data: activityList,
          statusCode: response.statusCode,
          message: response.message,
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to fetch activities: $e',
      );
    }
  }

  /// Create a new activity via multipart/form-data POST
  Future<ApiResponse<ActivityModel>> createActivity({
    required String activityName,
    required String datetime,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'activity_name': activityName,
        'datetime': datetime,
        if (imageFile != null)
          'image_icon': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _apiClient.multipartPost<dynamic>(
        AppUrl.activitiesCreate,
        formData: formData,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final activity = ActivityModel.fromJson(
          data['data'] as Map<String, dynamic>,
        );

        return ApiResponse.success(
          data: activity,
          statusCode: response.statusCode,
          message: response.message,
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to create activity: $e',
      );
    }
  }

  /// Delete an activity by ID (returns 204 No Content on success)
  Future<ApiResponse<bool>> deleteActivity(int activityId) async {
    try {
      final response = await _apiClient.delete<dynamic>(
        AppUrl.activityDelete(activityId),
      );

      if (response.statusCode == 204 || response.isSuccess) {
        return ApiResponse.success(
          data: true,
          statusCode: response.statusCode,
          message: 'Activity deleted successfully',
        );
      }

      return ApiResponse.error(
        statusCode: response.statusCode,
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(
        statusCode: 500,
        message: 'Failed to delete activity: $e',
      );
    }
  }
}