import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
import '../widgets/custom_snackbar.dart';

class ClassesController extends GetxController {
  Future<void> addClass(String name, String description, double price) async {
    try {
      isLoading.value = true;
      await _firestore.collection('class').add({
        'name': name,
        'description': description,
        'price': price,
      });
      await loadClasses();
      showCustomSnackbar("تمت الإضافة", "تم إضافة الصف بنجاح");
    } catch (e) {
      print('Error adding class: $e');
      showCustomSnackbar("خطأ", "حدث خطأ أثناء إضافة الصف");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editClass(String id, String name, String description, double price) async {
    try {
      isLoading.value = true;
      await _firestore.collection('class').doc(id).update({
        'name': name,
        'description': description,
        'price': price,
      });
      await loadClasses();
      showCustomSnackbar("تم التعديل", "تم تعديل الصف بنجاح");
    } catch (e) {
      print('Error editing class: $e');
      showCustomSnackbar("خطأ", "حدث خطأ أثناء تعديل الصف");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('class').doc(id).delete();
      await loadClasses();
      showCustomSnackbar("تم الحذف", "تم حذف الصف بنجاح");
    } catch (e) {
      print('Error deleting class: $e');
      showCustomSnackbar("خطأ", "حدث خطأ أثناء حذف الصف");
    } finally {
      isLoading.value = false;
    }
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final classes = <Class>[].obs;
  final subjects = <Subject>[].obs;
  final selectedClass = Rxn<Class>();

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  Future<void> loadClasses() async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore.collection('class').get();
      
      final loadedClasses = querySnapshot.docs
          .map((doc) => Class.fromFirestore(doc.data(), doc.id))
          .toList();

      // ترتيب الأقسام حسب الاسم
      loadedClasses.sort((a, b) => a.name.compareTo(b.name));
      
      classes.value = loadedClasses;
      print('Loaded ${classes.length} classes');
      
    } catch (e) {
      print('Error loading classes: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل الأقسام");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubjectsForClass(String classId) async {
    try {
      isLoading.value = true;
      
      final querySnapshot = await _firestore
          .collection('subjects')
          .where('classId', isEqualTo: classId)
          .get();
      
      final loadedSubjects = querySnapshot.docs
          .map((doc) => Subject.fromFirestore(doc.data(), doc.id))
          .toList();

      // ترتيب المواد حسب index
      loadedSubjects.sort((a, b) => a.index.compareTo(b.index));
      
      subjects.value = loadedSubjects;
      print('Loaded ${subjects.length} subjects for class $classId');
      
    } catch (e) {
      print('Error loading subjects: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل المواد");
    } finally {
      isLoading.value = false;
    }
  }

  void selectClass(Class selectedClass) {
    this.selectedClass.value = selectedClass;
    loadSubjectsForClass(selectedClass.id);
  }

  Future<void> refreshData() async {
    await loadClasses();
  }
} 