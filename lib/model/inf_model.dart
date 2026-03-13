import 'package:cloud_firestore/cloud_firestore.dart';

class InfModel {
  final String id;
  final String date;
  final String desc;
  final String forr;
  final String title;
  final int total_num;
  final List users;
  final DateTime? createdAt;

  InfModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.forr,
    required this.users,
    required this.date,
    required this.total_num,
    this.createdAt,
  });

  factory InfModel.fromFirestore(Map<String, dynamic> data, String id) {
    return InfModel(
      id: id,
      title: data['title'] ?? '',
      desc: data['desc'] ?? '',
      forr: data['forr'] ?? '',
      users: data['users'] ?? [],
      date: data['date'] ?? '',
      total_num: data['total_num'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'desc': desc,
      'forr': forr,
      'users': users,
      'date': date,
      'total_num': total_num,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

