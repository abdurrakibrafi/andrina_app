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

      final response =
      await _apiClient.get<Map<String, dynamic>>(AppUrl.privacyPolicy);

      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'];
        policyTitle.value = data?['title'] ?? '';
        policyContent.value = data?['content'] ?? '';
        LoggerUtils.logSuccess('Privacy policy fetched successfully');
      } else {
        LoggerUtils.logError('Privacy policy fetch failed: ${response.message}');
        Get.snackbar(
          'error'.tr, 'failed_load_privacy'.tr,  // ✅
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoggerUtils.logError('Privacy policy error: $e');
      Get.snackbar(
        'error'.tr, 'profile_update_failed'.tr,  // ✅
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}