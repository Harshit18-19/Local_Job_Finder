import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppliedJobsService {
  static const _key = 'applied_applications';

  static Future<bool> hasApplied(String jobId) async {
    final applications = await getApplications();
    return applications.any((application) => application['jobId'] == jobId);
  }

  static Future<void> addApplication(Map<String, dynamic> application) async {
    final preferences = await SharedPreferences.getInstance();
    final applications = preferences.getStringList(_key) ?? [];
    applications.add(jsonEncode(application));
    await preferences.setStringList(_key, applications);
  }

  static Future<List<Map<String, dynamic>>> getApplications() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_key) ?? [];
    return stored
        .map((value) => jsonDecode(value) as Map<String, dynamic>)
        .toList();
  }
}
