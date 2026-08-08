import 'package:chatter_bee/feature/Profile/controller/pro_status_controller.dart';
import 'package:chatter_bee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProAccessGate {
  static bool get isPro => ProStatusController.to.isProUser.value;

  static bool allowOrPrompt({String? featureName}) {
    if (isPro) return true;
    show(featureName: featureName ?? 'custom_image_upload'.tr);
    return false;
  }

  static void show({required String featureName}) {
    Get.dialog(Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.workspace_premium, color: Colors.amber),
              const SizedBox(width: 10),
              Expanded(child: Text('pro_required'.tr, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 12),
            Text('${'pro_feature_desc'.tr} "$featureName"',
              style: const TextStyle(color: Color(0xFF636F85), height: 1.35)),
            const SizedBox(height: 18),
            Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: [
              TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
              ElevatedButton(
                onPressed: () { Get.back(); Get.toNamed(AppRoutes.SUBSCRIPTION); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
                child: Text('upgrade_to_pro'.tr, style: const TextStyle(color: Colors.white))),
            ]),
          ]),
        ),
      ),
    ));
  }
}
