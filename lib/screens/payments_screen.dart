import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedPlan = 1;

  final _plans = const [
    _Plan('Starter', '₹0', 'Perfect for browsing local jobs',
        ['Unlimited search', 'Save jobs']),
    _Plan('Pro', '₹199', 'Monthly',
        ['Priority applications', 'Profile insights', 'Application tracker']),
    _Plan('Career Plus', '₹499', 'Monthly',
        ['Everything in Pro', 'Featured profile', 'Career support']),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Plans & Payments',
              style: TextStyle(fontWeight: FontWeight.w700))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: Colors.amber, size: 30),
                  SizedBox(height: 14),
                  Text('Invest in your next move.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Upgrade when you want more tools for your job search.',
                      style: TextStyle(color: Colors.white70, height: 1.35)),
                ]),
          ),
          const SizedBox(height: 24),
          const Text('Choose your plan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...List.generate(_plans.length,
              (index) => _planCard(_plans[index], index, isDark)),
          const SizedBox(height: 16),
          const Text(
              'Pay securely with Razorpay using the methods available on checkout.',
              style: TextStyle(height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedPlan == 0
                    ? () => Navigator.pop(context)
                    : _openRazorpay,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(
                    _selectedPlan == 0
                        ? 'Continue with Starter'
                        : 'Continue to secure payment',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              )),
          const SizedBox(height: 12),
          Text(
              'Payment is completed on Razorpay. Plan activation is not automatic.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _planCard(_Plan plan, int index, bool isDark) {
    final selected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1565C0).withValues(alpha: .09)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.grey.withValues(alpha: .18),
              width: selected ? 2 : 1),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFF1565C0) : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(plan.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  Text(plan.price,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Color(0xFF1565C0)))
                ]),
                Text(plan.subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 8),
                Text(plan.features.join('  •  '),
                    style: const TextStyle(fontSize: 12, height: 1.4)),
              ])),
        ]),
      ),
    );
  }

  Future<void> _openRazorpay() async {
    final uri = Uri.parse('https://razorpay.me/@harshitrai1056');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Razorpay checkout.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Razorpay checkout.')),
      );
    }
  }
}

class _Plan {
  final String name, price, subtitle;
  final List<String> features;
  const _Plan(this.name, this.price, this.subtitle, this.features);
}
