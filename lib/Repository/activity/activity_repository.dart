import 'dart:io';
import 'package:chatter_bee/models/activity/activity_models.dart' show ActivityModel;
import 'package:chatter_bee/services/api_client.dart';
import 'package:dio/dio.dart';
import '../../../config/app_url.dart';


class ActivityRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch activities list with optional filters
  /// [days] - number of days to fetch (default 7)
  /// [limit] - max records (default 50)
  /// [dateFrom] - start date filter (yyyy-MM-dd)
  /// [dateTo] - end date filter (yyyy-MM-dd)
  Future<ApiResponse<List<ActivityModel>>> getActivities({
    int days = 7,
    int limit = 50,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'days': days,
        'limit': limit,
      };

      if (dateFrom != null) queryParams['date_from'] = dateFrom;
      if (dateTo != null) queryParams['date_to'] = dateTo;

      final response = await _apiClient.get<dynamic>(
        AppUrl.activities,
        queryParameters: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> rawList = data['data'] ?? [];
        final activities = rawList
            .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          data: activities,
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

  /// Create a new activity
  /// [activityName] - name of the activity
  /// [datetime]    - ISO 8601 datetime string (e.g., "2026-02-24T12:00:00Z")
  /// [imageFile]   - optional image file to upload
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

  /// Delete an activity by ID
  Future<ApiResponse<bool>> deleteActivity(int activityId) async {
    try {
      final response = await _apiClient.delete<dynamic>(
        AppUrl.activityDelete(activityId),
      );

      // 204 No Content is success for delete
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