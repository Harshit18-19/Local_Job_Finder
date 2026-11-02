import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _email = 'harshit55121@gmail.com';
  static const _phone = '8009622425';

  Future<void> _openContact(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the contact app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(height: 14),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Find answers to common questions or get in touch with our support team.',
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Frequently asked questions',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _faq(
            context,
            'How do I find jobs near me?',
            'Browse jobs on the home screen. Use search and filters to narrow results by category, work type, salary, and distance. Allow location access to see nearby opportunities.',
          ),
          _faq(
            context,
            'Where can I find jobs I saved or applied to?',
            'Open your profile menu and choose Saved jobs to view your shortlist, or Applied jobs to track applications.',
          ),
          _faq(
            context,
            'How can I check my resume?',
            'Open Profile & resume from the profile menu to upload a PDF and review its ATS readiness and suggestions.',
          ),
          _faq(
            context,
            'I have a problem with my account or an application. What should I send?',
            'Contact support with a short description of the issue. Include the email on your account, the job title if relevant, and a screenshot or error message when available. Never send your password or payment card details.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Contact support',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.email_outlined),
                  ),
                  title: const Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(_email),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _openContact(
                    context,
                    Uri(
                      scheme: 'mailto',
                      path: _email,
                      queryParameters: const {
                        'subject': 'Local Job Finder support',
                      },
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.phone_outlined),
                  ),
                  title: const Text(
                    'Phone',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(_phone),
                  trailing: const Icon(Icons.call_rounded, size: 18),
                  onTap: () =>
                      _openContact(context, Uri(scheme: 'tel', path: _phone)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'When you contact us, please describe the issue so we can help you more quickly.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faq(BuildContext context, String question, String answer) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            answer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}
