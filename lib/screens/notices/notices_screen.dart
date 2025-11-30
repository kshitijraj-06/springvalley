import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/animations.dart';
import '../../core/services/firestore_service.dart';
import '../../core/widgets/styled_bottom_sheet.dart';

import '../../core/widgets/admin_wrapper.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Important', 'Events', 'Maintenance'];
  final FirestoreService _firestoreService = FirestoreService();

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
          FadeSlideTransition(
            delay: const Duration(milliseconds: 100),
            offset: const Offset(0, -0.2),
            child: _buildFilterTabs(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getNotices(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                final notices = docs.map((doc) => Notice.fromFirestore(doc)).toList();
                final filteredNotices = _filterNotices(notices);

                if (filteredNotices.isEmpty) {
                  return Center(
                    child: Text(
                      'No notices found',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: filteredNotices.length,
                    itemBuilder: (context, index) {
                      final notice = filteredNotices[index];
                      return FadeSlideTransition(
                        delay: Duration(milliseconds: 200 + (index * 100)),
                        child: _buildNoticeCard(notice),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AdminWrapper(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: ScaleOnTap(
            child: FloatingActionButton.extended(
              onPressed: _showAddNoticeDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Notice', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  List<Notice> _filterNotices(List<Notice> notices) {
    if (_selectedFilter == 'All') return notices;
    if (_selectedFilter == 'Important') return notices.where((n) => n.isImportant).toList();
    return notices.where((n) => n.category == _selectedFilter).toList();
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
            child: ScaleOnTap(
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return ScaleOnTap(
      child: Card(
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
                    AdminWrapper(
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteNotice(notice.id),
                      ),
                    ),
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
    showStyledBottomSheet(
      context: context,
      builder: (context, scrollController) => StyledBottomSheet(
        title: notice.title,
        scrollController: scrollController,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
        bottomAction: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() => notice.isRead = true);
              Navigator.pop(context);
            },
            child: const Text('Mark as Read'),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNotice(String id) async {
    try {
      await _firestoreService.deleteNotice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notice: $e')),
        );
      }
    }
  }

  void _showAddNoticeDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'General';
    bool isImportant = false;

    showStyledBottomSheet(
      context: context,
      builder: (context, scrollController) => StatefulBuilder(
        builder: (context, setModalState) => StyledBottomSheet(
          title: 'Add Notice',
          scrollController: scrollController,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['General', 'Events', 'Maintenance'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => setModalState(() => selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mark as Important'),
                value: isImportant,
                onChanged: (value) => setModalState(() => isImportant = value),
              ),
            ],
          ),
          bottomAction: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty) return;
                
                try {
                  await _firestoreService.addNotice({
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'category': selectedCategory,
                    'isImportant': isImportant,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notice added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding notice: $e')),
                    );
                  }
                }
              },
              child: const Text('Post Notice'),
            ),
          ),
        ),
      ),
    );
  }
}

class Notice {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  bool isRead;
  final bool isImportant;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.isRead,
    required this.isImportant,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      isImportant: data['isImportant'] ?? false,
    );
  }
}