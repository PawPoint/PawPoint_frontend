import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Branding Header (No 'const' here so Image.asset works)
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo1.png',
                    height: 40, // Increased slightly for better visibility
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Partner in Pet Care',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 2. Mission Section
            _buildCard(
              title: 'Our Mission',
              content:
                  'At PawPoint, our mission is to provide seamless, tech-driven healthcare for your pets. We bridge the gap between pet owners and veterinary experts to ensure every animal gets the attention they deserve.',
              icon: Icons.favorite,
            ),

            // 3. What We Offer Section
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'What We Offer',
                      icon: Icons.calendar_today,
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    _buildFeatureItem(
                      Icons.calendar_today,
                      'Seamless appointment booking with top vets.',
                    ),
                    _buildFeatureItem(
                      Icons.history,
                      'Full medical and vaccination history at your fingertips.',
                    ),
                    _buildFeatureItem(
                      Icons.admin_panel_settings,
                      'Robust tools for clinic admins and doctors.',
                    ),
                  ],
                ),
              ),
            ),

            // 4. Advantage Section
            _buildCard(
              title: 'The PawPoint Advantage',
              content:
                  '• Convenience: Book appointments anytime.\n'
                  '• Records: Keep your pet\'s medical history secure.\n'
                  '• Expertise: Direct access to qualified veterinarians.',
              icon: Icons.star,
            ),

            // 5. Contact Section
            _buildCard(
              title: 'Visit Us',
              content:
                  'Address: Jugan, Consolacion\n'
                  'Phone: +63 567 890 9876\n'
                  'Hours: Mon \u2013 Sat, 7:00 AM \u2013 6:00 PM\n'
                  '  (closed 12:00 PM \u2013 1:00 PM for staff lunch)\n'
                  '\ud83d\udea8 Open 24 hours for emergencies',
              icon: Icons.location_on,
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Developed by Sean & Rane | © 2026',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title, icon: icon),
            const Divider(),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
