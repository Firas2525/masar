import 'package:flutter/material.dart';
import 'package:kindergarten_user/color.dart';

class TimelinePage extends StatelessWidget {
  final Map subject;

  const TimelinePage({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final timeline = subject['timeline'] as List<dynamic>? ?? [];
  final int currentIndex = subject['index'] is int ? subject['index'] : 0;
  print(currentIndex);
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryblue,
        title: Text(subject['name'] ?? 'دروس المادة'),
      ),
      body: timeline.isEmpty
          ? Center(child: Text('لا يوجد دروس لهذه المادة'))
          : ListView.builder(padding: EdgeInsets.only(top: 10),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final item = timeline[index] as Map<String, dynamic>;
                final isDone = index < currentIndex;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDone ? primaryblue : primaryPink,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(left: 12, right: 8, top: 2),
                          decoration: BoxDecoration(
                            color: isDone ? primaryblue : primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: isDone
                              ? Icon(Icons.check, color: Colors.white, size: 24)
                              : Icon(Icons.circle_outlined, color: primaryPurble, size: 22),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? '',
                                style: TextStyle(
                                  color: isDone ? primaryBlack : primaryBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                item['description'] ?? '',
                                style: TextStyle(
                                  color: isDone ? primaryPurble : primaryPink,
                                  fontSize: 15,
                                ),
                              ),
                              if (isDone) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: primaryblue, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'تم إعطاء الدرس',
                                      style: TextStyle(
                                        color: primaryblue,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
