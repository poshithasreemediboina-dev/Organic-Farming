import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:green_connect/core/utils/validators.dart';
import 'package:green_connect/services/database_service.dart';
import 'package:green_connect/models/complaint_model.dart';
import 'package:green_connect/providers/complaint_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Experiment 14: Unit Tests & Validation Rules', () {
    // 1. Login form validation
    test('1. Login form validation - valid and invalid email & password', () {
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail('invalid-email'), 'Enter a valid email address');
      expect(Validators.validateEmail('farmer@greenconnect.org'), isNull);

      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters');
      expect(Validators.validatePassword('password123'), isNull);
    });

    // 2. Registration form validation
    test('2. Registration form validation - required fields and password matching', () {
      expect(Validators.validateRequired('', 'Full Name'), 'Full Name is required');
      expect(Validators.validateRequired('Ramesh Patil', 'Full Name'), isNull);

      expect(Validators.validatePhone('123'), 'Enter a valid 10-digit phone number');
      expect(Validators.validatePhone('9876543210'), isNull);

      expect(Validators.validateConfirmPassword('pass123', 'pass456'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
    });

    // 3. Complaint form validation
    test('3. Complaint form validation - category and title requirements', () {
      expect(Validators.validateRequired('', 'Complaint Title'), 'Complaint Title is required');
      expect(Validators.validateRequired('Canal water blocked', 'Complaint Title'), isNull);
      expect(Validators.validateRequired('', 'Location'), 'Location is required');
      expect(Validators.validateRequired('Baramati Sector 4', 'Location'), isNull);
    });

    // 4. Complaint status updates & workflow
    test('4. Complaint status update workflow (Pending -> In Progress -> Resolved)', () async {
      final db = DatabaseService();
      await db.initialize();

      // Submit test complaint
      final testComplaint = ComplaintModel(
        complaintId: 'GC9999',
        userId: 'usr_farmer_test',
        userName: 'Test Farmer',
        userPhone: '9999999999',
        title: 'Irrigation pump breakdown',
        category: 'Irrigation Issues',
        description: 'Primary pump motor burnt out due to voltage surge.',
        location: 'Field Sector 1',
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.addComplaint(testComplaint);
      expect(testComplaint.isPending, isTrue);

      // Admin transitions to In Progress
      final inProgress = await db.updateComplaintStatus(
        complaintId: 'GC9999',
        newStatus: 'In Progress',
        remarks: 'Electrician dispatched.',
      );
      expect(inProgress.status, 'In Progress');
      expect(inProgress.adminRemarks, 'Electrician dispatched.');

      // Admin transitions to Resolved
      final resolved = await db.updateComplaintStatus(
        complaintId: 'GC9999',
        newStatus: 'Resolved',
        remarks: 'Motor replaced with 5HP solar pump.',
      );
      expect(resolved.status, 'Resolved');
      expect(resolved.resolvedAt, isNotNull);
    });

    // 5. Provider functionality
    test('5. ComplaintProvider state management & statistics computation', () async {
      final provider = ComplaintProvider();
      await provider.loadComplaints();

      expect(provider.totalComplaintsCount, greaterThan(0));
      expect(provider.pendingComplaintsCount, greaterThanOrEqualTo(0));
      expect(provider.categoryDistribution, isNotEmpty);

      // Test filter
      provider.setStatusFilter('Pending');
      expect(provider.selectedStatus, 'Pending');
      for (var c in provider.filteredAdminComplaints) {
        expect(c.status, 'Pending');
      }
    });

    // 6. Targeted notification creation for farmer
    test('6. Targeted notification generated upon complaint resolution', () async {
      final db = DatabaseService();
      await db.initialize();

      const testFarmerId = 'usr_farmer_notif_test';
      final newComplaint = ComplaintModel(
        complaintId: 'GC8888',
        userId: testFarmerId,
        userName: 'Targeted Farmer',
        userPhone: '9876500000',
        title: 'Neem cake adulteration',
        category: 'Fertilizer Issues',
        description: 'Tested sample failed nitrogen assay.',
        location: 'Taluka Store',
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.addComplaint(newComplaint);

      // Verify submission notification
      var notifications = db.getNotificationsForUser(testFarmerId);
      expect(notifications.any((n) => n.complaintId == 'GC8888' && n.type == 'complaint_submitted'), isTrue);

      // Resolve and verify resolution notification
      await db.updateComplaintStatus(
        complaintId: 'GC8888',
        newStatus: 'Resolved',
        remarks: 'Batch recalled and genuine certified bags provided.',
      );

      notifications = db.getNotificationsForUser(testFarmerId);
      final resolveNotif = notifications.firstWhere((n) => n.complaintId == 'GC8888' && n.type == 'complaint_resolved');
      expect(resolveNotif.title, 'Complaint Resolved!');
      expect(resolveNotif.message, contains('GC8888'));
      expect(resolveNotif.isRead, isFalse);
    });
  });
}
