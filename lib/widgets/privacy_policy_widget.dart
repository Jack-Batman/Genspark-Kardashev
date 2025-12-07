import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Privacy Policy and Terms of Service Widget
class PrivacyPolicyWidget extends StatelessWidget {
  final Color? accentColor;
  
  const PrivacyPolicyWidget({
    super.key,
    this.accentColor,
  });
  
  // ═══════════════════════════════════════════════════════════════
  // CONFIGURATION - Update these URLs when you host your policies
  // ═══════════════════════════════════════════════════════════════
  
  /// URL to your hosted Privacy Policy
  /// TODO: Replace with your actual Privacy Policy URL
  static const String privacyPolicyUrl = 'https://kardashev-ascension.example.com/privacy';
  
  /// URL to your hosted Terms of Service
  /// TODO: Replace with your actual Terms of Service URL
  static const String termsOfServiceUrl = 'https://kardashev-ascension.example.com/terms';
  
  /// Contact email for privacy inquiries
  static const String contactEmail = 'privacy@kardashev-ascension.example.com';
  
  /// App name
  static const String appName = 'Kardashev Ascension';
  
  /// Developer/Company name
  static const String developerName = 'Your Company Name';
  
  /// Last updated date
  static const String lastUpdated = 'December 2024';

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).primaryColor;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.privacy_tip_outlined, color: color),
                const SizedBox(width: 12),
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Last Updated',
                    lastUpdated,
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Introduction',
                    '$developerName ("we", "us", or "our") operates the $appName mobile application (the "App"). '
                    'This Privacy Policy explains how we collect, use, and protect your information when you use our App.',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Information We Collect',
                    '''We collect the following types of information:

• Game Progress Data: Your game save data, achievements, and statistics are stored locally on your device.

• Purchase Information: When you make in-app purchases, transaction data is processed by Google Play. We receive confirmation of purchases but do not store your payment details.

• Advertising Data: We use Google AdMob to display ads. AdMob may collect device identifiers and usage data for ad personalization. You can opt out of personalized ads in your device settings.

• Analytics Data: We may collect anonymous usage statistics to improve the game experience, including play time, feature usage, and crash reports.''',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'How We Use Your Information',
                    '''We use collected information to:

• Save and restore your game progress
• Process in-app purchases
• Display relevant advertisements
• Improve game performance and features
• Provide customer support''',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Third-Party Services',
                    '''Our App uses the following third-party services:

• Google Play Services: For in-app purchases and app distribution
• Google AdMob: For displaying advertisements
• Firebase (optional): For analytics and crash reporting

Each of these services has their own privacy policy governing their use of your data.''',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Data Storage & Security',
                    'Your game data is stored locally on your device. We do not transfer your game progress to external servers '
                    'unless you explicitly use cloud save features (if available). We implement reasonable security measures '
                    'to protect any data we process.',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Children\'s Privacy',
                    'Our App is not directed to children under 13. We do not knowingly collect personal information from children. '
                    'If you are a parent and believe your child has provided us with personal information, please contact us.',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Your Rights',
                    '''You have the right to:

• Access your game data (stored locally on your device)
• Delete your game data by uninstalling the App or clearing app data
• Opt out of personalized advertising in your device settings
• Request information about data we process''',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Changes to This Policy',
                    'We may update this Privacy Policy from time to time. We will notify you of any changes by updating the '
                    '"Last Updated" date. Continued use of the App after changes constitutes acceptance of the updated policy.',
                    color,
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Contact Us',
                    'If you have questions about this Privacy Policy, please contact us at:\n\n$contactEmail',
                    color,
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(privacyPolicyUrl),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Full Policy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl(termsOfServiceUrl),
                          icon: const Icon(Icons.description_outlined, size: 16),
                          label: const Text('Terms'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Show privacy policy as a modal bottom sheet
void showPrivacyPolicy(BuildContext context, {Color? accentColor}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => PrivacyPolicyWidget(
        accentColor: accentColor,
      ),
    ),
  );
}

/// Compact privacy policy link widget for settings/store screens
class PrivacyPolicyLink extends StatelessWidget {
  final Color? color;
  
  const PrivacyPolicyLink({super.key, this.color});
  
  @override
  Widget build(BuildContext context) {
    final linkColor = color ?? Colors.white.withValues(alpha: 0.6);
    
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () => showPrivacyPolicy(context, accentColor: color),
          child: Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: linkColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        Text(
          ' • ',
          style: TextStyle(color: linkColor),
        ),
        TextButton(
          onPressed: () => _launchUrl(PrivacyPolicyWidget.termsOfServiceUrl),
          child: Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 12,
              color: linkColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
