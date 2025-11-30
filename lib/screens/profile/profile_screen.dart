import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/animations.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/widgets/styled_dialog.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      try {
        final doc = await _firestoreService.getUserProfile(_currentUser!.uid);
        if (doc.exists) {
          setState(() {
            _userData = doc.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameController = TextEditingController(text: _userData?['name'] ?? '');
    final phoneController = TextEditingController(text: _userData?['phone'] ?? '');
    final towerController = TextEditingController(text: _userData?['tower'] ?? '');
    final flatController = TextEditingController(text: _userData?['flatNo'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => StyledDialog(
        title: 'Edit Profile',
        icon: Icons.edit_outlined,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(nameController, 'Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildDialogTextField(phoneController, 'Phone', Icons.phone_outlined, isPhone: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDialogTextField(towerController, 'Tower', Icons.apartment)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDialogTextField(flatController, 'Flat No', Icons.door_front_door)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          StyledButton(
            text: 'Save',
            onPressed: () async {
              try {
                await _firestoreService.updateUserProfile(_currentUser!.uid, {
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'tower': towerController.text,
                  'flatNo': flatController.text,
                });
                Navigator.pop(context);
                _loadUserData(); // Reload data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating profile: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showFamilyMemberDialog({String? memberId, Map<String, dynamic>? data}) async {
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final relationController = TextEditingController(text: data?['relation'] ?? '');
    final isEditing = memberId != null;

    await showDialog(
      context: context,
      builder: (context) => StyledDialog(
        title: isEditing ? 'Edit Family Member' : 'Add Family Member',
        icon: Icons.family_restroom,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(nameController, 'Name', Icons.person_outline),
            const SizedBox(height: 16),
            _buildDialogTextField(relationController, 'Relation (e.g. Spouse, Son)', Icons.favorite_outline),
          ],
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          StyledButton(
            text: 'Save',
            onPressed: () async {
              if (nameController.text.isEmpty || relationController.text.isEmpty) return;
              
              try {
                if (isEditing) {
                  await _firestoreService.updateFamilyMember(_currentUser!.uid, memberId, {
                    'name': nameController.text,
                    'relation': relationController.text,
                  });
                } else {
                  await _firestoreService.addFamilyMember(_currentUser!.uid, {
                    'name': nameController.text,
                    'relation': relationController.text,
                  });
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEditing ? 'Member updated' : 'Member added')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  // ... (deleteFamilyMember remains same)

  // ... (build methods remain same)

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StyledDialog(
        title: 'Logout',
        icon: Icons.logout,
        iconColor: Colors.redAccent,
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          StyledButton(
            text: 'Logout',
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFamilyMember(String memberId) async {
    try {
      await _firestoreService.deleteFamilyMember(_currentUser!.uid, memberId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting member: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 100),
                  child: _buildMemberStats(context),
                ),
                const SizedBox(height: 24),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSectionTitle(context, 'Personal Details'),
                ),
                const SizedBox(height: 12),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 300),
                  child: _buildInfoCard(
                    context,
                    [
                      _buildProfileItem(context, Icons.person_outline, 'Name', _userData?['name'] ?? 'N/A'),
                      _buildDivider(),
                      _buildProfileItem(context, Icons.email_outlined, 'Email', _userData?['email'] ?? 'N/A'),
                      _buildDivider(),
                      _buildProfileItem(context, Icons.phone_outlined, 'Phone', _userData?['phone'] ?? 'N/A'),
                      _buildDivider(),
                      _buildProfileItem(
                        context, 
                        Icons.home_outlined, 
                        'Residence', 
                        (_userData?['tower'] != null && _userData?['flatNo'] != null)
                            ? '${_userData!['tower']} - ${_userData!['flatNo']}'
                            : (_userData?['flatNo'] ?? 'Not Assigned')
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context, 'Family Members'),
                      IconButton(
                        onPressed: () => _showFamilyMemberDialog(),
                        icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 500),
                  child: _buildFamilyMembersList(),
                ),
                // --- Pending Requests Section ---
                if (_userData?['role'] == 'resident') ...[
                  const SizedBox(height: 24),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 550),
                    child: _buildSectionTitle(context, 'Pending Requests'),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideTransition(
                    delay: const Duration(milliseconds: 550),
                    child: _buildPendingRequestsList(),
                  ),
                ],
                const SizedBox(height: 24),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 600),
                  child: _buildSectionTitle(context, 'Settings'),
                ),
                const SizedBox(height: 12),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 700),
                  child: _buildInfoCard(
                    context,
                    [
                      _buildSettingItem(context, Icons.notifications_outlined, 'Notifications', () {}),
                      _buildDivider(),
                      _buildSettingItem(context, Icons.security_outlined, 'Privacy & Security', () {}),
                      _buildDivider(),
                      _buildSettingItem(context, Icons.help_outline, 'Help & Support', () {}),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 800),
                  child: ScaleOnTap(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // --- Developer Option for Testing ---
                Center(
                  child: TextButton(
                    onPressed: () async {
                      if (_currentUser != null) {
                        final newRole = _userData?['role'] == 'admin' ? 'resident' : 'admin';
                        await _firestoreService.updateUserProfile(_currentUser!.uid, {'role': newRole});
                        _loadUserData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Role switched to $newRole')),
                        );
                      }
                    },
                    child: const Text(
                      'Dev: Switch Role (Admin/Resident)',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withBlue(100),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    (_userData?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _userData?['name'] ?? 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (_userData?['tower'] != null && _userData?['flatNo'] != null)
                      ? '${_userData!['tower']} - ${_userData!['flatNo']}'
                      : (_userData?['flatNo'] != null && _userData!['flatNo'].toString().isNotEmpty
                          ? 'Flat ${_userData!['flatNo']}'
                          : 'No Flat Assigned'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showEditProfileDialog,
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildMemberStats(BuildContext context) {
    final role = (_userData?['role'] ?? 'resident').toString().toUpperCase();
    final joinDate = _userData?['createdAt'] != null
        ? DateFormat('MMM yyyy').format((_userData!['createdAt'] as Timestamp).toDate())
        : 'Unknown';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(context, 'ROLE', role, Icons.badge_outlined, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(context, 'JOINED', joinDate, Icons.calendar_today_outlined, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[100], indent: 56);
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersList() {
    if (_currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getFamilyMembers(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.family_restroom, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Text(
                  'No family members added',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: docs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              final data = doc.data() as Map<String, dynamic>;
              final isLast = index == docs.length - 1;

              return Column(
                children: [
                  _buildFamilyMemberItem(doc.id, data),
                  if (!isLast) _buildDivider(),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsList() {
    if (_currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getPendingFamilyRequests(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              'No pending requests',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: docs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              final data = doc.data() as Map<String, dynamic>;
              final isLast = index == docs.length - 1;

              return Column(
                children: [
                  _buildPendingRequestItem(doc.id, data),
                  if (!isLast) _buildDivider(),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestItem(String id, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange[100],
            child: Text(
              (data['name'] ?? 'U').substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Requesting to join',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _handleRequestResponse(id, false),
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Reject',
              ),
              IconButton(
                onPressed: () => _handleRequestResponse(id, true),
                icon: const Icon(Icons.check, color: Colors.green),
                tooltip: 'Accept',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleRequestResponse(String memberId, bool accept) async {
    try {
      await _firestoreService.respondToFamilyRequest(memberId, accept);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? 'Request Accepted' : 'Request Rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildFamilyMemberItem(String id, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[200],
            child: Text(
              (data['name'] ?? 'U').substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  data['relation'] ?? 'Relation',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            onSelected: (value) {
              if (value == 'edit') {
                _showFamilyMemberDialog(memberId: id, data: data);
              } else if (value == 'delete') {
                _deleteFamilyMember(id);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  // void _showLogoutDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Logout'),
  //       content: const Text('Are you sure you want to logout?'),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _handleLogout();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //           ),
  //           child: const Text('Logout', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}