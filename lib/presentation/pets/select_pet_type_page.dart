import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_pet_page.dart';

class SelectPetTypePage extends StatefulWidget {
  const SelectPetTypePage({super.key});

  @override
  State<SelectPetTypePage> createState() => _SelectPetTypePageState();
}

class _SelectPetTypePageState extends State<SelectPetTypePage> {
  final List<Map<String, dynamic>> _petTypes = [
    {'label': 'Dog', 'icon': Icons.pets_rounded},
    {'label': 'Cat', 'icon': Icons.pets_rounded},
    {'label': 'Bird', 'icon': Icons.flutter_dash_rounded},
    {'label': 'Rabbit', 'icon': Icons.cruelty_free_rounded},
    {'label': 'Hamster', 'icon': Icons.pets_rounded},
    {'label': 'Turtle', 'icon': Icons.pets_rounded},
    {'label': 'Snake', 'icon': Icons.pets_rounded},
  ];

  void _selectType(String type) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AddPetPage(petType: type)),
    );
  }

  void _showOtherDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enter Pet Type',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. Ferret, Iguana...',
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
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(ctx);
              _selectType(value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
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
                    'Select Pet Type',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Subtitle ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'What kind of pet would you like to add?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ── Pet Type Grid ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Build rows of 2
                    for (int i = 0; i < _petTypes.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PetTypeButton(
                                label: _petTypes[i]['label'],
                                icon: _petTypes[i]['icon'],
                                onTap: () => _selectType(_petTypes[i]['label']),
                              ),
                            ),
                            const SizedBox(width: 14),
                            if (i + 1 < _petTypes.length)
                              Expanded(
                                child: _PetTypeButton(
                                  label: _petTypes[i + 1]['label'],
                                  icon: _petTypes[i + 1]['icon'],
                                  onTap: () =>
                                      _selectType(_petTypes[i + 1]['label']),
                                ),
                              )
                            else
                              const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),

                    // "Other" button — full width
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          if (_petTypes.length.isOdd)
                            Expanded(
                              child: _PetTypeButton(
                                label: 'Other',
                                icon: Icons.add_circle_outline_rounded,
                                onTap: _showOtherDialog,
                              ),
                            )
                          else ...[
                            Expanded(
                              child: _PetTypeButton(
                                label: 'Other',
                                icon: Icons.add_circle_outline_rounded,
                                onTap: _showOtherDialog,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(child: SizedBox()),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pet Type Button Widget ───────────────────────────────────────────────────
class _PetTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PetTypeButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black54),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
