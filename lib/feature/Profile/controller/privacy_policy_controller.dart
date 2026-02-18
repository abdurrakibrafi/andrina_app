import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:chatter_bee/utils/logger_utils.dart';
import 'package:get/get.dart';

class PrivacyPolicyController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxBool isLoading = false.obs;
  final RxString policyTitle = ''.obs;
  final RxString policyContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;
      LoggerUtils.logInfo('=== GET PRIVACY POLICY ===');

      final response = await _apiClient.get<Map<String, dynamic>>(AppUrl.privacyPolicy);

      if (response.isSuccess && response.data != null) {
        policyTitle.value = response.data!['title'] ?? '';
        policyContent.value = response.data!['content'] ?? '';
        LoggerUtils.logSuccess('Privacy policy fetched successfully');
      } else {
        LoggerUtils.logError('Privacy policy fetch failed: ${response.message}');
        Get.snackbar('Error', 'Failed to load privacy policy',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      LoggerUtils.logError('Privacy policy error: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}