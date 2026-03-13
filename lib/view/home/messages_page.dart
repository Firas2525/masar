import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../color.dart';
import '../../widgets/custom_snackbar.dart';
import 'conversation_chat_page.dart';

class UserMessagesPage extends StatelessWidget {
  final String? carId;
  const UserMessagesPage({Key? key, this.carId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(carId != null ? 'رسائل السيارة' : 'الرسائل'),
        backgroundColor: primaryblue,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: controller.streamUserConversations(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryblue));
          }
          final allConvs = snap.data ?? [];
          final cid = carId; // local copy to allow non-nullable use in closures
          final List<Map<String, dynamic>> convs;
          if (cid == null) {
            convs = allConvs;
          } else {
            final String filterId = cid;
            convs = allConvs.where((c) {
              final v = c['carId'];
              if (v == null) return false;
              if (v is String) {
                if (v.isEmpty) return false;
                if (v == filterId) return true;
                return v.contains(filterId);
              }
              try {
                if (v is Map && v['id'] != null) return v['id'] == filterId;
                final id = (v as dynamic).id;
                if (id != null) return id == filterId;
              } catch (_) {}
              return v.toString().contains(filterId);
            }).toList();
          }
          if (convs.isEmpty) {
            if (carId != null) {
              return Padding(
                padding: EdgeInsets.all(w * 0.04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لا توجد محادثات مرتبطة بهذه السيارة',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryblue,
                      ),
                      onPressed: () => Get.to(() => UserMessagesPage()),
                      child: Text('عرض كل المحادثات'),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Text(
                'لا توجد محادثات بعد',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Build list with optional profile completion banner
          final List<Widget> listChildren = [];
          if (controller.userName.isEmpty) {
            listChildren.add(
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Card(
                  color: primaryPink.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أكمل ملفك',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryPink,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'أدخل اسم مستخدم ليظهر للآخرين بدلاً من البريد',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPink,
                          ),
                          onPressed: () =>
                              _showSetUserNameDialog(context, controller),
                          child: Text(
                            'أضف اسم',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          listChildren.addAll(
            convs.map((c) {
              final participants = List<String>.from(c['participants'] ?? []);
              final otherId = participants.firstWhere(
                (p) => p != controller.userId,
                orElse: () => '',
              );
              final names = Map<String, dynamic>.from(
                c['participantNames'] ?? {},
              );
              final otherName = names[otherId] ?? '';
              final lastMessage = c['lastMessage'] ?? '';

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: 6,
                ),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: otherId.isNotEmpty
                      ? controller.getUserData(otherId)
                      : Future.value(null),
                  builder: (ctx, snapUser) {
                    final user = snapUser.data;
                    final subtitle = lastMessage;
                    final time = _formatTime(c['lastTimestamp']);

                    // compute a readable name (otherName > user.name > email local part)
                    String _computeFallbackName(Map<String, dynamic>? u) {
                      if (u == null) return '';
                      final n = (u['name'] ?? '').toString();
                      if (n.isNotEmpty) return n;
                      final e = (u['email'] ?? '').toString();
                      if (e.isNotEmpty) return e.split('@')[0];
                      return '';
                    }

                    final computedName = (otherName ?? '').toString().isNotEmpty
                        ? (otherName ?? '').toString()
                        : _computeFallbackName(user);

                    String _initialsFrom(String s) {
                      final parts = s
                          .split(' ')
                          .where((p) => p.isNotEmpty)
                          .toList();
                      if (parts.isEmpty) return '?';
                      if (parts.length == 1) {
                        return parts[0]
                            .substring(0, parts[0].length >= 2 ? 2 : 1)
                            .toUpperCase();
                      }
                      return (parts[0][0] + parts[1][0]).toUpperCase();
                    }

                    final avatarLabel = computedName.isNotEmpty
                        ? _initialsFrom(computedName)
                        : (user != null &&
                                  (user['email'] ?? '').toString().isNotEmpty
                              ? ((user['email'] as String)
                                    .split('@')[0]
                                    .substring(
                                      0,
                                      ((user['email'] as String)
                                                  .split('@')[0]
                                                  .length >=
                                              2)
                                          ? 2
                                          : 1,
                                    )
                                    .toUpperCase())
                              : '?');
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: primaryblue.withOpacity(0.12),
                          child:
                              (user != null &&
                                  (user['photo'] ?? user['avatar'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                              ? ClipOval(
                                  child: Image.network(
                                    (user['photo'] ?? user['avatar'] ?? ''),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  avatarLabel,
                                  style: TextStyle(
                                    color: primaryblue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        title: Text(
                          computedName.isNotEmpty
                              ? computedName
                              : (user != null
                                    ? (user['email'] ?? 'مستخدم')
                                    : 'مستخدم'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final convId = c['id'] as String?;
                          if (convId == null) return;
                          Get.to(
                            () => ConversationChatPage(
                              conversationId: convId,
                              otherUserId: otherId,
                              otherUserName: computedName,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );

          return ListView(children: listChildren);
        },
      ),
    );
  }

  String _formatTime(dynamic ts) {
    try {
      if (ts == null) return '';
      DateTime t;
      if (ts is Map && ts['_seconds'] != null) {
        t = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000);
      } else if (ts is DateTime) {
        t = ts;
      } else {
        return '';
      }
      return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  void _showSetUserNameDialog(BuildContext context, HomeController controller) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('أضف اسم مستخدم'),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: 'الاسم الظاهر'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                showCustomSnackbar('خطأ', 'الاسم لا يمكن أن يكون فارغاً');
                return;
              }
              await controller.setUserName(name);
              Navigator.of(context).pop();
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
