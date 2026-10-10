import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yum_quick/src/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:yum_quick/src/features/auth/presentation/screens/welcome_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders slide content without overflow', (
    WidgetTester tester,
  ) async {
    // Set a phone screen constraint
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.pumpAndSettle();

    // Verify Skip button exists
    expect(find.text('Skip'), findsOneWidget);

    // Verify first slide title
    expect(find.text('Order For Food'), findsOneWidget);

    // Verify Next button exists
    expect(find.text('Next'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify second slide title
    expect(find.text('Easy Payment'), findsOneWidget);

    // Reset view
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('WelcomeScreen renders yellow logo and action buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    await tester.pumpAndSettle();

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
