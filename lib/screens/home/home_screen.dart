import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/services/firestore_service.dart';
import '../notices/notices_screen.dart'; // For Notice model
import '../maintenance/maintenance_screen.dart';
import '../events/events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      // 1. Load Profile
      final doc = await _firestoreService.getUserProfile(_currentUser!.uid);
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
        });
      }

      // 2. Check & Generate Monthly Bill
      await _firestoreService.generateMonthlyBillIfMissing(_currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                offset: const Offset(0, -0.2),
                child: _buildHeader(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: _buildStatusBar(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: _buildTabSection(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: _buildMaintenanceCard(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 500),
                child: _buildComplaintsCard(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 600),
                child: _buildNoticesSection(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 700),
                child: _buildUpcomingEventCard(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 800),
                child: _buildSecuritySection(context),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleOnTap(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Raise complaint',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.cardWhite,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SV',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spring Valley',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Housing Society',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ScaleOnTap(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Icon(Icons.notifications_outlined, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      color: AppTheme.cardWhite,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, ${_userData?['name']?.split(' ')[0] ?? 'Resident'} 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back home',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment_rounded, color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (_userData?['tower'] != null && _userData?['flatNo'] != null)
                          ? '${_userData!['tower']} • Flat ${_userData!['flatNo']}'
                          : (_userData?['flatNo'] != null && _userData!['flatNo'].toString().isNotEmpty
                              ? 'Flat ${_userData!['flatNo']}'
                              : 'No Flat Assigned'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.darkGreen,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'All systems active',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.darkGreen.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(context, 'Overview', true),
            _buildTab(context, 'Maintenance', false),
            _buildTab(context, 'Security', false),
            _buildTab(context, 'Events', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, bool isSelected) {
    return ScaleOnTap(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textDark : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _currentUser != null ? _firestoreService.getMaintenanceBills(_currentUser!.uid) : null,
      builder: (context, snapshot) {
        double totalDue = 0;
        DateTime? nextDueDate;
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'pending') {
              totalDue += (data['amount'] ?? 0).toDouble();
              final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
              if (dueDate != null) {
                if (nextDueDate == null || dueDate.isBefore(nextDueDate)) {
                  nextDueDate = dueDate;
                }
              }
            }
          }
        }

        return ScaleOnTap(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: AppTheme.cardDecoration,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppTheme.orange),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maintenance Due',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              nextDueDate != null 
                                  ? 'Due by ${_formatDate(nextDueDate)}'
                                  : 'No pending dues',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (totalDue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Pending',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${totalDue.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.textDark,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.textDark.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Pay Now',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintsCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getComplaints(),
      builder: (context, snapshot) {
        int openCount = 0;
        int inProgressCount = 0;
        int resolvedCount = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];
            if (status == 'open') openCount++;
            else if (status == 'inProgress') inProgressCount++;
            else if (status == 'resolved') resolvedCount++;
          }
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          decoration: AppTheme.cardDecoration,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Complaints',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textLight),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildComplaintStatus('Open', '$openCount', AppTheme.blue, Icons.pending_actions_rounded)),
                    Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                    Expanded(child: _buildComplaintStatus('In Progress', '$inProgressCount', AppTheme.orange, Icons.construction_rounded)),
                    Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                    Expanded(child: _buildComplaintStatus('Resolved', '$resolvedCount', AppTheme.primaryGreen, Icons.check_circle_outline_rounded)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintStatus(String label, String count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNoticesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notice Board',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ScaleOnTap(
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getNotices(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text('Error loading notices');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: const Center(child: Text('No notices')),
                );
              }

              // Take top 2 notices
              final recentNotices = docs.take(2).map((doc) => Notice.fromFirestore(doc)).toList();

              return Column(
                children: recentNotices.map((notice) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildNoticeCard(
                      context,
                      notice.title,
                      notice.description,
                      _formatDate(notice.date),
                      notice.category,
                      DateTime.now().difference(notice.date).inHours < 24,
                      _getCategoryIcon(notice.category),
                      _getCategoryColor(notice.category),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Maintenance': return Icons.build_circle_outlined;
      case 'Events': return Icons.celebration_rounded;
      case 'Important': return Icons.campaign_rounded;
      default: return Icons.article_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Maintenance': return Colors.orange;
      case 'Events': return Colors.purple;
      case 'Important': return Colors.red;
      default: return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Widget _buildNoticeCard(BuildContext context, String title, String description, String time, String category, bool isNew, IconData icon, Color iconColor) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                      if (isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textLight),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textLight.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getEvents(),
      builder: (context, snapshot) {
        // Default/Loading state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEventCardContent(context, null);
        }

        // Get the first upcoming event
        final now = DateTime.now();
        final docs = snapshot.data!.docs;
        Map<String, dynamic>? nextEvent;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp?)?.toDate();
          if (date != null && date.isAfter(now)) {
            nextEvent = data;
            break; // Since it's ordered by date, the first one after now is the next event
          }
        }

        return _buildEventCardContent(context, nextEvent);
      },
    );
  }

  Widget _buildEventCardContent(BuildContext context, Map<String, dynamic>? event) {
    final title = event?['title'] ?? 'No Upcoming Events';
    final category = event != null ? 'Community Event' : 'Stay Tuned';
    final date = (event?['date'] as Timestamp?)?.toDate();
    final dateStr = date != null ? DateFormat('MMM dd').format(date) : '';

    return ScaleOnTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Event',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textLight),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: AppTheme.cardDecoration,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.orange, AppTheme.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(
                            Icons.celebration_rounded,
                            size: 150,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Text(
                                  category,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (dateStr.isNotEmpty)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    dateStr.split(' ')[0],
                                    style: TextStyle(
                                      color: AppTheme.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dateStr.split(' ')[1],
                                    style: TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSecuritySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gate Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ScaleOnTap(
                child: Text(
                  'View log',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getVisitors(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text('Error loading logs');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: const Center(child: Text('No recent activity')),
                );
              }

              final latestVisitor = docs.first.data() as Map<String, dynamic>;
              final name = latestVisitor['name'] ?? 'Visitor';
              final type = latestVisitor['type'] ?? 'Guest';
              final status = latestVisitor['status'] ?? 'Waiting';
              final timestamp = (latestVisitor['entryTime'] as Timestamp?)?.toDate() ?? DateTime.now();

              return Container(
                decoration: AppTheme.cardDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type == 'Delivery' ? Icons.local_shipping_rounded : Icons.person, 
                          color: AppTheme.blue
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                            ),
                            Text(
                              status,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTimeAgo(timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}