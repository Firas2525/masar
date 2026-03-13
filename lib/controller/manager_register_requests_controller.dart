import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManagerRegisterRequestsController extends GetxController {
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> pendingChildren = [];

  @override
  void onInit() {
    super.onInit();
    loadPendingChildren();
  }

  Future<void> loadPendingChildren() async {
    try {
      isLoading = true;
      update();
      final query = await _firestore
          .collection('children')
          .where('approved', isEqualTo: 'wait')
          .get();
      pendingChildren = query.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'],
              'parentId': data['parentId'] ?? '',
              'birthDate': data['birthDate'],
              'classroom': data['classroom'],
              'gender': data['gender'],
              'registerDate': data['registerDate'],
            };
          })
          .toList();
    } catch (e) {
      // You can add snackbar if desired
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> updateApproval(String childId, String newStatus) async {
    try {
      isLoading = true;
      update();
      await _firestore.collection('children').doc(childId).update({'approved': newStatus});
      pendingChildren.removeWhere((c) => c['id'] == childId);
    } catch (e) {
      // handle error
    } finally {
      isLoading = false;
      update();
    }
  }
}
