import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RequesterProfileScreen extends StatefulWidget {
  final int userId;

  const RequesterProfileScreen({super.key, required this.userId});

  @override
  State<RequesterProfileScreen> createState() => _RequesterProfileScreenState();
}

class _RequesterProfileScreenState extends State<RequesterProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getUserProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to load profile";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Requester Profile")),
        body: Center(child: Text(_error ?? "Profile not found")),
      );
    }

    final String? pictureBase64 = _profile!['profile_picture'];
    final Uint8List? imageBytes =
        (pictureBase64 != null && pictureBase64.isNotEmpty)
            ? base64Decode(pictureBase64)
            : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Requester Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                child: imageBytes == null ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
            const SizedBox(height: 20),
            _readonlyField("Name", _profile!['full_name'] ?? ""),
            const SizedBox(height: 12),
            _readonlyField("Phone Number", _profile!['contact_number'] ?? ""),
            const SizedBox(height: 12),
            _readonlyField(
              "Role",
              (_profile!['role'] ?? "").toString().toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
