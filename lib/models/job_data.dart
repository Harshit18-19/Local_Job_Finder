import 'job.dart';

final List<Job> sampleJobs = [..._curatedJobs, ..._generatedCategoryJobs()];

final List<Job> _curatedJobs = [
  const Job(
    id: '1',
    title: 'Flutter Developer',
    company: 'TechCorp Solutions',
    location: 'Connaught Place, Delhi',
    type: 'Full-time',
    salary: '₹6,50,000 - ₹8,50,000/yr',
    description:
        'We are looking for an experienced Flutter developer to build cross-platform mobile applications. You will work closely with our design and backend teams to deliver high-quality apps.',
    requirements: [
      '2+ years Flutter experience',
      'Strong Dart knowledge',
      'REST API integration',
      'Git version control',
    ],
    distanceKm: 1.2,
    postedDate: '2 days ago',
    category: 'Technology',
    rating: 4.8,
    applicants: 34,
    cardColor: 0xFF2563EB,
  ),
  const Job(
    id: '2',
    title: 'Barista',
    company: 'Morning Brew Café',
    location: 'Karol Bagh, Delhi',
    type: 'Part-time',
    salary: '₹180 - ₹220/hr',
    description:
        'Join our friendly team at Morning Brew Café. You will prepare beverages, serve customers, and maintain a clean workspace.',
    requirements: [
      'Customer service skills',
      'Coffee experience preferred',
      'Flexible schedule',
    ],
    distanceKm: 0.8,
    postedDate: '1 day ago',
    category: 'Food & Beverage',
    rating: 4.5,
    applicants: 12,
    cardColor: 0xFFD97706,
  ),
  const Job(
    id: '3',
    title: 'Delivery Driver',
    company: 'QuickShip Logistics',
    location: 'Mathura Road, Agra',
    type: 'Contract',
    salary: '₹200 - ₹250/hr',
    description:
        'Drive and deliver packages to customers in your local area. Flexible hours and competitive pay.',
    requirements: [
      'Valid driver\'s license',
      'Clean driving record',
      'Smartphone required',
    ],
    distanceKm: 2.5,
    postedDate: '3 days ago',
    category: 'Logistics',
    rating: 4.2,
    applicants: 8,
    cardColor: 0xFF059669,
  ),
  const Job(
    id: '4',
    title: 'Graphic Designer',
    company: 'Creative Studio NYC',
    location: 'Lajpat Nagar, Delhi',
    type: 'Full-time',
    salary: '₹4,50,000 - ₹5,80,000/yr',
    description:
        'Create stunning visual content for our clients across print and digital media.',
    requirements: [
      'Adobe Creative Suite',
      'Portfolio required',
      '3+ years experience',
      'UI/UX knowledge a plus',
    ],
    distanceKm: 1.9,
    postedDate: '5 days ago',
    category: 'Design',
    rating: 4.6,
    applicants: 21,
    cardColor: 0xFFDB2777,
  ),
  const Job(
    id: '5',
    title: 'Retail Sales Associate',
    company: 'Urban Outfitters',
    location: 'Vrindavan, Mathura',
    type: 'Part-time',
    salary: '₹160 - ₹190/hr',
    description:
        'Assist customers, manage inventory, and maintain store appearance in a fast-paced retail environment.',
    requirements: [
      'Sales experience preferred',
      'Friendly attitude',
      'Weekend availability',
    ],
    distanceKm: 3.1,
    postedDate: '1 week ago',
    category: 'Retail',
    rating: 4.1,
    applicants: 45,
    cardColor: 0xFF7C3AED,
  ),
  const Job(
    id: '6',
    title: 'Data Analyst',
    company: 'FinanceHub Inc.',
    location: 'Nehru Place, Delhi',
    type: 'Full-time',
    salary: '₹7,50,000 - ₹9,20,000/yr',
    description:
        'Analyze financial data, build dashboards, and provide actionable insights to stakeholders.',
    requirements: [
      'Python or R proficiency',
      'SQL expertise',
      'Excel advanced skills',
      'Finance background preferred',
    ],
    distanceKm: 4.0,
    postedDate: '4 days ago',
    category: 'Finance',
    rating: 4.9,
    applicants: 57,
    cardColor: 0xFF0891B2,
  ),
  const Job(
    id: '7',
    title: 'Node.js Backend Developer',
    company: 'CloudBase Technologies',
    location: 'Dwarka, Delhi',
    type: 'Full-time',
    salary: '₹7,00,000 - ₹9,00,000/yr',
    description:
        'Build and maintain scalable REST APIs and microservices using Node.js and Express.',
    requirements: [
      'Node.js & Express',
      'MongoDB/PostgreSQL',
      'Docker basics',
      'REST API design'
    ],
    distanceKm: 2.1,
    postedDate: '2 days ago',
    category: 'Technology',
    rating: 4.7,
    applicants: 29,
    cardColor: 0xFF16A34A,
  ),
  const Job(
    id: '8',
    title: 'Electrician',
    company: 'Bright Spark Services',
    location: 'Taj Nagri, Agra',
    type: 'Full-time',
    salary: '₹350 - ₹450/hr',
    description:
        'Install, maintain, and repair electrical systems in residential and commercial buildings.',
    requirements: [
      'Licensed electrician',
      '3+ years experience',
      'Safety compliance knowledge'
    ],
    distanceKm: 5.3,
    postedDate: '3 days ago',
    category: 'Trades',
    rating: 4.4,
    applicants: 10,
    cardColor: 0xFFF59E0B,
  ),
  const Job(
    id: '9',
    title: 'Nurse (RN)',
    company: 'City General Hospital',
    location: 'Rohini, Delhi',
    type: 'Full-time',
    salary: '₹8,00,000 - ₹10,50,000/yr',
    description:
        'Provide patient care, administer medications, and coordinate with medical staff in a busy hospital ward.',
    requirements: [
      'RN license',
      'BLS/ACLS certified',
      '2+ years clinical experience'
    ],
    distanceKm: 3.7,
    postedDate: '1 day ago',
    category: 'Healthcare',
    rating: 4.8,
    applicants: 18,
    cardColor: 0xFFDC2626,
  ),
  const Job(
    id: '10',
    title: 'Content Writer',
    company: 'MediaPulse Agency',
    location: 'Mathura City, Mathura',
    type: 'Remote',
    salary: '₹3,00,000 - ₹4,50,000/yr',
    description:
        'Write engaging blog posts, articles, and social media content for diverse clients.',
    requirements: [
      'Excellent English writing',
      'SEO knowledge',
      'Portfolio required'
    ],
    distanceKm: 1.5,
    postedDate: '6 days ago',
    category: 'Media',
    rating: 4.3,
    applicants: 38,
    cardColor: 0xFF9333EA,
  ),
  const Job(
    id: '11',
    title: 'Plumber',
    company: 'FlowFix Plumbing',
    location: 'Sikandra, Agra',
    type: 'Contract',
    salary: '₹300 - ₹400/hr',
    description:
        'Handle plumbing installations, repairs, and emergency call-outs for residential clients.',
    requirements: ['Licensed plumber', 'Own tools', 'Reliable transport'],
    distanceKm: 6.2,
    postedDate: '4 days ago',
    category: 'Trades',
    rating: 4.2,
    applicants: 7,
    cardColor: 0xFF0369A1,
  ),
  const Job(
    id: '12',
    title: 'UI/UX Designer',
    company: 'PixelCraft Studio',
    location: 'Saket, Delhi',
    type: 'Full-time',
    salary: '₹5,50,000 - ₹7,00,000/yr',
    description:
        'Design intuitive user interfaces and experiences for web and mobile products.',
    requirements: [
      'Figma proficiency',
      'User research skills',
      'Portfolio required',
      '2+ years experience'
    ],
    distanceKm: 2.8,
    postedDate: '1 week ago',
    category: 'Design',
    rating: 4.6,
    applicants: 42,
    cardColor: 0xFFE11D48,
  ),
  const Job(
    id: '13',
    title: 'Accountant',
    company: 'PrecisionBooks LLC',
    location: 'Janakpuri, Delhi',
    type: 'Full-time',
    salary: '₹6,00,000 - ₹7,80,000/yr',
    description:
        'Manage financial records, prepare tax filings, and support audits for small business clients.',
    requirements: [
      'CPA preferred',
      'QuickBooks expertise',
      'Attention to detail',
      'Excel advanced'
    ],
    distanceKm: 3.9,
    postedDate: '5 days ago',
    category: 'Finance',
    rating: 4.5,
    applicants: 23,
    cardColor: 0xFF065F46,
  ),
  const Job(
    id: '14',
    title: 'Warehouse Associate',
    company: 'SwiftStore Warehousing',
    location: 'Bodla, Agra',
    type: 'Part-time',
    salary: '₹170 - ₹210/hr',
    description:
        'Pick, pack, and ship orders in a fast-paced warehouse environment.',
    requirements: [
      'Physical fitness',
      'Forklift license a plus',
      'Punctuality'
    ],
    distanceKm: 8.4,
    postedDate: '2 days ago',
    category: 'Logistics',
    rating: 4.0,
    applicants: 15,
    cardColor: 0xFF92400E,
  ),
  const Job(
    id: '15',
    title: 'High School Math Teacher',
    company: 'Greenfield Academy',
    location: 'Govindpuri, Mathura',
    type: 'Full-time',
    salary: '₹5,00,000 - ₹6,50,000/yr',
    description:
        'Teach algebra, geometry, and calculus to grades 9–12 in a supportive school environment.',
    requirements: [
      'Teaching certification',
      'Math degree',
      'Classroom management skills'
    ],
    distanceKm: 4.5,
    postedDate: '1 week ago',
    category: 'Education',
    rating: 4.7,
    applicants: 19,
    cardColor: 0xFF1D4ED8,
  ),
  const Job(
    id: '16',
    title: 'Chef de Partie',
    company: 'The Grand Bistro',
    location: 'Fatehabad Road, Agra',
    type: 'Full-time',
    salary: '₹280 - ₹350/hr',
    description:
        'Lead a section of the kitchen, prepare dishes to high standards, and mentor junior cooks.',
    requirements: [
      'Culinary degree or equivalent',
      '3+ years kitchen experience',
      'Team leadership'
    ],
    distanceKm: 2.3,
    postedDate: '3 days ago',
    category: 'Food & Beverage',
    rating: 4.5,
    applicants: 11,
    cardColor: 0xFFB45309,
  ),
  const Job(
    id: '17',
    title: 'Cybersecurity Analyst',
    company: 'SecureNet Corp',
    location: 'Cyber City, Delhi',
    type: 'Full-time',
    salary: '₹9,00,000 - ₹12,00,000/yr',
    description:
        'Monitor networks, respond to incidents, and implement security policies to protect company assets.',
    requirements: [
      'CEH or CISSP preferred',
      'SIEM tools experience',
      'Incident response skills'
    ],
    distanceKm: 2.0,
    postedDate: '2 days ago',
    category: 'Technology',
    rating: 4.9,
    applicants: 31,
    cardColor: 0xFF1E3A5F,
  ),
  const Job(
    id: '18',
    title: 'Personal Trainer',
    company: 'FitLife Gym',
    location: 'Rajpur Road, Delhi',
    type: 'Part-time',
    salary: '₹250 - ₹350/hr',
    description:
        'Design and deliver personalised fitness programmes for gym members of all fitness levels.',
    requirements: [
      'ACE/NASM certification',
      'CPR certified',
      'Motivational skills'
    ],
    distanceKm: 1.8,
    postedDate: '4 days ago',
    category: 'Health & Fitness',
    rating: 4.6,
    applicants: 9,
    cardColor: 0xFF0F766E,
  ),
  const Job(
    id: '19',
    title: 'Social Media Manager',
    company: 'BrandBoost Agency',
    location: 'Vrindavan Road, Mathura',
    type: 'Remote',
    salary: '₹4,00,000 - ₹5,50,000/yr',
    description:
        'Manage brand social channels, create content calendars, and grow engagement across platforms.',
    requirements: [
      '2+ years social media experience',
      'Canva/Photoshop skills',
      'Analytics proficiency'
    ],
    distanceKm: 1.4,
    postedDate: '5 days ago',
    category: 'Media',
    rating: 4.4,
    applicants: 52,
    cardColor: 0xFF7E22CE,
  ),
  const Job(
    id: '20',
    title: 'Civil Engineer',
    company: 'UrbanBuild Consultants',
    location: 'Yamuna Expressway, Agra',
    type: 'Full-time',
    salary: '₹8,50,000 - ₹11,00,000/yr',
    description:
        'Design and oversee construction of infrastructure projects including roads, bridges, and drainage systems.',
    requirements: [
      'PE license preferred',
      'AutoCAD proficiency',
      '4+ years experience'
    ],
    distanceKm: 5.0,
    postedDate: '1 week ago',
    category: 'Engineering',
    rating: 4.7,
    applicants: 14,
    cardColor: 0xFF374151,
  ),
  const Job(
    id: '21',
    title: 'Receptionist',
    company: 'Prestige Law Firm',
    location: 'Pitampura, Delhi',
    type: 'Full-time',
    salary: '₹2,80,000 - ₹3,50,000/yr',
    description:
        'Greet clients, manage appointments, handle calls, and provide administrative support.',
    requirements: [
      'Professional communication',
      'MS Office proficiency',
      'Multitasking ability'
    ],
    distanceKm: 2.2,
    postedDate: '3 days ago',
    category: 'Administration',
    rating: 4.3,
    applicants: 27,
    cardColor: 0xFF475569,
  ),
  const Job(
    id: '22',
    title: 'Machine Learning Engineer',
    company: 'AI Ventures Lab',
    location: 'Noida Sector 62, Delhi NCR',
    type: 'Full-time',
    salary: '₹12,00,000 - ₹16,00,000/yr',
    description:
        'Develop and deploy ML models for NLP and computer vision products used by millions.',
    requirements: [
      'Python & TensorFlow/PyTorch',
      'MLOps experience',
      'Strong math background'
    ],
    distanceKm: 3.3,
    postedDate: '1 day ago',
    category: 'Technology',
    rating: 4.9,
    applicants: 63,
    cardColor: 0xFF4F46E5,
  ),
  const Job(
    id: '23',
    title: 'Carpenter',
    company: 'WoodCraft Interiors',
    location: 'Kamla Nagar, Agra',
    type: 'Contract',
    salary: '₹320 - ₹420/hr',
    description:
        'Fabricate and install custom furniture, cabinetry, and wooden fixtures for residential projects.',
    requirements: [
      '5+ years carpentry experience',
      'Own tools',
      'Blueprint reading'
    ],
    distanceKm: 6.8,
    postedDate: '6 days ago',
    category: 'Trades',
    rating: 4.3,
    applicants: 6,
    cardColor: 0xFF78350F,
  ),
  const Job(
    id: '24',
    title: 'Pharmacist',
    company: 'MediCare Pharmacy',
    location: 'Dampier Nagar, Mathura',
    type: 'Full-time',
    salary: '₹9,50,000 - ₹12,50,000/yr',
    description:
        'Dispense medications, counsel patients, and ensure compliance with pharmacy regulations.',
    requirements: [
      'PharmD degree',
      'NY pharmacist license',
      'Attention to detail'
    ],
    distanceKm: 7.1,
    postedDate: '4 days ago',
    category: 'Healthcare',
    rating: 4.8,
    applicants: 16,
    cardColor: 0xFF0C4A6E,
  ),
  const Job(
    id: '25',
    title: 'Event Coordinator',
    company: 'Stellar Events NYC',
    location: 'Vasant Kunj, Delhi',
    type: 'Full-time',
    salary: '₹4,20,000 - ₹5,80,000/yr',
    description:
        'Plan and execute corporate and social events from concept to completion.',
    requirements: [
      'Event planning experience',
      'Vendor management',
      'Strong organisational skills'
    ],
    distanceKm: 2.6,
    postedDate: '1 week ago',
    category: 'Hospitality',
    rating: 4.5,
    applicants: 33,
    cardColor: 0xFFBE185D,
  ),
  const Job(
    id: '26',
    title: 'Security Guard',
    company: 'ShieldForce Security',
    location: 'Sanjay Place, Agra',
    type: 'Part-time',
    salary: '₹190 - ₹230/hr',
    description:
        'Monitor premises, control access, and respond to security incidents at a commercial building.',
    requirements: [
      'Security license',
      'Physical fitness',
      'Night shift availability'
    ],
    distanceKm: 4.1,
    postedDate: '2 days ago',
    category: 'Security',
    rating: 4.1,
    applicants: 20,
    cardColor: 0xFF1F2937,
  ),
];

List<Job> _generatedCategoryJobs() {
  const categories = [
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
  const titles = {
    'Technology': 'Software Engineer',
    'Food & Beverage': 'Restaurant Associate',
    'Logistics': 'Operations Coordinator',
    'Design': 'Creative Designer',
    'Retail': 'Store Advisor',
    'Finance': 'Financial Associate',
    'Healthcare': 'Care Specialist',
    'Education': 'Learning Facilitator',
    'Media': 'Digital Content Specialist',
    'Trades': 'Service Technician',
    'Engineering': 'Project Engineer',
    'Administration': 'Office Coordinator',
    'Hospitality': 'Guest Experience Associate',
    'Security': 'Safety Officer',
    'Health & Fitness': 'Wellness Coach',
  };
  const companies = [
    'Nexa Works',
    'Urban Circle',
    'BrightPath Group',
    'LocalLeaf Services',
    'Momentum India',
    'Northstar Collective',
    'Everyday Partners',
    'Vista Hub',
  ];
  const locations = [
    'Saket, Delhi',
    'Indirapuram, Ghaziabad',
    'Sector 18, Noida',
    'Civil Lines, Agra',
    'Govardhan Road, Mathura',
    'Dwarka, Delhi',
    'Gurugram Sector 44, Delhi NCR',
    'Rohini, Delhi',
  ];
  const colors = [
    0xFF2563EB,
    0xFF059669,
    0xFF7C3AED,
    0xFFDB2777,
    0xFFF59E0B,
    0xFF0891B2,
    0xFFDC2626,
    0xFF4F46E5,
  ];
  const types = ['Full-time', 'Part-time', 'Contract', 'Remote'];

  return List.generate(categories.length * 20, (index) {
    final categoryIndex = index ~/ 20;
    final number = index % 20 + 1;
    final category = categories[categoryIndex];
    final seed = categoryIndex * 7 + number;
    final type = types[seed % types.length];
    return Job(
      id: 'generated-$categoryIndex-$number',
      title: '${titles[category]} ${number > 1 ? '($number)' : ''}',
      company: '${companies[seed % companies.length]} ${categoryIndex + 1}',
      location: locations[seed % locations.length],
      type: type,
      salary: type == 'Part-time' || type == 'Contract'
          ? '₹${180 + (seed % 9) * 20} - ₹${220 + (seed % 9) * 20}/hr'
          : '₹${4 + (seed % 8)},${20 + (seed % 6) * 10},000 - ₹${6 + (seed % 9)},${10 + (seed % 7) * 10},000/yr',
      description:
          'Join a growing local team as a $category professional. Build useful skills, make an impact in your community, and work with supportive colleagues.',
      requirements: [
        'Relevant $category experience preferred',
        'Strong communication skills',
        'A reliable, customer-first approach',
      ],
      distanceKm: 0.6 + (seed % 90) / 10,
      postedDate: number <= 4
          ? '$number day${number == 1 ? '' : 's'} ago'
          : '${number - 3} days ago',
      category: category,
      rating: 4.0 + (seed % 10) / 10,
      applicants: 5 + (seed * 3) % 74,
      cardColor: colors[seed % colors.length],
    );
  });
}
