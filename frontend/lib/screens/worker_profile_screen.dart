import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  final int userId;

  const WorkerProfileScreen({super.key, required this.userId});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final List<String> _professions = const [
    'Electrician',
    'Plumber',
    'Cleaner',
    'Painter',
    'Gardener',
    'Carpenter',
    'Mechanic',
    'Technician',
  ];

  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _selectedProfession;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _skillsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getUserProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _selectedProfession = _professions.contains(profile['profession'])
            ? profile['profession']
            : null;
        _skillsController.text = (profile['skills'] ?? '').toString();
        _experienceController.text =
            (profile['experience_years'] ?? '').toString();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to load profile";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWorkerDetails() async {
    if (_selectedProfession == null || _selectedProfession!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your profession")),
      );
      return;
    }

    final skills = _skillsController.text.trim();
    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your skills")),
      );
      return;
    }

    final experience = int.tryParse(_experienceController.text.trim());
    if (experience == null || experience < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Experience years must be a valid number")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService.updateWorkerDetails(
        widget.userId,
        _selectedProfession!,
        skills,
        experience,
      );
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Worker details updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Worker Profile")),
        body: Center(child: Text(_error ?? "Profile not found")),
      );
    }

    final String? pictureBase64 = _profile!['profile_picture'];
    final Uint8List? imageBytes =
        (pictureBase64 != null && pictureBase64.isNotEmpty)
            ? base64Decode(pictureBase64)
            : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Worker Profile"), centerTitle: true),
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
            const SizedBox(height: 18),
            const Text(
              "Worker Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedProfession,
              items: _professions
                  .map((profession) => DropdownMenuItem(
                        value: profession,
                        child: Text(profession),
                      ))
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedProfession = value;
                      });
                    },
              decoration: const InputDecoration(
                labelText: "Profession",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skillsController,
              enabled: !_isSaving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Skills",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _experienceController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Years of Experience",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveWorkerDetails,
              child: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save Worker Details"),
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
