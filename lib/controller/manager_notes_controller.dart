import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManagerNotesController extends GetxController {
  final isLoading = false.obs;
  final notes = <Map<String, dynamic>>[].obs;
  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      final query = await _firestore.collection('notes').get();
      final loaded = query.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      notes.value = loaded;
    } catch (e) {
      notes.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNote(String childId, String message) async {
    try {
      isLoading.value = true;
      await _firestore.collection('notes').add({
        'childId': childId,
        'message': message,
      });
      await fetchNotes();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('notes').doc(id).delete();
      await fetchNotes();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }
}
