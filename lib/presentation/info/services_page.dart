import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawpoint_mobileapp/data/service_data.dart';
import '../appointments/book_now_page.dart';

// ── Service data model ────────────────────────────────────────────────────────

class ServiceInfo {
  final String name;
  final String tagline;
  final String description;
  final IconData icon;
  final Color accentColor;
  final List<String> highlights;
  final String duration;
  final String idealFor;
  final double price;
  /// Asset paths for this service's photos.
  /// e.g. ['assets/images/checkup_1.jpg', 'assets/images/checkup_2.jpg']
  /// Falls back to the service icon placeholder if a file doesn't exist.
  final List<String> photos;

  const ServiceInfo({
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.highlights,
    required this.duration,
    required this.idealFor,
    required this.price,
    this.photos = const [],
  });

  String get formattedPrice => kFormatPrice(name);
}

// ── All services ──────────────────────────────────────────────────────────────

const List<ServiceInfo> _allServices = [
  ServiceInfo(
    name: 'General Check-up',
    tagline: 'Full-body wellness screening',
    price: 500,
    description:
        'A comprehensive nose-to-tail physical examination by our licensed veterinarians. '
        'We assess your pet\'s weight, heart, lungs, eyes, ears, teeth, coat, and vital signs '
        'to catch any early signs of illness and keep your companion in peak health.',
    icon: Icons.health_and_safety_rounded,
    accentColor: Color(0xFF4CAF50),
    highlights: [
      'Complete physical examination',
      'Weight & nutrition assessment',
      'Vital signs monitoring',
      'Early illness detection',
      'Personalized health report',
    ],
    duration: '30 – 45 min',
    idealFor: 'All pets, recommended every 6–12 months',
    photos: [
      'assets/images/checkup_1.jpg',
      'assets/images/checkup_2.jpg',
      'assets/images/checkup_3.jpg',
      'assets/images/checkup_4.jpg',
      'assets/images/checkup_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Diagnostics',
    tagline: 'Advanced lab & imaging tests',
    price: 1500,
    description:
        'State-of-the-art diagnostic services including blood panels, urinalysis, X-rays, '
        'and ultrasound. Our in-house laboratory delivers fast, accurate results so your vet '
        'can make informed decisions and start treatment without delay.',
    icon: Icons.biotech_rounded,
    accentColor: Color(0xFF2196F3),
    highlights: [
      'In-house blood & urine analysis',
      'Digital X-ray imaging',
      'Ultrasound scanning',
      'Rapid results turnaround',
      'Specialist interpretation',
    ],
    duration: '45 – 90 min',
    idealFor: 'Pets with symptoms or pre-surgical screening',
    photos: [
      'assets/images/diagnostics_1.jpg',
      'assets/images/diagnostics_2.jpg',
      'assets/images/diagnostics_3.jpg',
      'assets/images/diagnostics_4.jpg',
      'assets/images/diagnostics_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Dental Care',
    tagline: 'Sparkling smiles, healthy gums',
    price: 2500,
    description:
        'Professional dental scaling, polishing, and oral health assessment to prevent '
        'periodontal disease — the most common health issue in pets. Our dental suite '
        'uses ultrasonic scalers and safe anesthesia protocols for a stress-free experience.',
    icon: Icons.sentiment_very_satisfied_rounded,
    accentColor: Color(0xFF00BCD4),
    highlights: [
      'Ultrasonic plaque & tartar removal',
      'Polish & fluoride treatment',
      'Oral health assessment',
      'Safe anesthesia monitoring',
      'Home-care guidance',
    ],
    duration: '1 – 2 hours',
    idealFor: 'Pets 1 year and older, annually recommended',
    photos: [
      'assets/images/dental_1.jpg',
      'assets/images/dental_2.jpg',
      'assets/images/dental_3.jpg',
      'assets/images/dental_4.jpg',
      'assets/images/dental_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Nutrition Consultations',
    tagline: 'Tailored diets for every life stage',
    price: 800,
    description:
        'One-on-one sessions with our veterinary nutritionist to design the ideal meal '
        'plan for your pet\'s age, breed, health status, and lifestyle. Whether managing '
        'weight, allergies, or a chronic condition, we\'ll guide you to the best food choices.',
    icon: Icons.restaurant_menu_rounded,
    accentColor: Color(0xFFFF9800),
    highlights: [
      'Body condition scoring',
      'Customized meal plans',
      'Allergy & sensitivity guidance',
      'Supplement recommendations',
      'Weight management programs',
    ],
    duration: '30 – 45 min',
    idealFor: 'Pets with dietary needs or weight concerns',
    photos: [
      'assets/images/nutrition_1.jpg',
      'assets/images/nutrition_2.jpg',
      'assets/images/nutrition_3.jpg',
      'assets/images/nutrition_4.jpg',
      'assets/images/nutrition_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Parasite Prevention',
    tagline: 'Shield your pet year-round',
    price: 650,
    description:
        'Comprehensive parasite screening and preventive treatments for fleas, ticks, '
        'heartworm, intestinal worms, and mites. We provide safe, vet-approved preventatives '
        'tailored to your pet\'s weight and lifestyle to keep them protected every season.',
    icon: Icons.shield_rounded,
    accentColor: Color(0xFF9C27B0),
    highlights: [
      'Flea & tick screening',
      'Heartworm testing',
      'Intestinal parasite check',
      'Preventive medication plans',
      'Environmental decontamination advice',
    ],
    duration: '20 – 30 min',
    idealFor: 'All pets, especially outdoor or multi-pet households',
    photos: [
      'assets/images/parasite_1.jpg',
      'assets/images/parasite_2.jpg',
      'assets/images/parasite_3.jpg',
      'assets/images/parasite_4.jpg',
      'assets/images/parasite_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Quick Grooming',
    tagline: 'Fresh & clean in under an hour',
    price: 750,
    description:
        'Express grooming session covering bath, blow-dry, ear cleaning, nail trim, '
        'and a light brush-out. Perfect for busy pet owners who want their companion '
        'looking and smelling great without the wait.',
    icon: Icons.content_cut_rounded,
    accentColor: Color(0xFFE91E63),
    highlights: [
      'Medicated or regular shampoo bath',
      'Blow-dry & brush-out',
      'Nail trimming & filing',
      'Ear cleaning',
      'Bandana or bow finish',
    ],
    duration: '45 – 60 min',
    idealFor: 'Short-coated breeds or routine maintenance',
    photos: [
      'assets/images/grooming_quick_1.jpg',
      'assets/images/grooming_quick_2.jpg',
      'assets/images/grooming_quick_3.jpg',
      'assets/images/grooming_quick_4.jpg',
      'assets/images/grooming_quick_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Special Treatments',
    tagline: 'Targeted care for specific needs',
    price: 1200,
    description:
        'Specialized medical treatments including wound care, post-surgical recovery support, '
        'allergy therapy, acupuncture, rehabilitation exercises, and more. Our team creates a '
        'personalized treatment plan to help your pet recover faster and live comfortably.',
    icon: Icons.medical_services_rounded,
    accentColor: Color(0xFFFF5722),
    highlights: [
      'Wound care & bandaging',
      'Post-op recovery support',
      'Allergy injections & therapy',
      'Rehabilitation exercises',
      'Pain management',
    ],
    duration: 'Varies by treatment',
    idealFor: 'Pets recovering from illness, injury, or surgery',
    photos: [
      'assets/images/treatment_1.jpg',
      'assets/images/treatment_2.jpg',
      'assets/images/treatment_3.jpg',
      'assets/images/treatment_4.jpg',
      'assets/images/treatment_5.jpg',
    ],
  ),
  ServiceInfo(
    name: 'Full Grooming Packages',
    tagline: 'The complete spa experience',
    price: 2000,
    description:
        'Our premium all-inclusive grooming package covers everything from a deep conditioning '
        'bath, full coat styling and breed-specific haircut, ear cleaning, nail grinding, '
        'teeth brushing, and a finishing spritz — leaving your pet looking show-ready.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF795548),
    highlights: [
      'Deep conditioning treatment',
      'Breed-specific cut & styling',
      'Nail grinding (smooth finish)',
      'Teeth brushing',
      'Perfume & bow/bandana finish',
    ],
    duration: '2 – 3 hours',
    idealFor: 'Long-coated breeds or special occasions',
    photos: [
      'assets/images/grooming_full_1.jpg',
      'assets/images/grooming_full_2.jpg',
      'assets/images/grooming_full_3.jpg',
      'assets/images/grooming_full_4.jpg',
      'assets/images/grooming_full_5.jpg',
    ],
  ),
];

// ── Services List Page ────────────────────────────────────────────────────────

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Our Services',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),

            // ── Subtitle banner ─────────────────────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Text(
                'Expert care for your furry, feathered & scaly family members 🐾',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Service cards list ───────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: _allServices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final svc = _allServices[index];
                  return _ServiceListCard(
                    service: svc,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailPage(service: svc),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service list card ─────────────────────────────────────────────────────────

class _ServiceListCard extends StatelessWidget {
  final ServiceInfo service;
  final VoidCallback onTap;

  const _ServiceListCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Colored icon panel
            Container(
              width: 72,
              height: 80,
              decoration: BoxDecoration(
                color: service.accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Icon(service.icon, color: service.accentColor, size: 32),
              ),
            ),

            // ── Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.tagline,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: Colors.black38,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: service.accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service.formattedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: service.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right_rounded,
                  color: Colors.black26, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Detail Page ───────────────────────────────────────────────────────

class ServiceDetailPage extends StatelessWidget {
  final ServiceInfo service;

  const ServiceDetailPage({super.key, required this.service});

  // photos: uses service.photos list (falls back to icon placeholder if empty or file missing)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── Hero photo strip ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  height: 240,
                  color: service.accentColor.withOpacity(0.08),
                  child: Stack(
                    children: [
                      // Photo carousel — uses service.photos, falls back to icon placeholder
                      service.photos.isEmpty
                          ? Center(
                              child: _PhotoPlaceholder(
                                index: 1,
                                accentColor: service.accentColor,
                                serviceIcon: service.icon,
                              ),
                            )
                          : PageView.builder(
                              itemCount: service.photos.length,
                              itemBuilder: (context, index) => _PhotoPlaceholder(
                                assetPath: service.photos[index],
                                index: index + 1,
                                accentColor: service.accentColor,
                                serviceIcon: service.icon,
                              ),
                            ),

                      // Back button
                      Positioned(
                        top: 12,
                        left: 8,
                        child: SafeArea(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left_rounded,
                                  size: 26),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                          ),
                        ),
                      ),

                      // Swipe hint
                      Positioned(
                        bottom: 12,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.swipe_rounded,
                                  size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${service.photos.isEmpty ? 0 : service.photos.length} photos',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name & icon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: service.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(service.icon,
                                color: service.accentColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  service.tagline,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Quick info chips
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: service.duration,
                            color: service.accentColor,
                          ),
                          const SizedBox(width: 8),
                          // ── Price chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: service.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payments_rounded,
                                    size: 13, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  service.formattedPrice,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      _InfoChip(
                        icon: Icons.pets_rounded,
                        label: service.idealFor,
                        color: service.accentColor,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'About This Service',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.65,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // What's included
                      Text(
                        "What's Included",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...service.highlights.map(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: service.accentColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check_rounded,
                                    size: 13, color: service.accentColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  h,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Photo grid section
                      Text(
                        'Gallery',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      service.photos.isEmpty
                          ? Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: service.accentColor.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'No photos added yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: service.photos.length,
                              itemBuilder: (context, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _PhotoPlaceholder(
                                  assetPath: service.photos[index],
                                  index: index + 1,
                                  accentColor: service.accentColor,
                                  serviceIcon: service.icon,
                                  compact: true,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Book button ────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookNowPage(
                          initialService: service.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(
                    'Book a Schedule',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo placeholder widget ──────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  final int index;
  final Color accentColor;
  final IconData serviceIcon;
  final bool compact;
  /// Optional asset path — if provided, tries to load the real image first
  final String? assetPath;

  const _PhotoPlaceholder({
    required this.index,
    required this.accentColor,
    required this.serviceIcon,
    this.compact = false,
    this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    // Try loading the real image (if assetPath provided); fall back to styled placeholder
    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.07 + (index * 0.02)),
        border: Border.all(
          color: accentColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Image.asset(
        assetPath ?? 'assets/images/service_photo_$index.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              serviceIcon,
              size: compact ? 22 : 36,
              color: accentColor.withOpacity(0.35),
            ),
            if (!compact) ...[
              const SizedBox(height: 8),
              Text(
                'Photo $index',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: accentColor.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Coming soon',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: accentColor.withOpacity(0.35),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool fullWidth;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: chip) : chip;
  }
}
