import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../color.dart';
import '../../constants.dart';
import '../../model/home_model.dart';
import '../../widgets/custom_snackbar.dart';

class RequestCard extends StatelessWidget {
  final CarRequest request;
  final bool isAdmin;
  final bool isSubmitting;
  final Future<void> Function()? onAddImage;
  final Future<void> Function()? onViewUser;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onReject;
  final Future<void> Function()? onSavePending;
  final Future<void> Function()? onDelete;
  final Widget? adminEditor; // optional editor widget injected by admin pages
  final Future<Map<String, dynamic>?> Function(String uid)?
  fetchUser; // optional helper to fetch user/service center data

  const RequestCard({
    Key? key,
    required this.request,
    this.isAdmin = false,
    this.isSubmitting = false,
    this.onAddImage,
    this.onViewUser,
    this.onAccept,
    this.onReject,
    this.onSavePending,
    this.onDelete,
    this.adminEditor,
    this.fetchUser,
  }) : super(key: key);

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'مقبول':
        color = Colors.green;
        label = 'مقبول';
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        label = 'مرفوض';
        break;
      case 'finished':
      case 'منتهي':
        color = Colors.blueGrey;
        label = 'منتهي';
        break;
      default:
        color = Colors.orange;
        label = 'قيد الانتظار';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          maintainState: true,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: request.serviceCenterId != null
                  ? primaryblue.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                request.type.isNotEmpty ? request.type[0] : 'R',
                style: TextStyle(
                  color: request.serviceCenterId != null
                      ? primaryblue
                      : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.type,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  _statusChip(request.status),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (ctx) {
                        if (request.scheduledAt == null ||
                            request.scheduledAt!.isEmpty)
                          return Text('', style: TextStyle(fontSize: 12));
                        DateTime? dt = DateTime.tryParse(request.scheduledAt!);
                        if (dt != null) {
                          final local = dt.toLocal();
                          final txt =
                              '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
                          return Text(
                            txt,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        }
                        return Text('', style: TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                request.details.length > 70
                    ? '${request.details.substring(0, 70)}...'
                    : request.details,
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.images.isNotEmpty)
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: request.images.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                boundaryMargin: EdgeInsets.all(20),
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: CachedNetworkImage(
                                  imageUrl: request.images[i],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          child: Container(
                            width: 150,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: request.images[i],
                                width: 150,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 8),
                  Text(
                    'تفاصيل الطلب',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(request.details, style: textStyleBody),

                  SizedBox(height: 12),

                  if (request.response.isNotEmpty) ...[
                    Text(
                      'رد الجهة',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          left: BorderSide(color: primaryblue, width: 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(request.response),
                    ),
                  ],

                  if (request.finalDescription != null &&
                      request.finalDescription!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'وصف الانتهاء',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6),
                    Text(request.finalDescription!),
                  ],

                  if (request.serviceCenterId != null &&
                      request.serviceCenterId!.isNotEmpty &&
                      fetchUser != null) ...[
                    SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: fetchUser!(request.serviceCenterId!),
                      builder: (ctx, snapUser) {
                        if (snapUser.connectionState == ConnectionState.waiting)
                          return SizedBox.shrink();
                        final user = snapUser.data;
                        if (user == null) return SizedBox.shrink();
                        final profile = user['serviceProfile'] ?? {};
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مركز الصيانة:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text(profile['title'] ?? user['name'] ?? ''),
                            if ((profile['address'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Text('العنوان: ${profile['address'] ?? ''}'),
                            if ((user['phone'] ?? '').toString().isNotEmpty)
                              Text('الهاتف: ${user['phone'] ?? ''}'),
                          ],
                        );
                      },
                    ),
                  ],
                  if (request.finalPrice != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'السعر النهائي: ${request.finalPrice} ر.س',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: primaryPink,
                      ),
                    ),
                  ],

                  SizedBox(height: 10),
                  // admin editor (optional)
                  if (adminEditor != null) ...[
                    adminEditor!,
                    SizedBox(height: 12),
                  ],
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      // Build actions rows
                      final rows = <Widget>[];

                      if (isAdmin) {
                        // Row 1: قبول و رفض (Accept & Reject)
                        final row1 = <Widget>[];

                        row1.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: onAccept,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(64, 44),
                                  ),
                                  child: isSubmitting
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'قبول',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );

                        row1.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: onReject,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(64, 44),
                                  ),
                                  child: Text(
                                    'رفض',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        rows.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: row1,
                          ),
                        );

                        // Row 2: حفظ و حذف (Save & Delete)
                        final row2 = <Widget>[];

                        row2.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: onSavePending,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(64, 44),
                                  ),
                                  child: Text(
                                    'حفظ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        row2.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _showDeleteConfirmation(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(64, 44),
                                  ),
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        rows.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: row2,
                          ),
                        );
                      }

                      // Row 3: عرض و إضافة (View & Add)
                      final row3 = <Widget>[];

                      if (onViewUser != null) {
                        row3.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: onViewUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: Size(64, 44),
                                  ),
                                  child: Text(
                                    'عرض',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (onAddImage != null) {
                        row3.add(
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8,bottom: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: onAddImage,
                                  icon: Icon(
                                    Icons.photo_camera,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'صورة',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (row3.isNotEmpty) {
                        rows.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: row3,
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isAdmin)
                            Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(
                                _formatCreated(request),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ...rows,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF071B2C), primaryblue.withOpacity(0.95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'حذف الطلب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'هل تريد حذف هذا الطلب؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذا الإجراء لا يمكن التراجع عنه',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD32F2F), Color(0xFFFF6F00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await onDelete?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'حذف نهائياً',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCreated(CarRequest r) {
    String createdText = '';
    if (r.createdAt != null) {
      final local = r.createdAt!.toLocal();
      final dd = local.day.toString().padLeft(2, '0');
      final mm = local.month.toString().padLeft(2, '0');
      final yyyy = local.year.toString().padLeft(4, '0');
      final hh = local.hour.toString().padLeft(2, '0');
      final min = local.minute.toString().padLeft(2, '0');
      createdText = '$dd/$mm/$yyyy $hh:$min';
    } else if (r.createdAtClient != null && r.createdAtClient!.isNotEmpty) {
      final c = DateTime.tryParse(r.createdAtClient!);
      if (c != null) {
        final local = c.toLocal();
        final dd = local.day.toString().padLeft(2, '0');
        final mm = local.month.toString().padLeft(2, '0');
        final yyyy = local.year.toString().padLeft(4, '0');
        final hh = local.hour.toString().padLeft(2, '0');
        final min = local.minute.toString().padLeft(2, '0');
        createdText = '$dd/$mm/$yyyy $hh:$min';
      }
    }
    return createdText;
  }
}
