import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String date;
  final String desc;
  final String forr;
  final String name;
  final int total;
  final List users;
  final DateTime? createdAt;

  ActivityModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.forr,
    required this.users,
    required this.date,
    required this.total,
    this.createdAt,
  });

  factory ActivityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ActivityModel(
      id: id,
      name: data['name'] ?? '',
      desc: data['desc'] ?? '',
      forr: data['forr'] ?? '',
      users: data['users'] ?? [],
      date: data['date'] ?? '',
      total: data['total'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'desc': desc,
      'forr': forr,
      'users': users,
      'date': date,
      'total': total,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

