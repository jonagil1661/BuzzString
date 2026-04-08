import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  String _formatPrice(dynamic value) {
    if (value is num) {
      return '\$${value.toDouble().toStringAsFixed(2)}';
    }

    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (parsed != null) {
        return '\$${parsed.toStringAsFixed(2)}';
      }
      return value;
    }

    return '';
  }

  int _parseAvailability(dynamic value) {
    if (value is int) {
      return value < 0 ? 0 : value;
    }

    if (value is num) {
      final parsed = value.toInt();
      return parsed < 0 ? 0 : parsed;
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed < 0 ? 0 : parsed;
      }
    }

    return 0;
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
            constraints: const BoxConstraints(maxWidth: 700),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            'Shop',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Available items',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'To reserve an item, Zelle Jonathan at 770-595-7773 for the exact amount.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('shop')
                          .orderBy('item')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFB3A369),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Card(
                            color: Color(0x33FF0000),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Unable to load shop items.',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Card(
                            color: Color(0x1AFFFFFF),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No items available yet.',
                                style: TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final data = docs[index].data();
                            final itemName =
                                (data['item'] as String?)?.trim() ??
                                    'Unnamed item';
                            final priceText = _formatPrice(data['price']);
                            final availability = _parseAvailability(
                              data['availability'],
                            );
                            final isSoldOut = availability == 0;

                            return Card(
                              color: isSoldOut
                                  ? const Color(0xFF0A1018)
                                  : Colors.white.withOpacity(0.1),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                title: Text(
                                  itemName,
                                  style: TextStyle(
                                    color: isSoldOut
                                        ? Colors.white70
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  isSoldOut
                                      ? 'Sold out'
                                      : 'Availability: $availability',
                                  style: TextStyle(
                                    color: isSoldOut
                                        ? Colors.redAccent
                                        : Colors.white70,
                                    fontWeight: isSoldOut
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: Text(
                                  priceText,
                                  style: TextStyle(
                                    color: isSoldOut
                                        ? Colors.white60
                                        : const Color(0xFFB3A369),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
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
}
