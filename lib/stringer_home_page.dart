import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class StringerHomePage extends StatefulWidget {
  const StringerHomePage({super.key});

  @override
  State<StringerHomePage> createState() => _StringerHomePageState();
}

class _StringerHomePageState extends State<StringerHomePage> {
  final Set<String> _expandedRequests = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF003057),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF003057),
              Color(0xFF001A2E),
              Color(0xFF000F1A),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: const Color(0xFF001A2E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 48),
                        const Expanded(
                          child: Text(
                            "Stringer Dashboard",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            await AuthService().signOut();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Manage all stringing requests',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('stringingRequests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final requests = snapshot.data?.docs ?? [];

                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'No stringing requests found',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  );
                }

                requests.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });

                return Column(
                  children: requests.map((request) {
                    final data = request.data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final dateTime = timestamp?.toDate();
                    final isExpanded = _expandedRequests.contains(request.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Colors.white.withOpacity(0.1),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedRequests.remove(request.id);
                            } else {
                              _expandedRequests.add(request.id);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Request ID: ${request.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(request.reference.parent.parent!.id)
                                              .get(),
                                          builder: (context, userSnapshot) {
                                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Text('Loading...', style: TextStyle(fontSize: 12, color: Colors.grey));
                                            }
                                            
                                            if (userSnapshot.hasError || !userSnapshot.hasData) {
                                              return const Text('User info unavailable', style: TextStyle(fontSize: 12, color: Colors.grey));
                                            }
                                            
                                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                            final displayName = userData?['displayName'] as String?;
                                            final firstName = userData?['firstName'] as String?;
                                            final lastName = userData?['lastName'] as String?;
                                            final email = userData?['email'] as String?;
                                            
                                            String customerName = displayName ?? 
                                                ((firstName != null || lastName != null) ? '${firstName ?? ''} ${lastName ?? ''}'.trim() : null) ??
                                                email?.split('@').first ?? 'Unknown Customer';
                                            
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  customerName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (email != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    email,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 2),
                                                Text(
                                                  data['racket'] ?? 'Unknown racket',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getProgressColor(data['progress'] ?? 'Not received'),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              data['progress'] ?? 'Not received',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _showDeleteDialog(request.reference.parent.parent!.id, request.id),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (data['paidStatus'] == true) ? Colors.green : Colors.orange,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          (data['paidStatus'] == true) ? 'Paid' : 'Unpaid',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Text('Colors: ${_formatColors(data['racketColors'])}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Grip Color: ${data['gripColor'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('String Type: ${(data['stringType'] ?? 'Unknown').toString().replaceAll('\n', ' ')} - \$${data['cost'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Tension: ${data['tension'] ?? 'Unknown'} lbs', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('Payment Method: ${data['paymentMethod'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                if (data['additionalInfo'] != null && data['additionalInfo'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('Additional Info: ${data['additionalInfo']}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Submitted: ${_formatDateTime(dateTime)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Payment Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          Switch(
                                            value: data['paidStatus'] == true,
                                            onChanged: (value) {
                                              _updateRequestStatus(
                                                request.reference.parent.parent!.id, 
                                                request.id, 
                                                'paidStatus', 
                                                value
                                              );
                                            },
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.orange,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Progress:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                          const SizedBox(height: 4),
                                          _buildProgressButtons(request.reference.parent.parent!.id, request.id, data['progress'] ?? 'Not received'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(String progress) {
    switch (progress) {
      case 'Not received':
        return Colors.orange;
      case 'Received':
        return Colors.blue;
      case 'In progress':
        return Colors.purple;
      case 'Ready for pickup':
        return Colors.amber;
      case 'Picked up':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatColors(dynamic colors) {
    if (colors == null) return 'Unknown';
    if (colors is List) {
      return colors.join(', ');
    }
    return colors.toString();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressButtons(String userId, String requestId, String currentProgress) {
    final progressStages = ['Not received', 'Received', 'In progress', 'Ready for pickup', 'Picked up'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: progressStages.map((stage) {
        final isSelected = stage == currentProgress;
        return ElevatedButton(
          onPressed: () => _updateRequestStatus(userId, requestId, 'progress', stage),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? _getProgressColor(stage) : Colors.grey.shade300,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            minimumSize: const Size(80, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: Text(stage),
        );
      }).toList(),
    );
  }

  Future<void> _updateRequestStatus(String userId, String requestId, String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('stringingRequests')
          .doc(requestId)
          .update({field: value});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  void _showDeleteDialog(String userId, String requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF001A2E),
          title: const Text(
            'Delete Request',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this stringing request? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRequest(userId, requestId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRequest(String userId, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('stringingRequests')
          .doc(requestId)
          .delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
