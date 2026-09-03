class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String description;
  final List<String> requirements;
  final double distanceKm;
  final String postedDate;
  final String category;
  final double rating;
  final int applicants;
  final int cardColor; // ARGB int for gradient

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.distanceKm,
    required this.postedDate,
    required this.category,
    this.rating = 4.0,
    this.applicants = 0,
    this.cardColor = 0xFF2563EB,
  });
}
