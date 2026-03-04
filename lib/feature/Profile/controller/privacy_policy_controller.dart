import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/config/translations/language_controller.dart';
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

    // ✅ Re-fetch whenever language changes
    ever(LanguageController.to.currentLocale, (_) => fetchPrivacyPolicy());
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;
      LoggerUtils.logInfo('=== GET PRIVACY POLICY ===');

      // ✅ Pass current lang as query param
      final String lang = LanguageController.to.currentLocale.value.languageCode;
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${AppUrl.privacyPolicy}?lang=$lang',
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!['data'];

        // ✅ API returns: data.translations.{lang}.title / .content
        final translations = data?['translations'] as Map<String, dynamic>?;
        final langData = translations?[lang] as Map<String, dynamic>?;

        policyTitle.value   = langData?['title']   ?? '';
        policyContent.value = langData?['content'] ?? '';

        LoggerUtils.logSuccess('Privacy policy fetched successfully [$lang]');
      } else {
        LoggerUtils.logError('Privacy policy fetch failed: ${response.message}');
        Get.snackbar(
          'error'.tr, 'failed_load_privacy'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoggerUtils.logError('Privacy policy error: $e');
      Get.snackbar(
        'error'.tr, 'profile_update_failed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}