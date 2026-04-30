import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/models/pet_model.dart';
import 'add_pet_page.dart';

class PetInfoPage extends StatelessWidget {
  final PetModel pet;

  const PetInfoPage({super.key, required this.pet});

  /// Calculate age from birthday string (YYYY-MM-DD)
  /// Shows days if < 1 month, months if < 12, or years + months otherwise
  String _calculateAgeInMonths() {
    if (pet.birthday.isEmpty) {
      // Fallback: use the age field (years) and convert to months
      final years = int.tryParse(pet.age) ?? 0;
      if (years == 0) return '0 Months';
      return '${years * 12} Months';
    }
    try {
      final parts = pet.birthday.split('-');
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

      // If less than 1 month, show days instead
      if (months == 0) {
        final days = now.difference(birthDate).inDays;
        if (days <= 0) return '< 1 Day';
        if (days == 1) return '1 Day';
        return '$days Days';
      }

      return '$months Months';
    } catch (_) {
      final years = int.tryParse(pet.age) ?? 0;
      if (years == 0) return '0 Months';
      return '${years * 12} Months';
    }
  }

  /// Format birthday for display
  String _formatBirthday() {
    if (pet.birthday.isEmpty) return 'N/A';
    try {
      final parts = pet.birthday.split('-');
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return pet.birthday;
    }
  }

  /// Split characteristics by comma for chip display
  List<String> _getCharacteristicsList() {
    if (pet.characteristics.isEmpty) return [];
    return pet.characteristics
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeceased = pet.isDeceased;
    final characteristics = _getCharacteristicsList();

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
                    'PET INFORMATION',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDeceased ? Colors.grey : Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ── Pet Image ────────────────────────────────────
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFF5F5F5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _buildPetImage(isDeceased),
                    ),

                    const SizedBox(height: 20),

                    // ── Pet Name ─────────────────────────────────────
                    Text(
                      pet.name,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDeceased ? Colors.grey : Colors.black,
                      ),
                    ),

                    // ── Edit Button ─────────────────────────────────
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: isDeceased
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddPetPage(
                                    petType: pet.petType,
                                    editPet: pet,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDeceased
                            ? Colors.grey[400]
                            : Colors.black,
                        disabledBackgroundColor: Colors.grey[400],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ── Breed | Gender ──────────────────────────────
                    Text(
                      '${pet.breed} | ${pet.gender}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDeceased ? Colors.grey : Colors.black45,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Pet Type Badge ───────────────────────────────
                    if (pet.petType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDeceased
                              ? Colors.grey[200]
                              : Colors.black.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pet.petType,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDeceased ? Colors.grey : Colors.black54,
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // ── Birthday Display ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cake_rounded,
                          size: 16,
                          color: isDeceased ? Colors.grey : Colors.black38,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatBirthday(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDeceased ? Colors.grey : Colors.black38,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Deceased Banner ──────────────────────────────
                    if (isDeceased)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'In Loving Memory',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Stats Cards (Age, Height, Weight) ───────────
                    Row(
                      children: [
                        _StatCard(
                          label: 'Age',
                          value: _calculateAgeInMonths(),
                          isDeceased: isDeceased,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Height',
                          value: pet.height.isNotEmpty
                              ? '${pet.height} cm'
                              : 'N/A',
                          isDeceased: isDeceased,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          label: 'Weight',
                          value: pet.weight.isNotEmpty
                              ? '${pet.weight} lbs'
                              : 'N/A',
                          isDeceased: isDeceased,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Characteristics Section ─────────────────────
                    if (characteristics.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 22,
                            color: isDeceased ? Colors.grey : Colors.black87,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Characteristics',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDeceased ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: characteristics.map((trait) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDeceased
                                  ? Colors.grey[300]
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              trait,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDeceased
                                    ? Colors.grey[600]
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(bool isDeceased) {
    Widget imageWidget;
    if (pet.imageUrl != null && pet.imageUrl!.isNotEmpty) {
      imageWidget = Image.memory(
        base64Decode(pet.imageUrl!),
        fit: BoxFit.cover,
        width: 220,
        height: 220,
        errorBuilder: (_, _, _) =>
            Icon(Icons.pets_rounded, size: 64, color: Colors.black12),
      );
    } else {
      imageWidget = Center(
        child: Icon(Icons.pets_rounded, size: 64, color: Colors.black12),
      );
    }

    if (isDeceased) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}

// ── Stat Card Widget ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDeceased;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isDeceased,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDeceased ? Colors.grey[300] : Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDeceased ? Colors.grey[600] : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDeceased ? Colors.grey[500] : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
