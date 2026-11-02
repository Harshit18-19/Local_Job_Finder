import '../models/job.dart';

class ResumeAtsCategory {
  final String title;
  final int points;
  final int maximum;
  final String detail;
  final String improvement;

  const ResumeAtsCategory({
    required this.title,
    required this.points,
    required this.maximum,
    required this.detail,
    required this.improvement,
  });
}

class ResumeAtsEvaluation {
  final int score;
  final int wordCount;
  final int pageCount;
  final List<ResumeAtsCategory> categories;
  final List<String> missingKeywords;
  final List<String> suggestions;

  const ResumeAtsEvaluation({
    required this.score,
    required this.wordCount,
    required this.pageCount,
    required this.categories,
    required this.missingKeywords,
    required this.suggestions,
  });

  String get level {
    if (score >= 90) return 'Excellent ATS readiness';
    if (score >= 75) return 'Strong, with a few improvements';
    if (score >= 60) return 'Fair, with clear areas to improve';
    return 'Needs focused improvement';
  }
}

/// A transparent, offline checklist. It is not an employer's proprietary ATS.
class ResumeAtsService {
  static const _stopWords = {
    'the',
    'and',
    'for',
    'with',
    'from',
    'your',
    'you',
    'our',
    'their',
    'this',
    'that',
    'are',
    'was',
    'were',
    'will',
    'have',
    'has',
    'had',
    'into',
    'onto',
    'over',
    'under',
    'about',
    'using',
    'use',
    'work',
    'working',
    'ability',
    'able',
    'good',
    'excellent',
    'strong',
    'preferred',
    'required',
    'requirements',
    'requirement',
    'experience',
    'years',
    'year',
    'knowledge',
    'skills',
    'skill',
    'proficiency',
    'proficient',
    'plus',
    'basic',
    'advanced',
    'familiarity',
    'understanding',
    'degree',
    'related',
    'field',
    'role',
    'team',
    'candidate',
    'candidates',
    'including',
    'such',
    'they',
    'them',
    'across',
    'within',
    'also',
  };

  static const _actionVerbs = {
    'achieved',
    'built',
    'created',
    'delivered',
    'designed',
    'developed',
    'improved',
    'increased',
    'launched',
    'led',
    'managed',
    'organized',
    'reduced',
    'resolved',
    'saved',
    'streamlined',
    'supported',
    'implemented',
    'automated',
    'coordinated',
    'optimized',
    'trained',
    'grew',
    'won',
  };

  static ResumeAtsEvaluation evaluate({
    required String resumeText,
    required int pageCount,
    required Job targetJob,
  }) {
    final normalized = resumeText.replaceAll('\r', '\n');
    final lower = normalized.toLowerCase();
    final words = RegExp(r"[a-zA-Z0-9+#.']+")
        .allMatches(normalized)
        .map((match) => match.group(0)!)
        .toList();
    final wordCount = words.length;

    // Scale this continuously so resumes near a threshold do not all receive
    // the same points for noticeably different amounts of readable content.
    final readablePoints = (wordCount * 15 / 450).round().clamp(0, 15).toInt();

    final hasEmail = RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+')
        .hasMatch(normalized);
    final hasPhone = RegExp(r'(?<!\d)(?:\+?\d[\d\s().-]{7,}\d)(?!\d)')
        .hasMatch(normalized);
    final hasProfileLink = RegExp(
      r'(linkedin\.com|github\.com|portfolio|behance\.net|dribbble\.com)',
      caseSensitive: false,
    ).hasMatch(normalized);
    final contactPoints =
        (hasEmail ? 7 : 0) + (hasPhone ? 6 : 0) + (hasProfileLink ? 2 : 0);

    final hasExperience = _containsAny(lower, [
      'experience',
      'employment history',
      'work history',
      'professional background',
    ]);
    final hasSkills = _containsAny(lower, [
      'skills',
      'technical stack',
      'competencies',
    ]);
    final hasEducation = _containsAny(lower, [
      'education',
      'academic background',
    ]);
    final hasSummary = _containsAny(lower, [
      'summary',
      'professional profile',
      'career objective',
      'about me',
    ]);
    final sectionPoints =
        (hasExperience ? 8 : 0) +
        (hasSkills ? 5 : 0) +
        (hasEducation ? 4 : 0) +
        (hasSummary ? 3 : 0);
    final sectionsFound = [
      hasExperience,
      hasSkills,
      hasEducation,
      hasSummary,
    ].where((found) => found).length;

    final targetTerms = _terms(
      '${targetJob.title} ${targetJob.requirements.join(' ')}',
    );
    final matchedTerms = targetTerms
        .where((term) => _containsTerm(lower, term))
        .toSet();
    final missingKeywords = targetTerms.difference(matchedTerms).toList()
      ..sort();
    final keywordPoints = targetTerms.isEmpty
        ? 0
        : (25 * matchedTerms.length / targetTerms.length).round();

    final metricCount = RegExp(
      r'\b\d+(?:[.,]\d+)?\s?(?:%|percent|x|k|million|billion|users?|customers?|clients?|projects?|employees?|members?|orders?|₹|\$|rs\.?|lakh|crore|hours?|days?|weeks?|months?)\b',
      caseSensitive: false,
    ).allMatches(normalized).length;
    final actionVerbCount = _actionVerbs
        .where((verb) => _containsTerm(lower, verb))
        .length;
    final metricPoints = (metricCount.clamp(0, 5) * 7 / 5).round();
    final actionPoints = (actionVerbCount.clamp(0, 5) * 8 / 5).round();
    final impactPoints = metricPoints + actionPoints;

    final layoutPoints = pageCount <= 2
        ? 10
        : pageCount <= 3
        ? 8
        : pageCount <= 4
        ? 6
        : 3;

    final categories = [
      ResumeAtsCategory(
        title: 'Readable resume text',
        points: readablePoints,
        maximum: 15,
        detail: '$wordCount words were extracted from the PDF.',
        improvement: wordCount < 300
            ? 'Add relevant detail about your work, projects and results. Keep every line useful.'
            : 'Keep the content concise and easy to scan.',
      ),
      ResumeAtsCategory(
        title: 'Contact details',
        points: contactPoints,
        maximum: 15,
        detail:
            [
              if (hasEmail) 'email',
              if (hasPhone) 'phone',
              if (hasProfileLink) 'professional link',
            ].isEmpty
            ? 'No common contact details were detected.'
            : 'Detected: ${[if (hasEmail) 'email', if (hasPhone) 'phone', if (hasProfileLink) 'professional link'].join(', ')}.',
        improvement: 'Put a professional email and phone number near the top. Add LinkedIn or a portfolio link if relevant.',
      ),
      ResumeAtsCategory(
        title: 'Standard sections',
        points: sectionPoints,
        maximum: 20,
        detail: '$sectionsFound of 4 common section headings were found.',
        improvement: 'Use clear headings such as Summary, Experience, Skills and Education.',
      ),
      ResumeAtsCategory(
        title: 'Match to ${targetJob.title}',
        points: keywordPoints,
        maximum: 25,
        detail:
            '${matchedTerms.length} of ${targetTerms.length} useful job terms appear in the resume.',
        improvement: missingKeywords.isEmpty
            ? 'Keep tailoring your resume to this role.'
            : 'If accurate, include relevant terms such as ${missingKeywords.take(5).join(', ')} in your skills or experience.',
      ),
      ResumeAtsCategory(
        title: 'Action verbs and results',
        points: impactPoints,
        maximum: 15,
        detail:
            '$actionVerbCount action verbs and $metricCount measurable result(s) were detected.',
        improvement: 'Start bullets with clear action verbs and add real numbers that show impact. Never invent results.',
      ),
      ResumeAtsCategory(
        title: 'Resume length',
        points: layoutPoints,
        maximum: 10,
        detail: '$pageCount page(s). Page count is a guideline, not a rule.',
        improvement: 'Keep early-career resumes focused, often 1–2 pages. Longer resumes can fit extensive experience.',
      ),
    ];
    final score = categories.fold<int>(0, (sum, item) => sum + item.points);
    final suggestions = <String>[
      if (!hasSummary)
        'Add a 2–3 line summary tailored to ${targetJob.title}. Example structure: “${targetJob.title} with experience in [relevant skills]. Delivered [real result] by [what you did].” Replace every bracket with details that are true for you.',
      if (!hasExperience) 'Add a clearly titled Experience section. For each role or project, include your title, organization, dates, and 2–4 concise achievement bullets.',
      if (!hasSkills) 'Add a Skills section and list the tools, methods, and job skills you can actually use.',
      if (missingKeywords.isNotEmpty)
        'Compare the job description with your experience. Add relevant terms where they accurately describe your work: ${missingKeywords.take(8).join(', ')}.',
      if (metricCount == 0 || actionVerbCount < 2) 'Strengthen experience bullets with action + task + real outcome. Example: “Improved [process] by [X%] using [tool], helping [team/customer] achieve [result].” Do not guess or invent numbers.',
      if (!hasEmail || !hasPhone)
        'Put a selectable-text email and phone number near the top of the resume${!hasEmail && !hasPhone
            ? '.'
            : !hasEmail
            ? ' and add your email.'
            : ' and add your phone number.'}',
      if (!hasEducation) 'Add an Education section with your qualification, institution, and graduation year if relevant to the role.',
      if (wordCount < 300) 'Add useful detail about relevant responsibilities, projects, tools, and outcomes. Avoid filler; include only information that supports this application.',
      if (pageCount > 2) 'Review whether older or unrelated details can be shortened so the most relevant experience is easy to find.',
      if (score >= 90 && missingKeywords.isEmpty) 'Your checklist is already strong for this role. Review the job description once more and keep only accurate, relevant details.',
    ];
    if (suggestions.isEmpty) {
      suggestions.add(
        'Your resume covers the main checklist items. Tailor your strongest experience bullets to this job and keep every claim accurate.',
      );
    }

    return ResumeAtsEvaluation(
      score: score.clamp(0, 100).toInt(),
      wordCount: wordCount,
      pageCount: pageCount,
      categories: categories,
      missingKeywords: missingKeywords,
      suggestions: suggestions,
    );
  }

  static bool _containsAny(String text, List<String> terms) =>
      terms.any((term) => text.contains(term));

  static bool _containsTerm(String text, String term) {
    if (!RegExp(r'^[a-z0-9]+$').hasMatch(term)) {
      return text.contains(term);
    }
    return RegExp(
      '\\b${RegExp.escape(term)}\\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  static Set<String> _terms(String input) =>
      RegExp(r'[a-zA-Z][a-zA-Z0-9+#.]*')
          .allMatches(input.toLowerCase())
          .map((match) => match.group(0)!)
          .where((term) => term.length > 2 && !_stopWords.contains(term))
          .toSet();
}
