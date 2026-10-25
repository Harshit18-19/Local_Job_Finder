import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job.dart';
import '../models/job_data.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';

class LocalNeedsScreen extends StatefulWidget {
  const LocalNeedsScreen({super.key});

  @override
  State<LocalNeedsScreen> createState() => _LocalNeedsScreenState();
}

class _LocalNeedsScreenState extends State<LocalNeedsScreen> {
  final _locationController = TextEditingController();
  String _category = 'All';
  String _type = 'All';
  String? _selectedNeed;
  final Set<String> _mySkills = {};

  static const _types = ['All', 'Full-time', 'Part-time', 'Contract', 'Remote'];
  static const _profileAreaKey = 'job_seeker_preferred_area';
  static const _profileCategoryKey = 'job_seeker_preferred_category';
  static const _profileTypeKey = 'job_seeker_preferred_type';
  static const _profileSkillsKey = 'job_seeker_skills';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _locationController.text = prefs.getString(_profileAreaKey) ?? '';
      _category = prefs.getString(_profileCategoryKey) ?? 'All';
      _type = prefs.getString(_profileTypeKey) ?? 'All';
      _mySkills.addAll(prefs.getStringList(_profileSkillsKey) ?? const []);
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileAreaKey, _locationController.text.trim());
    await prefs.setString(_profileCategoryKey, _category);
    await prefs.setString(_profileTypeKey, _type);
    await prefs.setStringList(_profileSkillsKey, _mySkills.toList());
  }

  Map<String, int> get _employerNeeds {
    final counts = <String, int>{};
    for (final job in sampleJobs) {
      for (final requirement in job.requirements) {
        counts.update(requirement, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  List<MapEntry<String, int>> get _topNeeds {
    final entries = _employerNeeds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(6).toList();
  }

  List<Job> get _matches {
    final area = _locationController.text.trim().toLowerCase();
    return sampleJobs.where((job) {
      final matchesCategory = _category == 'All' || job.category == _category;
      final matchesType = _type == 'All' || job.type == _type;
      final matchesArea =
          area.isEmpty || job.location.toLowerCase().contains(area);
      final matchesNeed = _selectedNeed == null ||
          job.requirements.any((requirement) =>
              requirement.toLowerCase() == _selectedNeed!.toLowerCase());
      return matchesCategory && matchesType && matchesArea && matchesNeed;
    }).toList()
      ..sort((a, b) {
        final scoreOrder = _skillMatch(b).compareTo(_skillMatch(a));
        return scoreOrder != 0
            ? scoreOrder
            : a.distanceKm.compareTo(b.distanceKm);
      });
  }

  int _skillMatch(Job job) {
    if (_mySkills.isEmpty) return 0;
    final listedRequirements = job.requirements
        .map((requirement) => requirement.toLowerCase())
        .toSet();
    final matchingSkills = _mySkills
        .where((skill) => listedRequirements.contains(skill.toLowerCase()))
        .length;
    return (matchingSkills * 100 / _mySkills.length).round();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matches = _matches;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F7FC),
      appBar: AppBar(title: const Text('Local Hiring Pulse')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _introCard(),
          const SizedBox(height: 22),
          _sectionHeading('What employers need',
              'Common requirements in the current local listings'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topNeeds.map((need) {
              final selected = _selectedNeed == need.key;
              return FilterChip(
                selected: selected,
                label: Text('${need.key} · ${need.value}'),
                onSelected: (_) =>
                    setState(() => _selectedNeed = selected ? null : need.key),
                selectedColor: const Color(0xFF2563EB).withValues(alpha: 0.16),
                checkmarkColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(
                  color: selected ? const Color(0xFF1D4ED8) : null,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                side: BorderSide(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : (isDark ? Colors.white12 : Colors.black12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _sectionHeading('What do you need?',
              'Set your work preferences to find a better fit'),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            onChanged: (_) {
              setState(() {});
              _saveProfile();
            },
            decoration: InputDecoration(
              labelText: 'Preferred area',
              hintText: 'e.g. Delhi, Agra, Karol Bagh',
              prefixIcon: const Icon(Icons.location_on_outlined),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          Text('Role category',
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
            items: [
              'All',
              ...sampleJobs.map((job) => job.category).toSet().toList()..sort(),
            ]
                .map((value) =>
                    DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) {
              setState(() => _category = value ?? 'All');
              _saveProfile();
            },
          ),
          const SizedBox(height: 14),
          Text('Work type',
              style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _types
                .map((type) => ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      onSelected: (_) {
                        setState(() => _type = type);
                        _saveProfile();
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text('Skills you bring',
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              Text('Saved on this device',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Choose requirements you can meet; matching jobs rank first.',
              style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _topNeeds.map((need) {
              final selected = _mySkills.contains(need.key);
              return FilterChip(
                selected: selected,
                label: Text(need.key),
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _mySkills.remove(need.key);
                    } else {
                      _mySkills.add(need.key);
                    }
                  });
                  _saveProfile();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text('Matching opportunities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
              ),
              Text('${matches.length} found',
                  style: const TextStyle(
                      color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
            ],
          ),
          if (matches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 42, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 10),
                  const Text('No roles match these needs yet'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _category = 'All';
                        _type = 'All';
                        _selectedNeed = null;
                        _locationController.clear();
                        _mySkills.clear();
                      });
                      _saveProfile();
                    },
                    child: const Text('Clear preferences'),
                  ),
                ],
              ),
            )
          else
            ...matches.asMap().entries.expand((entry) => [
                  if (_mySkills.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          18, entry.key == 0 ? 12 : 4, 18, 0),
                      child: Text('${_skillMatch(entry.value)}% skills match',
                          style: TextStyle(
                              color: _skillMatch(entry.value) >= 50
                                  ? const Color(0xFF059669)
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  JobCard(
                    job: entry.value,
                    index: entry.key,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => JobDetailScreen(job: entry.value)),
                    ),
                  ),
                ]),
          const SizedBox(height: 8),
          Text(
            'Demand insights use the job listings currently shown in Local Job Finder.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _introCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.groups_rounded, color: Colors.white, size: 28),
            SizedBox(height: 12),
            Text('Connect local needs to local work',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text(
              'See what nearby companies ask for, then match opportunities to your skills, area and schedule.',
              style: TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
            ),
          ],
        ),
      );

  Widget _sectionHeading(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      );
}
