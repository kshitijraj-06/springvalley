import 'package:flutter/material.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Important', 'Events', 'Maintenance'];

  final List<Notice> _notices = [
    Notice(
      title: 'Water Supply Maintenance',
      description: 'Water supply will be interrupted tomorrow from 10 AM to 2 PM for maintenance work.',
      category: 'Maintenance',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      isImportant: true,
    ),
    Notice(
      title: 'Society Meeting',
      description: 'Monthly society meeting scheduled for this Saturday at 6 PM in the club house.',
      category: 'General',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      isImportant: false,
    ),
    Notice(
      title: 'New Year Celebration',
      description: 'Join us for the New Year celebration on Dec 31st at 8 PM. Entry fee: ₹500 per family.',
      category: 'Events',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      isImportant: false,
    ),
    Notice(
      title: 'Parking Rules Update',
      description: 'New parking rules effective from next month. Please check the detailed guidelines.',
      category: 'Important',
      date: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      isImportant: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredNotices.length,
                itemBuilder: (context, index) {
                  final notice = _filteredNotices[index];
                  return _buildNoticeCard(notice);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Notice> get _filteredNotices {
    if (_selectedFilter == 'All') return _notices;
    if (_selectedFilter == 'Important') return _notices.where((n) => n.isImportant).toList();
    return _notices.where((n) => n.category == _selectedFilter).toList();
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showNoticeDetail(notice),
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
                      notice.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: notice.isRead ? Colors.grey[700] : Colors.black,
                      ),
                    ),
                  ),
                  if (!notice.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (notice.isImportant) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'IMPORTANT',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notice.description,
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
                      color: _getCategoryColor(notice.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notice.category,
                      style: TextStyle(
                        color: _getCategoryColor(notice.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(notice.date),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Important': return Colors.red;
      case 'Events': return Colors.purple;
      case 'Maintenance': return Colors.orange;
      default: return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  void _showNoticeDetail(Notice notice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                      notice.title,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(notice.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      notice.category,
                      style: TextStyle(
                        color: _getCategoryColor(notice.category),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(notice.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                notice.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => notice.isRead = true);
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Read'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Notice {
  final String title;
  final String description;
  final String category;
  final DateTime date;
  bool isRead;
  final bool isImportant;

  Notice({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.isRead,
    required this.isImportant,
  });
}