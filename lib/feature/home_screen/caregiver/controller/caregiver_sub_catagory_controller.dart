// lib/feature/home_screen/caregiver/controller/caregiver_sub_catagory_controller.dart

import 'dart:io';
import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CaregiverSubCategoryController extends GetxController {
  final CaregiverCustomizationRepository _repo =
  CaregiverCustomizationRepository();
  final ImagePicker _picker = ImagePicker();

  late final CategoryModel parentCategory;

  // ─── State ───────────────────────────────────────────────────
  final RxList<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxSet<int> selectedIds = <int>{}.obs;

  // ─── Form (name + color + image — NO audio) ──────────────────
  final nameController = TextEditingController();
  final RxString formColorHex = '#B5CFD1'.obs;
  final Rx<File?> formImageFile = Rx<File?>(null);
  final RxBool formLoading = false.obs;

  SubCategoryModel? _editingSub;

  @override
  void onInit() {
    super.onInit();
    parentCategory = Get.arguments as CategoryModel;
    subCategories.value = parentCategory.subCategories;
  }

  // ─── Refresh from API ─────────────────────────────────────────
  Future<void> refresh() async {
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    if (communicatorId == 0) return;
    isLoading.value = true;
    final response = await _repo.getUserContent(communicatorId);
    isLoading.value = false;
    if (response.isSuccess && response.data != null) {
      final updated = response.data!.categories
          .firstWhereOrNull((c) => c.id == parentCategory.id);
      if (updated != null) subCategories.value = updated.subCategories;
      if (Get.isRegistered<CaregiverHomeController>()) {
        Get.find<CaregiverHomeController>().loadContent();
      }
    }
  }

  // ─── Edit mode ───────────────────────────────────────────────
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) selectedIds.clear();
  }

  void toggleSelection(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  // ─── Navigation ──────────────────────────────────────────────
  void onSubCategoryTap(SubCategoryModel sub) {
    if (isEditMode.value) {
      toggleSelection(sub.id);
    } else {
      Get.toNamed('/item-screen', arguments: sub);
    }
  }

  // ─── Add ─────────────────────────────────────────────────────
  void showAddSheet() {
    _editingSub = null;
    nameController.clear();
    formColorHex.value = '#B5CFD1';
    formImageFile.value = null;
    _openSheet('Add Sub Category');
  }

  // ─── Edit ────────────────────────────────────────────────────
  void showEditSheet(SubCategoryModel sub) {
    _editingSub = sub;
    nameController.text = sub.name;
    formColorHex.value = sub.color.isNotEmpty ? sub.color : '#B5CFD1';
    formImageFile.value = null;
    _openSheet('Edit Sub Category');
  }

  void _openSheet(String title) {
    Get.bottomSheet(
      _SubCategorySheet(controller: this, title: title),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Image ───────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512);
    if (picked != null) formImageFile.value = File(picked.path);
  }

  void removeImage() => formImageFile.value = null;

  // ─── Save ────────────────────────────────────────────────────
  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a name',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    formLoading.value = true;

    if (_editingSub != null) {
      // UPDATE — uses subcategory's own "id"
      final res = await _repo.updateSubCategory(
        subCategoryId: _editingSub!.id, // ✅ subcategory's own id
        name: nameController.text.trim(),
        color: formColorHex.value,
        imageFile: formImageFile.value,
      );
      formLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('✅ Updated', 'Sub-category updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // CREATE — uses parent category's "id" as main_category_id
      final communicatorId = CommunicatorSessionService.to.communicatorId.value;
      final res = await _repo.createSubCategory(
        name: nameController.text.trim(),
        color: formColorHex.value,
        order: subCategories.length,
        communicatorId: communicatorId,
        mainCategoryId: parentCategory.id, // ✅ parent category's id
        imageFile: formImageFile.value,
      );
      formLoading.value = false;
      if (res.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('✅ Created', 'Sub-category created',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════════
//  SUBCATEGORY BOTTOM SHEET — name + color + image (NO audio)
// ════════════════════════════════════════════════════════════════
class _SubCategorySheet extends StatelessWidget {
  final CaregiverSubCategoryController controller;
  final String title;

  const _SubCategorySheet(
      {required this.controller, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            // ── Name ──────────────────────────────────────────
            TextField(
              controller: controller.nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Sub-Category Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFFFC857), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Color ─────────────────────────────────────────
            const Text('Color',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kColorOptions.map((opt) {
                Color c;
                try {
                  c = Color(int.parse(
                      'FF${opt['hex']!.replaceAll('#', '')}',
                      radix: 16));
                } catch (_) {
                  c = const Color(0xFFB5CFD1);
                }
                final selected =
                    controller.formColorHex.value == opt['hex'];
                return GestureDetector(
                  onTap: () =>
                  controller.formColorHex.value = opt['hex']!,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? Colors.black87
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                            color: c.withOpacity(0.5),
                            blurRadius: 6)
                      ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 16),

            // ── Image ─────────────────────────────────────────
            const Text('Image (optional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() => controller.formImageFile.value != null
                ? Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(controller.formImageFile.value!,
                    width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: controller.removeImage,
                icon: const Icon(Icons.delete,
                    color: Colors.red, size: 18),
                label: const Text('Remove',
                    style: TextStyle(color: Colors.red)),
              ),
            ])
                : OutlinedButton.icon(
              onPressed: controller.pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Choose Image'),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            )),
            const SizedBox(height: 24),

            // ── Save ──────────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                controller.formLoading.value ? null : controller.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: controller.formLoading.value
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                    : const Text('Save',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}