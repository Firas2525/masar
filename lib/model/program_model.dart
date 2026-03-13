import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramSubject {
  final String subjectId;
  final int index;
  final String name;
  final String description;
  final List<TimelineItem> timeline;

  ProgramSubject({
    required this.subjectId,
    required this.index,
    required this.name,
    required this.description,
    required this.timeline,
  });

  factory ProgramSubject.fromMap(Map<String, dynamic> data) {
    List<TimelineItem> timelineItems = [];
    if (data['timeline'] != null && data['timeline'] is List) {
      timelineItems = (data['timeline'] as List)
          .map((item) => TimelineItem.fromMap(item))
          .toList();
    }

    return ProgramSubject(
      subjectId: data['subjectId'] ?? '',
      index: data['index'] ?? 0,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      timeline: timelineItems,
    );
  }
}

class TimelineItem {
  final String name;
  final String description;

  TimelineItem({
    required this.name,
    required this.description,
  });

  factory TimelineItem.fromMap(Map<String, dynamic> data) {
    return TimelineItem(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

class WeeklyDay {
  final String dayName;
  final List<String> subjectIds;
  final List<ProgramSubject> subjects;

  WeeklyDay({
    required this.dayName,
    required this.subjectIds,
    this.subjects = const [], // جعل subjects اختياري مع قيمة افتراضية
  });

  factory WeeklyDay.fromMap(Map<String, dynamic> data) {
    List<String> subjectIds = [];
    if (data['subjectIds'] != null && data['subjectIds'] is List) {
      subjectIds = (data['subjectIds'] as List)
          .map((id) => id.toString())
          .toList();
    }

    List<ProgramSubject> subjects = [];
    if (data['subjects'] != null && data['subjects'] is List) {
      subjects = (data['subjects'] as List)
          .map((subject) => ProgramSubject.fromMap(subject))
          .toList();
    }

    return WeeklyDay(
      dayName: data['dayName'] ?? '',
      subjectIds: subjectIds,
      subjects: subjects,
    );
  }
}

class Program {
  final String id;
  final String name;
  final String description;
  final String classId;
  final List<WeeklyDay> weeklySchedule;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.classId,
    required this.weeklySchedule,
  });

  factory Program.fromFirestore(Map<String, dynamic> data, String id) {
    List<WeeklyDay> weeklySchedule = [];
    if (data['weeklySchedule'] != null && data['weeklySchedule'] is List) {
      weeklySchedule = (data['weeklySchedule'] as List)
          .map((day) => WeeklyDay.fromMap(day))
          .toList();
    }

    return Program(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      classId: data['classId'] ?? '',
      weeklySchedule: weeklySchedule,
    );
  }
}

