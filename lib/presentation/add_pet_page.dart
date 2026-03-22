import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawpoint_mobileapp/models/pet_model.dart';

class AddPetPage extends StatefulWidget {
  final String petType;

  /// If provided, the page opens in **edit mode** with fields pre-filled.
  final PetModel? editPet;

  const AddPetPage({super.key, required this.petType, this.editPet});

  bool get isEditMode => editPet != null;

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

  /// Existing image from Firestore (base64 string)
  String? _existingImageBase64;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if in edit mode
    if (widget.isEditMode) {
      final pet = widget.editPet!;
      _nameController.text = pet.name;
      _breedController.text = pet.breed;
      _heightController.text = pet.height;
      _weightController.text = pet.weight;
      _birthdayController.text = pet.birthday;
      _characteristicsController.text = pet.characteristics;
      _selectedGender = pet.gender.isNotEmpty ? pet.gender : null;
      _existingImageBase64 = pet.imageUrl;
      // Auto-calculate age from existing birthday
      _updateAgeFromBirthday();
    }
  }

  /// Calculates age in months from the birthday text field and updates the age controller
  void _updateAgeFromBirthday() {
    final text = _birthdayController.text.trim();
    if (text.isEmpty) {
      _ageController.text = '';
      return;
    }
    try {
      final parts = text.split('-');
      final birthDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      int months =
          (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
      if (now.day < birthDate.day) months--;
      if (months < 0) months = 0;
      _ageController.text = months.toString();
    } catch (_) {
      _ageController.text = '';
    }
  }

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
              if (_pickedImageBytes != null ||
                  (_existingImageBase64 != null &&
                      _existingImageBase64!.isNotEmpty))
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
                    setState(() {
                      _pickedImageBytes = null;
                      _existingImageBase64 = null;
                    });
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
        setState(() {
          _pickedImageBytes = bytes;
          _existingImageBase64 = null; // New image replaces old
        });
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
  String _getImageBase64() {
    if (_pickedImageBytes != null) {
      return base64Encode(_pickedImageBytes!);
    }
    return _existingImageBase64 ?? '';
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
    DateTime initialDate = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      try {
        final parts = _birthdayController.text.split('-');
        initialDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
        _birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _updateAgeFromBirthday();
      });
    }
  }

  // ── Backend API base URL ──────────────────────────────────────────
  static const String _baseUrl = 'http://localhost:8000';

  Future<void> _savePet() async {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    final gender = _selectedGender ?? '';
    final ageText = _ageController.text.trim();
    final birthday = _birthdayController.text.trim();

    if (name.isEmpty || breed.isEmpty || gender.isEmpty || birthday.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Name, Breed, Gender, and Birthday.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      if (widget.isEditMode) {
        // ── UPDATE existing pet directly in Firestore ──────────────
        final petData = {
          'petType': widget.petType,
          'name': name,
          'breed': breed,
          'gender': gender,
          'age': int.tryParse(ageText) ?? ageText,
          'height':
              double.tryParse(_heightController.text.trim()) ??
              _heightController.text.trim(),
          'weight':
              double.tryParse(_weightController.text.trim()) ??
              _weightController.text.trim(),
          'birthday': _birthdayController.text.trim(),
          'characteristics': _characteristicsController.text.trim(),
          'imageUrl': _getImageBase64(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(widget.editPet!.id)
            .update(petData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name has been updated! 🐾'),
              backgroundColor: Colors.black87,
            ),
          );
          // Pop twice to go back to my_pets_page (skipping pet_info_page)
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        // ── ADD new pet via backend API ────────────────────────────
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
          'imageUrl': _getImageBase64(),
        };

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

  /// Mark the pet as deceased in Firestore
  Future<void> _markAsDeceased() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.grey[600], size: 22),
            const SizedBox(width: 8),
            Text(
              'Mark as Deceased',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to mark ${widget.editPet!.name} as deceased?\n\nThis action cannot be undone. The pet will be displayed in grayscale and can no longer be edited.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(widget.editPet!.id)
          .update({'isDeceased': true});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.editPet!.name} has been marked as deceased. Rest in peace. 🕊️',
            ),
            backgroundColor: Colors.grey[700],
          ),
        );
        // Pop back to my_pets_page
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.isEditMode;

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
                    isEdit
                        ? 'Edit ${widget.editPet!.name}'
                        : 'Add ${widget.petType}',
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
                        child: _buildPhotoWidget(),
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
                            readOnly: true,
                            suffixText: 'mos',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Height & Weight ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _heightController,
                            hint: 'Height',
                            keyboardType: TextInputType.number,
                            suffixText: 'cm',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _FormField(
                            controller: _weightController,
                            hint: 'Weight',
                            keyboardType: TextInputType.number,
                            suffixText: 'lbs',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Birthday (Calendar Picker) ─────────────────
                    _FormField(
                      controller: _birthdayController,
                      hint: 'Birthday (YYYY-MM-DD)',
                      readOnly: true,
                      onTap: () => _selectBirthday(context),
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
                          hintText: '+ Characteristics (comma separated)',
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

            // ── Bottom Buttons ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 16),
              child: Row(
                children: [
                  // ── Deceased button (only in edit mode) ──────────
                  if (isEdit) ...[
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _markAsDeceased,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Deceased',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // ── Save / Update button ────────────────────────
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.black.withOpacity(
                            0.4,
                          ),
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
                                isEdit ? 'UPDATE' : 'SAVE',
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
          ],
        ),
      ),
    );
  }

  /// Build the photo circle widget — handles new picks, existing base64, and empty state
  Widget _buildPhotoWidget() {
    if (_pickedImageBytes != null) {
      return Image.memory(
        _pickedImageBytes!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
    if (_existingImageBase64 != null && _existingImageBase64!.isNotEmpty) {
      return Image.memory(
        base64Decode(_existingImageBase64!),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.add, size: 40, color: Colors.black54),
      );
    }
    return const Icon(Icons.add, size: 40, color: Colors.black54);
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
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
          suffixText: suffixText,
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
