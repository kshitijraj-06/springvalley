import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/admin_wrapper.dart';
import '../../core/services/firestore_service.dart';
import '../../core/widgets/styled_bottom_sheet.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getComplaints(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final complaints = docs.map((doc) => Complaint.fromFirestore(doc)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildComplaintsList(complaints),
              _buildComplaintsList(complaints.where((c) => c.status == ComplaintStatus.open).toList()),
              _buildComplaintsList(complaints.where((c) => c.status == ComplaintStatus.inProgress).toList()),
              _buildComplaintsList(complaints.where((c) => c.status == ComplaintStatus.resolved).toList()),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: ScaleOnTap(
          child: FloatingActionButton.extended(
            onPressed: () => _showRaiseComplaintDialog(),
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Raise Complaint', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List<Complaint> complaints) {
    if (complaints.isEmpty) {
      return Center(
        child: FadeSlideTransition(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No complaints found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to raise your first complaint',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return FadeSlideTransition(
          delay: Duration(milliseconds: 100 * index),
          child: _buildComplaintCard(complaint),
        );
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return ScaleOnTap(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showComplaintDetail(complaint),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(complaint.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(complaint.status).toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(complaint.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatDate(complaint.createdAt),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        AdminWrapper(
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _deleteComplaint(complaint.id),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        complaint.category,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (complaint.priority == Priority.high)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'HIGH',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
      ),
    );
  }

  Future<void> _deleteComplaint(String id) async {
    try {
      await _firestoreService.deleteComplaint(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting complaint: $e')),
        );
      }
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open: return Colors.blue;
      case ComplaintStatus.inProgress: return Colors.orange;
      case ComplaintStatus.resolved: return Colors.green;
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.open: return 'Open';
      case ComplaintStatus.inProgress: return 'In Progress';
      case ComplaintStatus.resolved: return 'Resolved';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  void _showComplaintDetail(Complaint complaint) {
    showStyledBottomSheet(
      context: context,
      builder: (context, scrollController) => StyledBottomSheet(
        title: complaint.title,
        scrollController: scrollController,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTimeline(complaint),
            const SizedBox(height: 24),
            AdminWrapper(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Actions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ComplaintStatus>(
                      value: complaint.status,
                      decoration: const InputDecoration(
                        labelText: 'Update Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: ComplaintStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusText(status)),
                        );
                      }).toList(),
                      onChanged: (newStatus) async {
                        if (newStatus != null && newStatus != complaint.status) {
                          try {
                            String statusString;
                            switch (newStatus) {
                              case ComplaintStatus.open: statusString = 'open'; break;
                              case ComplaintStatus.inProgress: statusString = 'inProgress'; break;
                              case ComplaintStatus.resolved: statusString = 'resolved'; break;
                            }
                            await _firestoreService.updateComplaintStatus(complaint.id, statusString);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Status updated successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating status: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(Complaint complaint) {
    return Column(
      children: [
        _buildTimelineItem('Created', true, true),
        _buildTimelineItem('Assigned', complaint.status != ComplaintStatus.open, false),
        _buildTimelineItem('In Progress', complaint.status == ComplaintStatus.inProgress || complaint.status == ComplaintStatus.resolved, false),
        _buildTimelineItem('Resolved', complaint.status == ComplaintStatus.resolved, false),
      ],
    );
  }

  Widget _buildTimelineItem(String title, bool isCompleted, bool isFirst) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            if (!isFirst)
              Container(
                width: 2,
                height: 30,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isCompleted ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showRaiseComplaintDialog() {
    showStyledBottomSheet(
      context: context,
      builder: (context, scrollController) => RaiseComplaintForm(scrollController: scrollController),
    );
  }
}

class RaiseComplaintForm extends StatefulWidget {
  final ScrollController scrollController;
  const RaiseComplaintForm({super.key, required this.scrollController});

  @override
  State<RaiseComplaintForm> createState() => _RaiseComplaintFormState();
}

class _RaiseComplaintFormState extends State<RaiseComplaintForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  final List<String> _categories = [
    'Plumbing',
    'Electrical',
    'Maintenance',
    'Security',
    'Cleaning',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return StyledBottomSheet(
      title: 'Raise Complaint',
      scrollController: widget.scrollController,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt),
            label: const Text('Attach Images'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      bottomAction: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitComplaint,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Submit Complaint'),
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (_selectedCategory == null || _titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestoreService.addComplaint({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'status': 'open',
        'priority': 'medium', // Default
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}


enum ComplaintStatus { open, inProgress, resolved }
enum Priority { low, medium, high }

class Complaint {
  final String id;
  final String title;
  final String category;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final Priority priority;

  Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.priority,
  });

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: _parsePriority(data['priority']),
    );
  }

  static ComplaintStatus _parseStatus(String? status) {
    switch (status) {
      case 'inProgress': return ComplaintStatus.inProgress;
      case 'resolved': return ComplaintStatus.resolved;
      default: return ComplaintStatus.open;
    }
  }

  static Priority _parsePriority(String? priority) {
    switch (priority) {
      case 'high': return Priority.high;
      case 'low': return Priority.low;
      default: return Priority.medium;
    }
  }
}