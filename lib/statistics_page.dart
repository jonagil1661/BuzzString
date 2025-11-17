import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _totalRequests = 0;
  double _totalMoneyEarned = 0.0;
  double _netProfit = 0.0;
  Map<String, int> _stringTypeCounts = {};
  Map<String, int> _tensionCounts = {};
  bool _isLoading = true;

  final Map<String, int> _costOfStringPerRacket = {
    'BG80\nWhite': 6,
    'BG80\nYellow': 6,
    'BG80\nBlack': 6,
    'BG65 Ti\nWhite': 4,
    'BG65 Ti\nYellow': 4,
    'BG65 Ti\nPink': 4,
    'Exbolt 63\nYellow': 7,
    'Aerobite\nWhite/Red': 8,
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('stringingRequests')
          .get();

      _totalRequests = snapshot.docs.length;
      _totalMoneyEarned = 0.0;
      _netProfit = 0.0;
      _stringTypeCounts.clear();
      _tensionCounts.clear();

      Map<String, double> stringTypeCosts = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        print('Document data: $data');
        
        final stringType = data['stringType'] as String? ?? 'Unknown';
        final tensionValue = data['tension'];
        final tension = tensionValue is String ? tensionValue : tensionValue?.toString() ?? 'Unknown';
        final cost = (data['cost'] as num?)?.toDouble() ?? 0.0;

        print('String type: $stringType, Tension: $tension, Cost: $cost');

        _stringTypeCounts[stringType] = (_stringTypeCounts[stringType] ?? 0) + 1;
        _tensionCounts[tension] = (_tensionCounts[tension] ?? 0) + 1;
        
        if (!stringTypeCosts.containsKey(stringType)) {
          stringTypeCosts[stringType] = cost;
        }
      }

      for (String stringType in _stringTypeCounts.keys) {
        final count = _stringTypeCounts[stringType]!;
        final cost = stringTypeCosts[stringType] ?? 0.0;
        final stringCost = _costOfStringPerRacket[stringType] ?? 0;
        final subtotal = count * cost;
        final profitPerRacket = cost - stringCost;
        final netProfitSubtotal = count * profitPerRacket;
        
        _totalMoneyEarned += subtotal;
        _netProfit += netProfitSubtotal;
        
        print('$stringType: $count requests × $cost = $subtotal (profit: $profitPerRacket × $count = $netProfitSubtotal)');
      }

      print('Total money earned: $_totalMoneyEarned');
      print('String type costs: $stringTypeCosts');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Statistics",
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
                    const Text(
                      'Stringing Request Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      _buildStatCard(
                        'Total Requests',
                        _totalRequests.toString(),
                        Icons.assignment,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Gross Revenue',
                        '\$${_totalMoneyEarned.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Net Profit',
                        '\$${_netProfit.toStringAsFixed(2)}',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                      const SizedBox(height: 30),
                      _buildSectionCard(
                        'String Type Distribution',
                        _stringTypeCounts,
                        Icons.category,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        'Tension Distribution',
                        _tensionCounts,
                        Icons.tune,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Map<String, int> data, IconData icon) {
    List<MapEntry<String, int>> sortedEntries;
    
    if (title == 'Tension Distribution') {
      sortedEntries = data.entries.toList()
        ..sort((a, b) {
          final aValue = int.tryParse(a.key) ?? 0;
          final bValue = int.tryParse(b.key) ?? 0;
          return bValue.compareTo(aValue);
        });
    } else if (title == 'String Type Distribution') {
      sortedEntries = data.entries.toList()
        ..sort((a, b) {
          final aIsCustom = a.key.startsWith('Custom: ');
          final bIsCustom = b.key.startsWith('Custom: ');
          
          if (aIsCustom && !bIsCustom) {
            return 1;
          } else if (!aIsCustom && bIsCustom) {
            return -1;
          } else {
            return a.key.compareTo(b.key);
          }
        });
    } else {
      sortedEntries = data.entries.toList();
    }

    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedEntries.isEmpty)
              const Text(
                'No data available',
                style: TextStyle(
                  color: Colors.white70,
                ),
              )
            else
              ...sortedEntries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
