import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../main.dart';
import '../models/job.dart';
import '../models/job_data.dart';
import '../widgets/job_card.dart';
import '../widgets/featured_job_card.dart';
import '../widgets/shimmer_card.dart';
import '../services/auth_service.dart';
import 'job_detail_screen.dart';
import 'login_screen.dart';
import 'saved_jobs_screen.dart';
import 'applied_jobs_screen.dart';
import 'payments_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  String _sortBy = 'Distance';
  double _maxSalaryLakh = 20;
  List<Job> _filtered = [];
  bool _loading = true;
  bool _searchFocused = false;
  late AnimationController _headerAnim;
  String _userName = '';
  String _userEmail = '';

  final _categories = [
    'All',
    'Technology',
    'Food & Beverage',
    'Logistics',
    'Design',
    'Retail',
    'Finance',
    'Healthcare',
    'Education',
    'Media',
    'Trades',
    'Engineering',
    'Administration',
    'Hospitality',
    'Security',
    'Health & Fitness',
  ];

  final _types = ['All', 'Full-time', 'Part-time', 'Contract', 'Remote'];

  final _categoryIcons = {
    'All': Icons.apps_rounded,
    'Technology': Icons.code_rounded,
    'Food & Beverage': Icons.coffee_rounded,
    'Logistics': Icons.local_shipping_rounded,
    'Design': Icons.palette_rounded,
    'Retail': Icons.storefront_rounded,
    'Finance': Icons.account_balance_rounded,
    'Healthcare': Icons.local_hospital_rounded,
    'Education': Icons.school_rounded,
    'Media': Icons.campaign_rounded,
    'Trades': Icons.construction_rounded,
    'Engineering': Icons.engineering_rounded,
    'Administration': Icons.admin_panel_settings_rounded,
    'Hospitality': Icons.celebration_rounded,
    'Security': Icons.security_rounded,
    'Health & Fitness': Icons.fitness_center_rounded,
  };

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerAnim.forward();
    _loadUser();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _filtered = List.from(sampleJobs)
            ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    final email = await AuthService.getUserEmail();
    if (mounted)
      setState(() {
        _userName = name ?? 'User';
        _userEmail = email ?? '';
      });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = sampleJobs.where((job) {
        final matchSearch = query.isEmpty ||
            job.title.toLowerCase().contains(query) ||
            job.company.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query);
        final matchCategory =
            _selectedCategory == 'All' || job.category == _selectedCategory;
        final matchType = _selectedType == 'All' || job.type == _selectedType;
        final salaryNum = _parseSalaryLakh(job.salary);
        final matchSalary = salaryNum == null || salaryNum <= _maxSalaryLakh;
        return matchSearch && matchCategory && matchType && matchSalary;
      }).toList();
      _sortJobs();
    });
  }

  double? _parseSalaryLakh(String salary) {
    final match = RegExp(r'\u20b9(\d+(?:,\d+)*)').firstMatch(salary);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '');
    final val = int.tryParse(raw);
    if (val == null) return null;
    return val > 10000 ? val / 100000 : val / 100;
  }

  void _sortJobs() {
    switch (_sortBy) {
      case 'Distance':
        _filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 'Rating':
        _filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Salary':
        _filtered.sort((a, b) {
          final sa = _parseSalaryLakh(a.salary) ?? 0;
          final sb = _parseSalaryLakh(b.salary) ?? 0;
          return sb.compareTo(sa);
        });
        break;
      case 'Newest':
        break;
    }
  }

  List<Job> get _featuredJobs =>
      sampleJobs.where((j) => j.rating >= 4.5).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF0F4FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverHeader(isDark),
          SliverToBoxAdapter(child: _buildSearchBar(isDark)),
          SliverToBoxAdapter(child: _buildStatsRow(isDark)),
          SliverToBoxAdapter(child: _buildCategoryChips(isDark)),
          if (!_loading && !_searchFocused && _selectedCategory == 'All')
            SliverToBoxAdapter(child: _buildFeaturedSection()),
          SliverToBoxAdapter(child: _buildResultsHeader()),
          if (_loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const ShimmerJobCard(),
                childCount: 4,
              ),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => JobCard(
                  job: _filtered[i],
                  index: i,
                  onTap: () => _openDetail(_filtered[i]),
                ),
                childCount: _filtered.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1A237E),
                      const Color(0xFF0D47A1),
                      const Color(0xFF006064)
                    ]
                  : [
                      const Color(0xFF1565C0),
                      const Color(0xFF1976D2),
                      const Color(0xFF0288D1)
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 60,
                bottom: 30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.work_rounded,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'JobFinder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _headerIconBtn(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                () => themeNotifier.value =
                                    isDark ? ThemeMode.light : ThemeMode.dark,
                              ),
                              const SizedBox(width: 8),
                              _headerIconBtn(Icons.bookmark_rounded, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SavedJobsScreen()),
                                );
                              }),
                              const SizedBox(width: 8),
                              _headerIconBtn(
                                  Icons.tune_rounded, _showFilterSheet),
                              const SizedBox(width: 8),
                              _headerIconBtn(
                                  Icons.person_rounded, _showProfileSheet),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Your Dream',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              'Job in India 🇮🇳',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${sampleJobs.length} opportunities near you',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Focus(
        onFocusChange: (f) => setState(() => _searchFocused = f),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0)
                    .withValues(alpha: isDark ? 0.15 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search jobs, companies, locations...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF1565C0), size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey[400]),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final totalJobs = sampleJobs.length;
    final fullTime = sampleJobs.where((j) => j.type == 'Full-time').length;
    final remote = sampleJobs.where((j) => j.type == 'Remote').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _statCard('$totalJobs', 'Total Jobs', Icons.work_outline_rounded,
              const Color(0xFF1565C0), isDark),
          const SizedBox(width: 10),
          _statCard('$fullTime', 'Full-time', Icons.access_time_rounded,
              const Color(0xFF059669), isDark),
          const SizedBox(width: 10),
          _statCard('$remote', 'Remote', Icons.laptop_mac_rounded,
              const Color(0xFF7C3AED), isDark),
        ],
      ),
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
                Text(label,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                          )
                        : null,
                    color: selected
                        ? null
                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1565C0)
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcons[cat] ?? Icons.work_outline,
                        size: 14,
                        color: selected ? Colors.white : Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey[600],
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('Featured',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Top Picks',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${_featuredJobs.length} jobs',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            height: 185,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: _featuredJobs.length,
              itemBuilder: (_, i) => FeaturedJobCard(
                job: _featuredJobs[i],
                onTap: () => _openDetail(_featuredJobs[i]),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    if (_loading) return const SizedBox(height: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_filtered.length} Jobs Found',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1565C0)),
            ),
          ),
          const Spacer(),
          Icon(Icons.near_me_rounded, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(_sortBy == 'Distance' ? 'Nearest first' : 'Sorted by $_sortBy',
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: FadeIn(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.search_off_rounded,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('No jobs found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Try adjusting your search or filters',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Job job) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => JobDetailScreen(job: job),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _showProfileSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(_userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(_userEmail,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: .05)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExpansionTile(
                  leading: const Icon(Icons.manage_accounts_rounded,
                      color: Color(0xFF1565C0)),
                  title: const Text('Account & preferences',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Profile, alerts and privacy',
                      style: TextStyle(fontSize: 12)),
                  children: [
                    _profileMenuTile(Icons.badge_outlined, 'Profile & resume',
                        'Complete your professional profile'),
                    _profileMenuTile(Icons.notifications_none_rounded,
                        'Job alerts', 'Manage alerts and recommendations'),
                    _profileMenuTile(Icons.tune_rounded, 'Search preferences',
                        'Location, salary and work style'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _profileActionTile(Icons.bookmark_outline_rounded, 'Saved jobs',
                  'Your shortlist', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SavedJobsScreen()));
              }),
              const SizedBox(height: 10),
              _profileActionTile(Icons.assignment_rounded, 'Applied jobs',
                  'Track employer approval', () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AppliedJobsScreen()));
              }),
              const SizedBox(height: 10),
              _profileActionTile(Icons.credit_card_rounded, 'Plans & payments',
                  'Manage your JobFinder plan', () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaymentsScreen()));
              }),
              const SizedBox(height: 10),
              _profileActionTile(Icons.help_outline_rounded, 'Help & support',
                  'FAQs and contact support', () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Support centre coming soon.')));
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await AuthService.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileMenuTile(IconData icon, String title, String subtitle) =>
      ListTile(
        dense: true,
        leading: Icon(icon, size: 20),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title will be available soon.')),
        ),
      );

  Widget _profileActionTile(
          IconData icon, String title, String subtitle, VoidCallback onTap) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: .05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: .16)),
            ),
            child: Row(children: [
              Icon(icon, color: const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ])),
              const Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ),
      );

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        selectedType: _selectedType,
        types: _types,
        sortBy: _sortBy,
        maxSalaryLakh: _maxSalaryLakh,
        onTypeSelected: (t) {
          setState(() => _selectedType = t);
          _applyFilters();
        },
        onSortChanged: (s) {
          setState(() => _sortBy = s);
          _applyFilters();
        },
        onSalaryChanged: (v) {
          setState(() => _maxSalaryLakh = v);
          _applyFilters();
        },
        onReset: () {
          setState(() {
            _selectedType = 'All';
            _selectedCategory = 'All';
            _sortBy = 'Distance';
            _maxSalaryLakh = 20;
            _searchController.clear();
          });
          _applyFilters();
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String selectedType;
  final List<String> types;
  final String sortBy;
  final double maxSalaryLakh;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<double> onSalaryChanged;
  final VoidCallback onReset;

  const _FilterSheet({
    required this.selectedType,
    required this.types,
    required this.sortBy,
    required this.maxSalaryLakh,
    required this.onTypeSelected,
    required this.onSortChanged,
    required this.onSalaryChanged,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _type;
  late String _sortBy;
  late double _maxSalary;

  final _sortOptions = ['Distance', 'Rating', 'Salary', 'Newest'];

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _sortBy = widget.sortBy;
    _maxSalary = widget.maxSalaryLakh;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Filter & Sort',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.onReset();
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Reset',
                      style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Sort By',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sortOptions.map((opt) {
              final sel = _sortBy == opt;
              return GestureDetector(
                onTap: () {
                  setState(() => _sortBy = opt);
                  widget.onSortChanged(opt);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0288D1)])
                        : null,
                    color: sel
                        ? null
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(opt,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.grey[600],
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Job Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: widget.types.map((type) {
              final sel = _type == type;
              return GestureDetector(
                onTap: () {
                  setState(() => _type = type);
                  widget.onTypeSelected(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: sel
                        ? const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF0288D1)])
                        : null,
                    color: sel
                        ? null
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1565C0)
                                  .withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(type,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.grey[600],
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Max Salary',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Text(
                _maxSalary >= 20
                    ? 'Any'
                    : '₹${_maxSalary.toStringAsFixed(0)}L/yr',
                style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
          Slider(
            value: _maxSalary,
            min: 2,
            max: 20,
            divisions: 18,
            activeColor: const Color(0xFF1565C0),
            onChanged: (v) {
              setState(() => _maxSalary = v);
              widget.onSalaryChanged(v);
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Show Results',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
