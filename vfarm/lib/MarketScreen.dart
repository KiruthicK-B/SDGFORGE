import 'package:flutter/material.dart';
import 'package:vfarm/BookingService.dart';
import 'package:vfarm/home.dart';
import 'package:vfarm/markets/Buy_products.dart';
import 'package:vfarm/markets/Sell_produce.dart';
import 'package:vfarm/markets/price_trends.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  bool _showConsultationDropdown = false;

  @override
  Widget build(BuildContext context) {
    return MainWrapper(
      currentRoute: '/markets',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.storefront, size: 48, color: Color(0xFF0A9D88)),
                  SizedBox(height: 8),
                  Text(
                    "Agricultural Marketplace",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Buy, sell, and get expert advice",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Marketplace",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMarketplaceSection(context),
            const SizedBox(height: 24),
            const Text(
              "Expert Consultation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildExpertConsultationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplaceSection(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildMarketCard(
          context,
          title: "Buy Products",
          icon: Icons.shopping_cart,
          description: "Purchase seeds, fertilizers, tools, and more",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuyProducts()),
            );
          },
        ),
        _buildMarketCard(
          context,
          title: "Sell Produce",
          icon: Icons.sell,
          description: "List your crops and farm products for sale",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SellProduce()),
            );
          },
        ),
        _buildMarketCard(
          context,
          title: "Equipment Rental",
          icon: Icons.agriculture,
          description: "Rent farming equipment and machinery",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookServiceScreen()),
            );
          },
        ),
        _buildMarketCard(
          context,
          title: "Price Trends",
          icon: Icons.trending_up,
          description: "Check current market prices and trends",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PriceTrends()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpertConsultationSection(BuildContext context) {
    return Column(
      children: [
        _buildConsultationCard(
          context,
          title: "Crop Consultation",
          icon: Icons.grass,
          description:
              "Get expert advice on crop selection, disease management, and yield optimization",
          onTap: () {
            setState(() {
              _showConsultationDropdown = !_showConsultationDropdown;
            });
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showConsultationDropdown ? null : 0,
          child:
              _showConsultationDropdown
                  ? Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: _buildConsultationDropdown(context),
                  )
                  : const SizedBox(),
        ),
        const SizedBox(height: 16),
       
      ],
    );
  }

  Widget _buildConsultationDropdown(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpertListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_search, color: Colors.white),
                  label: const Text(
                    "Browse Experts",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A9D88),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecentConsultationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history, color: Color(0xFF0A9D88)),
                  label: const Text(
                    "History",
                    style: TextStyle(color: Color(0xFF0A9D88)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF0A9D88)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A9D88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: const Color(0xFF0A9D88)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                title == "Crop Consultation"
                    ? (_showConsultationDropdown
                        ? Icons.expand_less
                        : Icons.expand_more)
                    : Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationDialog(BuildContext context, String consultationType) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Request $consultationType"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Describe your requirement",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "$consultationType request submitted. Our expert will contact you soon.",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9D88),
                ),
                child: const Text("SUBMIT"),
              ),
            ],
          ),
    );
  }
}

// Expert Model
class Expert {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int consultationCount;
  final double price;
  final String location;
  final String profileImage;
  final List<String> expertise;
  final String description;
  final bool isAvailable;

  Expert({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.consultationCount,
    required this.price,
    required this.location,
    required this.profileImage,
    required this.expertise,
    required this.description,
    required this.isAvailable,
  });
}

// Expert List Screen
class ExpertListScreen extends StatefulWidget {
  const ExpertListScreen({super.key});

  @override
  State<ExpertListScreen> createState() => _ExpertListScreenState();
}

class _ExpertListScreenState extends State<ExpertListScreen> {
  List<Expert> experts = [
    Expert(
      id: '1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'Crop Disease Management',
      experience: '15 years',
      rating: 4.8,
      consultationCount: 250,
      price: 500.0,
      location: 'Bangalore, Karnataka',
      profileImage: 'vfarm-logo.png',
      expertise: ['Disease Management', 'Pest Control', 'Organic Farming'],
      description:
          'Experienced agricultural scientist specializing in crop diseases and sustainable farming practices.',
      isAvailable: true,
    ),
    Expert(
      id: '2',
      name: 'Prof. Priya Sharma',
      specialization: 'Soil Health & Nutrition',
      experience: '12 years',
      rating: 4.9,
      consultationCount: 180,
      price: 600.0,
      location: 'Mysore, Karnataka',
      profileImage: 'https://via.placeholder.com/100',
      expertise: ['Soil Testing', 'Nutrient Management', 'Fertilizer Planning'],
      description:
          'Soil science expert with extensive knowledge in soil health assessment and crop nutrition.',
      isAvailable: true,
    ),
    Expert(
      id: '3',
      name: 'Mr. Suresh Patil',
      specialization: 'Crop Selection & Planning',
      experience: '20 years',
      rating: 4.7,
      consultationCount: 320,
      price: 400.0,
      location: 'Hubli, Karnataka',
      profileImage: 'https://via.placeholder.com/100',
      expertise: ['Crop Rotation', 'Yield Optimization', 'Market Analysis'],
      description:
          'Veteran farmer turned consultant with practical experience in crop planning and yield maximization.',
      isAvailable: false,
    ),
  ];

  List<Expert> filteredExperts = [];
  String selectedSpecialization = 'All';
  String selectedLocation = 'All';
  double maxPrice = 1000.0;
  bool availableOnly = false;

  @override
  void initState() {
    super.initState();
    filteredExperts = experts;
  }

  void _applyFilters() {
    setState(() {
      filteredExperts =
          experts.where((expert) {
            bool matchesSpecialization =
                selectedSpecialization == 'All' ||
                expert.specialization.contains(selectedSpecialization);
            bool matchesLocation =
                selectedLocation == 'All' ||
                expert.location.contains(selectedLocation);
            bool matchesPrice = expert.price <= maxPrice;
            bool matchesAvailability = !availableOnly || expert.isAvailable;

            return matchesSpecialization &&
                matchesLocation &&
                matchesPrice &&
                matchesAvailability;
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Experts'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${filteredExperts.length} experts found'),
                TextButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.tune),
                  label: const Text('Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredExperts.length,
              itemBuilder: (context, index) {
                return _buildExpertCard(filteredExperts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Expert expert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(expert.profileImage),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expert.specialization,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            ' ${expert.rating} (${expert.consultationCount})',
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  expert.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              expert.isAvailable ? 'Available' : 'Busy',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expert.price}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A9D88),
                      ),
                    ),
                    const Text(
                      'per consultation',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(expert.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                Text(
                  ' ${expert.location}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  expert.expertise
                      .map(
                        (skill) => Chip(
                          label: Text(
                            skill,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: const Color(
                            0xFF0A9D88,
                          ).withOpacity(0.1),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showExpertDetails(expert),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        expert.isAvailable
                            ? () => _bookConsultation(expert)
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A9D88),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Filter Experts'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Specialization:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedSpecialization,
                          isExpanded: true,
                          items:
                              [
                                'All',
                                'Disease Management',
                                'Soil Health',
                                'Crop Selection',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSpecialization = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Location:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: selectedLocation,
                          isExpanded: true,
                          items:
                              ['All', 'Bangalore', 'Mysore', 'Hubli'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedLocation = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Max Price:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: maxPrice,
                          min: 100.0,
                          max: 1000.0,
                          divisions: 18,
                          label: '₹${maxPrice.round()}',
                          onChanged: (value) {
                            setDialogState(() {
                              maxPrice = value;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Available only'),
                          value: availableOnly,
                          onChanged: (value) {
                            setDialogState(() {
                              availableOnly = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A9D88),
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showExpertDetails(Expert expert) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(expert.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Specialization: ${expert.specialization}'),
                  Text('Experience: ${expert.experience}'),
                  Text('Location: ${expert.location}'),
                  const SizedBox(height: 8),
                  Text(
                    'About:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(expert.description),
                  const SizedBox(height: 8),
                  Text(
                    'Expertise:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 4,
                    children:
                        expert.expertise
                            .map(
                              (skill) => Chip(
                                label: Text(
                                  skill,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: const Color(
                                  0xFF0A9D88,
                                ).withOpacity(0.1),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
              if (expert.isAvailable)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _bookConsultation(expert);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A9D88),
                  ),
                  child: const Text(
                    'BOOK NOW',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
    );
  }

  void _bookConsultation(Expert expert) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(expert: expert)),
    );
  }
}

// Payment Screen
class PaymentScreen extends StatefulWidget {
  final Expert expert;

  const PaymentScreen({super.key, required this.expert});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'UPI';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _problemController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Consultation'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpertSummary(),
              const SizedBox(height: 24),
              _buildConsultationDetails(),
              const SizedBox(height: 24),
              _buildScheduling(),
              const SizedBox(height: 24),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              _buildPriceBreakdown(),
              const SizedBox(height: 32),
              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpertSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(widget.expert.profileImage),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.expert.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.expert.specialization),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        ' ${widget.expert.rating} (${widget.expert.consultationCount})',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '₹${widget.expert.price}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A9D88),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _problemController,
              decoration: const InputDecoration(
                labelText: 'Describe your problem *',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please describe your problem';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduling() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule Consultation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Color(0xFF0A9D88),
              ),
              title: const Text('Date'),
              subtitle: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF0A9D88)),
              title: const Text('Time'),
              subtitle: Text('${selectedTime.format(context)}'),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Row(
                children: [
                  Image.asset(
                    'assets/upi_icon.png',
                    width: 24,
                    height: 24,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.payment, color: Color(0xFF0A9D88)),
                  ),
                  const SizedBox(width: 8),
                  const Text('UPI'),
                ],
              ),
              value: 'UPI',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF0A9D88)),
                  const SizedBox(width: 8),
                  const Text('Credit/Debit Card'),
                ],
              ),
              value: 'Card',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF0A9D88),
                  ),
                  const SizedBox(width: 8),
                  const Text('Wallet'),
                ],
              ),
              value: 'Wallet',
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    const double platformFee = 20.0;
    const double gst = 36.0;
    final double total = widget.expert.price + platformFee + gst;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Consultation Fee', '₹${widget.expert.price}'),
            _buildPriceRow('Platform Fee', '₹$platformFee'),
            _buildPriceRow('GST (18%)', '₹$gst'),
            const Divider(),
            _buildPriceRow('Total Amount', '₹$total', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF0A9D88) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    const double platformFee = 20.0;
    const double gst = 36.0;
    final double total = widget.expert.price + platformFee + gst;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _processPayment(total);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A9D88),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Pay ₹$total & Book Consultation',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _processPayment(double amount) {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      // Create consultation record
      final consultation = ConsultationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        expertName: widget.expert.name,
        expertSpecialization: widget.expert.specialization,
        clientName: _nameController.text,
        clientPhone: _phoneController.text,
        problem: _problemController.text,
        scheduledDate: selectedDate,
        scheduledTime: selectedTime,
        amount: amount,
        status: 'Scheduled',
        paymentMethod: selectedPaymentMethod,
        bookingDate: DateTime.now(),
      );

      // Navigate to consultation confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ConsultationConfirmationScreen(consultation: consultation),
        ),
      );
    });
  }
}

// Consultation Record Model
class ConsultationRecord {
  final String id;
  final String expertName;
  final String expertSpecialization;
  final String clientName;
  final String clientPhone;
  final String problem;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime bookingDate;
  String? consultationNotes;
  String? recommendations;
  DateTime? completionDate;

  ConsultationRecord({
    required this.id,
    required this.expertName,
    required this.expertSpecialization,
    required this.clientName,
    required this.clientPhone,
    required this.problem,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.bookingDate,
    this.consultationNotes,
    this.recommendations,
    this.completionDate,
  });
}

// Consultation Confirmation Screen
class ConsultationConfirmationScreen extends StatelessWidget {
  final ConsultationRecord consultation;

  const ConsultationConfirmationScreen({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Consultation Booked Successfully!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking ID: ${consultation.id}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    _buildConfirmationCard(context),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationCard(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetailRow('Expert', consultation.expertName),
            _buildDetailRow(
              'Specialization',
              consultation.expertSpecialization,
            ),
            _buildDetailRow(
              'Date',
              '${consultation.scheduledDate.day}/${consultation.scheduledDate.month}/${consultation.scheduledDate.year}',
            ),
            _buildDetailRow('Time', consultation.scheduledTime.format(context)),
            _buildDetailRow('Amount Paid', '₹${consultation.amount}'),
            _buildDetailRow('Payment Method', consultation.paymentMethod),
            _buildDetailRow('Status', consultation.status),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What happens next?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Our expert will call you at the scheduled time'),
                  Text('• Keep your phone ready 5 minutes before the call'),
                  Text(
                    '• Prepare any documents or photos related to your problem',
                  ),
                  Text(
                    '• You will receive consultation notes after the session',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecentConsultationsScreen(),
                ),
                (route) => route.settings.name == '/markets',
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text(
              'View My Consultations',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A9D88),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/markets',
                (route) => false,
              );
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Marketplace'),
          ),
        ),
      ],
    );
  }
}

// Recent Consultations Screen
class RecentConsultationsScreen extends StatefulWidget {
  const RecentConsultationsScreen({super.key});

  @override
  State<RecentConsultationsScreen> createState() =>
      _RecentConsultationsScreenState();
}

class _RecentConsultationsScreenState extends State<RecentConsultationsScreen> {
  List<ConsultationRecord> consultations = [
    // Sample data - in real app, this would come from database
    ConsultationRecord(
      id: '1001',
      expertName: 'Dr. Rajesh Kumar',
      expertSpecialization: 'Crop Disease Management',
      clientName: 'Farmer John',
      clientPhone: '+91 9876543210',
      problem:
          'Black spots appearing on tomato leaves, yellowing from bottom up. Need immediate advice.',
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      scheduledTime: const TimeOfDay(hour: 10, minute: 30),
      amount: 556.0,
      status: 'Completed',
      paymentMethod: 'UPI',
      bookingDate: DateTime.now().subtract(const Duration(days: 3)),
      consultationNotes:
          'Diagnosed with Early Blight disease. Recommended immediate treatment with copper-based fungicide.',
      recommendations: '''
Treatment Plan:
1. Apply Copper Oxychloride (2g/L) spray every 7 days
2. Remove affected leaves and dispose properly
3. Improve air circulation between plants
4. Apply mulch to prevent soil splashing
5. Follow-up spray with Mancozeb after 15 days

Preventive Measures:
• Avoid overhead watering
• Maintain proper plant spacing
• Regular inspection for early detection
• Crop rotation with non-solanaceous crops

Expected Recovery: 2-3 weeks with proper treatment
''',
      completionDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ConsultationRecord(
      id: '1002',
      expertName: 'Prof. Priya Sharma',
      expertSpecialization: 'Soil Health & Nutrition',
      clientName: 'Farmer John',
      clientPhone: '+91 9876543210',
      problem:
          'Soil pH testing and nutrient management for upcoming wheat season.',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      scheduledTime: const TimeOfDay(hour: 14, minute: 0),
      amount: 656.0,
      status: 'Scheduled',
      paymentMethod: 'Card',
      bookingDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final completedConsultations =
        consultations.where((c) => c.status == 'Completed').toList();
    final upcomingConsultations =
        consultations.where((c) => c.status == 'Scheduled').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.grey[100],
              child: const TabBar(
                labelColor: Color(0xFF0A9D88),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF0A9D88),
                tabs: [Tab(text: 'Upcoming'), Tab(text: 'Completed')],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildConsultationsList(upcomingConsultations, true),
                  _buildConsultationsList(completedConsultations, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationsList(
    List<ConsultationRecord> consultationList,
    bool isUpcoming,
  ) {
    if (consultationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.schedule : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming consultations'
                  : 'No completed consultations',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Book a consultation to get expert advice'
                  : 'Your consultation history will appear here',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: consultationList.length,
      itemBuilder: (context, index) {
        return _buildConsultationCard(consultationList[index], isUpcoming);
      },
    );
  }

  Widget _buildConsultationCard(
    ConsultationRecord consultation,
    bool isUpcoming,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.expertName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        consultation.expertSpecialization,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        consultation.status == 'Completed'
                            ? Colors.green
                            : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    consultation.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${consultation.scheduledDate.day}/${consultation.scheduledDate.month}/${consultation.scheduledDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  consultation.scheduledTime.format(context),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Problem: ${consultation.problem}',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Amount: ₹${consultation.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A9D88),
                  ),
                ),
                const Spacer(),
                if (consultation.status == 'Completed')
                  TextButton(
                    onPressed: () => _showConsultationDetails(consultation),
                    child: const Text('View Details'),
                  )
                else
                  TextButton(
                    onPressed: () => _showRescheduleDialog(consultation),
                    child: const Text('Reschedule'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConsultationDetails(ConsultationRecord consultation) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Consultation Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildDetailSection('Expert Information', [
                      'Name: ${consultation.expertName}',
                      'Specialization: ${consultation.expertSpecialization}',
                    ]),
                    _buildDetailSection('Consultation Details', [
                      'Date: ${consultation.scheduledDate.day}/${consultation.scheduledDate.month}/${consultation.scheduledDate.year}',
                      'Time: ${consultation.scheduledTime.format(context)}',
                      'Amount: ₹${consultation.amount}',
                      'Status: ${consultation.status}',
                    ]),
                    _buildDetailSection('Problem Description', [
                      consultation.problem,
                    ]),
                    if (consultation.consultationNotes != null)
                      _buildDetailSection('Consultation Notes', [
                        consultation.consultationNotes!,
                      ]),
                    if (consultation.recommendations != null)
                      _buildDetailSection('Recommendations', [
                        consultation.recommendations!,
                      ]),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadConsultationReport(consultation);
                        },
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: const Text(
                          'Download Report',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A9D88),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A9D88),
          ),
        ),
        const SizedBox(height: 8),
        ...details
            .map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(detail),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showRescheduleDialog(ConsultationRecord consultation) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reschedule Consultation'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Would you like to reschedule your consultation?'),
                SizedBox(height: 16),
                Text(
                  'Note: Rescheduling is allowed up to 24 hours before the scheduled time.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Reschedule request sent. You will be contacted shortly.',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9D88),
                ),
                child: const Text(
                  'RESCHEDULE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _downloadConsultationReport(ConsultationRecord consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation report downloaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
