import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/complaint_model.dart';
import '../models/notification_model.dart';
import '../models/community_model.dart';
import '../models/product_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  bool _initialized = false;

  final List<UserModel> _users = [];
  final List<ComplaintModel> _complaints = [];
  final List<NotificationModel> _notifications = [];
  final List<CommunityPostModel> _posts = [];
  final List<ProductModel> _products = [];

  // Storage Keys
  static const String _kUsers = 'db_users_v1';
  static const String _kComplaints = 'db_complaints_v1';
  static const String _kNotifications = 'db_notifications_v1';
  static const String _kPosts = 'db_posts_v1';
  static const String _kProducts = 'db_products_v1';

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Check if data is already stored
    final usersRaw = prefs.getString(_kUsers);
    final complaintsRaw = prefs.getString(_kComplaints);
    final notificationsRaw = prefs.getString(_kNotifications);
    final postsRaw = prefs.getString(_kPosts);
    final productsRaw = prefs.getString(_kProducts);

    if (usersRaw != null) {
      _users.clear();
      final list = json.decode(usersRaw) as List<dynamic>;
      _users.addAll(list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)));
    } else {
      _seedUsers();
      await _persistUsers();
    }

    if (complaintsRaw != null) {
      _complaints.clear();
      final list = json.decode(complaintsRaw) as List<dynamic>;
      _complaints.addAll(list.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)));
    } else {
      _seedComplaints();
      await _persistComplaints();
    }

    if (notificationsRaw != null) {
      _notifications.clear();
      final list = json.decode(notificationsRaw) as List<dynamic>;
      _notifications.addAll(list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)));
    } else {
      _seedNotifications();
      await _persistNotifications();
    }

    if (postsRaw != null) {
      _posts.clear();
      final list = json.decode(postsRaw) as List<dynamic>;
      _posts.addAll(list.map((e) => CommunityPostModel.fromJson(e as Map<String, dynamic>)));
    } else {
      _seedPosts();
      await _persistPosts();
    }

    if (productsRaw != null) {
      _products.clear();
      final list = json.decode(productsRaw) as List<dynamic>;
      _products.addAll(list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)));
    } else {
      _seedProducts();
      await _persistProducts();
    }

    _initialized = true;
  }

  // --- SEED DATA ---
  void _seedUsers() {
    _users.addAll([
      UserModel(
        id: 'usr_farmer_1',
        name: 'Ramesh Patil',
        email: 'farmer@greenconnect.org',
        phone: '9876543210',
        role: 'Farmer',
        city: 'Baramati',
        state: 'Maharashtra',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      UserModel(
        id: 'usr_farmer_2',
        name: 'Savitri Devi',
        email: 'savitri@greenconnect.org',
        phone: '9822334455',
        role: 'Farmer',
        city: 'Nashik',
        state: 'Maharashtra',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'usr_admin_1',
        name: 'Dr. Arvind Sharma (Admin)',
        email: 'admin@greenconnect.org',
        phone: '9123456780',
        role: 'Administrator',
        city: 'Pune',
        state: 'Maharashtra',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      UserModel(
        id: 'usr_member_1',
        name: 'Ananya Deshmukh',
        email: 'ananya@greenconnect.org',
        phone: '9988776655',
        role: 'Community Member',
        city: 'Nagpur',
        state: 'Maharashtra',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ]);
  }

  void _seedComplaints() {
    _complaints.addAll([
      ComplaintModel(
        complaintId: 'GC1025',
        userId: 'usr_farmer_1',
        userName: 'Ramesh Patil',
        userPhone: '9876543210',
        title: 'Canal water supply disrupted during flowering stage',
        category: 'Water Supply Problem',
        description: 'The primary distribution sub-canal valve has been blocked by silt for the last 4 days. Our certified organic soybean fields require urgent watering.',
        location: 'Baramati Canal Zone Block 4',
        cropName: 'Organic Soybean',
        status: 'In Progress',
        adminRemarks: 'Irrigation officer visited the site today. Silt clearance machinery scheduled for tomorrow morning.',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      ComplaintModel(
        complaintId: 'GC1024',
        userId: 'usr_farmer_1',
        userName: 'Ramesh Patil',
        userPhone: '9876543210',
        title: 'Spotted stem borer infestation on organic corn',
        category: 'Pest Problems',
        description: 'Observed yellowing of whorl leaves and bore holes with frass on 2 acres of sweet corn. Need bio-control guidance immediately.',
        location: 'East Field, Plot 12, Baramati',
        cropName: 'Sweet Corn',
        status: 'Resolved',
        adminRemarks: 'Recommended Trichogramma chilonis egg parasitoid cards @ 50,000/ha combined with 5% Neem Seed Kernel Extract spray.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ComplaintModel(
        complaintId: 'GC1026',
        userId: 'usr_farmer_2',
        userName: 'Savitri Devi',
        userPhone: '9822334455',
        title: 'Delays in NPOP renewal inspection',
        category: 'Organic Certification Issues',
        description: 'Annual organic certification audit request submitted 30 days ago. Renewal certificate required for export grape consignment.',
        location: 'Dindori Taluka, Nashik',
        cropName: 'Organic Table Grapes',
        status: 'Pending',
        adminRemarks: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      ComplaintModel(
        complaintId: 'GC1027',
        userId: 'usr_farmer_1',
        userName: 'Ramesh Patil',
        userPhone: '9876543210',
        title: 'Certified neem cake fertilizer has foul synthetic smell',
        category: 'Fertilizer Issues',
        description: 'Purchased 20 bags of organic neem cake from subsidized depot. Material appears adulterated with chemical solvent odor.',
        location: 'Baramati Agro Center',
        cropName: 'Pomegranate Orchard',
        status: 'Pending',
        adminRemarks: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  void _seedNotifications() {
    _notifications.addAll([
      NotificationModel(
        notificationId: 'notif_1',
        userId: 'usr_farmer_1',
        complaintId: 'GC1024',
        title: 'Complaint Resolved!',
        message: 'Your complaint #GC1024 regarding Pest Problems has been successfully resolved by the administration.',
        type: 'complaint_resolved',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      NotificationModel(
        notificationId: 'notif_2',
        userId: 'usr_farmer_1',
        complaintId: 'GC1025',
        title: 'Complaint Status Updated',
        message: 'Your complaint #GC1025 status has been updated to "In Progress". Admin remarks added.',
        type: 'complaint_in_progress',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        notificationId: 'notif_3',
        userId: 'usr_farmer_1',
        complaintId: 'GC1027',
        title: 'Complaint Registered Successfully',
        message: 'Complaint #GC1027 regarding Fertilizer Issues has been received. Our team will review it shortly.',
        type: 'complaint_submitted',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  void _seedPosts() {
    _posts.addAll([
      CommunityPostModel(
        id: 'post_1',
        userId: 'usr_farmer_1',
        userName: 'Ramesh Patil',
        userRole: 'Farmer',
        userLocation: 'Baramati, Maharashtra',
        title: 'How I eliminated fruit flies using Holy Basil traps',
        content: 'Sharing my organic orchard experience: Crushed tulsi (holy basil) leaves mixed with a drop of jaggery extract in recycled plastic bottles reduced Bactrocera cucurbitae fruit flies by 85% within 10 days! No synthetic traps needed.',
        category: 'Natural Pest Control',
        imageUrl: null,
        likes: 24,
        likedUserIds: ['usr_farmer_2', 'usr_member_1'],
        comments: [
          CommentModel(
            id: 'c1',
            userId: 'usr_farmer_2',
            userName: 'Savitri Devi',
            userRole: 'Farmer',
            content: 'Great insight Rameshji! At what height did you hang the bottles on the trees?',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          CommentModel(
            id: 'c2',
            userId: 'usr_farmer_1',
            userName: 'Ramesh Patil',
            userRole: 'Farmer',
            content: 'Around 4 to 5 feet off the ground in shaded canopy areas.',
            createdAt: DateTime.now().subtract(const Duration(hours: 20)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CommunityPostModel(
        id: 'post_2',
        userId: 'usr_farmer_2',
        userName: 'Savitri Devi',
        userRole: 'Farmer',
        userLocation: 'Nashik, Maharashtra',
        title: 'Fermented Jeevamrutha recipe for rapid root development',
        content: 'Preparation ratio for 1 acre: 10 kg native cow dung, 10 litres cow urine, 2 kg jaggery, 2 kg chickpea flour, and a handful of fertile virgin bund soil. Ferment for 48 hours in shade stirring clockwise twice a day. Outstanding microbial bloom!',
        category: 'Organic Fertilizers',
        imageUrl: null,
        likes: 38,
        likedUserIds: ['usr_farmer_1'],
        comments: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      CommunityPostModel(
        id: 'post_3',
        userId: 'usr_member_1',
        userName: 'Ananya Deshmukh',
        userRole: 'Community Member',
        userLocation: 'Nagpur, Maharashtra',
        title: 'Direct farm-to-door organic vegetables basket experience',
        content: 'Received our first weekly harvest crate from our local GreenConnect farmers group. The natural flavor and shelf life of the heirloom tomatoes and spinach are incredible compared to supermarket produce.',
        category: 'Organic Vegetables',
        imageUrl: null,
        likes: 19,
        likedUserIds: [],
        comments: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
    ]);
  }

  void _seedProducts() {
    _products.addAll([
      ProductModel(
        id: 'prod_1',
        sellerId: 'usr_farmer_1',
        sellerName: 'Ramesh Patil',
        sellerPhone: '9876543210',
        sellerLocation: 'Baramati, Maharashtra',
        name: 'Cold-Pressed Certified Organic Mustard Oil',
        category: 'Natural Fertilizers',
        description: 'Virgin wood-churned (Kacchi Ghani) mustard oil residue cake, exceptional nitrogen and sulfur source for organic soil enrichment.',
        price: 450.0,
        unit: '5 kg bag',
        imageUrl: null,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ProductModel(
        id: 'prod_2',
        sellerId: 'usr_farmer_2',
        sellerName: 'Savitri Devi',
        sellerPhone: '9822334455',
        sellerLocation: 'Nashik, Maharashtra',
        name: 'Heirloom Desi Tomato Seeds (Desi Tamatar)',
        category: 'Seeds',
        description: 'Non-GMO, open-pollinated indigenous variety with high lycopene, robust wilt resistance and rich tangy aroma.',
        price: 180.0,
        unit: '100g pack',
        imageUrl: null,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ProductModel(
        id: 'prod_3',
        sellerId: 'usr_farmer_1',
        sellerName: 'Ramesh Patil',
        sellerPhone: '9876543210',
        sellerLocation: 'Baramati, Maharashtra',
        name: 'Enriched Earthworm Vermicompost',
        category: 'Natural Fertilizers',
        description: 'Matured for 90 days with cow dung and neem leaves. Rich in beneficial mycorrhizae and micronutrients.',
        price: 650.0,
        unit: '25 kg bag',
        imageUrl: null,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      ProductModel(
        id: 'prod_4',
        sellerId: 'usr_farmer_2',
        sellerName: 'Savitri Devi',
        sellerPhone: '9822334455',
        sellerLocation: 'Nashik, Maharashtra',
        name: 'Fresh Harvested Organic Seedless Grapes',
        category: 'Fruits',
        description: 'Directly harvested from certified organic vineyards. Free from synthetic fungicide sprays.',
        price: 120.0,
        unit: 'kg',
        imageUrl: null,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProductModel(
        id: 'prod_5',
        sellerId: 'usr_farmer_1',
        sellerName: 'Ramesh Patil',
        sellerPhone: '9876543210',
        sellerLocation: 'Baramati, Maharashtra',
        name: 'Solar Powered Pest Light Trap',
        category: 'Farming Equipment',
        description: 'Automatic day-night sensor light trap for monitoring and trapping nocturnal moths, bollworms, and leaf folders.',
        price: 1850.0,
        unit: 'piece',
        imageUrl: null,
        inStock: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ]);
  }

  // --- PERSISTENCE HELPERS ---
  Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, json.encode(_users.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kComplaints, json.encode(_complaints.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNotifications, json.encode(_notifications.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistPosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPosts, json.encode(_posts.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProducts, json.encode(_products.map((e) => e.toJson()).toList()));
  }

  // --- USER OPERATIONS ---
  List<UserModel> getUsers() => List.unmodifiable(_users);

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  UserModel? getUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> createUser(UserModel user) async {
    _users.insert(0, user);
    await _persistUsers();
    return user;
  }

  // --- COMPLAINT OPERATIONS ---
  List<ComplaintModel> getAllComplaints() {
    // Return sorted newest first
    final list = List<ComplaintModel>.from(_complaints);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<ComplaintModel> getComplaintsByUser(String userId) {
    final list = _complaints.where((c) => c.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  ComplaintModel? getComplaintById(String complaintId) {
    try {
      return _complaints.firstWhere((c) => c.complaintId.toUpperCase() == complaintId.trim().toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Future<ComplaintModel> addComplaint(ComplaintModel complaint) async {
    _complaints.insert(0, complaint);
    await _persistComplaints();

    // Auto-create confirmation notification for farmer
    final notif = NotificationModel(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: complaint.userId,
      complaintId: complaint.complaintId,
      title: 'Complaint Registered Successfully',
      message: 'Your complaint #${complaint.complaintId} regarding ${complaint.category} has been received and queued for review.',
      type: 'complaint_submitted',
      isRead: false,
      createdAt: DateTime.now(),
    );
    await addNotification(notif);

    return complaint;
  }

  /// Admin updates status and adds remarks.
  /// Automatically generates notification for the complaint owner!
  Future<ComplaintModel> updateComplaintStatus({
    required String complaintId,
    required String newStatus,
    String? remarks,
  }) async {
    final index = _complaints.indexWhere((c) => c.complaintId.toUpperCase() == complaintId.trim().toUpperCase());
    if (index == -1) {
      throw Exception('Complaint #$complaintId not found.');
    }

    final old = _complaints[index];
    final isNowResolved = newStatus == 'Resolved';

    final updated = old.copyWith(
      status: newStatus,
      adminRemarks: remarks ?? old.adminRemarks,
      updatedAt: DateTime.now(),
      resolvedAt: isNowResolved ? DateTime.now() : (newStatus == 'In Progress' ? null : old.resolvedAt),
    );

    _complaints[index] = updated;
    await _persistComplaints();

    // Generate Targeted Notification for this Farmer
    String notifTitle;
    String notifMessage;
    String notifType;

    if (newStatus == 'Resolved') {
      notifTitle = 'Complaint Resolved!';
      notifMessage = 'Your complaint #${old.complaintId} regarding ${old.category} has been successfully resolved by the administration.';
      notifType = 'complaint_resolved';
    } else if (newStatus == 'In Progress') {
      notifTitle = 'Complaint In Progress';
      notifMessage = 'Administrative review has begun for complaint #${old.complaintId}: ${remarks ?? "Action is being taken."}';
      notifType = 'complaint_in_progress';
    } else if (newStatus == 'Rejected') {
      notifTitle = 'Complaint Status Update';
      notifMessage = 'Complaint #${old.complaintId} was reviewed and closed: ${remarks ?? "See remarks for details."}';
      notifType = 'admin_response';
    } else {
      notifTitle = 'Complaint Remarks Added';
      notifMessage = 'Admin updated remarks for #${old.complaintId}: ${remarks ?? ""}';
      notifType = 'admin_response';
    }

    final notif = NotificationModel(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: old.userId,
      complaintId: old.complaintId,
      title: notifTitle,
      message: notifMessage,
      type: notifType,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await addNotification(notif);

    return updated;
  }

  // --- NOTIFICATION OPERATIONS ---
  List<NotificationModel> getNotificationsForUser(String userId) {
    final list = _notifications.where((n) => n.userId == userId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int getUnreadNotificationCount(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    await _persistNotifications();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistNotifications();
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _persistNotifications();
  }

  // --- COMMUNITY POST OPERATIONS ---
  List<CommunityPostModel> getCommunityPosts() {
    final list = List<CommunityPostModel>.from(_posts);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<CommunityPostModel> addCommunityPost(CommunityPostModel post) async {
    _posts.insert(0, post);
    await _persistPosts();
    return post;
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final likedList = List<String>.from(post.likedUserIds);
      int newLikes = post.likes;

      if (likedList.contains(userId)) {
        likedList.remove(userId);
        newLikes = (newLikes > 0) ? newLikes - 1 : 0;
      } else {
        likedList.add(userId);
        newLikes += 1;
      }

      _posts[index] = post.copyWith(
        likes: newLikes,
        likedUserIds: likedList,
      );
      await _persistPosts();
    }
  }

  Future<void> addPostComment(String postId, CommentModel comment) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final comments = List<CommentModel>.from(post.comments)..add(comment);
      _posts[index] = post.copyWith(comments: comments);
      await _persistPosts();
    }
  }

  Future<void> deleteCommunityPost(String postId) async {
    _posts.removeWhere((p) => p.id == postId);
    await _persistPosts();
  }

  // --- PRODUCT OPERATIONS ---
  List<ProductModel> getProducts() {
    final list = List<ProductModel>.from(_products);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    _products.insert(0, product);
    await _persistProducts();
    return product;
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await _persistProducts();
  }
}
