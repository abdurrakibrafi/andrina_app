import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunicatorInvitationController extends GetxController {
  final ProfileInvitationRepo _repo = ProfileInvitationRepo();

  final RxBool isLoading = false.obs;
  final RxList<InvitationModel> receivedInvitations = <InvitationModel>[].obs;
  final RxSet<int> processingIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReceivedInvitations();
  }

  // ==================== LOAD RECEIVED INVITATIONS ====================
  Future<void> loadReceivedInvitations() async {
    try {
      isLoading.value = true;
      final response = await _repo.listInvitations(type: 'received', status: 'pending');

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        List<dynamic> rawList = [];

        // API: {success, data: {invitations: [...], total_count: N}}
        if (responseData['data'] is Map) {
          rawList = (responseData['data'] as Map)['invitations'] ??
              (responseData['data'] as Map)['results'] ??
              [];
        } else if (responseData['data'] is List) {
          rawList = responseData['data'];
        } else if (responseData['invitations'] is List) {
          rawList = responseData['invitations'];
        } else if (responseData['results'] is List) {
          rawList = responseData['results'];
        }

        receivedInvitations.value = rawList
            .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Loaded ${receivedInvitations.length} received invitations');
      }
    } catch (e) {
      debugPrint('Load received invitations error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== ACCEPT INVITATION ====================
  Future<void> acceptInvitation(InvitationModel invitation) async {
    if (processingIds.contains(invitation.id)) return;
    try {
      processingIds.add(invitation.id);
      processingIds.refresh();

      final response = await _repo.acceptInvitation(invitationId: invitation.id);
      if (response.isSuccess) {
        receivedInvitations.removeWhere((inv) => inv.id == invitation.id);
        Get.snackbar(
          'Connected! 🎉',
          'You are now connected with ${invitation.caregiverName ?? 'the caregiver'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
          duration: const Duration(seconds: 3),
        );
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List ? firstError.first.toString() : firstError.toString();
        }
        Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      Get.snackbar('Error', 'Failed to accept invitation. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      processingIds.remove(invitation.id);
      processingIds.refresh();
    }
  }

  // ==================== REJECT INVITATION ====================
  Future<void> rejectInvitation(InvitationModel invitation) async {
    if (processingIds.contains(invitation.id)) return;
    try {
      processingIds.add(invitation.id);
      processingIds.refresh();

      final response = await _repo.rejectInvitation(invitationId: invitation.id);
      if (response.isSuccess) {
        receivedInvitations.removeWhere((inv) => inv.id == invitation.id);
        Get.snackbar('Declined', 'Invitation has been declined.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          errorMsg = firstError is List ? firstError.first.toString() : firstError.toString();
        }
        Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('Reject invitation error: $e');
      Get.snackbar('Error', 'Failed to decline invitation. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      processingIds.remove(invitation.id);
      processingIds.refresh();
    }
  }

  bool isProcessing(int id) => processingIds.contains(id);
}