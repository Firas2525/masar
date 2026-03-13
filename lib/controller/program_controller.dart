import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/program_model.dart';
import '../model/home_model.dart' hide TimelineItem;
import '../widgets/custom_snackbar.dart';

class ProgramController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final isLoading = false.obs;
  final programs = <Program>[].obs;
  final selectedChild = Rxn<Child>();
  final subjects = <Map<String, dynamic>>[];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadProgramsForChild(Child child) async {
    try {
      isLoading.value = true;
      selectedChild.value = child;
      
      print('Loading programs for child: ${child.name}');
      print('Child classroom: ${child.classroom}');
      
      // التحقق من وجود البيانات أولاً
      final classesQuery = await _firestore.collection('class').get();
      final programsQuery = await _firestore.collection('programs').get();
      final subjectsQuery = await _firestore.collection('subjects').get();
      subjects.clear();
      for (final doc in subjectsQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        subjects.add(data);
      }
      
      print('Found ${classesQuery.docs.length} classes');
      print('Found ${programsQuery.docs.length} programs');
      print('Found ${subjectsQuery.docs.length} subjects');
      
      // البحث عن ID الكلاس بناءً على اسم الكلاس
      String? classId;
      for (final classDoc in classesQuery.docs) {
        final className = classDoc.data()['name'] as String? ?? '';
        if (className == child.classroom) {
          classId = classDoc.id;
          print('Found class ID: $classId for class name: $className');
          break;
        }
      }
      
      if (classId == null) {
        print('No class found with name: ${child.classroom}');
        showCustomSnackbar("تنبيه", "لم يتم العثور على قسم الطفل: ${child.classroom}");
        return;
      }
      
      // جلب البرامج التي classId يساوي id الكلاس
      final querySnapshot = await _firestore
          .collection('programs')
          .where('classId', isEqualTo: classId)
          .get();
      
      print('Found ${querySnapshot.docs.length} programs for class ID: $classId');
      
      final loadedPrograms = <Program>[];
      
      for (final doc in querySnapshot.docs) {
        try {
          print('Processing program document: ${doc.id}');
          print('Program data: ${doc.data()}');
          
          final programData = doc.data();
          final program = Program.fromFirestore(programData, doc.id);
          
          print('Parsed program: ${program.name}');
          print('Program has ${program.weeklySchedule.length} days');
          
          // جلب تفاصيل المواد من collection subjects
          final enrichedProgram = await _enrichProgramWithSubjects(program);
          loadedPrograms.add(enrichedProgram);
          
        } catch (e) {
          print('Error parsing program ${doc.id}: $e');
        }
      }

      // ترتيب البرامج حسب الاسم
      loadedPrograms.sort((a, b) => a.name.compareTo(b.name));
      
      programs.value = loadedPrograms;
      print('Successfully loaded ${programs.length} programs for child ${child.name}');
      
    } catch (e) {
      print('Error loading programs: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تحميل البرامج");
    } finally {
      print(programs);
      isLoading.value = false;
    }
  }

  Future<Program> _enrichProgramWithSubjects(Program program) async {
    try {
      print('Enriching program: ${program.name}');
      print('Program has ${program.weeklySchedule.length} days');
      
      final enrichedDays = <WeeklyDay>[];
      
      for (final day in program.weeklySchedule) {
        print('Processing day: ${day.dayName}');
        print('Day has ${day.subjectIds.length} subject IDs');
        
        final enrichedSubjects = <ProgramSubject>[];
        
        // جلب تفاصيل المواد من collection subjects بناءً على subjectIds
        for (final subjectId in day.subjectIds) {
          print('Processing subject ID: $subjectId');
          
          // جلب تفاصيل المادة من collection subjects
          final subjectDoc = await _firestore
              .collection('subjects')
              .doc(subjectId)
              .get();
          
          if (subjectDoc.exists) {
            print('Found subject document: ${subjectDoc.data()}');
            final subjectData = subjectDoc.data()!;
            final timelineItems = <TimelineItem>[];
            
            if (subjectData['timeline'] != null && subjectData['timeline'] is List) {
              timelineItems.addAll(
                (subjectData['timeline'] as List)
                    .map((item) => TimelineItem.fromMap(item))
                    .toList()
              );
              print('Loaded ${timelineItems.length} timeline items');
            }
            
            // الحصول على index من البيانات المخزنة في البرنامج أو استخدام 1 كقيمة افتراضية
            int subjectIndex = 1; // قيمة افتراضية
            if (day.subjects.isNotEmpty) {
              // البحث عن المادة في subjects المحفوظة للحصول على index
              final existingSubject = day.subjects.firstWhere(
                (subject) => subject.subjectId == subjectId,
                orElse: () => ProgramSubject(
                  subjectId: subjectId,
                  index: 1,
                  name: '',
                  description: '',
                  timeline: [],
                ),
              );
              subjectIndex = existingSubject.index;
            }
            
            final enrichedSubject = ProgramSubject(
              subjectId: subjectId,
              index: subjectIndex,
              name: subjectData['name'] ?? 'مادة غير محددة',
              description: subjectData['description'] ?? 'وصف غير محدد',
              timeline: timelineItems,
            );
            
            enrichedSubjects.add(enrichedSubject);
            print('Added enriched subject: ${enrichedSubject.name} with index: ${enrichedSubject.index}');
          } else {
            print('Subject document not found for ID: $subjectId');
            // إذا لم يتم العثور على المادة، إنشاء مادة افتراضية
            final defaultSubject = ProgramSubject(
              subjectId: subjectId,
              index: 1,
              name: 'مادة غير موجودة',
              description: 'لم يتم العثور على تفاصيل المادة',
              timeline: [],
            );
            enrichedSubjects.add(defaultSubject);
          }
        }
        
        final enrichedDay = WeeklyDay(
          dayName: day.dayName,
          subjectIds: day.subjectIds,
          subjects: enrichedSubjects,
        );
        
        enrichedDays.add(enrichedDay);
        print('Added enriched day: ${enrichedDay.dayName} with ${enrichedDay.subjects.length} subjects');
      }
      
      final enrichedProgram = Program(
        id: program.id,
        name: program.name,
        description: program.description,
        classId: program.classId,
        weeklySchedule: enrichedDays,
      );
      
      print('Enriched program completed: ${enrichedProgram.name} with ${enrichedProgram.weeklySchedule.length} days');
      return enrichedProgram;
      
    } catch (e) {
      print('Error enriching program with subjects: $e');
      return program;
    }
  }

  // حساب النسبة المئوية للتقدم
  double calculateProgress(ProgramSubject subject) {
    if (subject.timeline.isEmpty) return 0.0;
    return (subject.index / subject.timeline.length) * 100;
  }

  // الحصول على اسم المرحلة الحالية
  String getCurrentTimelineName(ProgramSubject subject) {
    if (subject.timeline.isEmpty) return 'غير محدد';
    if (subject.index >= subject.timeline.length) {
      return subject.timeline.last.name;
    }
    return subject.timeline[subject.index - 1].name;
  }

  Future<void> refreshData() async {
    if (selectedChild.value != null) {
      await loadProgramsForChild(selectedChild.value!);
    }
  }
}
