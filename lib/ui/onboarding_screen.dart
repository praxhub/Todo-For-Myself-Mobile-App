import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytodo/features/home/presentation/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = GoogleFonts.outfit(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurface,
    );
    final bodyStyle = GoogleFonts.inter(
      fontSize: 16,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.5,
    );

    PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: titleStyle,
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: theme.colorScheme.surface,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: theme.colorScheme.surface,
      allowImplicitScrolling: true,
      pages: [
        PageViewModel(
          title: "Capture Your Day",
          body:
              "Easily track all your tasks, deadlines, and habits in one beautiful place.",
          image: _buildImage(Icons.task_alt_rounded, theme.colorScheme.primary),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Deep Focus",
          body:
              "Use the built-in Pomodoro timer to concentrate on your most important work without distractions.",
          image: _buildImage(Icons.timer_rounded, theme.colorScheme.secondary),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Smarter Insights",
          body:
              "Visualize your productivity habits and see your financial timeline with FinPilot AI.",
          image:
              _buildImage(Icons.insights_rounded, theme.colorScheme.tertiary),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: Text('Skip',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
      next: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
      done: Text('Get Started',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
      curve: Curves.fastOutSlowIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        activeSize: const Size(22.0, 10.0),
        activeColor: theme.colorScheme.primary,
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  Widget _buildImage(IconData icon, Color color) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 70, color: color),
      ),
    );
  }
}
