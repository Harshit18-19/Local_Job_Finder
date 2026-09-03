import 'package:flutter_test/flutter_test.dart';
import 'package:local_job_finder/main.dart';

void main() {
  testWidgets('New users see the onboarding slides',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const LocalJobApp(loggedIn: false, onboardingComplete: false),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(
        find.text('A better job search starts close to home.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
