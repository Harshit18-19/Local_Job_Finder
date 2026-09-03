import 'package:shared_preferences/shared_preferences.dart';

class SavedJobsService {
  static const _key = 'saved_job_ids';

  static Future<Set<String>> getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? []).toSet();
  }

  static Future<void> toggle(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? []).toSet();
    if (ids.contains(jobId)) {
      ids.remove(jobId);
    } else {
      ids.add(jobId);
    }
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<bool> isSaved(String jobId) async {
    final ids = await getSavedIds();
    return ids.contains(jobId);
  }
}
