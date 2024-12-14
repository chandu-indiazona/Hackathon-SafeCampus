import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting date and time

class ComplaintHistoryPage extends StatefulWidget {
  @override
  _ComplaintHistoryPageState createState() => _ComplaintHistoryPageState();
}

class _ComplaintHistoryPageState extends State<ComplaintHistoryPage> {
  final List<Complaint> complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('complaints')
            .where('studentUid', isEqualTo: user.uid)
            .get();

        setState(() {
          complaints.clear();
          for (var doc in snapshot.docs) {
            Timestamp timestamp = doc['timestamp'];
            DateTime complaintDateTime = timestamp.toDate();
            complaints.add(Complaint(
              id: doc.id, // Add document ID to fetch comments
              type: doc['incidentType'] ?? 'Unknown',
              date: DateFormat('yyyy-MM-dd').format(complaintDateTime),
              time: DateFormat('hh:mm a').format(complaintDateTime),
              location: doc['location'] ?? 'Unknown',
              status: doc['status'] ?? 'Unknown',
            ));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching complaints: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> _fetchComments(String complaintId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .collection('comments')
          .orderBy('timestamp') // Optional: Order comments by timestamp
          .get();

      // Use the correct field name for the comment content
      return snapshot.docs.map((doc) => doc['content'] as String).toList();
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  void _showCommentsDialog(BuildContext context, String complaintId) async {
    List<String> comments = await _fetchComments(complaintId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comments'),
        content: comments.isEmpty
            ? Text('No comments available.')
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: comments.map((comment) => Text('- $comment')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint History'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? Center(child: Text('No complaints found.'))
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _getStatusBorderColor(complaint.status),
                width: 2,
              ),
            ),
            color: _getStatusBackgroundColor(complaint.status),
            child: ListTile(
              leading: Icon(
                _getStatusIcon(complaint.status),
                color: _getStatusColor(complaint.status),
                size: 40,
              ),
              title: Text(
                '${complaint.type} - ${complaint.location}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(complaint.status),
                ),
              ),
              subtitle: Text(
                'Date: ${complaint.date}\nTime: ${complaint.time}\nStatus: ${complaint.status}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: complaint.status == 'Solved'
                  ? IconButton(
                icon: Icon(Icons.comment, color: Colors.orange),
                onPressed: () =>
                    _showCommentsDialog(context, complaint.id),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'solved':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_top;
      case 'unresolved':
        return Icons.pending;
      default:
        return Icons.error;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'solved':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'unresolved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'solved':
        return Colors.green[50]!;
      case 'processing':
        return Colors.blue[50]!;
      case 'unresolved':
        return Colors.red[50]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'solved':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'unresolved':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Complaint {
  final String id; // Document ID for fetching subcollection
  final String type;
  final String date;
  final String time;
  final String location;
  final String status;

  Complaint({
    required this.id,
    required this.type,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
  });
}
