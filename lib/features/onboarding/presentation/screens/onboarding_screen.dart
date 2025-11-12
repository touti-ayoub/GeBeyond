import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Amazing Places',
      description: 'Explore thousands of destinations, hotels, and experiences around the world',
      image: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800',
      icon: Icons.explore,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Book with Confidence',
      description: 'Easy booking process with secure payments and instant confirmation',
      image: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
      icon: Icons.flight_takeoff,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Earn Rewards',
      description: 'Get points on every booking and unlock exclusive member benefits',
      image: 'https://images.unsplash.com/photo-1483347756197-71ef80e95f73?w=800',
      icon: Icons.emoji_events,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Plan Your Journey',
      description: 'Create personalized itineraries and manage all your trips in one place',
      image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      icon: Icons.map,
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _skipOnboarding() async {
    await _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], size, theme);
            },
          ),

          // Skip Button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => _buildIndicator(index == _currentPage),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Next/Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.arrow_forward_ios,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, Size size, ThemeData theme) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(page.image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}

