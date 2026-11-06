import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:green_connect/widgets/custom_button.dart';
import 'package:green_connect/widgets/complaint_card.dart';
import 'package:green_connect/widgets/status_badge.dart';
import 'package:green_connect/models/complaint_model.dart';
import 'package:green_connect/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Experiment 14: Widget Tests & UI Verification', () {
    // 7. Custom button widget
    testWidgets('7. CustomButton renders text, responds to tap and shows loading spinner', (tester) async {
      bool tapped = false;

      // Normal state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit Grievance',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Grievance'), findsOneWidget);
      await tester.tap(find.text('Submit Grievance'));
      expect(tapped, isTrue);

      // Loading state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit Grievance',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // 8. Complaint card widget & Status badge
    testWidgets('8. ComplaintCard renders complaint ID, title, category, and status badge', (tester) async {
      final complaint = ComplaintModel(
        complaintId: 'GC1025',
        userId: 'usr_farmer_1',
        userName: 'Ramesh Patil',
        userPhone: '9876543210',
        title: 'Canal water supply disrupted during flowering stage',
        category: 'Water Supply Problem',
        description: 'Primary distribution sub-canal valve blocked.',
        location: 'Baramati Canal Zone Block 4',
        status: 'In Progress',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplaintCard(
              complaint: complaint,
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('#GC1025'), findsOneWidget);
      expect(find.text('Canal water supply disrupted during flowering stage'), findsOneWidget);
      expect(find.text('Water Supply Problem'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);

      await tester.tap(find.byType(ComplaintCard));
      expect(cardTapped, isTrue);
    });

    // 9. Navigation smoke test
    testWidgets('9. GreenConnect app boots up to SplashScreen and displays branding', (tester) async {
      await tester.pumpWidget(const GreenConnectApp());

      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Growing Together, Naturally.'), findsOneWidget);

      // Advance timer past splash duration to complete navigation and prevent pending timer exception
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();
    });
  });
}
