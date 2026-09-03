import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.radar_rounded,
      color: Color(0xFF2563EB),
      eyebrow: 'WELCOME TO JOBFINDER',
      title: 'A better job search starts close to home.',
      description:
          'Discover trusted opportunities that fit your skills, schedule, and neighbourhood.',
      stat: '1,000+ local opportunities',
    ),
    _Slide(
      icon: Icons.location_on_rounded,
      color: Color(0xFF0D9488),
      eyebrow: 'SEARCH NEARBY',
      title: 'Find work where life happens.',
      description:
          'Browse roles by location and see exactly how far each opportunity is from you.',
      stat: 'Jobs sorted by distance',
    ),
    _Slide(
      icon: Icons.tune_rounded,
      color: Color(0xFF7C3AED),
      eyebrow: 'MAKE IT YOURS',
      title: 'Only see roles worth your time.',
      description:
          'Filter by category, work style, salary, and more to make every search count.',
      stat: 'Smart filters in one tap',
    ),
    _Slide(
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFDB2777),
      eyebrow: 'TOP PICKS',
      title: 'Let the best matches rise to the top.',
      description:
          'Explore highly rated employers and roles selected to help you make a confident move.',
      stat: 'Curated featured roles',
    ),
    _Slide(
      icon: Icons.bookmark_added_rounded,
      color: Color(0xFFF59E0B),
      eyebrow: 'STAY ORGANISED',
      title: 'Save the jobs you want to revisit.',
      description:
          'Build a personal shortlist and keep the next great opportunity within easy reach.',
      stat: 'Your shortlist, always ready',
    ),
    _Slide(
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF059669),
      eyebrow: 'READY WHEN YOU ARE',
      title: 'Your next chapter is one tap away.',
      description:
          'Create a free account, apply with confidence, and take the next step in your career.',
      stat: 'Quick, guided applications',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool signUp = false}) async {
    await AuthService.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => signUp ? const SignupScreen() : const LoginScreen()),
    );
  }

  void _next() {
    if (_page == _slides.length - 1) {
      _finish(signUp: true);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              slide.color,
              Color.lerp(slide.color, const Color(0xFF0F172A), .58)!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                child: Row(
                  children: [
                    const _BrandMark(),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _finish(),
                      child: const Text('Skip',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _page = index),
                  itemBuilder: (_, index) => _SlideContent(
                      slide: _slides[index], active: index == _page),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                          _slides.length,
                          (index) => Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 4,
                                  margin: EdgeInsets.only(
                                      right:
                                          index == _slides.length - 1 ? 0 : 6),
                                  decoration: BoxDecoration(
                                    color: index <= _page
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: .24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: slide.color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Text(
                          _page == _slides.length - 1
                              ? 'Create free account'
                              : 'Continue',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => _finish(),
                      child: const Text('I already have an account',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _Slide slide;
  final bool active;

  const _SlideContent({required this.slide, required this.active});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FadeInDown(
              key: ValueKey(slide.title),
              duration: const Duration(milliseconds: 550),
              child: _Illustration(icon: slide.icon),
            ),
          ),
          const SizedBox(height: 52),
          FadeInLeft(
            key: ValueKey('${slide.title}-copy'),
            duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slide.eyebrow,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .75),
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
                const SizedBox(height: 12),
                Text(slide.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        height: 1.12,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Text(slide.description,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 15,
                        height: 1.45)),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .18))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 17),
                    const SizedBox(width: 8),
                    Text(slide.stat,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final IconData icon;
  const _Illustration({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .08))),
      Container(
          width: 164,
          height: 164,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: .25), width: 2))),
      Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .16),
                    blurRadius: 24,
                    offset: const Offset(0, 12))
              ]),
          child: Icon(icon, size: 54, color: const Color(0xFF2563EB))),
      const Positioned(
          right: 7, bottom: 28, child: _Bubble(icon: Icons.bolt_rounded)),
      const Positioned(
          left: 14, top: 24, child: _Bubble(icon: Icons.favorite_rounded)),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  final IconData icon;
  const _Bubble({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => const Row(children: [
        Icon(Icons.work_rounded, color: Colors.white, size: 22),
        SizedBox(width: 8),
        Text('JobFinder',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
      ]);
}

class _Slide {
  final IconData icon;
  final Color color;
  final String eyebrow;
  final String title;
  final String description;
  final String stat;

  const _Slide(
      {required this.icon,
      required this.color,
      required this.eyebrow,
      required this.title,
      required this.description,
      required this.stat});
}
