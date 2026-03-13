import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/home_model.dart';
import '../../color.dart';

class ChildLocationStatusPage extends StatefulWidget {
  final Child child;
  const ChildLocationStatusPage({required this.child});

  @override
  State<ChildLocationStatusPage> createState() => _ChildLocationStatusPageState();
}

class _ChildLocationStatusPageState extends State<ChildLocationStatusPage> {
  bool _isLoading = false;
  String? _location;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() { _isLoading = true; });
    final doc = await FirebaseFirestore.instance.collection('children').doc(widget.child.id).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() { _location = data?['location']?.toString() ?? ''; });
    } else {
      setState(() { _location = ''; });
    }
    setState(() { _isLoading = false; });
  }

  Future<void> _updateLocation(String newLocation) async {
    setState(() { _isLoading = true; });
    final docRef = FirebaseFirestore.instance.collection('children').doc(widget.child.id);
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.update({'location': newLocation});
    } else {
      await docRef.set({'location': newLocation}, SetOptions(merge: true));
    }
    setState(() { _location = newLocation; _isLoading = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تغيير موقع الطفل إلى $newLocation')));
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('موقع الطفل'),
        backgroundColor: primaryblue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: h * 0.04),
            Text('الموقع الحالي:', style: TextStyle(fontSize: w * 0.05, fontWeight: FontWeight.bold)),
            SizedBox(height: h * 0.02),
            _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryblue))
                : Text(_location?.isNotEmpty == true ? _location! : 'غير محدد', style: TextStyle(fontSize: w * 0.045, color: primaryblue, fontWeight: FontWeight.bold)),
            SizedBox(height: h * 0.04),
            Divider(),
            SizedBox(height: h * 0.04),
            Text('تغيير موقع الطفل:', style: TextStyle(fontSize: w * 0.045, fontWeight: FontWeight.w600)),
            SizedBox(height: h * 0.03),
            _isLoading
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _locationButton('في الباص', w),
                      _locationButton('في البيت', w),
                      _locationButton('في الروضة', w),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _locationButton(String label, double w) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryblue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.018),
      ),
      onPressed: () => _updateLocation(label),
      child: Text(label, style: TextStyle(fontSize: w * 0.04, color: Colors.white)),
    );
  }
}
