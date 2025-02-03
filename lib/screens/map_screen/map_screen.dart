import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grid_practice/constants/app_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  var initialCameraPosition = const CameraPosition(
    target: LatLng(11.572543, 104.893275),
    zoom: 20,
  );

  var address = '';
  Timer? _timer;
  int _start = 2;
  Marker? selectedLocationMarker;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 20,
      );

      setState(() {
        initialCameraPosition = newPosition;
        selectedLocation = LatLng(position.latitude, position.longitude);
        updateSelectedLocationMarker();
      });

      _mapController.animateCamera(CameraUpdate.newCameraPosition(newPosition));

      getLocationAddress(LatLng(position.latitude, position.longitude));
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void updateSelectedLocationMarker() {
    if (selectedLocation != null) {
      setState(() {
        selectedLocationMarker = Marker(
          markerId: const MarkerId('selected_location'),
          position: selectedLocation!,
          infoWindow: InfoWindow(title: 'Selected Location', snippet: address),
        );
      });
    }
  }

  void delayTwoSecondToGetAddress(LatLng location) {
    _timer?.cancel();
    _start = 2;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          timer.cancel();
          getLocationAddress(location);
        } else {
          _start--;
        }
      },
    );
  }

  void getLocationAddress(LatLng location) {
    placemarkFromCoordinates(location.latitude, location.longitude)
        .then((value) {
      if (value.isNotEmpty) {
        final place = value.first;
        setState(() {
          address =
              '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.subAdministrativeArea ?? ''} ${place.administrativeArea ?? ''} ${place.postalCode ?? ''} ${place.country ?? ''}'
                  .trim()
                  .replaceAll(RegExp(r'\n+'), '\n');
          updateSelectedLocationMarker(); // Update marker with new address
        });
      } else {
        setState(() {
          address = 'No address available';
        });
      }
    }).catchError((error) {
      setState(() {
        address = 'Error retrieving address: $error';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Location"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: initialCameraPosition,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: selectedLocationMarker != null
                    ? {selectedLocationMarker!}
                    : {},
                onCameraMove: (position) {
                  setState(() {
                    address = 'Loading ...';
                    selectedLocation = position.target;
                    updateSelectedLocationMarker();
                  });
                  delayTwoSecondToGetAddress(position.target);
                },
                onCameraIdle: () {
                  if (selectedLocation != null) {
                    updateSelectedLocationMarker();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    AppImage.location,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        address,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Bounceable(
              onTap: () {
                if (address == "Loading ...") {
                  Flushbar(
                    message: "Please wait for the address to load",
                    backgroundColor: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                    messageText: const Text(
                      "Please wait for the address to load",
                      style: TextStyle(color: Colors.white),
                    ),
                  ).show(context);
                } else {
                  Navigator.of(context).pop({
                    'address': address,
                    'latitude': selectedLocation?.latitude,
                    'longitude': selectedLocation?.longitude,
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 20),
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Center(
                    child: Text(
                      "Select this Location",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
