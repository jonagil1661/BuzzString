import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  String? _selectedRequestId;
  Map<String, dynamic>? _selectedRequest;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF003057),
        appBar: AppBar(
          title: const Text('Track My Stringing'),
          backgroundColor: const Color(0xFF003057),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Please log in to track your stringing requests.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

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
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Track My Stringing",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProgressDisplay(),
                    const SizedBox(height: 20),
                    _buildRequestsList(user.uid),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('stringingRequests')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
          );
        }

        final requests = snapshot.data?.docs ?? [];
        
        requests.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        if (requests.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No stringing requests found.\nSubmit a request to start tracking!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'My Stringing Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...requests.map((request) {
              final data = request.data() as Map<String, dynamic>;
              final requestId = request.id;
              final isSelected = _selectedRequestId == requestId;

              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp?.toDate();
              final dateStr = date != null 
                  ? '${date.month}/${date.day}/${date.year}'
                  : 'Unknown date';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFB3A369).withOpacity(0.2) : Colors.transparent,
                  border: isSelected 
                      ? Border.all(color: const Color(0xFFB3A369), width: 2)
                      : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    data['racket'] ?? 'Unknown Racket',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('String: ${(data['stringType'] ?? 'Unknown').toString().replaceAll('\n', ' ')} - \$${data['cost'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Paid: ',
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextSpan(
                              text: (data['paidStatus'] == true) ? 'Yes' : 'No',
                              style: TextStyle(
                                color: (data['paidStatus'] == true) ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('Submitted: $dateStr', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isSelected ? const Color(0xFFB3A369) : Colors.white70,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedRequestId = requestId;
                      _selectedRequest = data;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildProgressDisplay() {
    if (_selectedRequest == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 80,
              color: Colors.white70,
            ),
            SizedBox(height: 20),
            Text(
              'Select a stringing request\nto view progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    final progress = _getProgressFromData();
    final progressValue = progress['value'] as double;
    final progressStage = progress['stage'] as String;
    final progressDescription = progress['description'] as String;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Request Progress',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progressValue),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progressStage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  progressDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildProgressSteps(progressValue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps(double progress) {
    final steps = [
      {'name': 'Received', 'threshold': 0.25},
      {'name': 'In progress', 'threshold': 0.5},
      {'name': 'Ready for pickup', 'threshold': 0.75},
      {'name': 'Picked up', 'threshold': 1.0},
    ];

    return Column(
      children: steps.map((step) {
        final threshold = step['threshold'] as double;
        final isCompleted = progress >= threshold;
        final isCurrent = progress >= (threshold - 0.33) && progress < threshold;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? const Color(0xFFB3A369) : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? const Color(0xFFB3A369) : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getProgressFromData() {
    final progressStatus = _selectedRequest?['progress'] as String? ?? 'Not received';
    double progressValue;
    String stageName;
    String description;
    
    switch (progressStatus) {
      case 'Not received':
        progressValue = 0.0;
        stageName = 'Not received';
        description = 'Waiting for the racket to be received.';
        break;
      case 'Received':
        progressValue = 0.25;
        stageName = 'Received';
        description = 'Your racket has been received.';
        break;
      case 'In progress':
        progressValue = 0.5;
        stageName = 'In progress';
        description = 'Your racket is currently being strung.';
        break;
      case 'Ready for pickup':
        progressValue = 0.75;
        stageName = 'Ready for pickup';
        description = 'Your racket is ready for pickup! Please pick it up at the club.';
        break;
      case 'Picked up':
        progressValue = 1.0;
        stageName = 'Picked up';
        description = 'Your racket has been successfully picked up.';
        break;
      default:
        progressValue = 0.0;
        stageName = 'Not received';
        description = 'Your stringing request has been submitted.';
    }
    
    return {
      'value': progressValue,
      'stage': stageName,
      'description': description,
    };
  }

  Color _getProgressColor(double progress) {
    if (progress == 0.0) return Colors.orange;
    if (progress == 0.25) return Colors.blue;
    if (progress == 0.5) return Colors.purple;
    if (progress == 0.75) return Colors.amber;
    if (progress == 1.0) return Colors.green;
    return Colors.grey;
  }
}
