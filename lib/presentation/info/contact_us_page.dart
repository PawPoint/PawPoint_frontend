import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class _SupportMessage {
  final String text;
  final bool isUser;
  final bool isQuickReply; // render as chip row
  final List<String> quickReplies;

  const _SupportMessage({
    required this.text,
    required this.isUser,
    this.isQuickReply = false,
    this.quickReplies = const [],
  });
}

// ── Support Q&A tree ─────────────────────────────────────────────────────────

const String _welcomeText =
    'Hi there! 👋 Welcome to PawPoint Support. How can I help you today? Please choose a topic below.';

const List<String> _mainTopics = [
  '📅 Booking & Appointments',
  '💳 Pricing & Services',
  '🐾 My Pets',
  '👤 Account & Profile',
  '📍 Clinic Location & Hours',
  '🚨 Emergency & Urgent Care',
];

const Map<String, Map<String, String>> _qaTree = {
  // ── Booking ────────────────────────────────────────────────────────────────
  '📅 Booking & Appointments': {
    'How do I book an appointment?':
        'You can book an appointment directly in the app by going to the **Book Now** tab. Select your preferred service, pick a date and time, and confirm your booking. It\'s that easy! 🐾',
    'Can I cancel my appointment?':
        'Yes! Go to **My Appointments**, find the appointment you want to cancel, and tap "Cancel Appointment." Please cancel at least 24 hours in advance so another pet can take your slot.',
    'What are the available booking hours?':
        'You can book appointments from **Monday to Saturday, 7 AM – 6 PM**. Note: 12 PM – 1 PM is our lunch break, so no slots are available during that time.',
    'Can I book on Sundays?':
        'Sundays are currently not available for regular bookings. However, we offer **24-hour emergency services** every day including Sundays.',
  },

  // ── Pricing ────────────────────────────────────────────────────────────────
  '💳 Pricing & Services': {
    'What are your service prices?':
        'Here\'s a quick overview of our prices:\n\n• General Check-up — ₱500\n• Diagnostics — ₱1,200\n• Dental Care — ₱800\n• Nutrition Consultations — ₱400\n• Parasite Prevention — ₱600\n• Quick Grooming — ₱300\n• Special Treatments — ₱700\n• Full Grooming Packages — ₱1,000',
    'Do you offer discounts?':
        'We occasionally run promos during pet wellness weeks and holidays. Make sure to check the **Services** page and your **Notifications** for updates! 🎉',
    'What payment methods do you accept?':
        'We accept **cash** payments at the clinic. Additional payment methods may be added soon — stay tuned!',
    'Are there additional charges?':
        'The prices listed are the base rates. Some premium add-ons (e.g., special medication, extended grooming) may have additional charges that the vet will discuss with you.',
  },

  // ── Pets ───────────────────────────────────────────────────────────────────
  '🐾 My Pets': {
    'How do I add a pet?':
        'Navigate to the **My Pets** tab and tap the **"+" button**. You\'ll be guided to select the pet type, add a name, breed, age, and a photo. Your pet will be saved to your profile automatically!',
    'Can I add multiple pets?':
        'Absolutely! You can add as many pets as you have. Each pet will appear on your My Pets page with their own profile.',
    'How do I view my pet\'s info?':
        'Tap on any pet card in the **My Pets** page to see their detailed profile, including breed, age, and the pet types we support.',
    'What pet types are supported?':
        'We currently support: 🐕 Dogs, 🐈 Cats, 🐦 Birds, 🐇 Rabbits, 🐹 Hamsters, 🐢 Turtles, 🐍 Snakes, and Other exotic pets.',
  },

  // ── Account ────────────────────────────────────────────────────────────────
  '👤 Account & Profile': {
    'How do I update my profile?':
        'Go to **Profile → Manage Profile**. There you can update your name, phone number, address, and upload a new profile photo.',
    'How do I change my password?':
        'In the **Manage Profile** page, scroll down to the "Change Password" section. Enter your current password and your new password to update it.',
    'I forgot my password. What do I do?':
        'On the **Login** page, tap **"Forgot your password?"**. Enter your email and we\'ll send you a password reset link.',
    'How do I logout?':
        'Go to **Profile**, scroll to the bottom, and tap **Logout**. You\'ll be asked to confirm before being logged out.',
  },

  // ── Location ───────────────────────────────────────────────────────────────
  '📍 Clinic Location & Hours': {
    'Where is the clinic located?':
        'PawPoint Veterinary Clinic is located in **Tacloban City, Leyte, Philippines**. You can find the exact address and a map on our **About Us** page.',
    'What are your operating hours?':
        'We\'re open **Monday to Saturday, 7 AM – 6 PM**. Emergency services are available **24 hours a day, 7 days a week** including holidays.',
    'Is there parking available?':
        'Yes, we have parking available for clients. If you have any concerns on finding us, feel free to call our clinic directly.',
    'Do you do home visits?':
        'At the moment, we do not offer home visit services. All appointments are conducted at our clinic. We\'re exploring this option for the future!',
  },

  // ── Emergency ──────────────────────────────────────────────────────────────
  '🚨 Emergency & Urgent Care': {
    'Do you handle emergencies?':
        '**Yes!** Our emergency line is available **24/7, including Sundays and holidays**. Please call our clinic hotline directly for urgent cases.',
    'What counts as a pet emergency?':
        'Emergencies include: difficulty breathing, poisoning, severe injury or trauma, uncontrolled bleeding, seizures, or complete lethargy/unresponsiveness. When in doubt — call us!',
    'How do I contact the clinic urgently?':
        'For urgent matters, go to **Profile → Contact Us** or visit our **About Us** page for our clinic contact number. Our emergency team is always on standby.',
    'Can I walk in without an appointment?':
        'For emergencies, **yes — walk-ins are always welcome**. For routine visits, we recommend booking in advance to minimize your wait time.',
  },
};

// ── Page ──────────────────────────────────────────────────────────────────────

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _scrollController = ScrollController();
  final List<_SupportMessage> _messages = [];
  String? _activeCategory; // which topic's questions are shown

  @override
  void initState() {
    super.initState();
    // Initial bot greeting
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConversation());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startConversation() {
    setState(() {
      _messages.clear();
      _activeCategory = null;
    });
    _addBotMessage(_welcomeText, quickReplies: _mainTopics);
  }

  void _addBotMessage(String text, {List<String> quickReplies = const []}) {
    setState(() {
      _messages.add(_SupportMessage(
        text: text,
        isUser: false,
        isQuickReply: quickReplies.isNotEmpty,
        quickReplies: quickReplies,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(_SupportMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onTopicSelected(String topic) {
    _addUserMessage(topic);
    _activeCategory = topic;
    final questions = _qaTree[topic]?.keys.toList() ?? [];
    Future.delayed(const Duration(milliseconds: 300), () {
      _addBotMessage(
        'Great choice! Here are some common questions about **${topic.substring(2).trim()}**:',
        quickReplies: [...questions, '⬅️ Back to topics'],
      );
    });
  }

  void _onQuestionSelected(String question) {
    if (question == '⬅️ Back to topics') {
      _addUserMessage('Back to topics');
      Future.delayed(const Duration(milliseconds: 300), () {
        _addBotMessage(_welcomeText, quickReplies: _mainTopics);
        _activeCategory = null;
      });
      return;
    }

    _addUserMessage(question);
    final answer = _qaTree[_activeCategory]?[question];
    if (answer != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _addBotMessage(answer, quickReplies: [
          '🔙 More questions about ${_activeCategory?.substring(2).trim() ?? 'this topic'}',
          '🏠 Back to main topics',
          '✅ That answered my question',
        ]);
      });
    }
  }

  void _onFollowUp(String action) {
    if (action.startsWith('🔙')) {
      _addUserMessage(action);
      final questions = _qaTree[_activeCategory]?.keys.toList() ?? [];
      Future.delayed(const Duration(milliseconds: 300), () {
        _addBotMessage('Here are more questions you can ask:', quickReplies: [...questions, '⬅️ Back to topics']);
      });
    } else if (action == '🏠 Back to main topics') {
      _addUserMessage('Back to main topics');
      Future.delayed(const Duration(milliseconds: 300), () {
        _activeCategory = null;
        _addBotMessage(_welcomeText, quickReplies: _mainTopics);
      });
    } else if (action == '✅ That answered my question') {
      _addUserMessage('That answered my question, thanks!');
      Future.delayed(const Duration(milliseconds: 300), () {
        _addBotMessage(
          'Glad I could help! 😊🐾 Is there anything else I can assist you with?',
          quickReplies: ['🏠 Back to main topics', '🚪 Done, close support'],
        );
      });
    } else if (action == '🚪 Done, close support') {
      _addUserMessage("Done, closing support.");
      Future.delayed(const Duration(milliseconds: 400), () {
        _addBotMessage(
          'Thank you for reaching out to PawPoint Support! Have a paw-some day! 🐾✨\n\nYou can start a new conversation anytime.',
          quickReplies: ['🔄 Start new conversation'],
        );
      });
    } else if (action == '🔄 Start new conversation') {
      Future.delayed(const Duration(milliseconds: 100), _startConversation);
    }
  }

  void _onChipTap(String choice) {
    // Determine context of the chip
    if (_activeCategory == null && _mainTopics.contains(choice)) {
      _onTopicSelected(choice);
    } else if (choice == '⬅️ Back to topics' ||
        choice == '🏠 Back to main topics' ||
        choice == '✅ That answered my question' ||
        choice == '🚪 Done, close support' ||
        choice == '🔄 Start new conversation' ||
        choice.startsWith('🔙')) {
      _onFollowUp(choice);
    } else if (_activeCategory != null && _qaTree[_activeCategory]?.containsKey(choice) == true) {
      _onQuestionSelected(choice);
    } else {
      // fallback
      _onFollowUp(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1A1A1A),
              ),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PawPoint Support',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                    ),
                    Text(
                      'Online',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Restart',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: _startConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Message list ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isLast = index == _messages.length - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment:
                        msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'PawPoint Support',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.black38),
                          ),
                        ),
                      _buildBubble(msg),
                      // Show quick reply chips only on the LAST bot message
                      if (!msg.isUser && msg.isQuickReply && isLast) ...[
                        const SizedBox(height: 10),
                        _buildQuickReplies(msg.quickReplies),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Footer ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.lock_outline, size: 14, color: Colors.black26),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Select an option above to get help • PawPoint Support',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_SupportMessage msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _parseMarkdown(msg.text, isUser),
        ),
      ),
    );
  }

  /// Very simple inline **bold** markdown renderer
  Widget _parseMarkdown(String text, bool isUser) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      final isBold = i.isOdd;
      spans.add(TextSpan(
        text: parts[i],
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          height: 1.5,
          color: isUser ? Colors.white : const Color(0xFF1A1A1A),
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildQuickReplies(List<String> replies) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: replies.map((r) {
        final isBack = r.contains('Back') || r.contains('Done') || r.contains('close') || r.contains('🔄');
        return GestureDetector(
          onTap: () => _onChipTap(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isBack ? const Color(0xFFEEEEEE) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isBack ? Colors.transparent : const Color(0xFF1A1A1A),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              r,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isBack ? Colors.black45 : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
