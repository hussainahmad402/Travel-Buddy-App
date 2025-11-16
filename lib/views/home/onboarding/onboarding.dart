import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelbuddy/constants/file_path.dart';
import 'package:travelbuddy/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": AppPaths.onboarding1,
      "title": "Life is brief, but the universe is vast.",
      "highlight": "vast", // 👈 highlighted word
      "desc": "At Tourista Adventures, we curate unique and immersive travel experiences to destinations around the globe.",
    },
    {
      "image": AppPaths.onboarding2,
      "title": "The world is waiting for you, go discover it.",
      "highlight": "discover it", // 👈 highlighted word
      "desc": "Embark on an unforgettable journey by venturing outside of your comfort zone. The world is full of hidden gems just waiting to be discovered.",
    },
    {
      "image": AppPaths.onboarding3,
      "title": "People don’t take trips, trips take people.",
      "highlight": "people", // 👈 highlighted word
      "desc": "To get the best of your adventure you just need to leave and go where you like. We are waiting for you.",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstTime", false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(page["image"]!, fit: BoxFit.cover),

              // Blur overlay
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.1), // dim overlay
                ),
              ),

              // Foreground content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 🔹 Title with fade animation + highlighted word
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: RichText(
                        key: ValueKey(page["title"]), // important for animation
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          children: _buildTitleSpans(page["title"]!, page["highlight"]!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Description with fade animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        page["desc"]!,
                        key: ValueKey(page["desc"]), // important for animation
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == dotIndex ? 16 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == dotIndex
                                ? AppColors.primary
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Button
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔹 Helper to highlight a specific word
  List<TextSpan> _buildTitleSpans(String text, String highlight) {
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerHighlight, start);
      if (index < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: const TextStyle(color: AppColors.primary), // 🔥 highlighted color
      ));

      start = index + highlight.length;
    }

    return spans;
  }
}
