import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool isFromSettings;

  const OnboardingPage({
    super.key,
    this.isFromSettings = false,
  });

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = [
    const _OnboardingSlide(
      title: 'Payments for any business',
      description: 'From e-commerce stores to subscription businesses - we offer a complete stack for all your payments needs across channels',
      assetPath: 'assets/images/onboarding_wallet.png',
    ),
    const _OnboardingSlide(
      title: 'Optimize your revenue',
      description: 'Protect yourself from fraud and increase authorization rates on every payment using our machine learning from millions of businesses',
      assetPath: 'assets/images/onboarding_piggy_bank.png',
    ),
    const _OnboardingSlide(
      title: 'Easy transfers in a few taps',
      description: 'Transfer and receive money as easily as possible and keep track of your expenses in details and great goals',
      assetPath: 'assets/images/onboarding_chart.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() {
    if (widget.isFromSettings) {
      Navigator.pop(context);
    } else {
      ref.read(settingsProvider.notifier).setHasSeenOnboarding(true);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Top background should probably match the image background or be a brand color.
    // Since images have dark background, we keep it dark or use primary if it blends. 
    // Let's use backgroundDark for top to blend with images, and surface for bottom card.
    final topBackgroundColor = AppColors.backgroundDark;
    final bottomSheetColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryColor = AppColors.primary;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final descColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: topBackgroundColor,
      body: Column(
        children: [
          // Top section with 3D Image
          Expanded(
            flex: 5, 
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildImageSection(_slides[index]);
              },
            ),
          ),
          // Bottom section with card
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bottomSheetColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(AppValues.gapLarge * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Text Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(_currentPage),
                      children: [
                        Text(
                          _slides[_currentPage].title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _slides[_currentPage].description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: descColor,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? (widget.isFromSettings ? 'Close' : 'Get Started')
                            : 'Get Started',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(_OnboardingSlide slide) {
    return Container(
      padding: const EdgeInsets.all(AppValues.gapLarge),
      alignment: Alignment.center,
      child: Image.asset(
        slide.assetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String assetPath;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.assetPath,
  });
}
