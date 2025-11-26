import 'package:flutter/material.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Complaint> _complaints = [
    Complaint(
      id: 'C001',
      title: 'Elevator Issue - Tower A',
      category: 'Maintenance',
      description: 'Elevator in Tower A is making strange noises and stops frequently.',
      status: ComplaintStatus.inProgress,
      createdDate: DateTime.now().subtract(const Duration(days: 3)),
      priority: Priority.high,
    ),
    Complaint(
      id: 'C002',
      title: 'Water Leakage in Parking',
      category: 'Plumbing',
      description: 'Water is leaking from the ceiling in the basement parking area.',
      status: ComplaintStatus.open,
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: Priority.medium,
    ),
    Complaint(
      id: 'C003',
      title: 'Security Gate Issue',
      category: 'Security',
      description: 'Main gate is not closing properly, causing security concerns.',
      status: ComplaintStatus.resolved,
      createdDate: DateTime.now().subtract(const Duration(days: 7)),
      priority: Priority.high,
    ),
  ];

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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintsList(_complaints),
          _buildComplaintsList(_complaints.where((c) => c.status == ComplaintStatus.open).toList()),
          _buildComplaintsList(_complaints.where((c) => c.status == ComplaintStatus.inProgress).toList()),
          _buildComplaintsList(_complaints.where((c) => c.status == ComplaintStatus.resolved).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRaiseComplaintDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Raise Complaint', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildComplaintsList(List<Complaint> complaints) {
    if (complaints.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return _buildComplaintCard(complaint);
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showComplaintDetail(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(complaint.status),
                      style: TextStyle(
                        color: _getStatusColor(complaint.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                complaint.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
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
                  const Spacer(),
                  Text(
                    'ID: ${complaint.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  void _showComplaintDetail(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatusTimeline(complaint),
              const SizedBox(height: 24),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const RaiseComplaintForm(),
    );
  }
}

class RaiseComplaintForm extends StatefulWidget {
  const RaiseComplaintForm({super.key});

  @override
  State<RaiseComplaintForm> createState() => _RaiseComplaintFormState();
}

class _RaiseComplaintFormState extends State<RaiseComplaintForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

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
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Raise Complaint',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complaint submitted successfully!')),
                  );
                },
                child: const Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
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
  final DateTime createdDate;
  final Priority priority;

  Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.createdDate,
    required this.priority,
  });
}