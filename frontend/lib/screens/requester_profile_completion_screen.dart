import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RequesterProfileCompletionScreen extends StatefulWidget {
  final int userId;
  const RequesterProfileCompletionScreen({super.key, required this.userId});

  @override
  State<RequesterProfileCompletionScreen> createState() =>
      _RequesterProfileCompletionScreenState();
}

class _RequesterProfileCompletionScreenState
    extends State<RequesterProfileCompletionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _profilePicture;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      if (!ApiService.isAllowedProfileImage(picked)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Only PNG and JPG/JPEG files are allowed"),
          ),
        );
        return;
      }
      setState(() {
        _profilePicture = picked;
      });
    }
  }

  Future<void> _uploadAndContinue() async {
    if (_profilePicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await ApiService.completeRequesterProfile(widget.userId, _profilePicture);
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/requesterDashboard',
          arguments: {'userId': widget.userId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Almost there!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Upload a profile picture to complete your account (required)",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: isLoading ? null : _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _profilePicture == null
                            ? "Tap to upload profile picture"
                            : _profilePicture!.name,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _uploadAndContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload & Continue',
                        style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
