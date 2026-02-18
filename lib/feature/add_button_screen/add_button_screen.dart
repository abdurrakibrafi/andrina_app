import 'package:chatter_bee/config/app_colors.dart';
import 'package:chatter_bee/feature/add_button_screen/add_button_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddButtonScreen extends GetView<AddButtonController> {
  const AddButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Button',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word Input Field
            _buildLabel('Word'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.wordController,
              hintText: 'Type the word',
            ),
            const SizedBox(height: 22),

            // Speak As Section
            _buildLabel('Speak As'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.speakAsController,
              hintText: 'Speak As',
            ),
            const SizedBox(height: 12),
            _buildAudioControls(),
            const SizedBox(height: 22),

            // Color Selector
            _buildLabel('Color'),
            const SizedBox(height: 6),
            Obx(() => _buildColorDropdown()),
            const SizedBox(height: 22),

            // Image/Icon Section
            _buildLabel('Image/Icon'),
            const SizedBox(height: 12),
            Obx(() => _buildImageSection()),

            const SizedBox(height: 48),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.nunito(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildAudioControls() {
    return Row(
      children: [
        _buildAudioButton(
          icon: Icons.play_circle,
          onTap: controller.playAudio,
        ),
        const SizedBox(width: 6),
        _buildAudioButton(
          icon: Icons.pause_circle,
          onTap: controller.recordAudio,
        ),
        const SizedBox(width: 6),
        _buildAudioButton(
          icon: Icons.delete,
          onTap: controller.deleteAudio,
        ),
      ],
    );
  }

  Widget _buildAudioButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildColorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<Color>(
        value: controller.selectedColor.value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: controller.availableColors.map((color) {
          return DropdownMenuItem(
            value: color,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all( color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getColorName(color),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (color) {
          if (color != null) {
            controller.selectColor(color);
          }
        },
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == const Color(0xFFB5CFD1)) return 'Light Blue';
    if (color == const Color(0xFFFFC107)) return 'Yellow';
    if (color == const Color(0xFFE91E63)) return 'Pink';
    if (color == const Color(0xFF4CAF50)) return 'Green';
    return 'Select Color';
  }

  Widget _buildImageSection() {
    if (controller.selectedImagePath.value.isEmpty) {
      return _buildUploadImagePlaceholder();
    }
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(

              color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            controller.selectedImagePath.value,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadImagePlaceholder() {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file,
                  size: 30,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Upload Image',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Image must be in JPG or PNG format\nand at least 100*100 pixels',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: controller.saveButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}