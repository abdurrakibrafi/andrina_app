// lib/feature/home_screen/caregiver/controller/caregiver_item_controller.dart

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
import 'package:chatter_bee/config/app_url.dart';
import 'package:chatter_bee/feature/home_screen/caregiver/controller/caregiver_home_controller.dart';
import 'package:chatter_bee/models/caregiver_models/caregiver_content_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CaregiverItemController extends GetxController {
  final CaregiverCustomizationRepository _repo =
  CaregiverCustomizationRepository();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecorderInitialized = false;
  late final SubCategoryModel parentSubCategory;

  // ─── State ───────────────────────────────────────────────────
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxInt playingItemId = (-1).obs;

  // ─── Form ────────────────────────────────────────────────────
  final wordController = TextEditingController();
  final RxString formColorHex = '#FFD700'.obs;
  final Rx<File?> formImageFile = Rx<File?>(null);
  final Rx<File?> formAudioFile = Rx<File?>(null);
  final RxString audioFileName = ''.obs;
  final RxBool isRecording = false.obs;
  final RxBool isPlayingFormAudio = false.obs;
  final RxBool formLoading = false.obs;

  ItemModel? _editingItem;

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _soundPlayer;

  final List<Map<String, String>> colorOptions = [
    {'hex': '#FFD700', 'label': 'Gold'},
    {'hex': '#FFC857', 'label': 'Yellow'},
    {'hex': '#FF5733', 'label': 'Orange Red'},
    {'hex': '#4CAF50', 'label': 'Green'},
    {'hex': '#2196F3', 'label': 'Blue'},
    {'hex': '#9C27B0', 'label': 'Purple'},
    {'hex': '#E91E63', 'label': 'Pink'},
    {'hex': '#B5CFD1', 'label': 'Light Blue'},
  ];

  @override
  void onInit() {
    super.onInit();
    parentSubCategory = Get.arguments as SubCategoryModel;
    items.value = parentSubCategory.items;
    _initAudio();
  }


  Future<void> _initAudio() async {
    _recorder = FlutterSoundRecorder();
    _soundPlayer = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    _isRecorderInitialized = true;

    await _soundPlayer!.openPlayer();
  }

  Color get formColor {
    try {
      final hex = formColorHex.value.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFFFFD700);
    }
  }

  // ─── Refresh ─────────────────────────────────────────────────
  Future<void> refresh() async {
    final communicatorId = CommunicatorSessionService.to.communicatorId.value;
    if (communicatorId == 0) return;
    isLoading.value = true;
    final response = await _repo.getUserContent(communicatorId);
    isLoading.value = false;
    if (response.isSuccess && response.data != null) {
      for (final cat in response.data!.categories) {
        final sub = cat.subCategories
            .firstWhereOrNull((s) => s.id == parentSubCategory.id);
        if (sub != null) {
          items.value = sub.items;
          break;
        }
      }
      if (Get.isRegistered<CaregiverHomeController>()) {
        Get.find<CaregiverHomeController>().loadContent();
      }
    }
  }

  // ─── Play item audio from URL ─────────────────────────────────
  Future<void> playItemAudio(ItemModel item) async {
    final url = AppUrl.mediaUrl(item.speak);
    if (url == null) return;

    if (playingItemId.value == item.id) {
      await _audioPlayer.stop();
      playingItemId.value = -1;
      return;
    }

    playingItemId.value = item.id;
    await _audioPlayer.play(UrlSource(url));
    _audioPlayer.onPlayerComplete.listen((_) {
      if (playingItemId.value == item.id) playingItemId.value = -1;
    });
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

  // ─── Add/Edit sheets ─────────────────────────────────────────
  void showAddSheet() {
    _editingItem = null;
    _resetForm();
    _showItemSheet('Add Item / Button');
  }

  void showEditSheet(ItemModel item) {
    _editingItem = item;
    wordController.text = item.word ?? '';
    formColorHex.value =
    item.color.isNotEmpty ? item.color : '#FFD700';
    formImageFile.value = null;
    formAudioFile.value = null;
    audioFileName.value = '';
    isRecording.value = false;
    isPlayingFormAudio.value = false;
    _showItemSheet('Edit Item / Button');
  }

  void _resetForm() {
    wordController.clear();
    formColorHex.value = '#FFD700';
    formImageFile.value = null;
    formAudioFile.value = null;
    audioFileName.value = '';
    isRecording.value = false;
    isPlayingFormAudio.value = false;
  }

  void _showItemSheet(String title) {
    Get.bottomSheet(
      ItemFormSheet(controller: this, title: title),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Save ────────────────────────────────────────────────────
  Future<void> save() async {
    if (wordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a word',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    formLoading.value = true;

    if (_editingItem != null) {
      final response = await _repo.updateItem(
        itemId: _editingItem!.id,
        word: wordController.text.trim(),
        color: formColorHex.value,
        imageFile: formImageFile.value,
        audioFile: formAudioFile.value,
      );
      formLoading.value = false;
      if (response.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('✅ Updated', 'Item updated',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      final communicatorId =
          CommunicatorSessionService.to.communicatorId.value;
      final response = await _repo.createItem(
        categoryId: parentSubCategory.id,
        word: wordController.text.trim(),
        color: formColorHex.value,
        communicatorId: communicatorId,
        imageFile: formImageFile.value,
        audioFile: formAudioFile.value,
      );
      formLoading.value = false;
      if (response.isSuccess) {
        Get.back();
        await refresh();
        Get.snackbar('✅ Created', 'Item created',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', response.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.microphone.request();
      return status.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
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

  // ─── Audio — Microphone permission + record ───────────────────
  Future<void> toggleRecording() async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) return;

    if (!_isRecorderInitialized) {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }

    if (isRecording.value) {
      final path = await _recorder!.stopRecorder();
      isRecording.value = false;

      if (path != null) {
        formAudioFile.value = File(path);
        audioFileName.value = 'recorded_audio.aac';
      }
    } else {
      final dir = await getTemporaryDirectory();
      final recordPath =
          '${dir.path}/item_audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder!.startRecorder(
        toFile: recordPath,
        codec: Codec.aacADTS,
      );

      isRecording.value = true;
    }
  }

  // ─── Play recorded audio ──────────────────────────────────────
  Future<void> toggleFormAudioPlayback() async {
    if (formAudioFile.value == null) return;
    if (isPlayingFormAudio.value) {
      await _soundPlayer!.stopPlayer();
      isPlayingFormAudio.value = false;
    } else {
      isPlayingFormAudio.value = true;
      await _soundPlayer!.startPlayer(
        fromURI: formAudioFile.value!.path,
        whenFinished: () => isPlayingFormAudio.value = false,
      );
    }
  }

  void removeAudio() async {
    formAudioFile.value = null;
    audioFileName.value = '';

    if (isPlayingFormAudio.value) {
      await _soundPlayer?.stopPlayer();
      isPlayingFormAudio.value = false;
    }

    if (isRecording.value) {
      await _recorder?.stopRecorder();
      isRecording.value = false;
    }
  }

  @override
  void onClose() {
    wordController.dispose();
    _recorder?.closeRecorder();
    _soundPlayer?.closePlayer();
    _audioPlayer.dispose();
    _isRecorderInitialized = false;
    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════════
//  ITEM FORM BOTTOM SHEET  (word + color + image + audio)
// ════════════════════════════════════════════════════════════════

class ItemFormSheet extends StatelessWidget {
  final CaregiverItemController controller;
  final String title;

  const ItemFormSheet(
      {super.key, required this.controller, required this.title});

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

            // ── Word ──────────────────────────────────────────
            TextField(
              controller: controller.wordController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Word / Label',
                hintText: 'e.g. I am hungry',
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
              children: controller.colorOptions.map((opt) {
                Color c;
                try {
                  c = Color(int.parse(
                      'FF${opt['hex']!.replaceAll('#', '')}',
                      radix: 16));
                } catch (_) {
                  c = const Color(0xFFFFD700);
                }
                final isSelected =
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
                        color: isSelected
                            ? Colors.black87
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                            color: c.withOpacity(0.5),
                            blurRadius: 6)
                      ]
                          : [],
                    ),
                    child: isSelected
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
            const SizedBox(height: 16),

            // ── Audio ─────────────────────────────────────────
            const Text('Voice / Audio (speak)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Obx(() {
              final hasAudio = controller.formAudioFile.value != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _AudioBtn(
                      icon: controller.isRecording.value
                          ? Icons.stop
                          : Icons.mic,
                      color: controller.isRecording.value
                          ? Colors.red
                          : const Color(0xFFFFC857),
                      label: controller.isRecording.value
                          ? 'Stop'
                          : 'Record',
                      onTap: controller.toggleRecording,
                    ),
                    if (hasAudio) ...[
                      const SizedBox(width: 10),
                      _AudioBtn(
                        icon: controller.isPlayingFormAudio.value
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: const Color(0xFF4CAF50),
                        label: controller.isPlayingFormAudio.value
                            ? 'Stop'
                            : 'Play',
                        onTap: controller.toggleFormAudioPlayback,
                      ),
                      const SizedBox(width: 10),
                      _AudioBtn(
                        icon: Icons.delete_outline,
                        color: Colors.red,
                        label: 'Delete',
                        onTap: controller.removeAudio,
                      ),
                    ],
                  ]),

                  if (controller.isRecording.value) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Recording...',
                          style:
                          TextStyle(color: Colors.red, fontSize: 12)),
                    ]),
                  ],

                  if (hasAudio && !controller.isRecording.value) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.audio_file,
                              color: Color(0xFF4CAF50), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            controller.audioFileName.value.isEmpty
                                ? 'Audio ready'
                                : controller.audioFileName.value,
                            style: const TextStyle(
                                color: Color(0xFF4CAF50), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  Text('Record voice, then tap Play to preview',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500])),
                ],
              );
            }),
            const SizedBox(height: 24),

            // ── Save ──────────────────────────────────────────
            Obx(() => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.formLoading.value
                    ? null
                    : controller.save,
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

class _AudioBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AudioBtn(
      {required this.icon,
        required this.color,
        required this.label,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}