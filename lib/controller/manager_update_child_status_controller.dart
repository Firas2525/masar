import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManagerUpdateChildStatusController extends GetxController {
  final isLoading = false.obs;
  final children = <Map<String, dynamic>>[].obs;
  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchChildren() async {
    try {
      isLoading.value = true;
      final query = await _firestore.collection('children').get();
      final loaded = query.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      children.value = loaded;
    } catch (e) {
      children.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      isLoading.value = true;
      await _firestore.collection('children').doc(id).update({
        'status': status,
      });
      await fetchChildren();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
