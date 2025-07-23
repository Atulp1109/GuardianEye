import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _locationFormKey = GlobalKey<FormState>();
  final _cameraFormKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _cameraIpController = TextEditingController();
  final TextEditingController _cameraNameController = TextEditingController();

  List<Map<String, String>> locations = [];
  List<Map<String, String>> cameras = [];

  @override
  void dispose() {
    _locationController.dispose();
    _cameraIpController.dispose();
    _cameraNameController.dispose();
    super.dispose();
  }

  void _addLocation() {
    if (_locationFormKey.currentState!.validate()) {
      setState(() {
        locations.add({
          'name': _locationController.text,
        });
        _locationController.clear();
      });
      Get.snackbar(
        'Success',
        'Location added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _addCamera() {
    if (_cameraFormKey.currentState!.validate()) {
      setState(() {
        cameras.add({
          'name': _cameraNameController.text,
          'ip': _cameraIpController.text,
        });
        _cameraNameController.clear();
        _cameraIpController.clear();
      });
      Get.snackbar(
        'Success',
        'Camera added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void _removeLocation(int index) {
    setState(() {
      locations.removeAt(index);
    });
    Get.snackbar(
      'Removed',
      'Location deleted',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _removeCamera(int index) {
    setState(() {
      cameras.removeAt(index);
    });
    Get.snackbar(
      'Removed',
      'Camera deleted',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveSettings() async {
    try {
      await FirebaseFirestore.instance.collection('admin_settings').add({
        'locations': locations,
        'cameras': cameras,
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Settings Saved',
        'All configurations have been updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purple.shade800,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade800.withOpacity(0.8),
              Colors.purple.shade600,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Locations Section
                _buildSectionHeader('Manage Locations'),
                Form(
                  key: _locationFormKey,
                  child: _buildAddItemCard(
                    context,
                    controller: _locationController,
                    hintText: 'Enter location name',
                    labelText: 'Location Name',
                    onAdd: _addLocation,
                    icon: Icons.location_on,
                  ),
                ),
                const SizedBox(height: 10),
                _buildItemsList(
                  context,
                  items: locations,
                  itemBuilder: (index) => Text(locations[index]['name'] ?? ''),
                  onRemove: _removeLocation,
                  emptyMessage: 'No locations added yet',
                ),

                const SizedBox(height: 30),

                // Cameras Section
                _buildSectionHeader('Manage Cameras'),
                Form(
                  key: _cameraFormKey,
                  child: _buildAddCameraCard(context),
                ),
                const SizedBox(height: 10),
                _buildItemsList(
                  context,
                  items: cameras,
                  itemBuilder: (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cameras[index]['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(cameras[index]['ip'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  onRemove: _removeCamera,
                  emptyMessage: 'No cameras added yet',
                ),

                const SizedBox(height: 30),

                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save all settings to backend
                      _saveSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SAVE ALL SETTINGS',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAddItemCard(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required VoidCallback onAdd,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                prefixIcon: Icon(icon, color: Colors.purple.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('ADD', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCameraCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _cameraNameController,
              decoration: InputDecoration(
                labelText: 'Camera Name',
                hintText: 'e.g., Main Entrance Camera',
                prefixIcon: Icon(Icons.videocam, color: Colors.purple.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter camera name';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _cameraIpController,
              decoration: InputDecoration(
                labelText: 'Camera IP Address',
                hintText: 'e.g., 192.168.1.100:8080',
                prefixIcon:
                    Icon(Icons.network_check, color: Colors.purple.shade700),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter IP address with port';
                }

                final ipWithPortRegex = RegExp(
                  r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}' // IP pattern
                  r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' // Last octet
                  r':([0-9]{1,5})$', // Port (1–5 digits)
                );

                if (!ipWithPortRegex.hasMatch(value)) {
                  return 'Enter a valid IP address and port (e.g., 192.168.1.100:8080)';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('ADD CAMERA',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context, {
    required List<Map<String, String>> items,
    required Widget Function(int index) itemBuilder,
    required Function(int index) onRemove,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(
                  items == locations ? Icons.location_on : Icons.videocam,
                  color: Colors.purple.shade700,
                ),
              ),
              title: itemBuilder(index),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade400),
                onPressed: () => onRemove(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
