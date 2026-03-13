import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

import '../../controller/home_controller.dart';
import '../../color.dart';

import 'package:geolocator/geolocator.dart';
import 'service_request_page.dart';
import '../../widgets/custom_snackbar.dart';

class ServiceCentersMapPage extends StatefulWidget {
  final LatLng? initialCenter;
  final String? carId;
  const ServiceCentersMapPage({Key? key, this.initialCenter, this.carId})
    : super(key: key);

  @override
  _ServiceCentersMapPageState createState() => _ServiceCentersMapPageState();
}

class _ServiceCentersMapPageState extends State<ServiceCentersMapPage> {
  LatLng? _userLocation;
  final MapController _mapController = MapController();
  bool _userCentered = false;

  // خريطة CartoDB Voyager
  static const String _tileUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      // If denied, show a rationale then request
      if (permission == LocationPermission.denied) {
        final ask = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('صلاحية الموقع'),
            content: Text('نحتاج إلى صلاحية الموقع لتحديد موقعك على الخريطة. هل تريد منح الصلاحية؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('طلب الإذن')),
            ],
          ),
        );
        if (ask != true) {
          showCustomSnackbar('صلاحية الموقع', 'تم إلغاء طلب الإذن');
          return;
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showCustomSnackbar('صلاحية الموقع', 'يرجى منح صلاحية الموقع لتحديد موقعك');
          return;
        }
      }

      // If permanently denied, offer to open app settings
      if (permission == LocationPermission.deniedForever) {
        final open = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('صلاحية الموقع معطلة'),
            content: Text('تم تعطيل صلاحية الموقع نهائياً. يمكنك فتح إعدادات التطبيق لتفعيلها.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('إلغاء')),
              ElevatedButton(onPressed: () {
                Geolocator.openAppSettings();
                Navigator.pop(context, true);
              }, child: Text('فتح الإعدادات')),
            ],
          ),
        );
        if (open != true) return;
        // After returning from settings, try again once
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          showCustomSnackbar('صلاحية الموقع', 'يرجى تفعيل صلاحية الموقع من إعدادات النظام');
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (mounted) {
        setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
        WidgetsBinding.instance.addPostFrameCallback((_) => _moveToUser(zoom: 15));
      }
    } catch (e) {
      print('Could not get user location: $e');
      showCustomSnackbar('خطأ', 'تعذر الحصول على موقع المستخدم');
    }
  }

  void _moveToUser({double zoom = 13}) {
    if (_userLocation == null) return;
    try {
      _mapController.move(_userLocation!, zoom);
      setState(() { _userCentered = true; });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(_userLocation!, zoom);
          setState(() { _userCentered = true; });
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة مراكز الصيانة'),
        backgroundColor: primaryblue,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: controller.streamServiceCenters(),
        builder: (ctx, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final centers = snap.data!;
          final markers = <Marker>[];
          // Determine highlighted point (if any) from initialCenter
          final LatLng? highlighted = widget.initialCenter;

          for (final c in centers) {
            final prof = c['serviceProfile'] ?? {};
            final lat = (prof['lat'] is num) 
                ? (prof['lat'] as num).toDouble()
                : (double.tryParse('${prof['lat']}') ?? 0.0);
            final lng = (prof['lng'] is num)
                ? (prof['lng'] as num).toDouble()
                : (double.tryParse('${prof['lng']}') ?? 0.0);
            if (lat == 0.0 && lng == 0.0) continue;

            final point = LatLng(lat, lng);
            final uid = c['uid'] ?? c['id'] ?? '';
            bool isHighlighted = false;
            if (highlighted != null) {
              const epsilon = 0.0005; // ~50m tolerance
              if ((point.latitude - highlighted.latitude).abs() < epsilon &&
                  (point.longitude - highlighted.longitude).abs() < epsilon) {
                isHighlighted = true;
              }
            }

            markers.add(
              Marker(
                point: point,
                width: isHighlighted ? 52 : 44,
                height: isHighlighted ? 52 : 44,
                child: GestureDetector(
                  onTap: () {
                    // Use AlertDialog for compatibility and clear actions
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          prof['title'] ?? 'مركز صيانة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((prof['address'] ?? '').toString().isNotEmpty)
                              Text(
                                'العنوان: ${prof['address']}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            if ((prof['phone'] ?? '').toString().isNotEmpty)
                              SizedBox(height: 8),
                            if ((prof['phone'] ?? '').toString().isNotEmpty)
                              Text('هاتف: ${prof['phone']}'),
                            if ((prof['description'] ?? '')
                                .toString()
                                .isNotEmpty)
                              SizedBox(height: 8),
                            if ((prof['description'] ?? '')
                                .toString()
                                .isNotEmpty)
                              Text('${prof['description']}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('إغلاق'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryblue,
                            ),
                            onPressed: () {
                              Get.back();
                              Get.to(
                                () => ServiceRequestPage(
                                  carId: widget.carId ?? '',
                                  serviceCenterId: uid,
                                  profile: prof,
                                ),
                              );
                            },
                            child: Text('حجز صيانة'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.location_on,
                    color: isHighlighted ? primaryPink : Colors.redAccent,
                    size: isHighlighted ? 48 : 40,
                  ),
                ),
              ),
            );
          }

          // Add user location marker if available
          if (_userLocation != null) {
            markers.add(
              Marker(
                point: _userLocation!,
                width: 44,
                height: 44,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          }

          final centerPoint =
              widget.initialCenter ??
              _userLocation ??
              (markers.isNotEmpty
                  ? markers.first.point
                  : LatLng(24.7136, 46.6753));

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: (widget.initialCenter != null
                  ? 15
                  : (_userLocation != null ? 13 : 12)),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                subdomains: const ['a', 'b', 'c'],
                additionalOptions: {
                  'User-Agent': 'kindergarten_user_app/1.0',
                },
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _determinePosition();
          if (_userLocation != null) {
            _moveToUser(zoom: 15);
          } else {
            showCustomSnackbar('خطأ', 'تعذر الحصول على موقع المستخدم');
          }
        },
        label: Text('موقعي'),
        icon: Icon(Icons.my_location),
        backgroundColor: primaryPink,
      ),
    );
  }
}
