import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class WorkerProfileCompletionScreen extends StatefulWidget {
  final int userId;
  const WorkerProfileCompletionScreen({super.key, required this.userId});

  @override
  State<WorkerProfileCompletionScreen> createState() =>
      _WorkerProfileCompletionScreenState();
}

class _WorkerProfileCompletionScreenState
    extends State<WorkerProfileCompletionScreen> {
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _selectedProfession;
  XFile? _profilePicture;
  bool isLoading = false;

  final List<String> professions = [
    'Electrician',
    'Plumber',
    'Cleaner',
    'Painter',
    'Gardener',
    'Carpenter',
    'Mechanic',
    'Technician',
  ];

  @override
  void dispose() {
    _skillsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    // Validate inputs
    if (_selectedProfession == null || _selectedProfession!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a profession")),
      );
      return;
    }

    if (_skillsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your skills")),
      );
      return;
    }

    if (_experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter years of experience")),
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

    if (_profilePicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a profile picture")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.completeWorkerProfile(
        widget.userId,
        _selectedProfession!,
        _skillsController.text.trim(),
        experience,
        _profilePicture,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profile created successfully!"),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to worker dashboard after a short delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/workerDashboard',
            arguments: {'userId': widget.userId},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Worker Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Tell us about yourself",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Complete your worker profile to start getting jobs",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Profile Picture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: isLoading ? null : _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _profilePicture == null
                                ? "Tap to upload profile picture"
                                : _profilePicture!.name,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Profession Dropdown
                const Text(
                  "Profession",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProfession,
                  items: professions
                      .map((profession) => DropdownMenuItem(
                            value: profession,
                            child: Text(profession),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfession = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select your profession',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  hint: const Text('Choose profession'),
                ),
                const SizedBox(height: 20),

                // Skills (comma-separated)
                const Text(
                  "Skills",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _skillsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Enter your skills (comma-separated)',
                    hintText: 'e.g., Leak fixing, Pipe installation, Water testing',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Years of Experience
                const Text(
                  "Years of Experience",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Years of experience',
                    hintText: 'e.g., 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Complete Profile',
                          style: TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
