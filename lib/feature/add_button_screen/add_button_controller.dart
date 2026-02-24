// import 'dart:io';
// import 'package:chatter_bee/Repository/caregiver_repository/caregiver_customization_repository.dart';
// import 'package:chatter_bee/feature/home_screen/caregiver/controller/home_controller.dart';
// import 'package:chatter_bee/services/api_client.dart';
// import 'package:chatter_bee/services/communicator_session_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// /// Controls what type of button is being added
// enum AddButtonType { quickSpeak, tapToTalk }
//
// class AddButtonController extends GetxController {
//   final CaregiverCustomizationRepository _repo = CaregiverCustomizationRepository();
//   final ImagePicker _imagePicker = ImagePicker();
//
//   // ==================== TEXT CONTROLLERS ====================
//   final wordController = TextEditingController();
//   final speakAsController = TextEditingController();
//
//   // ==================== OBSERVABLES ====================
//   var selectedColor = const Color(0xFFB5CFD1).obs;
//   var selectedImageFile = Rxn<File>();
//   var isLoading = false.obs;
//
//   /// Which type of button to create
//   var buttonType = AddButtonType.quickSpeak.obs;
//
//   // ==================== AVAILABLE COLORS ====================
//   final List<Color> availableColors = [
//     const Color(0xFFB5CFD1),
//     const Color(0xFFFFC107),
//     const Color(0xFFE91E63),
//     const Color(0xFF4CAF50),
//   ];
//
//   // ==================== SELECT COLOR ====================
//   void selectColor(Color color) => selectedColor.value = color;
//
//   // ==================== PICK IMAGE ====================
//   Future<void> pickImage() async {
//     try {
//       final picked = await _imagePicker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//         maxWidth: 512,
//         maxHeight: 512,
//       );
//       if (picked != null) {
//         selectedImageFile.value = File(picked.path);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to pick image: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   // ==================== AUDIO CONTROLS ====================
//   void playAudio() {
//     Get.snackbar('Audio', 'Play audio');
//   }
//
//   void recordAudio() => _showAudioNote();
//   void deleteAudio() => Get.snackbar('Audio', 'Audio deleted');
//   void uploadAudio() => _showAudioNote();
//
//   void _showAudioNote() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFFFF9E6),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.note_alt, size: 40, color: Color(0xFFFFC107)),
//               ),
//               const SizedBox(height: 20),
//               const Text('Note!',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               const Text(
//                 'Please note that ChatterBee\ncurrently supports audio\nformats .mp3 and .wav only',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 45,
//                 child: ElevatedButton(
//                   onPressed: () => Get.back(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFFFC107),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text('Ok',
//                       style: TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ==================== COLOR HEX STRING ====================
//   String get _colorHex {
//     final value = selectedColor.value.value;
//     return '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
//   }
//
//   // ==================== SAVE BUTTON ====================
//   Future<void> saveButton() async {
//     final word = wordController.text.trim();
//     if (word.isEmpty) {
//       Get.snackbar('Error', 'Please enter a word',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red.shade100,
//           colorText: Colors.red.shade900);
//       return;
//     }
//
//     if (!CommunicatorSessionService.to.hasSelected) {
//       Get.snackbar('Error', 'No communicator selected. Please select a communicator first.',
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }
//
//     final communicatorId = CommunicatorSessionService.to.communicatorId.value;
//
//     try {
//       isLoading.value = true;
//
//       ApiResponse<dynamic> response;
//
//       if (buttonType.value == AddButtonType.quickSpeak) {
//         // Create Quick Speak
//         response = await _repo.createQuickSpeak(
//           name: word,
//           word: speakAsController.text.trim().isNotEmpty
//               ? speakAsController.text.trim()
//               : word,
//           color: _colorHex,
//           communicatorId: communicatorId,
//           imageFile: selectedImageFile.value,
//         );
//       } else {
//         // Create Category (root level)
//         response = await _repo.createCategory(
//           name: word,
//           color: _colorHex,
//           order: 0,
//           imageFile: selectedImageFile.value,
//         );
//       }
//
//       if (response.isSuccess) {
//         Get.back();
//         Get.snackbar(
//           'Success 🎉',
//           '"$word" added successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: const Color(0xFFE8F5E9),
//           duration: const Duration(seconds: 3),
//         );
//         // Refresh home screen
//         _refreshHome();
//       } else {
//         String errorMsg = response.message;
//         if (response.errors != null && response.errors!.isNotEmpty) {
//           final first = response.errors!.values.first;
//           errorMsg = first is List ? first.first.toString() : first.toString();
//         }
//         Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Something went wrong: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void _refreshHome() {
//     try {
//       final homeController = Get.find<HomeController>();
//       homeController.refresh();
//     } catch (_) {}
//   }
//
//   @override
//   void onClose() {
//     wordController.dispose();
//     speakAsController.dispose();
//     super.onClose();
//   }
// }