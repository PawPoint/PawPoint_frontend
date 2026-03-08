import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPetPage extends StatefulWidget {
  final String petType;

  const AddPetPage({super.key, required this.petType});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _characteristicsController = TextEditingController();

  String? _selectedGender;
  bool _isSaving = false;

  // ── Image Picker ──────────────────────────────────────────────────
  Uint8List? _pickedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _showImageSourceSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Upload Pet Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F0F0),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Colors.black87,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage();
                },
              ),
              if (_pickedImageBytes != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_rounded, color: Colors.red),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _pickedImageBytes = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? xfile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      if (xfile != null) {
        final bytes = await xfile.readAsBytes();
        setState(() => _pickedImageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Convert picked image bytes to Base64 string for Firestore storage
  String _encodeImageToBase64() {
    if (_pickedImageBytes == null) return '';
    return base64Encode(_pickedImageBytes!);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthdayController.dispose();
    _characteristicsController.dispose();
    super.dispose();
  }

  // ── Calendar Date Picker Function ──────────────────────────────────
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Earliest year they can pick
      lastDate: DateTime.now(), // Cannot pick a future date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formats date as YYYY-MM-DD perfectly for Firestore
        _birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // ── Backend API base URL ──────────────────────────────────────────
  // Use localhost for web/desktop, 10.0.2.2 for Android emulator
  static const String _baseUrl = 'http://localhost:8000';

  Future<void> _savePet() async {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    final gender = _selectedGender ?? '';
    final ageText = _ageController.text.trim();

    if (name.isEmpty || breed.isEmpty || gender.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Name, Breed, Gender, and Age.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      // Build the pet data payload matching the backend PetModel
      final Map<String, dynamic> petData = {
        'petType': widget.petType,
        'name': name,
        'breed': breed,
        'gender': gender,
        'age': int.tryParse(ageText),
        'height': double.tryParse(_heightController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'birthday': _birthdayController.text.trim(),
        'characteristics': _characteristicsController.text.trim(),
        'imageUrl': _encodeImageToBase64(),
      };

      // Send POST request to the backend API
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/${user.uid}/pets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(petData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name has been added! 🐾'),
              backgroundColor: Colors.black87,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Add ${widget.petType}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ───────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ── Photo Upload Circle ────────────────────────
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width: 2),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _pickedImageBytes != null
                            ? Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : const Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.black54,
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Pet's Name ─────────────────────────────────
                    _FormField(controller: _nameController, hint: "Pet's Name"),
                    const SizedBox(height: 14),

                    // ── Breed ──────────────────────────────────────
                    _FormField(controller: _breedController, hint: 'Breed'),
                    const SizedBox(height: 14),

                    // ── Gender & Age ───────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFDDDDDD),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                hint: Text(
                                  'Gender',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black38,
                                  ),
                                ),
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black38,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                items: ['Male', 'Female']
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _FormField(
                            controller: _ageController,
                            hint: 'Age',
                            keyboardType:
                                TextInputType.number, // Number keyboard
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Height & Weight (With suffixes & number kb) ──
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _heightController,
                            hint: 'Height',
                            keyboardType: TextInputType.number,
                            suffixText: 'cm', // Adds 'cm' to the field
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _FormField(
                            controller: _weightController,
                            hint: 'Weight',
                            keyboardType: TextInputType.number,
                            suffixText: 'kg', // Adds 'kg' to the field
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Birthday (Calendar Picker) ─────────────────
                    _FormField(
                      controller: _birthdayController,
                      hint: 'Birthday (YYYY-MM-DD)',
                      readOnly: true, // Prevents manual typing
                      onTap: () => _selectBirthday(context), // Opens calendar
                    ),
                    const SizedBox(height: 14),

                    // ── Characteristics ────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                      ),
                      child: TextField(
                        controller: _characteristicsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: '+ Characteristics',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ── Save Button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.black.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'SAVE',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
}

// ── Upgraded Reusable Form Field ────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;

  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType, // Activates number keyboard if passed
        readOnly: readOnly, // Locks typing if it's a date picker
        onTap: onTap, // Triggers date picker when tapped
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
          suffixText: suffixText, // Shows 'cm' or 'kg'
          suffixStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
