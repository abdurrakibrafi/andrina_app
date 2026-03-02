
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/services/api_client.dart';
import 'package:get/get.dart';

class FaqItem {
  final int id;
  final String title;
  final String content;

  FaqItem({required this.id, required this.title, required this.content});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class SupportController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxList<FaqItem> faqList = <FaqItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFaqs();
  }

  Future<void> fetchFaqs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/api/settings/faq/',
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data!['data'] ?? [];
        faqList.value = data
            .map((item) => FaqItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = 'error'.tr;
    } finally {
      isLoading.value = false;
    }
  }
}