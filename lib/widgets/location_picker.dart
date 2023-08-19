// location_picker.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPicker extends StatefulWidget {
  final ValueChanged<String>? onLocationPicked;
  final String? initialCoordinates;

  const LocationPicker({Key? key, this.onLocationPicked, this.initialCoordinates}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? _coordinates;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCoordinates != null && widget.initialCoordinates!.isNotEmpty) {
      _coordinates = widget.initialCoordinates;
    }
  }

  Future<void> _pickLocation() async {
    setState(() {
      _isLoading = true;
    });

    PermissionStatus coarseStatus = await Permission.locationWhenInUse.request();

    if (coarseStatus.isGranted) {
      PermissionStatus fineStatus = await Permission.location.request();
      if (fineStatus.isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition();
          String newCoordinates = "${position.latitude},${position.longitude}";

          if (newCoordinates != _coordinates) {
            setState(() {
              _coordinates = newCoordinates;
              _isLoading = false;
            });
            if (widget.onLocationPicked != null) {
              widget.onLocationPicked!(_coordinates!);
            }
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fine location permission not granted")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coarse location permission not granted")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_coordinates != null) {
      final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$_coordinates");
      if (await launchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not open the map.";
      }
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            if (_coordinates != null)
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text("View in Google Maps"),
                onTap: () {
                  _openInGoogleMaps();
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Select Location"),
              onTap: () {
                _pickLocation();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text("Location", style: subHeadingStyle(color: Colors.black)),
        ),
        GestureDetector(
          onTap: _isLoading ? null : (_coordinates == null ? _pickLocation : _showOptions),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isLoading
                      ? "Loading..."
                      : (_coordinates ?? "Select current location"),
                  style: const TextStyle(color: Colors.black54),
                ),
                const Icon(
                  Icons.location_on,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}