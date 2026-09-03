import 'package:shared_preferences/shared_preferences.dart';

class AppliedJobsService {
  static const _key = 'applied_job_ids';

  static Future<void> add(String jobId) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = preferences.getStringList(_key) ?? [];
    if (!ids.contains(jobId)) {
      ids.add(jobId);
      await preferences.setStringList(_key, ids);
    }
  }

  static Future<List<String>> getAppliedIds() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_key) ?? [];
  }
}
