import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> _savePet() async {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    final gender = _selectedGender ?? '';
    final age = _ageController.text.trim();

    if (name.isEmpty || breed.isEmpty || gender.isEmpty || age.isEmpty) {
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .add({
            'petType': widget.petType,
            'name': name,
            'breed': breed,
            'gender': gender,
            'age': age,
            'height': _heightController.text.trim(),
            'weight': _weightController.text.trim(),
            'birthday': _birthdayController.text.trim(),
            'characteristics': _characteristicsController.text.trim(),
            'imageUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name has been added! 🐾'),
            backgroundColor: Colors.black87,
          ),
        );
        Navigator.pop(context);
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
                      onTap: () {
                        // Placeholder for image picker functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Photo upload coming soon!'),
                            backgroundColor: Colors.black54,
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26, width: 2),
                        ),
                        child: const Icon(
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

                    // ── Gender & Age (side by side) ────────────────
                    Row(
                      children: [
                        // Gender dropdown
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
                        // Age field
                        Expanded(
                          child: _FormField(
                            controller: _ageController,
                            hint: 'Age',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Height & Weight (side by side) ─────────────
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _heightController,
                            hint: 'Height',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _FormField(
                            controller: _weightController,
                            hint: 'Weight',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Birthday ───────────────────────────────────
                    _FormField(
                      controller: _birthdayController,
                      hint: 'Birthday',
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

// ── Reusable Form Field ─────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _FormField({required this.controller, required this.hint});

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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
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
