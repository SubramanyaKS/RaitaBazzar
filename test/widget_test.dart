import 'package:flutter_test/flutter_test.dart';
import 'package:raitabazzar/main.dart';

void main() {
  testWidgets('App launches and renders welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify app title and continue button render
    expect(find.text('RaithaBazzar'), findsWidgets);
    expect(find.text('Continue'), findsOneWidget);
  });
}
