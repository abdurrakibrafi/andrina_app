import 'package:chatter_bee/Repository/profile_invitation_repo.dart';
import 'package:chatter_bee/models/profile_invitation_model/profile_invitation_model.dart';
import 'package:chatter_bee/services/communicator_session_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaregiverInvitationController extends GetxController {
  final ProfileInvitationRepo _repo = ProfileInvitationRepo();

  final RxBool isSendingInvitation = false.obs;
  final RxBool isLoadingConnections = false.obs;
  final RxBool isLoadingInvitations = false.obs;
  final RxInt selectedConnectionId = (-1).obs;
  final RxInt isSwitchingTo = (-1).obs;

  final RxList<ConnectionModel> connections = <ConnectionModel>[].obs;
  final RxList<InvitationModel> sentInvitations = <InvitationModel>[].obs;

  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadConnections();
    loadSentInvitations();
  }

  // ==================== LOAD CONNECTIONS ====================
  Future<void> loadConnections() async {
    try {
      isLoadingConnections.value = true;
      final response = await _repo.listConnections();

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;

        // ✅ FIX: API returns {data: {connections: [...], subscription_info: {...}}}
        // তাই data.connections থেকে list নিতে হবে
        List<dynamic> rawList = [];

        if (responseData['data'] is Map) {
          // Structure: {data: {connections: [...]}}
          rawList = responseData['data']['connections'] ?? [];
        } else if (responseData['connections'] is List) {
          // Structure: {connections: [...]}
          rawList = responseData['connections'];
        } else if (responseData['results'] is List) {
          rawList = responseData['results'];
        } else if (responseData['data'] is List) {
          rawList = responseData['data'];
        }

        connections.value = rawList
            .map((e) => ConnectionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Pre-selected communicator mark করা
        final selected = connections.firstWhereOrNull((c) => c.isSelected);
        if (selected != null) selectedConnectionId.value = selected.id;
        debugPrint('✅ Loaded ${connections.length} connections');

        // connections load শেষে এই ২ লাইন যোগ করো
        final saved = CommunicatorSessionService.to.communicatorId.value;
        if (saved != 0) {
          final c = connections.firstWhereOrNull((c) => c.communicatorId == saved);
          if (c != null) selectedConnectionId.value = c.id;
        }


      }
    } catch (e) {
      debugPrint('Load connections error: $e');
    } finally {
      isLoadingConnections.value = false;
    }
  }

  // ==================== LOAD SENT INVITATIONS ====================
  Future<void> loadSentInvitations() async {
    try {
      isLoadingInvitations.value = true;
      final response = await _repo.listInvitations(type: 'sent', status: 'pending');

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        List<dynamic> rawList = [];

        if (responseData['data'] is Map) {
          rawList = responseData['data']['invitations'] ??
              responseData['data']['results'] ??
              responseData['data'] ?? [];
        } else if (responseData['data'] is List) {
          rawList = responseData['data'];
        } else if (responseData['results'] is List) {
          rawList = responseData['results'];
        } else if (responseData['invitations'] is List) {
          rawList = responseData['invitations'];
        }

        sentInvitations.value = rawList
            .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Loaded ${sentInvitations.length} sent invitations');
      }
    } catch (e) {
      debugPrint('Load sent invitations error: $e');
    } finally {
      isLoadingInvitations.value = false;
    }
  }

  // ==================== SEND INVITATION ====================
  Future<void> sendInvitation() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter communicator\'s email',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSendingInvitation.value = true;
      final response = await _repo.sendInvitation(email: email);

      if (response.isSuccess) {
        emailController.clear();
        Get.back(); // close bottom sheet
        Get.snackbar(
          'Invitation Sent! 🎉',
          'An invitation has been sent to $email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
          duration: const Duration(seconds: 3),
        );
        await loadSentInvitations();
      } else {
        // ✅ FIX: 400 error এর actual message দেখাও
        // errors field এ detail থাকতে পারে
        String errorMsg = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          final firstError = response.errors!.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMsg = firstError.first.toString();
          } else {
            errorMsg = firstError.toString();
          }
        }
        Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('Send invitation error: $e');
      Get.snackbar('Error', 'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingInvitation.value = false;
    }
  }

  // ==================== SELECT COMMUNICATOR ====================
  Future<void> selectCommunicator(ConnectionModel connection) async {
    if (selectedConnectionId.value == connection.id) return;

    try {
      isSwitchingTo.value = connection.id;
      final response = await _repo.copyDefaultContent(
        targetUserId: connection.communicatorId,
      );
      if (response.isSuccess) {
        selectedConnectionId.value = connection.id;

        // save in communicator session
        await CommunicatorSessionService.to.setSelected(
          connection.communicatorId,
          connection.communicatorName,
        );

        Get.snackbar(
          'Switched!',
          'Now viewing ${connection.communicatorName}\'s profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
        );
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to switch profile. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSwitchingTo.value = -1;
    }
  }

  // ==================== DISCONNECT ====================
  Future<void> disconnectCommunicator(ConnectionModel connection) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Disconnect?'),
        content:
        Text('Are you sure you want to disconnect from ${connection.communicatorName}?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _repo.disconnectProfile(connectionId: connection.id);
      if (response.isSuccess) {
        connections.removeWhere((c) => c.id == connection.id);
        if (selectedConnectionId.value == connection.id) selectedConnectionId.value = -1;
        Get.snackbar('Disconnected', '${connection.communicatorName} has been disconnected.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', response.message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to disconnect. Try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ==================== SHOW INVITE DIALOG ====================
  void showInviteDialog() {
    emailController.clear();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Invite Communicator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Enter the email address of the communicator you want to connect with.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'communicator@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFC857), width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSendingInvitation.value ? null : sendInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC857),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isSendingInvitation.value
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Send Invitation',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}