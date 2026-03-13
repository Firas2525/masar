import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../widgets/custom_snackbar.dart';

class DataInitializationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final isInitializing = false.obs;

  // بيانات تجريبية للمستخدم
  final Map<String, dynamic> testUserData = {
    'name': 'أحمد محمد',
    'email': 'ahmed@test.com',
    'phone': '+966501234567',
    'address': 'الرياض، المملكة العربية السعودية',
    'role': 'parent',
    'createdAt': FieldValue.serverTimestamp(),
  };

  // بيانات تجريبية للأطفال
  final List<Map<String, dynamic>> testChildrenData = [
    {
      'name': 'فاطمة أحمد',
      'birthDate': '15-03-2019',
      'classroom': 'الفئة الأولى',
      'gender': 'female',
      'healthInfo': {
        'allergies': ['حساسية من المكسرات'],
        'medications': [],
        'emergencyContact': '+966501234568',
      },
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'علي أحمد',
      'birthDate': '22-07-2020',
      'classroom': 'الفئة الثانية',
      'gender': 'male',
      'healthInfo': {
        'allergies': [],
        'medications': [],
        'emergencyContact': '+966501234568',
      },
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'سارة محمد',
      'birthDate': '10-05-2020',
      'classroom': 'التحضيري',
      'gender': 'female',
      'healthInfo': {
        'allergies': [],
        'medications': [],
        'emergencyContact': '+966501234569',
      },
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للإعلانات
  final List<Map<String, dynamic>> testAnnouncementsData = [
    {
      'content': 'مرحباً بكم في روضة الأطفال! نتمنى لكم عاماً دراسياً موفقاً',
      'type': 'general',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'content': 'سيتم عقد اجتماع أولياء الأمور يوم الخميس القادم',
      'type': 'meeting',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'content': 'تذكير: موعد تسديد الرسوم الشهرية غداً',
      'type': 'payment',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للأنشطة
  final List<Map<String, dynamic>> testActivitiesData = [
    {
      'name': 'الرسم والتلوين',
      'desc': 'أنشطة فنية لتنمية الإبداع',
      'forr': 'جميع الفئات',
      'date': '2024-01-15',
      'total': 25,
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'الرياضة والحركة',
      'desc': 'أنشطة رياضية لتنمية المهارات الحركية',
      'forr': 'الفئة الأولى',
      'date': '2024-01-16',
      'total': 20,
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'القراءة والقصص',
      'desc': 'جلسات قراءة تفاعلية',
      'forr': 'الفئة الثانية',
      'date': '2024-01-17',
      'total': 15,
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للبرامج
  final List<Map<String, dynamic>> testProgramsData = [
    {
      'title': 'برنامج تنمية المهارات اللغوية',
      'desc': 'برنامج شامل لتنمية مهارات اللغة العربية والإنجليزية',
      'forr': 'جميع الفئات',
      'date': '2024-01-20',
      'total_num': 30,
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'برنامج العلوم والتجارب',
      'desc': 'تجارب علمية بسيطة وممتعة',
      'forr': 'الفئة الثانية',
      'date': '2024-01-25',
      'total_num': 20,
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للدورات
  final List<Map<String, dynamic>> testCoursesData = [
    {
      'title': 'دورة الموسيقى والغناء',
      'desc': 'تعلم الألحان والأناشيد التعليمية',
      'forr': 'الفئة الأولى',
      'date': '2024-01-30',
      'total_num': 15,
      'cost': '200 ريال',
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'دورة الحاسوب للأطفال',
      'desc': 'تعلم أساسيات الحاسوب بطريقة مبسطة',
      'forr': 'الفئة الثانية',
      'date': '2024-02-05',
      'total_num': 12,
      'cost': '300 ريال',
      'users': [],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للملاحظات
  final List<Map<String, dynamic>> testNotesData = [
    {
      'content': 'فاطمة تظهر تحسناً ملحوظاً في مهارات التواصل',
      'type': 'academic',
      'teacherId': 'teacher1',
      'date': FieldValue.serverTimestamp(),
    },
    {
      'content': 'علي يحتاج إلى مزيد من الاهتمام في مهارات الكتابة',
      'type': 'academic',
      'teacherId': 'teacher2',
      'date': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للمدفوعات
  final List<Map<String, dynamic>> testPaymentsData = [
    {
      'amount': 500.0,
      'description': 'رسوم شهر يناير',
      'status': 'paid', // تأكد من أن القيمة صحيحة
      'date': FieldValue.serverTimestamp(),
      'dueDate': Timestamp.fromDate(DateTime(2024, 1, 31)),
      'payNumber': 'PAY-001',
    },
    {
      'amount': 500.0,
      'description': 'رسوم شهر فبراير',
      'status': 'pending', // تأكد من أن القيمة صحيحة
      'date': FieldValue.serverTimestamp(),
      'dueDate': Timestamp.fromDate(DateTime(2024, 2, 29)),
      'payNumber': 'PAY-002',
    },
    {
      'amount': 500.0,
      'description': 'رسوم شهر مارس',
      'status': 'overdue', // إضافة حالة متأخر
      'date': FieldValue.serverTimestamp(),
      'dueDate': Timestamp.fromDate(DateTime(2024, 3, 31)),
      'payNumber': 'PAY-003',
    },
  ];

  // بيانات تجريبية للاختبارات
  final List<Map<String, dynamic>> testTestsData = [
    {
      'subject': 'اللغة العربية',
      'score': 85.0,
      'maxScore': 100.0,
      'notes': 'أداء ممتاز في القراءة والكتابة',
      'teacherId': 'teacher1',
      'date': FieldValue.serverTimestamp(),
    },
    {
      'subject': 'الرياضيات',
      'score': 90.0,
      'maxScore': 100.0,
      'notes': 'متفوق في العمليات الحسابية',
      'teacherId': 'teacher2',
      'date': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للصفوف
  final List<Map<String, dynamic>> testClassesData = [
    {
      'name': 'الفئة الأولى',
      'description': 'للأطفال من عمر 3-4 سنوات',
      'maxStudents': 20,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'الفئة الثانية',
      'description': 'للأطفال من عمر 4-5 سنوات',
      'maxStudents': 18,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'الفئة الثالثة',
      'description': 'للأطفال من عمر 5-6 سنوات',
      'maxStudents': 15,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  // بيانات تجريبية للجدول الزمني
  final List<Map<String, dynamic>> testScheduleData = [
    {
      'day': 'الأحد',
      'activities': [
        {
          'name': 'الاستقبال والتحية',
          'time': '08:00 - 08:30',
          'description': 'استقبال الأطفال وبداية اليوم الدراسي',
        },
        {
          'name': 'اللغة العربية',
          'time': '08:30 - 09:30',
          'description': 'تعلم الحروف والكلمات',
        },
        {
          'name': 'الراحة واللعب',
          'time': '09:30 - 10:00',
          'description': 'وقت للراحة واللعب الحر',
        },
      ],
    },
    {
      'day': 'الاثنين',
      'activities': [
        {
          'name': 'الرياضيات',
          'time': '08:30 - 09:30',
          'description': 'تعلم الأرقام والعمليات الحسابية',
        },
        {
          'name': 'الرسم',
          'time': '09:30 - 10:30',
          'description': 'أنشطة فنية وإبداعية',
        },
      ],
    },
  ];

  @override
  void onInit() {
    super.onInit();
    // التحقق من وجود بيانات أولية عند بدء التطبيق
    _checkAndInitializeData();
  }

  Future<void> _checkAndInitializeData() async {
    try {
      isInitializing.value = true;
      
      // التحقق من وجود مستخدم تجريبي
      final userExists = await _checkTestUserExists();
      if (!userExists) {
        print('Creating test user and initializing data...');
        await _createTestUser();
        await _initializeAllData();
        print('Data initialization completed successfully');
        showCustomSnackbar("نجح", "تم إنشاء البيانات التجريبية بنجاح");
      } else {
        print('Test user already exists, skipping initialization');
      }
    } catch (e) {
      print('Error in _checkAndInitializeData: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في تهيئة البيانات: $e");
    } finally {
      isInitializing.value = false;
    }
  }

  Future<bool> _checkTestUserExists() async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: testUserData['email'])
          .get();
      final exists = query.docs.isNotEmpty;
      print('Test user exists in Firestore: $exists');
      return exists;
    } catch (e) {
      print('Error checking test user: $e');
      return false;
    }
  }

  Future<void> _createTestUser() async {
    try {
      // التحقق من وجود المستخدم أولاً
      final existingUser = await _auth.fetchSignInMethodsForEmail(testUserData['email']);
      if (existingUser.isNotEmpty) {
        print('Test user already exists in Auth');
        // التحقق من وجود البيانات في Firestore
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: testUserData['email'])
            .get();
        
        if (userQuery.docs.isEmpty) {
          print('User exists in Auth but not in Firestore, creating Firestore document...');
          // الحصول على معرف المستخدم من Auth
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: testUserData['email'],
            password: '123456',
          );
          
          // إضافة بيانات المستخدم إلى Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(testUserData);
          
          // تسجيل الخروج
          await _auth.signOut();
        }
        return;
      }

      // إنشاء حساب المستخدم في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: testUserData['email'],
        password: '123456', // كلمة مرور بسيطة للاختبار
      );

      // إضافة بيانات المستخدم إلى Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(testUserData);

      print('Test user created successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Test user already exists');
        // محاولة إنشاء البيانات في Firestore إذا لم تكن موجودة
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: testUserData['email'])
            .get();
        
        if (userQuery.docs.isEmpty) {
          print('Creating Firestore document for existing user...');
          // الحصول على معرف المستخدم من Auth
          final userCredential = await _auth.signInWithEmailAndPassword(
            email: testUserData['email'],
            password: '123456',
          );
          
          // إضافة بيانات المستخدم إلى Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(testUserData);
          
          // تسجيل الخروج
          await _auth.signOut();
        }
      } else {
        print('Error creating test user: $e');
        throw e;
      }
    } catch (e) {
      print('Error creating test user: $e');
      throw e;
    }
  }

  Future<void> _initializeAllData() async {
    try {
      // إنشاء الصفوف
      await _createClasses();
      
      // إنشاء رقم الطالب الأولي
      await _createInitialKidNumber();
      
      // إنشاء الأطفال
      final childrenRefs = await _createChildren();
      
      // إنشاء الإعلانات
      await _createAnnouncements();
      
      // إنشاء الأنشطة
      await _createActivities();
      
      // إنشاء البرامج
      await _createPrograms();
      
      // إنشاء الدورات
      await _createCourses();
      
      // إنشاء الملاحظات مع ربطها بالأطفال
      await _createNotes(childrenRefs);
      
      // إنشاء المدفوعات مع ربطها بالمستخدم
      await _createPayments();
      
      // إنشاء الاختبارات مع ربطها بالأطفال
      await _createTests(childrenRefs);
      
      // إنشاء الجدول الزمني
      await _createSchedule();
      
      // ربط الأطفال بالمستخدم
      await _linkChildrenToUser(childrenRefs);
      
      print('Data initialization completed successfully!');
      print('Created ${childrenRefs.length} children');
      print('Created ${testAnnouncementsData.length} announcements');
      print('Created ${testClassesData.length} classes');
      
    } catch (e) {
      print('Error in _initializeAllData: $e');
      throw e;
    }
  }

  Future<List<DocumentReference>> _createChildren() async {
    final List<DocumentReference> childrenRefs = [];
    
    // الحصول على معرف المستخدم التجريبي
    final userQuery = await _firestore
        .collection('users')
        .where('email', isEqualTo: testUserData['email'])
        .get();
    
    if (userQuery.docs.isEmpty) {
      print('Test user not found, cannot create children');
      return childrenRefs;
    }
    
    final userId = userQuery.docs.first.id;
    
    for (final childData in testChildrenData) {
      final childWithParentId = Map<String, dynamic>.from(childData);
      childWithParentId['parentId'] = userId; // استخدام UID كسلسلة نصية
      
      final docRef = await _firestore.collection('children').add(childWithParentId);
      childrenRefs.add(docRef);
    }
    
    return childrenRefs;
  }

  Future<void> _createClasses() async {
    try {
      final classesData = [
        {
          'name': 'التحضيري',
          'description': 'قسم التحضيري للأطفال من سن 3-4 سنوات',
          'price': 500.0, // Ensure it's double
        },
        {
          'name': 'التمهيدي',
          'description': 'قسم التمهيدي للأطفال من سن 4-5 سنوات',
          'price': 600.0, // Ensure it's double
        },
        {
          'name': 'الروضة',
          'description': 'قسم الروضة للأطفال من سن 5-6 سنوات',
          'price': 700.0, // Ensure it's double
        },
      ];

      for (final classData in classesData) {
        await _firestore.collection('class').add(classData);
      }
      print('Classes created successfully with prices: ${classesData.map((c) => '${c['name']}: ${c['price']}').join(', ')}');
    } catch (e) {
      print('Error creating classes: $e');
    }
  }

  Future<void> _createInitialKidNumber() async {
    try {
      await _firestore.collection('Numbers').doc('kId').set({
        'kId': 1,
      });
      print('Initial kid number created successfully');
    } catch (e) {
      print('Error creating initial kid number: $e');
    }
  }

  Future<void> _createAnnouncements() async {
    try {
      final announcementsData = [
        {
          'content': 'مرحباً بكم في روضة الأطفال! نتمنى لكم عاماً دراسياً موفقاً',
          'date': FieldValue.serverTimestamp(),
        },
        {
          'content': 'سيتم عقد اجتماع أولياء الأمور الأسبوع القادم',
          'date': FieldValue.serverTimestamp(),
        },
        {
          'content': 'تذكير: يرجى إحضار الكتب المطلوبة غداً',
          'date': FieldValue.serverTimestamp(),
        },
      ];

      for (final announcementData in announcementsData) {
        await _firestore.collection('announcements').add(announcementData);
      }
      print('Announcements created successfully');
    } catch (e) {
      print('Error creating announcements: $e');
    }
  }

  Future<void> _createActivities() async {
    for (final activityData in testActivitiesData) {
      await _firestore.collection('activities').add(activityData);
    }
  }

  Future<void> _createPrograms() async {
    try {
      // الحصول على الأقسام والمواد
      final classesQuery = await _firestore.collection('class').get();
      final subjectsQuery = await _firestore.collection('subjects').get();
      
      final classes = classesQuery.docs;
      final subjects = subjectsQuery.docs;

      for (final classDoc in classes) {
        final className = classDoc.data()['name'] as String;
        final classId = classDoc.id; // استخدام ID الكلاس وليس الاسم
        final classSubjects = subjects.where((doc) => doc.data()['classId'] == classId).toList();
        
        print('Creating programs for class: $className (ID: $classId)');
        print('Found ${classSubjects.length} subjects for this class');
        
        if (classSubjects.isEmpty) {
          print('No subjects found for class: $className');
          continue;
        }
        
        // إنشاء برامج مختلفة لكل قسم
        final programsData = _getProgramsForClass(className, classSubjects);
        
        for (final programData in programsData) {
          programData['classId'] = classId; // استخدام ID الكلاس
          await _firestore.collection('programs').add(programData);
          print('Created program: ${programData['name']} for class ID: $classId');
          print('Program has ${(programData['weeklySchedule'] as List).length} days');
        }
      }
      print('Programs created successfully');
    } catch (e) {
      print('Error creating programs: $e');
    }
  }

  List<Map<String, dynamic>> _getProgramsForClass(String className, List<QueryDocumentSnapshot> subjects) {
    switch (className) {
      case 'التحضيري':
        return [
          {
            'name': 'البرنامج التجريبي الشامل للتحضيري',
            'description': 'برنامج تجريبي شامل ومفصل لتعلم جميع المهارات الأساسية في التحضيري مع جدول أسبوعي منظم',
            'weeklySchedule': [
              {
                'dayName': 'الأحد',
                'subjectIds': subjects.take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الاثنين',
                'subjectIds': subjects.skip(2).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الثلاثاء',
                'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الأربعاء',
                'subjectIds': subjects.skip(1).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الخميس',
                'subjectIds': subjects.skip(3).take(2).map((doc) => doc.id).toList(),
              },
            ],
          },
          {
            'name': 'البرنامج الأساسي للتحضيري',
            'description': 'برنامج شامل لتعلم الأساسيات في التحضيري',
            'weeklySchedule': [
              {
                'dayName': 'الأحد',
                'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الاثنين',
                'subjectIds': subjects.skip(1).take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الثلاثاء',
                'subjectIds': subjects.skip(2).take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الأربعاء',
                'subjectIds': subjects.skip(3).take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الخميس',
                'subjectIds': subjects.skip(4).take(1).map((doc) => doc.id).toList(),
              },
            ],
          },
        ];
      case 'التمهيدي':
        return [
          {
            'name': 'البرنامج المتقدم للتمهيدي',
            'description': 'برنامج متقدم لتعلم المهارات المتقدمة في التمهيدي',
            'weeklySchedule': [
              {
                'dayName': 'الأحد',
                'subjectIds': subjects.take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الاثنين',
                'subjectIds': subjects.skip(2).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الثلاثاء',
                'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الأربعاء',
                'subjectIds': subjects.skip(1).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الخميس',
                'subjectIds': subjects.skip(3).take(2).map((doc) => doc.id).toList(),
              },
            ],
          },
        ];
      case 'الروضة':
        return [
          {
            'name': 'البرنامج النهائي للروضة',
            'description': 'برنامج نهائي لتعلم جميع المهارات الأساسية في الروضة',
            'weeklySchedule': [
              {
                'dayName': 'الأحد',
                'subjectIds': subjects.take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الاثنين',
                'subjectIds': subjects.skip(2).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الثلاثاء',
                'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الأربعاء',
                'subjectIds': subjects.skip(1).take(2).map((doc) => doc.id).toList(),
              },
              {
                'dayName': 'الخميس',
                'subjectIds': subjects.skip(3).take(2).map((doc) => doc.id).toList(),
              },
            ],
          },
        ];
      default:
        return [];
    }
  }

  Future<void> _createCourses() async {
    for (final courseData in testCoursesData) {
      await _firestore.collection('courses').add(courseData);
    }
  }

  Future<void> _createNotes(List<DocumentReference> childrenRefs) async {
    for (int i = 0; i < testNotesData.length && i < childrenRefs.length; i++) {
      final noteData = Map<String, dynamic>.from(testNotesData[i]);
      noteData['childId'] = childrenRefs[i].id;
      await _firestore.collection('notes').add(noteData);
    }
  }

  Future<void> _createPayments() async {
    try {
      // الحصول على معرف المستخدم التجريبي
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: testUserData['email'])
          .get();
      
      if (userQuery.docs.isNotEmpty) {
        final userId = userQuery.docs.first.id;
        
        // الحصول على الأطفال للمستخدم
        final childrenQuery = await _firestore
            .collection('children')
            .where('parentId', isEqualTo: userId)
            .get();
        
        final children = childrenQuery.docs;
        
        if (children.isNotEmpty) {
          // إنشاء مدفوعات لكل طفل
          for (int i = 0; i < children.length; i++) {
            final childId = children[i].id;
            
            for (int j = 0; j < testPaymentsData.length; j++) {
              final paymentData = Map<String, dynamic>.from(testPaymentsData[j]);
              paymentData['userId'] = userId;
              paymentData['childId'] = childId;
              paymentData['payNumber'] = 'PAY-${(i + 1).toString().padLeft(3, '0')}-${(j + 1).toString().padLeft(3, '0')}';
              
              // ضمان وجود تاريخ صحيح
              if (paymentData['date'] == null) {
                paymentData['date'] = FieldValue.serverTimestamp();
              }
              
              await _firestore.collection('payments').add(paymentData);
            }
          }
          
          print('Created ${children.length * testPaymentsData.length} payments for ${children.length} children');
        } else {
          print('No children found for user, creating payments without childId');
          for (final paymentData in testPaymentsData) {
            final paymentWithUserId = Map<String, dynamic>.from(paymentData);
            paymentWithUserId['userId'] = userId;
            paymentWithUserId['childId'] = ''; // إضافة childId فارغ لتجنب الأخطاء
            paymentWithUserId['payNumber'] = 'PAY-000-${DateTime.now().millisecondsSinceEpoch}';
            
            // ضمان وجود تاريخ صحيح
            if (paymentWithUserId['date'] == null) {
              paymentWithUserId['date'] = FieldValue.serverTimestamp();
            }
            
            await _firestore.collection('payments').add(paymentWithUserId);
          }
        }
      }
    } catch (e) {
      print('Error creating payments: $e');
    }
  }

  Future<void> _createTests(List<DocumentReference> childrenRefs) async {
    for (int i = 0; i < testTestsData.length && i < childrenRefs.length; i++) {
      final testData = Map<String, dynamic>.from(testTestsData[i]);
      testData['childId'] = childrenRefs[i].id;
      await _firestore.collection('tests').add(testData);
    }
  }

  Future<void> _createSchedule() async {
    for (final scheduleData in testScheduleData) {
      await _firestore.collection('schedule').add(scheduleData);
    }
  }

  Future<void> _linkChildrenToUser(List<DocumentReference> childrenRefs) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: testUserData['email'])
          .get();
      
      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        await userDoc.reference.update({
          'children': childrenRefs,
        });
      }
    } catch (e) {
      print('Error linking children to user: $e');
    }
  }

  // دالة لحذف جميع البيانات التجريبية (للاستخدام في التطوير فقط)
  Future<void> deleteAllTestData() async {
    try {
      isInitializing.value = true;
      
      // حذف جميع المجموعات
      final collections = [
        'users',
        'children',
        'class',
        'advertisments',
        'activities',
        'programs',
        'courses',
        'notes',
        'payments',
        'tests',
        'schedule',
        'Numbers',
      ];
      
      for (final collectionName in collections) {
        final query = await _firestore.collection(collectionName).get();
        final batch = _firestore.batch();
        
        for (final doc in query.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
      showCustomSnackbar("نجح", "تم حذف جميع البيانات التجريبية");
    } catch (e) {
      print('Error deleting test data: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف البيانات");
    } finally {
      isInitializing.value = false;
    }
  }

  // دالة لإعادة تهيئة البيانات
  Future<void> reinitializeData() async {
    try {
      isInitializing.value = true;
      await deleteAllTestData();
      await _createTestUser();
      await _createClasses();
      await _createSubjects();
      await _createPrograms();
      await _createChildren();
      await _createAnnouncements();
      await _createInitialKidNumber();
      showCustomSnackbar("نجح", "تم إعادة تهيئة البيانات بنجاح");
    } catch (e) {
      print('Error reinitializing data: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إعادة تهيئة البيانات");
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _createSubjects() async {
    try {
      // الحصول على الأقسام
      final classesQuery = await _firestore.collection('class').get();
      final classes = classesQuery.docs;

      for (final classDoc in classes) {
        final className = classDoc.data()['name'] as String;
        final subjectsData = _getSubjectsForClass(className);
        
        for (int i = 0; i < subjectsData.length; i++) {
          final subjectData = subjectsData[i];
          subjectData['classId'] = classDoc.id;
          subjectData['index'] = i + 1;
          await _firestore.collection('subjects').add(subjectData);
        }
      }
      print('Subjects created successfully');
    } catch (e) {
      print('Error creating subjects: $e');
    }
  }

  List<Map<String, dynamic>> _getSubjectsForClass(String className) {
    switch (className) {
      case 'التحضيري':
        return [
          {
            'name': 'اللغة العربية',
            'description': 'تعلم الحروف العربية والقراءة والكتابة',
            'timeline': [
              {
                'name': 'الحروف الهجائية',
                'description': 'تعلم جميع الحروف العربية مع الحركات',
              },
              {
                'name': 'الكلمات البسيطة',
                'description': 'تكوين كلمات من حرفين وثلاثة أحرف',
              },
              {
                'name': 'الجمل القصيرة',
                'description': 'قراءة وكتابة جمل بسيطة',
              },
              {
                'name': 'القصص القصيرة',
                'description': 'قراءة قصص بسيطة وفهم المحتوى',
              },
              {
                'name': 'التعبير الكتابي',
                'description': 'كتابة جمل وتعبيرات بسيطة',
              },
            ],
          },
          {
            'name': 'الرياضيات',
            'description': 'تعلم الأرقام والعمليات الحسابية الأساسية',
            'timeline': [
              {
                'name': 'الأرقام من 1 إلى 10',
                'description': 'تعلم كتابة وقراءة الأرقام الأساسية',
              },
              {
                'name': 'العد والترتيب',
                'description': 'عد الأشياء وترتيبها حسب العدد',
              },
              {
                'name': 'الجمع البسيط',
                'description': 'جمع أرقام بسيطة باستخدام الصور',
              },
              {
                'name': 'الطرح البسيط',
                'description': 'طرح أرقام بسيطة باستخدام الصور',
              },
              {
                'name': 'الأشكال الهندسية',
                'description': 'تعلم الأشكال الأساسية (مربع، دائرة، مثلث)',
              },
            ],
          },
          {
            'name': 'اللغة الإنجليزية',
            'description': 'تعلم أساسيات اللغة الإنجليزية للأطفال',
            'timeline': [
              {
                'name': 'الحروف الإنجليزية',
                'description': 'تعلم الحروف الأبجدية الإنجليزية',
              },
              {
                'name': 'الألوان والأرقام',
                'description': 'تعلم أسماء الألوان والأرقام بالإنجليزية',
              },
              {
                'name': 'أسماء الحيوانات',
                'description': 'تعلم أسماء الحيوانات الشائعة',
              },
              {
                'name': 'الجمل البسيطة',
                'description': 'تكوين جمل بسيطة بالإنجليزية',
              },
              {
                'name': 'المحادثة البسيطة',
                'description': 'ممارسة المحادثة البسيطة',
              },
            ],
          },
          {
            'name': 'العلوم',
            'description': 'اكتشاف العالم من حولنا',
            'timeline': [
              {
                'name': 'أجزاء الجسم',
                'description': 'تعلم أجزاء الجسم البشري',
              },
              {
                'name': 'الحيوانات والنباتات',
                'description': 'التعرف على أنواع الحيوانات والنباتات',
              },
              {
                'name': 'الطقس والفصول',
                'description': 'تعلم الفصول الأربعة وأنواع الطقس',
              },
              {
                'name': 'الألوان والضوء',
                'description': 'اكتشاف الألوان وخصائص الضوء',
              },
              {
                'name': 'التجارب البسيطة',
                'description': 'إجراء تجارب علمية بسيطة وآمنة',
              },
            ],
          },
          {
            'name': 'الفنون والإبداع',
            'description': 'تطوير المهارات الفنية والإبداعية',
            'timeline': [
              {
                'name': 'الرسم الحر',
                'description': 'التعبير عن النفس من خلال الرسم',
              },
              {
                'name': 'التلوين',
                'description': 'تعلم تقنيات التلوين المختلفة',
              },
              {
                'name': 'الأشغال اليدوية',
                'description': 'صنع أشياء بسيطة من مواد مختلفة',
              },
              {
                'name': 'الموسيقى والحركة',
                'description': 'التعرف على الأصوات والحركة الإيقاعية',
              },
              {
                'name': 'المسرح البسيط',
                'description': 'تمثيل قصص بسيطة وتطوير الثقة بالنفس',
              },
            ],
          },
        ];
      case 'التمهيدي':
        return [
          {
            'name': 'القراءة والكتابة',
            'description': 'تطوير مهارات القراءة والكتابة',
            'timeline': [
              {
                'name': 'الحروف المتقدمة',
                'description': 'تعلم الحروف المتقدمة والحركات',
              },
              {
                'name': 'الكلمات المركبة',
                'description': 'قراءة وكتابة كلمات مركبة',
              },
              {
                'name': 'القصص القصيرة',
                'description': 'قراءة قصص قصيرة وفهمها',
              },
            ],
          },
          {
            'name': 'الرياضيات المتقدمة',
            'description': 'تعلم العمليات الحسابية الأساسية',
            'timeline': [
              {
                'name': 'الأرقام من 1-20',
                'description': 'تعلم الأرقام الكبيرة',
              },
              {
                'name': 'الجمع والطرح',
                'description': 'عمليات الجمع والطرح البسيطة',
              },
              {
                'name': 'المقارنة',
                'description': 'مقارنة الأرقام والأحجام',
              },
            ],
          },
          {
            'name': 'العلوم والتجارب',
            'description': 'تجارب علمية بسيطة وممتعة',
            'timeline': [
              {
                'name': 'التجارب البسيطة',
                'description': 'تجارب علمية آمنة وبسيطة',
              },
              {
                'name': 'الطقس والفصول',
                'description': 'تعلم الفصول الأربعة والطقس',
              },
              {
                'name': 'الحواس الخمس',
                'description': 'تعلم الحواس الخمس واستخداماتها',
              },
            ],
          },
        ];
      case 'الروضة':
        return [
          {
            'name': 'اللغة العربية المتقدمة',
            'description': 'تطوير مهارات اللغة العربية المتقدمة',
            'timeline': [
              {
                'name': 'القواعد الأساسية',
                'description': 'تعلم قواعد اللغة الأساسية',
              },
              {
                'name': 'التعبير الكتابي',
                'description': 'كتابة فقرات قصيرة',
              },
              {
                'name': 'الفهم القرائي',
                'description': 'فهم النصوص والقصص',
              },
            ],
          },
          {
            'name': 'الرياضيات المتقدمة',
            'description': 'تعلم الرياضيات المتقدمة',
            'timeline': [
              {
                'name': 'الأرقام من 1-100',
                'description': 'تعلم الأرقام الكبيرة',
              },
              {
                'name': 'العمليات الحسابية',
                'description': 'الجمع والطرح والضرب البسيط',
              },
              {
                'name': 'الهندسة البسيطة',
                'description': 'الأشكال الهندسية والقياسات',
              },
            ],
          },
          {
            'name': 'العلوم والتكنولوجيا',
            'description': 'تعلم العلوم والتكنولوجيا الحديثة',
            'timeline': [
              {
                'name': 'التكنولوجيا البسيطة',
                'description': 'تعلم استخدام الأجهزة البسيطة',
              },
              {
                'name': 'البيئة والمحافظة عليها',
                'description': 'تعلم المحافظة على البيئة',
              },
              {
                'name': 'الاكتشافات العلمية',
                'description': 'تعلم الاكتشافات العلمية المهمة',
              },
            ],
          },
        ];
      default:
        return [];
    }
  }

  // دالة لحذف البيانات فقط (بدون إعادة إنشاء)
  Future<void> clearDataOnly() async {
    try {
      isInitializing.value = true;
      
      // حذف البيانات فقط
      await deleteAllTestData();
      
      showCustomSnackbar("نجح", "تم حذف جميع البيانات بنجاح");
    } catch (e) {
      print('Error clearing data: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في حذف البيانات");
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> createExperimentalProgram() async {
    try {
      print('Creating experimental program for التحضيري...');
      
      // البحث عن قسم التحضيري
      final classQuery = await _firestore
          .collection('class')
          .where('name', isEqualTo: 'التحضيري')
          .get();
      
      if (classQuery.docs.isEmpty) {
        print('التحضيري class not found');
        return;
      }
      
      final classDoc = classQuery.docs.first;
      final classId = classDoc.id;
      print('Found التحضيري class with ID: $classId');
      
      // البحث عن المواد الخاصة بقسم التحضيري
      final subjectsQuery = await _firestore
          .collection('subjects')
          .where('classId', isEqualTo: classId)
          .get();
      
      final subjects = subjectsQuery.docs;
      print('Found ${subjects.length} subjects for التحضيري');
      
      if (subjects.isEmpty) {
        print('No subjects found for التحضيري');
        return;
      }
      
      // إنشاء برنامج تجريبي مفصل مع أيام الأسبوع
      final experimentalProgram = {
        'name': 'البرنامج التجريبي الشامل للتحضيري',
        'description': 'برنامج تجريبي شامل ومفصل لتعلم جميع المهارات الأساسية في التحضيري مع جدول أسبوعي منظم',
        'classId': classId,
        'weeklySchedule': [
          {
            'dayName': 'الأحد',
            'subjectIds': subjects.take(2).map((doc) => doc.id).toList(),
          },
          {
            'dayName': 'الاثنين',
            'subjectIds': subjects.skip(2).take(2).map((doc) => doc.id).toList(),
          },
          {
            'dayName': 'الثلاثاء',
            'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
          },
          {
            'dayName': 'الأربعاء',
            'subjectIds': subjects.skip(1).take(2).map((doc) => doc.id).toList(),
          },
          {
            'dayName': 'الخميس',
            'subjectIds': subjects.skip(3).take(2).map((doc) => doc.id).toList(),
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'isExperimental': true,
        'version': '1.0',
        'features': [
          'تتبع التقدم التفصيلي',
          'مواد شاملة ومتنوعة',
          'timeline مفصل لكل مادة',
          'تقارير التقدم',
          'جدول أسبوعي منظم',
        ],
      };
      
      // إضافة البرنامج التجريبي
      final programRef = await _firestore.collection('programs').add(experimentalProgram);
      print('Created experimental program with ID: ${programRef.id}');
      
      // طباعة تفاصيل البرنامج
      print('Experimental Program Details:');
      print('- Name: ${experimentalProgram['name']}');
      print('- Description: ${experimentalProgram['description']}');
      print('- Class ID: ${experimentalProgram['classId']}');
      print('- Days Count: ${(experimentalProgram['weeklySchedule'] as List).length}');
      print('- Features: ${experimentalProgram['features']}');
      
      // طباعة تفاصيل كل يوم
      for (int i = 0; i < (experimentalProgram['weeklySchedule'] as List).length; i++) {
        final day = (experimentalProgram['weeklySchedule'] as List)[i];
        print('- Day ${i + 1}: ${day['dayName']} - ${(day['subjectIds'] as List).length} subjects');
      }
      
      showCustomSnackbar("نجح", "تم إنشاء البرنامج التجريبي للتحضيري بنجاح");
      
    } catch (e) {
      print('Error creating experimental program: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إنشاء البرنامج التجريبي: $e");
    }
  }

  Future<void> createSimpleTestProgram() async {
    try {
      print('Creating simple test program...');
      
      // البحث عن قسم التحضيري
      final classQuery = await _firestore
          .collection('class')
          .where('name', isEqualTo: 'التحضيري')
          .get();
      
      if (classQuery.docs.isEmpty) {
        print('التحضيري class not found');
        return;
      }
      
      final classDoc = classQuery.docs.first;
      final classId = classDoc.id;
      print('Found التحضيري class with ID: $classId');
      
      // البحث عن المواد الخاصة بقسم التحضيري
      final subjectsQuery = await _firestore
          .collection('subjects')
          .where('classId', isEqualTo: classId)
          .get();
      
      final subjects = subjectsQuery.docs;
      print('Found ${subjects.length} subjects for التحضيري');
      
      if (subjects.isEmpty) {
        print('No subjects found for التحضيري');
        showCustomSnackbar("تنبيه", "لم يتم العثور على مواد للقسم التحضيري");
        return;
      }
      
      // إنشاء برنامج تجريبي بسيط مع مواد حقيقية
      final simpleProgram = {
        'name': 'برنامج تجريبي بسيط',
        'description': 'برنامج تجريبي بسيط للاختبار مع مواد حقيقية',
        'classId': classId,
        'weeklySchedule': [
          {
            'dayName': 'الأحد',
            'subjectIds': subjects.take(1).map((doc) => doc.id).toList(),
          },
          {
            'dayName': 'الاثنين',
            'subjectIds': subjects.skip(1).take(1).map((doc) => doc.id).toList(),
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'isTest': true,
      };
      
      // إضافة البرنامج التجريبي
      final programRef = await _firestore.collection('programs').add(simpleProgram);
      print('Created simple test program with ID: ${programRef.id}');
      print('Program has ${(simpleProgram['weeklySchedule'] as List).length} days');
      
      // طباعة تفاصيل البرنامج
      print('Simple Test Program Details:');
      print('- Name: ${simpleProgram['name']}');
      print('- Description: ${simpleProgram['description']}');
      print('- Class ID: ${simpleProgram['classId']}');
      print('- Days Count: ${(simpleProgram['weeklySchedule'] as List).length}');
      
      // طباعة تفاصيل كل يوم
      for (int i = 0; i < (simpleProgram['weeklySchedule'] as List).length; i++) {
        final day = (simpleProgram['weeklySchedule'] as List)[i];
        print('- Day ${i + 1}: ${day['dayName']} - ${(day['subjectIds'] as List).length} subjects');
      }
      
      showCustomSnackbar("نجح", "تم إنشاء البرنامج التجريبي البسيط بنجاح");
      
    } catch (e) {
      print('Error creating simple test program: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إنشاء البرنامج التجريبي البسيط: $e");
    }
  }

  // دالة لإعادة إنشاء المدفوعات بالهيكل الصحيح
  Future<void> recreatePaymentsWithProperStructure() async {
    try {
      print('Recreating payments with proper structure...');
      
      // حذف المدفوعات الموجودة
      final existingPayments = await _firestore.collection('payments').get();
      final batch = _firestore.batch();
      
      for (final doc in existingPayments.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Deleted ${existingPayments.docs.length} existing payments');
      
      // إعادة إنشاء المدفوعات
      await _createPayments();
      
      showCustomSnackbar("نجح", "تم إعادة إنشاء المدفوعات بالهيكل الصحيح");
    } catch (e) {
      print('Error recreating payments: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إعادة إنشاء المدفوعات");
    }
  }

  Future<void> recreatePaymentsWithProperStatus() async {
    try {
      print('Recreating payments with proper status...');
      
      // حذف المدفوعات الموجودة
      final existingPayments = await _firestore.collection('payments').get();
      final batch = _firestore.batch();
      for (final doc in existingPayments.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Deleted ${existingPayments.docs.length} existing payments');
      
      // إعادة إنشاء المدفوعات مع status صحيح
      await _createPayments();
      showCustomSnackbar("نجح", "تم إعادة إنشاء المدفوعات مع الحالات الصحيحة");
    } catch (e) {
      print('Error recreating payments with status: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إعادة إنشاء المدفوعات");
    }
  }

  Future<void> createSampleChatMessages() async {
    try {
      print('Creating sample chat messages...');
      
      // الحصول على معرف المستخدم التجريبي
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: testUserData['email'])
          .get();
      
      if (userQuery.docs.isEmpty) {
        print('Test user not found, cannot create chat messages');
        return;
      }
      
      final userId = userQuery.docs.first.id;
      final userName = userQuery.docs.first.data()['name'] ?? 'ولي الأمر';
      
      // الحصول على الأطفال
      final childrenQuery = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: userId)
          .get();
      
      if (childrenQuery.docs.isEmpty) {
        print('No children found for user, cannot create chat messages');
        return;
      }
      
      final sampleMessages = [
        {
          'content': 'مرحباً! كيف حال الطالب اليوم؟',
          'senderId': 'teacher1',
          'senderName': 'المعلمة سارة',
          'senderType': 'teacher',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
        {
          'content': 'الحمد لله، الطالب بخير ومتفاعل في الدراسة',
          'senderId': userId,
          'senderName': userName,
          'senderType': 'parent',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
        {
          'content': 'ممتاز! الطالب أظهر تحسناً كبيراً في القراءة',
          'senderId': 'teacher1',
          'senderName': 'المعلمة سارة',
          'senderType': 'teacher',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
        {
          'content': 'شكراً لكِ. هل هناك واجبات مطلوبة؟',
          'senderId': userId,
          'senderName': userName,
          'senderType': 'parent',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
        {
          'content': 'نعم، تم تكليف الطالب بقراءة قصة وتلخيصها',
          'senderId': 'teacher1',
          'senderName': 'المعلمة سارة',
          'senderType': 'teacher',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
      ];
      
      // إنشاء رسائل لكل طفل
      for (final childDoc in childrenQuery.docs) {
        final childId = childDoc.id;
        
        for (final messageData in sampleMessages) {
          final messageWithChildId = Map<String, dynamic>.from(messageData);
          messageWithChildId['childId'] = childId;
          
          await _firestore.collection('chat_messages').add(messageWithChildId);
        }
      }
      
      print('Created ${sampleMessages.length * childrenQuery.docs.length} sample chat messages');
      showCustomSnackbar("نجح", "تم إنشاء رسائل محادثة تجريبية");
    } catch (e) {
      print('Error creating sample chat messages: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إنشاء رسائل المحادثة");
    }
  }

  Future<void> createFirebaseIndexes() async {
    try {
      print('Creating Firebase indexes...');
      
      // إنشاء index للمحادثات
      final indexData = {
        'collectionGroup': 'chat_messages',
        'queryScope': 'COLLECTION',
        'fields': [
          {
            'fieldPath': 'childId',
            'order': 'ASCENDING',
          },
          {
            'fieldPath': 'timestamp',
            'order': 'ASCENDING',
          },
        ],
      };
      
      // ملاحظة: لا يمكن إنشاء الـ indexes برمجياً في Firebase
      // يجب إنشاؤها يدوياً من Firebase Console
      print('Please create the following index manually in Firebase Console:');
      print('Collection: chat_messages');
      print('Fields: childId (Ascending), timestamp (Ascending)');
      print('Or use this link: https://console.firebase.google.com/v1/r/project/kindergarten-2ada3/firestore/indexes');
      
      showCustomSnackbar("تنبيه", "يرجى إنشاء الـ index يدوياً في Firebase Console");
    } catch (e) {
      print('Error creating Firebase indexes: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إنشاء الـ indexes");
    }
  }

  Future<void> recreateClassesWithPrices() async {
    try {
      print('Recreating classes with prices...');
      
      // حذف الصفوف الموجودة
      final existingClasses = await _firestore.collection('class').get();
      final batch = _firestore.batch();
      for (final doc in existingClasses.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Deleted ${existingClasses.docs.length} existing classes');
      
      // إعادة إنشاء الصفوف مع الأسعار
      await _createClasses();
      showCustomSnackbar("نجح", "تم إعادة إنشاء الصفوف مع الأسعار");
    } catch (e) {
      print('Error recreating classes: $e');
      showCustomSnackbar("خطأ", "حدث خطأ في إعادة إنشاء الصفوف");
    }
  }
} 