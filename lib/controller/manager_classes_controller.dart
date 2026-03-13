import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';

class ManagerClassesController extends GetxController {
  final isLoading = false.obs;
  final classes = <Class>[].obs;
  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      final query = await _firestore.collection('classes').get();
      final loaded = query.docs
          .map((doc) => Class.fromFirestore(doc.data(), doc.id))
          .toList();
      classes.value = loaded;
    } catch (e) {
      classes.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClass(String name, String description, double price) async {
    try {
      isLoading.value = true;
      await _firestore.collection('classes').add({
        'name': name,
        'description': description,
        'price': price,
      });
      await fetchClasses();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClass(
    String id,
    String name,
    String description,
    double price,
  ) async {
    try {
      isLoading.value = true;
      await _firestore.collection('classes').doc(id).update({
        'name': name,
        'description': description,
        'price': price,
      });
      await fetchClasses();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('classes').doc(id).delete();
      await fetchClasses();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
