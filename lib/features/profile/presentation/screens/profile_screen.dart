import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/services/rewards_service.dart';
import '../../../../core/services/data_reset_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = UserProfileService();
  final _rewardsService = RewardsService();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _profileService.initialize();
    await _rewardsService.initialize();
    await _rewardsService.loadRewards();
    _profileService.addListener(_onProfileChanged);
    _rewardsService.addListener(_onProfileChanged);
    setState(() {});
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    _rewardsService.removeListener(_onProfileChanged);
    super.dispose();
  }

  // Mock user data - now using service
  Map<String, dynamic> get _userData => _profileService.toMap();

  List<Map<String, dynamic>> get _stats => [
    {
      'icon': Icons.flight_takeoff,
      'label': 'Trips',
      'value': _profileService.trips.toString()
    },
    {
      'icon': Icons.location_on,
      'label': 'Countries',
      'value': _profileService.countries.toString()
    },
    {
      'icon': Icons.star,
      'label': 'Reviews',
      'value': _profileService.reviews.toString()
    },
    {
      'icon': Icons.emoji_events,
      'label': 'Points',
      'value': _rewardsService.totalPoints >= 1000
          ? '${(_rewardsService.totalPoints / 1000).toStringAsFixed(1)}K'
          : _rewardsService.totalPoints.toString()
    },
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.card_giftcard,
      'title': 'Rewards & Points',
      'subtitle': 'View your loyalty rewards',
      'route': '/profile/rewards',
    },
    {
      'icon': Icons.person_outline,
      'title': 'Personal Information',
      'subtitle': 'Update your details',
      'route': '/profile/personal-info',
    },
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
      'subtitle': 'Get assistance',
      'route': '/profile/support',
    },
    {
      'icon': Icons.description_outlined,
      'title': 'Terms & Policies',
      'subtitle': 'Legal information',
      'route': '/profile/terms',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code),
                tooltip: 'My QR Code',
                onPressed: () {
                  _showQRCodeDialog(context);
                },
              ),
            ],
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(context),
          ),

          // Member Level Card
          SliverToBoxAdapter(
            child: _buildMemberLevelCard(context),
          ),

          // Menu Items
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _menuItems[index];
                  return _buildMenuItem(context, item);
                },
                childCount: _menuItems.length,
              ),
            ),
          ),

          // Logout Button
          SliverToBoxAdapter(
            child: _buildLogoutButton(context),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16),
                        color: colorScheme.onPrimary,
                        iconSize: 16,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // Change avatar
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                _userData['name'],
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                _userData['email'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Bio
              Text(
                _userData['bio'],
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _stats.map((stat) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemberLevelCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get data from RewardsService
    final memberLevel = _rewardsService.getMemberLevel();
    final totalPoints = _rewardsService.totalPoints;
    final pointsForNext = _rewardsService.getPointsForNextLevel();
    final progress = _rewardsService.getProgressToNextLevel();

    // Determine gradient colors based on member level
    List<Color> gradientColors;
    IconData levelIcon;

    switch (memberLevel) {
      case 'Platinum':
        gradientColors = [const Color(0xFF9333EA), const Color(0xFF7C3AED)];
        levelIcon = Icons.workspace_premium;
        break;
      case 'Gold':
        gradientColors = [const Color(0xFFFFD700), const Color(0xFFFFA500)];
        levelIcon = Icons.stars;
        break;
      case 'Silver':
        gradientColors = [const Color(0xFFC0C0C0), const Color(0xFF9CA3AF)];
        levelIcon = Icons.star_half;
        break;
      default: // Bronze
        gradientColors = [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
        levelIcon = Icons.star_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  levelIcon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberLevel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Member since ${_userData['joinDate']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$totalPoints Points',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to Rewards screen
                    context.push('/profile/rewards');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Redeem'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item['icon'] as IconData,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          item['title'],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          item['subtitle'],
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: () {
          // Navigate to specific page based on title
          final title = item['title'];
          if (title == 'Rewards & Points') {
            context.push('/profile/rewards');
          } else if (title == 'Personal Information') {
            _showPersonalInfoPage(context);
          } else if (title == 'Help & Support') {
            _showHelpAndSupportPage(context);
          } else if (title == 'Terms & Policies') {
            _showTermsAndPoliciesPage(context);
          }
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // Clear all user data
                    await DataResetService().clearAllData();

                    // Navigate to login
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      context.go('/login');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // QR Code Dialog
  void _showQRCodeDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code_2, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('My QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // QR Code placeholder
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: 150,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userData['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ID: ${_userData['email'].hashCode.abs()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share this QR code to connect with other travelers',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Code saved to gallery')),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Save'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Personal Information Page
  void _showPersonalInfoPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalInformationPage(),
      ),
    );
  }

  // Help & Support Page
  void _showHelpAndSupportPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpAndSupportPage(),
      ),
    );
  }

  // Terms & Policies Page
  void _showTermsAndPoliciesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TermsAndPoliciesPage(),
      ),
    );
  }
}

// Personal Information Page
class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = UserProfileService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // Initialize service and load data
    await _profileService.initialize();
    
    // Initialize controllers with loaded data
    _nameController = TextEditingController(text: _profileService.name);
    _emailController = TextEditingController(text: _profileService.email);
    _phoneController = TextEditingController(text: _profileService.phone);
    _bioController = TextEditingController(text: _profileService.bio);
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final success = await _profileService.saveProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Personal Information'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                          onPressed: () {
                            // Change photo
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Bio Field
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.edit_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              const SizedBox(height: 24),

              // Additional Info
              Text(
                'Account Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildInfoTile(
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: _profileService.joinDate,
              ),
              _buildInfoTile(
                icon: Icons.workspace_premium,
                label: 'Membership Level',
                value: _profileService.memberLevel,
              ),
              _buildInfoTile(
                icon: Icons.stars,
                label: 'Loyalty Points',
                value: '${_profileService.points.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )} Points',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Help & Support Page
class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final faqs = [
      {
        'question': 'How do I book a trip?',
        'answer': 'Browse our explore page, select your destination, and click the "Book Now" button. Follow the steps to complete your booking.',
      },
      {
        'question': 'Can I cancel my booking?',
        'answer': 'Yes, you can cancel up to 48 hours before your trip for a full refund. Check our cancellation policy for details.',
      },
      {
        'question': 'How do I contact support?',
        'answer': 'You can reach us via email at support@gobeyond.com or call us at +1 (800) 123-4567. We\'re available 24/7.',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': 'We accept all major credit cards, PayPal, and Apple Pay for your convenience.',
      },
      {
        'question': 'How do I earn loyalty points?',
        'answer': 'Earn points with every booking! 1 point = \$1 spent. Redeem points for discounts on future trips.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.headset_mic,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Need Help?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is available 24/7',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactButton(
                        context,
                        icon: Icons.email,
                        label: 'Email',
                        onTap: () {},
                      ),
                      _buildContactButton(
                        context,
                        icon: Icons.phone,
                        label: 'Call',
                        onTap: () {},
                      ),
                      _buildContactButton(
                        context,
                        icon: Icons.chat,
                        label: 'Chat',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // FAQs Section
            Text(
              'Frequently Asked Questions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...faqs.map((faq) => _buildFAQItem(
              context,
              question: faq['question']!,
              answer: faq['answer']!,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            question,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Terms & Policies Page
class TermsAndPoliciesPage extends StatelessWidget {
  const TermsAndPoliciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Policies'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPolicyCard(
            context,
            icon: Icons.description,
            title: 'Terms of Service',
            description: 'Read our terms and conditions',
            onTap: () => _showPolicyDetail(context, 'Terms of Service', _termsOfService),
          ),
          _buildPolicyCard(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            description: 'How we handle your data',
            onTap: () => _showPolicyDetail(context, 'Privacy Policy', _privacyPolicy),
          ),
          _buildPolicyCard(
            context,
            icon: Icons.cancel,
            title: 'Cancellation Policy',
            description: 'Booking cancellation terms',
            onTap: () => _showPolicyDetail(context, 'Cancellation Policy', _cancellationPolicy),
          ),
          _buildPolicyCard(
            context,
            icon: Icons.cookie,
            title: 'Cookie Policy',
            description: 'How we use cookies',
            onTap: () => _showPolicyDetail(context, 'Cookie Policy', _cookiePolicy),
          ),
          const SizedBox(height: 16),
          Text(
            'Last updated: November 6, 2025',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showPolicyDetail(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }

  static const String _termsOfService = '''
Terms of Service

Welcome to GoBeyond! By using our services, you agree to these terms.

1. Acceptance of Terms
By accessing and using GoBeyond, you accept and agree to be bound by the terms and provision of this agreement.

2. Use License
Permission is granted to temporarily download one copy of the materials on GoBeyond's app for personal, non-commercial transitory viewing only.

3. Booking Terms
- All bookings are subject to availability
- Prices are subject to change without notice
- Full payment is required at time of booking

4. User Conduct
Users must not:
- Use the service for any illegal purposes
- Attempt to gain unauthorized access
- Interfere with the proper working of the service

5. Limitation of Liability
GoBeyond shall not be liable for any damages arising from the use or inability to use the service.

6. Modifications
We reserve the right to modify these terms at any time. Continued use constitutes acceptance of modified terms.

For questions about these Terms, contact us at legal@gobeyond.com
''';

  static const String _privacyPolicy = '''
Privacy Policy

Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.

1. Information We Collect
- Personal identification information (Name, email, phone)
- Booking and travel preferences
- Payment information
- Usage data and analytics

2. How We Use Your Information
- Process bookings and transactions
- Improve our services
- Send promotional communications (with consent)
- Ensure platform security

3. Data Protection
We implement industry-standard security measures to protect your data:
- Encryption of sensitive information
- Secure payment processing
- Regular security audits

4. Sharing Your Information
We do not sell your personal information. We may share data with:
- Service providers (travel partners)
- Payment processors
- Legal authorities (when required by law)

5. Your Rights
You have the right to:
- Access your personal data
- Request data correction or deletion
- Opt-out of marketing communications
- Download your data

6. Cookies
We use cookies to enhance user experience and analyze usage patterns.

For privacy inquiries, contact privacy@gobeyond.com
''';

  static const String _cancellationPolicy = '''
Cancellation Policy

We understand plans change. Here's our cancellation policy:

1. Free Cancellation Period
- Cancel up to 48 hours before departure: Full refund
- Cancel 24-48 hours before: 50% refund
- Cancel less than 24 hours: No refund

2. Modification Policy
- Changes made 7+ days before: No fee
- Changes made 3-7 days before: \$50 modification fee
- Changes made less than 3 days: \$100 modification fee

3. Force Majeure
Full refund available for cancellations due to:
- Natural disasters
- Government travel restrictions
- Serious illness (with medical documentation)

4. Travel Insurance
We recommend purchasing travel insurance to protect your investment.

5. Refund Processing
- Refunds processed within 5-10 business days
- Original payment method will be credited
- Processing fees are non-refundable

6. Partner Cancellations
If a trip is cancelled by our partners:
- Full refund issued immediately
- Alternative options provided
- Compensation for inconvenience

For cancellation requests, contact bookings@gobeyond.com
''';

  static const String _cookiePolicy = '''
Cookie Policy

This Cookie Policy explains how GoBeyond uses cookies and similar technologies.

1. What Are Cookies?
Cookies are small text files stored on your device when you visit our website or use our app.

2. Types of Cookies We Use

Essential Cookies:
- Required for basic functionality
- Enable secure login
- Remember your preferences

Analytics Cookies:
- Track usage patterns
- Help improve our services
- Understand user behavior

Marketing Cookies:
- Deliver personalized content
- Track campaign effectiveness
- Provide relevant advertisements

3. Third-Party Cookies
We use cookies from trusted partners:
- Google Analytics
- Payment processors
- Social media platforms

4. Managing Cookies
You can control cookies through:
- Browser settings
- App preferences
- Opt-out tools

Note: Disabling cookies may limit functionality.

5. Cookie Duration
- Session cookies: Deleted when you close the app
- Persistent cookies: Remain for a set period

6. Updates to This Policy
We may update this policy to reflect changes in technology or regulations.

For questions about cookies, contact privacy@gobeyond.com
''';
}
