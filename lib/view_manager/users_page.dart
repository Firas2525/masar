import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kindergarten_user/color.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _searchQuery = '';
  String? _filterType;

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المستخدمون',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: w * 0.055,
          ),
        ),
        backgroundColor: primaryblue,
        elevation: 4,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // البحث والفلترة
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مستخدم...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
                SizedBox(height: 12),
                // الفلترة
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text('الكل'),
                      selected: _filterType == null,
                      onSelected: (val) => setState(() => _filterType = null),
                    ),
                    FilterChip(
                      label: Text('مراكز الصيانة'),
                      selected: _filterType == 'service',
                      onSelected: (val) => setState(() => _filterType = val ? 'service' : null),
                    ),
                    FilterChip(
                      label: Text('مستخدمون عاديون'),
                      selected: _filterType == 'regular',
                      onSelected: (val) => setState(() => _filterType = val ? 'regular' : null),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // قائمة المستخدمين
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF38B6FF)),
                  );
                }
                final allUsers = snapshot.data!.docs;
                
                // تطبيق البحث والفلترة
                final filteredUsers = allUsers.where((doc) {
                  final user = doc.data() as Map<String, dynamic>;
                  final name = (user['name'] ?? '').toString().toLowerCase();
                  final email = (user['email'] ?? '').toString().toLowerCase();
                  final phone = (user['phone'] ?? '').toString().toLowerCase();
                  final isServiceOwner = user['isServiceOwner'] ?? false;
                  
                  // البحث
                  final matchesSearch = _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);
                  
                  // الفلترة
                  late bool matchesFilter;
                  if (_filterType == null) {
                    matchesFilter = true;
                  } else if (_filterType == 'service') {
                    matchesFilter = isServiceOwner == true;
                  } else if (_filterType == 'regular') {
                    matchesFilter = isServiceOwner != true;
                  } else {
                    matchesFilter = true;
                  }
                  
                  return matchesSearch && matchesFilter;
                }).toList();
                
                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'لا يوجد مستخدمون',
                      style: TextStyle(color: Colors.grey, fontSize: w * 0.045),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(w * 0.04),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final doc = filteredUsers[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final children = user['children'] as List<dynamic>?;
                    final userId = doc.id;
              return Card(
                margin: EdgeInsets.only(bottom: h * 0.02),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primaryblue.withOpacity(0.12),
                        child: Text(
                          (user['name'] ?? 'U').toString().isNotEmpty
                              ? (user['name'] ?? 'U')[0]
                              : 'U',
                          style: TextStyle(
                            color: primaryblue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'بدون اسم',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.045,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'البريد الإلكتروني: ${user['email'] ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: w * 0.038,
                              ),
                            ),
                            SizedBox(height: 6),
                            if ((user['isServiceOwner'] ?? false) == true)
                              Chip(
                                label: Text(
                                  'مركز صيانة',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.deepOrangeAccent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 0,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Actions
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        'تأكيد الحذف',
                                        style: TextStyle(color: primaryPink),
                                      ),
                                      content: Text(
                                        'هل تريد حذف هذا المستخدم؟',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryPink,
                                          ),
                                          child: Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('تم حذف المستخدم'),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.delete, color: primaryPink),
                              ),

                              // Chat removed: no chat action on user cards per design
                              SizedBox(width: 4),

                              IconButton(
                                onPressed: () async {
                                  // Open a dedicated page to edit service owner info
                                  final res = await Get.to(
                                    () => ServiceOwnerEditPage(userId: userId),
                                  );
                                  if (res == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم تحويل المستخدم لمركز صيانة',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.build,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
              }
            ),
          ),
        ],
      ),
    );
  }
}

class MapPickerPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const MapPickerPage({Key? key, this.initialLat, this.initialLng})
    : super(key: key);

  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng center;
  LatLng? picked;

  @override
  void initState() {
    super.initState();
    center = LatLng(widget.initialLat ?? 24.7136, widget.initialLng ?? 46.6753);
    if (widget.initialLat != null && widget.initialLng != null) {
      picked = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختر الموقع على الخريطة'),
        backgroundColor: primaryblue,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('إلغاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (tapPos, latlng) {
                setState(() {
                  picked = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                additionalOptions: {
                  'User-Agent': 'kindergarten_user_app/1.0',
                },
              ),
              if (picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: picked!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '© OpenStreetMap contributors · CartoDB',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: picked == null
                  ? null
                  : () {
                      Navigator.of(context).pop(picked);
                    },
              label: Text('اختر الموقع'),
              icon: Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate page to edit/confirm service owner data (replaces the old inline dialog)
class ServiceOwnerEditPage extends StatefulWidget {
  final String userId;
  const ServiceOwnerEditPage({Key? key, required this.userId})
    : super(key: key);

  @override
  _ServiceOwnerEditPageState createState() => _ServiceOwnerEditPageState();
}

class _ServiceOwnerEditPageState extends State<ServiceOwnerEditPage> {
  final _title = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  LatLng? _picked;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists) {
      final data = doc.data() ?? {};
      final profileRaw = data['serviceProfile'];
      final profile = (profileRaw is Map)
          ? Map<String, dynamic>.from(profileRaw)
          : null;
      if (profile != null) {
        _title.text = profile['title'] ?? '';
        _address.text = profile['address'] ?? '';
        _description.text = profile['description'] ?? '';
        final lat = profile['lat'];
        final lng = profile['lng'];
        if (lat != null && lng != null)
          _picked = LatLng((lat as num).toDouble(), (lng as num).toDouble());
      }
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تحويل لمركز صيانة'),
        backgroundColor: primaryblue,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات المركز',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryblue,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _title,
                            decoration: InputDecoration(labelText: 'اسم المحل'),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _address,
                            decoration: InputDecoration(
                              labelText: 'العنوان النصي',
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _description,
                            maxLines: 3,
                            decoration: InputDecoration(labelText: 'وصف المحل'),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final picked = await Navigator.of(context)
                                      .push<LatLng?>(
                                        MaterialPageRoute(
                                          builder: (_) => MapPickerPage(
                                            initialLat: _picked?.latitude,
                                            initialLng: _picked?.longitude,
                                          ),
                                        ),
                                      );
                                  if (picked != null)
                                    setState(() => _picked = picked);
                                },
                                icon: Icon(Icons.map),
                                label: Text('اختيار من الخريطة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryblue,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _picked == null
                                      ? 'لم يتم اختيار موقع'
                                      : 'الموقع: ${_picked!.latitude.toStringAsFixed(6)}, ${_picked!.longitude.toStringAsFixed(6)}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryblue,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      try {
                        final profile = {
                          'title': _title.text.trim(),
                          'address': _address.text.trim(),
                          'description': _description.text.trim(),
                        };
                        if (_picked != null) {
                          profile['lat'] = _picked!.latitude.toString();
                          profile['lng'] = _picked!.longitude.toString();
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .set({
                              'isServiceOwner': true,
                              'serviceProfile': profile,
                            }, SetOptions(merge: true));
                        Navigator.of(context).pop(true);
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text('فشل الحفظ'),
                            content: Text('$e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: Text('إغلاق'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      'تأكيد',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
