import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _complaints => _db.collection('complaints');
  CollectionReference get _visitors => _db.collection('visitors');
  CollectionReference get _notices => _db.collection('notices');

  // --- User Operations ---
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set(data);
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _users.doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] ?? 'resident';
      }
      return 'resident';
    } catch (e) {
      return 'resident';
    }
  }

  Future<bool> isAdmin(String uid) async {
    final role = await getUserRole(uid);
    return role == 'admin';
  }

  // --- Family Member Operations ---
  Stream<QuerySnapshot> getFamilyMembers(String uid) {
    return _users.doc(uid).collection('family').orderBy('createdAt').snapshots();
  }

  Future<void> addFamilyMember(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).collection('family').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFamilyMember(String uid, String memberId, Map<String, dynamic> data) async {
    await _users.doc(uid).collection('family').doc(memberId).update(data);
  }

  Future<void> deleteFamilyMember(String uid, String memberId) async {
    await _users.doc(uid).collection('family').doc(memberId).delete();
  }

  // --- Complaint Operations ---
  Future<void> addComplaint(Map<String, dynamic> data) async {
    await _complaints.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getComplaints() {
    return _complaints.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> deleteComplaint(String id) async {
    await _complaints.doc(id).delete();
  }

  Future<void> updateComplaintStatus(String id, String status) async {
    await _complaints.doc(id).update({'status': status});
  }

  // --- Visitor Operations ---
  Future<void> addVisitor(Map<String, dynamic> data) async {
    await _visitors.add({
      ...data,
      'entryTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getVisitors() {
    return _visitors.orderBy('entryTime', descending: true).snapshots();
  }

  // --- Notice Operations ---
  Stream<QuerySnapshot> getNotices() {
    return _notices.orderBy('date', descending: true).snapshots();
  }

  Future<void> addNotice(Map<String, dynamic> data) async {
    await _notices.add({
      ...data,
      'date': FieldValue.serverTimestamp(),
      'isRead': false, // Default
    });
  }

  Future<void> deleteNotice(String id) async {
    await _notices.doc(id).delete();
  }
  // --- Maintenance Operations ---
  CollectionReference get _maintenance => _db.collection('maintenance_bills');

  Stream<QuerySnapshot> getMaintenanceBills(String uid) {
    return _maintenance
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Future<void> payMaintenanceBill(String billId) async {
    await _maintenance.doc(billId).update({
      'status': 'paid',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  // For testing/admin purposes
  Future<void> createMaintenanceBill(Map<String, dynamic> data) async {
    await _maintenance.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // pending, paid
    });
  }

  Future<void> generateMonthlyBillIfMissing(String uid) async {
    final now = DateTime.now();
    final currentMonth = "${_getMonthName(now.month)} ${now.year}";

    // Check if bill exists for this month
    final query = await _maintenance
        .where('userId', isEqualTo: uid)
        .where('month', isEqualTo: currentMonth)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      // Generate bill
      await createMaintenanceBill({
        'userId': uid,
        'amount': 1000, // Fixed amount as requested
        'month': currentMonth,
        'dueDate': now.add(const Duration(days: 7)), // Due in 7 days
        'status': 'pending',
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // --- Events Operations ---
  CollectionReference get _events => _db.collection('events');

  Stream<QuerySnapshot> getEvents() {
    return _events.orderBy('date', descending: false).snapshots();
  }

  Future<void> addEvent(Map<String, dynamic> data) async {
    await _events.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Family Association Logic ---

  // Find a resident by phone number
  Future<DocumentSnapshot?> findUserByPhone(String phone) async {
    // 1. Try exact match
    var query = await _users
        .where('phone', isEqualTo: phone)
        .where('role', isEqualTo: 'resident')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }

    // 2. Handle +91 prefix variations
    String altPhone;
    if (phone.startsWith('+91')) {
      altPhone = phone.substring(3).trim(); // Try without +91
    } else {
      altPhone = '+91${phone.trim()}'; // Try with +91
    }

    query = await _users
        .where('phone', isEqualTo: altPhone)
        .where('role', isEqualTo: 'resident')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }

    return null;
  }

  // Link a family member to a resident
  Future<void> linkFamilyMember(String memberUid, String residentUid) async {
    await _users.doc(memberUid).update({
      'linkedResidentId': residentUid,
      'associationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Check association status for a user
  Future<Map<String, dynamic>?> checkFamilyAssociation(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('linkedResidentId')) {
        return {
          'linkedResidentId': data['linkedResidentId'],
          'status': data['associationStatus'] ?? 'pending',
        };
      }
    }
    return null;
  }

  // Get pending requests for a resident
  Stream<QuerySnapshot> getPendingFamilyRequests(String residentUid) {
    return _users
        .where('linkedResidentId', isEqualTo: residentUid)
        .where('associationStatus', isEqualTo: 'pending')
        .snapshots();
  }

  // Accept or Reject request
  Future<void> respondToFamilyRequest(String memberUid, bool accept) async {
    final status = accept ? 'approved' : 'rejected';
    
    Map<String, dynamic> updateData = {
      'associationStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (accept) {
      // If accepted, we need to get the resident's details to inherit tower/flat
      final memberDoc = await _users.doc(memberUid).get();
      final memberData = memberDoc.data() as Map<String, dynamic>;
      final residentUid = memberData['linkedResidentId'];

      if (residentUid != null) {
        final residentDoc = await _users.doc(residentUid).get();
        if (residentDoc.exists) {
          final residentData = residentDoc.data() as Map<String, dynamic>;
          
          // Inherit details
          updateData['tower'] = residentData['tower'];
          updateData['flatNo'] = residentData['flatNo'];

          // Add to resident's family subcollection
          await _users.doc(residentUid).collection('family').doc(memberUid).set({
            'name': memberData['name'],
            'relation': 'Family Member', // Default
            'uid': memberUid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    await _users.doc(memberUid).update(updateData);
  }
}
