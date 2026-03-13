import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Child {
  final String id;
  final String name;
  final String birthDate;
  final String classroom;
  final String classId;
  final String parentId;
  final String gender;
  final int kId;
  final DateTime? registerDate;
  final String approved;
  final String location; // موقع الطفل: في الروضة، في الباص، في المنزل

  Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.classroom,
    required this.parentId,
    required this.classId,
    required this.gender,
    required this.kId,
    this.registerDate,
    required this.approved,
    this.location = 'في المنزل', // القيمة الافتراضية
  });

  factory Child.fromFirestore(Map<String, dynamic> data, String id) {
    try {
      return Child(
        id: id,
        name: data['name']?.toString() ?? '',
        birthDate: data['birthDate']?.toString() ?? '',
        classroom: data['classroom']?.toString() ?? '',
        parentId: data['parentId'] is DocumentReference
            ? (data['parentId'] as DocumentReference).id
            : (data['parentId']?.toString() ?? ''),
        gender: data['gender']?.toString() ?? '',
        kId: data['kId'] is int
            ? data['kId']
            : int.tryParse(data['kId']?.toString() ?? '0') ?? 0,
        registerDate: data['registerDate'] != null
            ? (data['registerDate'] is Timestamp
                  ? (data['registerDate'] as Timestamp).toDate()
                  : DateTime.tryParse(data['registerDate'].toString()) ??
                        DateTime.now())
            : null,
        approved: data['approved']?.toString() ?? 'wait',
        location: data['location']?.toString() ?? 'في المنزل',
        classId: data['classroom']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing child data: $e');
      print('Child data: $data');
      // إرجاع بيانات افتراضية في حالة الخطأ
      return Child(
        id: id,
        name: data['name']?.toString() ?? 'غير محدد',
        birthDate: data['birthDate']?.toString() ?? '',
        classroom: data['classroom']?.toString() ?? 'غير محدد',
        parentId: data['parentId']?.toString() ?? '',
        gender: data['gender']?.toString() ?? '',
        kId: 0,
        registerDate: null,
        approved: 'wait',
        location: data['location']?.toString() ?? 'في المنزل',
        classId: data['classroom']?.toString() ?? '',
      );
    }
  }

  // حساب عمر الطفل
  String get age {
    try {
      if (birthDate.isEmpty) return 'غير محدد';

      final birthDateParts = birthDate.split('-');
      if (birthDateParts.length == 3) {
        final birth = DateTime(
          int.parse(birthDateParts[2]),
          int.parse(birthDateParts[1]),
          int.parse(birthDateParts[0]),
        );
        final now = DateTime.now();
        final age = now.difference(birth).inDays ~/ 365;
        return '$age سنوات';
      }
      return 'غير محدد';
    } catch (e) {
      print('Error calculating age: $e');
      return 'غير محدد';
    }
  }

  // تنسيق تاريخ التسجيل
  String get formattedRegisterDate {
    if (registerDate == null) return 'غير محدد';
    try {
      return '${registerDate!.day.toString().padLeft(2, '0')}/${registerDate!.month.toString().padLeft(2, '0')}/${registerDate!.year}';
    } catch (e) {
      print('Error formatting register date: $e');
      return 'غير محدد';
    }
  }

  // تنسيق تاريخ الميلاد
  String get formattedBirthDate {
    try {
      if (birthDate.isEmpty) return 'غير محدد';

      final birthDateParts = birthDate.split('-');
      if (birthDateParts.length == 3) {
        return '${birthDateParts[0]}/${birthDateParts[1]}/${birthDateParts[2]}';
      }
      return birthDate;
    } catch (e) {
      print('Error formatting birth date: $e');
      return birthDate.isEmpty ? 'غير محدد' : birthDate;
    }
  }

  // الحصول على حالة الموافقة
  String get approvalStatus {
    try {
      switch (approved.toLowerCase()) {
        case 'approved':
          return 'موافق عليه';
        case 'wait':
          return 'في الانتظار';
        case 'rejected':
          return 'مرفوض';
        default:
          return 'غير محدد';
      }
    } catch (e) {
      print('Error getting approval status: $e');
      return 'غير محدد';
    }
  }

  // الحصول على الجنس بالعربية
  String get genderInArabic {
    try {
      switch (gender.toLowerCase()) {
        case 'male':
          return 'ذكر';
        case 'female':
          return 'أنثى';
        default:
          return 'غير محدد';
      }
    } catch (e) {
      print('Error getting gender in Arabic: $e');
      return 'غير محدد';
    }
  }
}

class Announcement {
  final String id;
  final String content;

  Announcement({required this.id, required this.content});

  factory Announcement.fromFirestore(Map<String, dynamic> data, String id) {
    return Announcement(id: id, content: data['content'] ?? '');
  }
}

// نموذج لإدخالات سجل الصيانة
class MaintenanceRecord {
  final String id; // client generated id
  final String date; // ISO string
  final String title;
  final String description;
  final double cost;

  MaintenanceRecord({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.cost,
  });

  factory MaintenanceRecord.fromMap(Map<String, dynamic> data) {
    return MaintenanceRecord(
      id: data['id']?.toString() ?? UniqueKey().toString(),
      date: data['date']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      cost: data['cost'] != null
          ? double.tryParse(data['cost'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'title': title,
    'description': description,
    'cost': cost,
  };
}

// نموذج للمخالفة المرورية
class Violation {
  final String id;
  final String title;
  final String description;
  final double fine;
  final String status; // pending | active | resolved
  final DateTime? createdAt;
  final Map<String, dynamic>? transfer; // transfer info submitted by user
  final String type; // violation category/type

  Violation({
    required this.id,
    required this.title,
    required this.description,
    required this.fine,
    this.status = 'pending',
    this.createdAt,
    this.transfer,
    this.type = 'أخرى',
  });

  factory Violation.fromMap(Map<String, dynamic> data) {
    DateTime? created;
    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'] is Timestamp) {
          created = (data['createdAt'] as Timestamp).toDate();
        } else {
          created = DateTime.tryParse(data['createdAt'].toString());
        }
      } catch (e) {
        created = null;
      }
    }
    Map<String, dynamic>? transferMap;
    try {
      if (data['transfer'] != null && data['transfer'] is Map) {
        transferMap = Map<String, dynamic>.from(data['transfer'] as Map);
      }
    } catch (e) {
      transferMap = null;
    }
    String vType = 'أخرى';
    try {
      if (data['type'] != null) vType = data['type'].toString();
    } catch (e) {
      vType = 'أخرى';
    }
    return Violation(
      id: data['id']?.toString() ?? UniqueKey().toString(),
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      fine: data['fine'] != null
          ? double.tryParse(data['fine'].toString()) ?? 0.0
          : 0.0,
      status: data['status']?.toString() ?? 'pending',
      createdAt: created,
      transfer: transferMap,
      type: vType,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'fine': fine,
    'status': status,
    'type': type,
    'createdAt':
        createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    if (transfer != null) 'transfer': transfer,
  };
}

// نموذج إعلان سيارة
class Car {
  final String id;
  final String image;
  final String fuelType;
  final String title;
  final String desc;
  final String bodyType;
  final String mileageKill;
  final String trans;
  final String brand;
  final String color;
  final String address;
  final String phone;
  final String userId;
  final DateTime? registerDate;
  final String mechanicImage;
  final String licenseImage;
  final bool isForSale;
  final String?
  price; // new: optional price field (string to preserve formatting)
  final List<MaintenanceRecord> maintenance;
  final String plateNumber; // رقم اللوحة
  final List<Violation> violations;

  Car({
    required this.id,
    required this.image,
    required this.fuelType,
    required this.title,
    required this.desc,
    required this.bodyType,
    required this.mileageKill,
    required this.trans,
    required this.brand,
    required this.color,
    required this.address,
    this.phone = '',
    this.registerDate,
    required this.userId,
    this.mechanicImage = '',
    this.licenseImage = '',
    this.isForSale = false,
    this.price = '',
    this.maintenance = const [],
    this.plateNumber = '',
    this.violations = const [],
  });

  factory Car.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? reg;
    if (data['registerDate'] != null) {
      try {
        if (data['registerDate'] is Timestamp) {
          reg = (data['registerDate'] as Timestamp).toDate();
        } else {
          reg = DateTime.tryParse(data['registerDate'].toString());
        }
      } catch (e) {
        reg = null;
      }
    }

    List<MaintenanceRecord> maintenanceList = [];
    try {
      if (data['maintenance'] != null && data['maintenance'] is List) {
        maintenanceList = (data['maintenance'] as List)
            .map((m) => MaintenanceRecord.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      }
    } catch (e) {
      maintenanceList = [];
    }

    List<Violation> violationsList = [];
    try {
      if (data['violations'] != null && data['violations'] is List) {
        violationsList = (data['violations'] as List)
            .map((v) => Violation.fromMap(Map<String, dynamic>.from(v)))
            .toList();
      }
    } catch (e) {
      violationsList = [];
    }

    return Car(
      id: id,
      image: data['image']?.toString() ?? '',
      fuelType: data['fuelType']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      desc: data['desc']?.toString() ?? '',
      bodyType: data['bodyType']?.toString() ?? '',
      mileageKill: data['mileageKill']?.toString() ?? '',
      trans: data['trans']?.toString() ?? '',
      brand: data['brand']?.toString() ?? '',
      color: data['color']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      registerDate: reg,
      mechanicImage: data['mechanicImage']?.toString() ?? '',
      licenseImage: data['licenseImage']?.toString() ?? '',
      isForSale: data['isForSale'] == true,
      maintenance: maintenanceList,
      price: data['price']?.toString() ?? '',
      plateNumber: data['plateNumber']?.toString() ?? '',
      violations: violationsList,
    );
  }
}

// نموذج لطلبات المستخدم المتعلقة بالسيارة
class CarRequest {
  final String id;
  final String carId;
  final String userId;
  final String type;
  final String details;
  final List<String> images;
  final String status; // pending | accepted | rejected | finished
  final String response; // تفاصيل الرد من الجهة
  final String? serviceCenterId; // id of the service center (user id)
  final String? scheduledAt; // ISO string for scheduled appointment
  final String? finalDescription; // description when finished
  final double? finalPrice; // price when finished
  final DateTime? createdAt;
  final String? createdAtClient; // client-side iso string fallback

  CarRequest({
    required this.id,
    required this.carId,
    required this.userId,
    required this.type,
    required this.details,
    this.images = const [],
    this.status = 'pending',
    this.response = '',
    this.serviceCenterId,
    this.scheduledAt,
    this.finalDescription,
    this.finalPrice,
    this.createdAt,
    this.createdAtClient,
  });

  factory CarRequest.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? created;
    String? createdClient;

    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'] is Timestamp) {
          created = (data['createdAt'] as Timestamp).toDate();
        } else {
          created = DateTime.tryParse(data['createdAt'].toString());
        }
      } catch (e) {
        created = null;
      }
    }

    if (data['createdAtClient'] != null) {
      createdClient = data['createdAtClient'].toString();
    }

    return CarRequest(
      id: id,
      carId: data['carId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      details: data['details']?.toString() ?? '',
      images: data['images'] != null && data['images'] is List
          ? List<String>.from(data['images'])
          : [],
      status: data['status']?.toString() ?? 'pending',
      response: data['response']?.toString() ?? '',
      serviceCenterId: data['serviceCenterId']?.toString(),
      scheduledAt: data['scheduledAt']?.toString(),
      finalDescription: data['finalDescription']?.toString(),
      finalPrice: data['finalPrice'] != null
          ? double.tryParse(data['finalPrice'].toString())
          : null,
      createdAt: created,
      createdAtClient: createdClient,
    );
  }

  Map<String, dynamic> toMap() => {
    'carId': carId,
    'userId': userId,
    'type': type,
    'details': details,
    'images': images,
    'status': status,
    'response': response,
    'serviceCenterId': serviceCenterId,
    'scheduledAt': scheduledAt,
    'finalDescription': finalDescription,
    'finalPrice': finalPrice,
    'createdAt':
        createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'createdAtClient': createdAtClient ?? DateTime.now().toIso8601String(),
  };

  // ----------------------
  // Purchase Request model
  // ----------------------
}

class PurchaseRequest {
  final String id;
  final String carId;
  final String userId; // buyer
  final String sellerId; // owner of car
  final String details; // buyer textual details
  final List<String> images; // buyer uploaded images (not shown to seller)
  final String
  status; // pending (to seller) | rejected_by_seller | pending_admin | rejected_by_admin | accepted | finished
  final String? sellerDescription; // text added by seller when accepting
  final List<String>?
  sellerFiles; // files added by seller when accepting (visible to admin)
  final String? adminNotes;
  final List<String>? adminImages;
  final DateTime? createdAt;
  final String? createdAtClient;

  PurchaseRequest({
    required this.id,
    required this.carId,
    required this.userId,
    required this.sellerId,
    required this.details,
    this.images = const [],
    this.status = 'pending',
    this.sellerDescription,
    this.sellerFiles,
    this.adminNotes,
    this.adminImages,
    this.createdAt,
    this.createdAtClient,
  });

  factory PurchaseRequest.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? created;
    String? createdClient;

    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'] is Timestamp) {
          created = (data['createdAt'] as Timestamp).toDate();
        } else {
          created = DateTime.tryParse(data['createdAt'].toString());
        }
      } catch (e) {
        created = null;
      }
    }

    if (data['createdAtClient'] != null) {
      createdClient = data['createdAtClient'].toString();
    }

    return PurchaseRequest(
      id: id,
      carId: data['carId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      sellerId: data['sellerId']?.toString() ?? '',
      details: data['details']?.toString() ?? '',
      images: data['images'] != null && data['images'] is List
          ? List<String>.from(data['images'])
          : [],
      status: data['status']?.toString() ?? 'pending',
      sellerDescription: data['sellerDescription']?.toString(),
      sellerFiles: data['sellerFiles'] != null && data['sellerFiles'] is List
          ? List<String>.from(data['sellerFiles'])
          : null,
      adminNotes: data['adminNotes']?.toString(),
      adminImages: data['adminImages'] != null && data['adminImages'] is List
          ? List<String>.from(data['adminImages'])
          : null,
      createdAt: created,
      createdAtClient: createdClient,
    );
  }

  Map<String, dynamic> toMap() => {
    'carId': carId,
    'userId': userId,
    'sellerId': sellerId,
    'details': details,
    'images': images,
    'status': status,
    'sellerDescription': sellerDescription,
    'sellerFiles': sellerFiles,
    'adminNotes': adminNotes,
    'adminImages': adminImages,
    'createdAt':
        createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'createdAtClient': createdAtClient ?? DateTime.now().toIso8601String(),
  };
}

// Generic user request to admin/support
class UserRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String status; // pending | accepted | rejected | responded
  final String? adminResponse;
  final DateTime? createdAt;
  final String? createdAtClient;

  UserRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.adminResponse,
    this.createdAt,
    this.createdAtClient,
  });

  factory UserRequest.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? created;
    String? createdClient;
    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'] is Timestamp) {
          created = (data['createdAt'] as Timestamp).toDate();
        } else {
          created = DateTime.tryParse(data['createdAt'].toString());
        }
      } catch (e) {
        created = null;
      }
    }
    if (data['createdAtClient'] != null) createdClient = data['createdAtClient'].toString();
    final status = data['status']?.toString() ?? 'pending';
    final adminResp = data['adminResponse']?.toString();

    return UserRequest(
      id: id,
      userId: data['userId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      status: status,
      adminResponse: adminResp,
      createdAt: created,
      createdAtClient: createdClient,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'title': title,
    'description': description,
    'status': status,
    if (adminResponse != null) 'adminResponse': adminResponse,
    'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'createdAtClient': createdAtClient ?? DateTime.now().toIso8601String(),
  };
}

// نموذج لدفعة / فاتورة يرفعها المستخدم
class Payment {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String transferRef; // رقم الحوالة أو مرجع الدفع
  final String status; // pending | accepted | rejected
  final DateTime? createdAt;
  final String? createdAtClient;
  final String? adminNotes;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.transferRef,
    this.status = 'pending',
    this.createdAt,
    this.createdAtClient,
    this.adminNotes,
  });

  factory Payment.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime? created;
    String? createdClient;
    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'] is Timestamp) {
          created = (data['createdAt'] as Timestamp).toDate();
        } else {
          created = DateTime.tryParse(data['createdAt'].toString());
        }
      } catch (e) {
        created = null;
      }
    }
    if (data['createdAtClient'] != null) createdClient = data['createdAtClient'].toString();

    double amt = 0.0;
    try {
      if (data['amount'] != null) amt = double.tryParse(data['amount'].toString()) ?? 0.0;
    } catch (e) {
      amt = 0.0;
    }

    return Payment(
      id: id,
      userId: data['userId']?.toString() ?? '',
      amount: amt,
      description: data['description']?.toString() ?? '',
      transferRef: data['transferRef']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      createdAt: created,
      createdAtClient: createdClient,
      adminNotes: data['adminNotes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'amount': amount,
    'description': description,
    'transferRef': transferRef,
    'status': status,
    'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'createdAtClient': createdAtClient ?? DateTime.now().toIso8601String(),
    if (adminNotes != null) 'adminNotes': adminNotes,
  };
}

class Class {
  final String id;
  final String name;
  final String description;
  final double price;

  Class({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Class.fromFirestore(Map<String, dynamic> data, String id) {
    double price;
    try {
      if (data['price'] != null) {
        if (data['price'] is String) {
          price = double.parse(data['price']);
        } else if (data['price'] is int) {
          price = (data['price'] as int).toDouble();
        } else if (data['price'] is double) {
          price = data['price'];
        } else {
          price = 0.0;
        }
      } else {
        price = 0.0;
      }
    } catch (e) {
      print('Error parsing class price: $e');
      price = 0.0;
    }

    return Class(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: price,
    );
  }
}

class TimelineItem {
  final String name;
  final String description;

  TimelineItem({required this.name, required this.description});

  factory TimelineItem.fromMap(Map<String, dynamic> data) {
    return TimelineItem(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

class Subject {
  final String id;
  final String name;
  final String description;
  final String teacher;
  final int index;
  final List<TimelineItem> timeline;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.teacher,
    required this.index,
    required this.timeline,
  });

  factory Subject.fromFirestore(Map<String, dynamic> data, String id) {
    List<TimelineItem> timelineItems = [];
    if (data['timeline'] != null && data['timeline'] is List) {
      timelineItems = (data['timeline'] as List)
          .map((item) => TimelineItem.fromMap(item))
          .toList();
    }

    return Subject(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      teacher: data['teacher'] ?? '',
      index: data['index'] ?? 0,
      timeline: timelineItems,
    );
  }
}

class Quiz {
  final String id;
  final String subjectId;
  final String subjectName;
  final String quizName;
  final int quizSuccessMark;
  final int quizFullMark;
  final String className;
  final List<dynamic> questions;
  final List<dynamic> studentsMarks;

  Quiz({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.quizName,
    required this.quizSuccessMark,
    required this.quizFullMark,
    required this.className,
    required this.questions,
    required this.studentsMarks,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data, String id) {
    return Quiz(
      id: id,
      subjectId: data['subjectId'] ?? '',
      subjectName: data['subjectName'] ?? '',
      quizName: data['quizName'] ?? '',
      quizSuccessMark: data['quizSuccessMark'] ?? 0,
      quizFullMark: data['quizFullMark'] ?? 0,
      className: data['className'] ?? '',
      questions: data['questions'] ?? [],
      studentsMarks: data['studentsMarks'] ?? [],
    );
  }
}
