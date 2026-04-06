import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NextPickupDropoffPage extends StatefulWidget {
  const NextPickupDropoffPage({super.key});

  @override
  State<NextPickupDropoffPage> createState() => _NextPickupDropoffPageState();
}

class _NextPickupDropoffPageState extends State<NextPickupDropoffPage> {
  Map<String, dynamic>? _cachedArrivalData;
  int _streamRetryKey = 0;

  Timestamp? _readTimestamp(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is Timestamp ? value : null;
  }

  bool _hasRequiredFields(Map<String, dynamic> data) {
    final date = (data['date'] as String?)?.trim() ?? '';
    final day = (data['dayOfWeek'] as String?)?.trim() ?? '';
    final start = (data['startTime'] as String?)?.trim() ?? '';
    final end = (data['endTime'] as String?)?.trim() ?? '';
    return date.isNotEmpty &&
        day.isNotEmpty &&
        start.isNotEmpty &&
        end.isNotEmpty;
  }

  Map<String, dynamic>? _selectArrivalData(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) return null;

    QueryDocumentSnapshot<Map<String, dynamic>>? selected;
    for (final doc in docs) {
      if (doc.id == 'current') {
        selected = doc;
        break;
      }
    }

    if (selected == null) {
      var latest = docs.first;
      var latestUpdated = _readTimestamp(latest.data(), 'updatedAt');
      for (final doc in docs.skip(1)) {
        final updated = _readTimestamp(doc.data(), 'updatedAt');
        if (latestUpdated == null && updated != null) {
          latest = doc;
          latestUpdated = updated;
          continue;
        }
        if (latestUpdated != null &&
            updated != null &&
            updated.compareTo(latestUpdated) > 0) {
          latest = doc;
          latestUpdated = updated;
        }
      }
      selected = latest;
    }

    return selected.data();
  }

  Widget _buildArrivalDetails(Map<String, dynamic> data) {
    final monthDay = (data['date'] as String?) ?? 'Unknown date';
    final dayOfWeek = (data['dayOfWeek'] as String?) ?? 'Unknown day';
    final startTime = (data['startTime'] as String?) ?? 'TBD';
    final endTime = (data['endTime'] as String?) ?? 'TBD';
    final updatedAt = _readTimestamp(data, 'updatedAt');

    return Column(
      children: [
        Text(
          monthDay,
          style: const TextStyle(
            color: Color(0xFFB3A369),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          dayOfWeek,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            '$startTime - $endTime',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (updatedAt != null) ...[
          const SizedBox(height: 14),
          Text(
            'Last updated: ${_formatLastUpdated(updatedAt.toDate())}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final month = dateTime.month.toString();
    final day = dateTime.day.toString();
    final year = dateTime.year.toString();
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month/$day/$year $hour12:$minute$period';
  }

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
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Next Pickup/Dropoff',
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
                    const SizedBox(height: 28),
                    const Text(
                      'Jonathan will be at GTBC on:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      key: ValueKey(_streamRetryKey),
                      stream: FirebaseFirestore.instance
                          .collection('ArrivalDate')
                          .snapshots()
                          .timeout(
                        const Duration(seconds: 10),
                        onTimeout: (sink) {
                          sink.addError(
                              'Connection timeout. Please check your internet.');
                        },
                      ),
                      builder: (context, snapshot) {
                        final user = FirebaseAuth.instance.currentUser;
                        final isAuthenticated = user != null;
                        // Handle different connection states
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // If we have cached data, show it while waiting
                          if (_cachedArrivalData != null) {
                            return _buildArrivalDetails(_cachedArrivalData!);
                          }
                          // Otherwise show loading
                          return const CircularProgressIndicator(
                            color: Color(0xFFB3A369),
                          );
                        }

                        // Handle errors
                        if (snapshot.hasError) {
                          // If we have cached data, show it despite the error
                          if (_cachedArrivalData != null) {
                            return Column(
                              children: [
                                _buildArrivalDetails(_cachedArrivalData!),
                                const SizedBox(height: 16),
                                Text(
                                  'Syncing...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            );
                          }
                          // Check if user is authenticated
                          if (!isAuthenticated) {
                            return Column(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.red[300],
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Please log in to view arrival details',
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Go Back'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB3A369),
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          }
                          // Otherwise show error with retry
                          final errorMsg =
                              snapshot.error?.toString() ?? 'Unknown error';
                          return Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[300],
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to load arrival details',
                                style: TextStyle(
                                  color: Colors.red[300],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  errorMsg.length > 100
                                      ? '${errorMsg.substring(0, 100)}...'
                                      : errorMsg,
                                  style: TextStyle(
                                    color: Colors.red[200],
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _streamRetryKey++;
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3A369),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          );
                        }

                        // Process snapshot data
                        final docs = snapshot.data?.docs ?? [];
                        final selectedData = _selectArrivalData(docs);

                        if (selectedData != null &&
                            _hasRequiredFields(selectedData)) {
                          _cachedArrivalData = selectedData;
                        }

                        final displayData = _cachedArrivalData;

                        if (displayData == null) {
                          return Column(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.white.withOpacity(0.3),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No next arrival planned yet.\nPlease check back soon.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }

                        return _buildArrivalDetails(displayData);
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
}
