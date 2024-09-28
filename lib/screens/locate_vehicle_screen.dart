import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocateVehicleScreen extends StatefulWidget {
  const LocateVehicleScreen({Key? key}) : super(key: key);

  @override
  _LocateVehicleScreenState createState() => _LocateVehicleScreenState();
}

class _LocateVehicleScreenState extends State<LocateVehicleScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _vehiclePosition;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadVehiclePosition();
  }

  Future<void> _getCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _updateMarkers();
        });
        _mapController.move(_currentPosition!, 15);
      } catch (e) {
        print("Error getting location: $e");
      }
    } else {
      print("Location permission denied");
    }
  }

  Future<void> _loadVehiclePosition() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() is Map) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('vehiclePosition')) {
          GeoPoint geoPoint = data['vehiclePosition'];
          setState(() {
            _vehiclePosition = LatLng(geoPoint.latitude, geoPoint.longitude);
            _updateMarkers();
          });
        }
      }
    }
  }

  void _updateMarkers() {
    _markers = [];
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentPosition!,
          child: Icon(Icons.location_on, color: Colors.red),
        ),
      );
    }
    if (_vehiclePosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _vehiclePosition!,
          child: Icon(Icons.directions_car, color: Colors.blue),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locate Vehicle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _mapController.move(_vehiclePosition ?? _currentPosition!, 15),
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }
}
