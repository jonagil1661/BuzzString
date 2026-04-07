import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'string_status_manager.dart';

class UpdateStringTypes extends StatefulWidget {
  const UpdateStringTypes({super.key});

  @override
  State<UpdateStringTypes> createState() => _UpdateStringTypesState();
}

class _UpdateStringTypesState extends State<UpdateStringTypes> {
  final Map<String, String> _stringImages = {
    "BG65 Ti\nWhite": "assets/images/strings/bg_65_ti_white.png",
    "BG65 Ti\nPink": "assets/images/strings/bg_65_ti_pink.png",
    "BG65 Ti\nYellow": "assets/images/strings/bg_65_ti_yellow.png",
    "BG80\nWhite": "assets/images/strings/bg_80_white.png",
    "BG80\nYellow": "assets/images/strings/bg_80_yellow.png",
    "BG80\nBlack": "assets/images/strings/bg_80_black.png",
    "Exbolt 63\nYellow": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite\nWhite/Red": "assets/images/strings/aerobite.png",
  };

  Map<String, bool> _stringStatus = {};
  Map<String, double> _stringCosts = {};
  Map<String, TextEditingController> _costControllers = {};
  final Map<String, bool> _costUpdatedByString = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _stringAvailabilitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
    _listenToStringAvailability();
  }

  @override
  void dispose() {
    _stringAvailabilitySubscription?.cancel();
    for (var controller in _costControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _listenToStringAvailability() {
    _stringAvailabilitySubscription = FirebaseFirestore.instance
        .collection('stringAvailability')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      setState(() {
        for (final doc in snapshot.docs) {
          final stringName = _getStringNameFromDocumentId(doc.id);
          if (stringName == null || !_stringImages.containsKey(stringName)) {
            continue;
          }

          final data = doc.data();
          _stringStatus[stringName] = data['availability'] == true;

          final firestoreCost = (data['cost'] as num?)?.toDouble();
          if (firestoreCost != null) {
            _stringCosts[stringName] = firestoreCost;
            _costControllers[stringName]?.text = firestoreCost.toStringAsFixed(0);
            _costUpdatedByString[stringName] = true;
          } else {
            _stringCosts.remove(stringName);
            _costControllers[stringName]?.text = '';
            _costUpdatedByString[stringName] = false;
          }
        }
      });
    });
  }

  String? _getStringNameFromDocumentId(String docId) {
    const mapping = {
      'bg65_ti_white': 'BG65 Ti\nWhite',
      'bg65_ti_pink': 'BG65 Ti\nPink',
      'bg65_ti_yellow': 'BG65 Ti\nYellow',
      'bg80_white': 'BG80\nWhite',
      'bg80_yellow': 'BG80\nYellow',
      'bg80_black': 'BG80\nBlack',
      'exbolt_63_yellow': 'Exbolt 63\nYellow',
      'aerobite_white_red': 'Aerobite\nWhite/Red',
    };

    return mapping[docId];
  }

  Future<void> _initializeStatus() async {
    final statusManager = StringStatusManager();
    Map<String, bool> tempStatus = {};
    Map<String, double> tempCosts = {};
    
    for (String stringName in _stringImages.keys) {
      tempStatus[stringName] = await statusManager.isInStock(stringName);
      final cost = await statusManager.getCost(stringName);
      if (cost != null) {
        tempCosts[stringName] = cost;
        _costUpdatedByString[stringName] = true;
      } else {
        _costUpdatedByString[stringName] = false;
      }
      
      if (!_costControllers.containsKey(stringName)) {
        _costControllers[stringName] = TextEditingController();
      }
    }
    
    if (mounted) {
      setState(() {
        _stringStatus = tempStatus;
        _stringCosts = tempCosts;
        
        for (String stringName in _stringImages.keys) {
          final cost = _stringCosts[stringName];
          _costControllers[stringName]!.text =
              (cost != null) ? cost.toStringAsFixed(0) : '';
        }
      });
    }
  }

  Future<void> _updateStringStatus(String stringName, bool isInStock) async {
    print('Updating string status for $stringName to $isInStock');
    
    setState(() {
      _stringStatus[stringName] = isInStock;
    });

    try {
      await StringStatusManager().updateStatus(stringName, isInStock);
      print('Firestore updated successfully');
    } catch (e) {
      print('Error updating Firestore: $e');
      if (mounted) {
        setState(() {
          _stringStatus[stringName] = !isInStock;
        });
      }
    }
  }

  Future<void> _confirmStringCost(String stringName) async {
    final controller = _costControllers[stringName];
    if (controller == null) return;
    final previousCost = _stringCosts[stringName];
    
    final newCost = double.tryParse(controller.text);
    if (newCost == null || newCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid cost amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Confirming string cost for $stringName to $newCost');
    
    setState(() {
      _stringCosts[stringName] = newCost;
    });

    try {
      await StringStatusManager().updateCost(stringName, newCost);
      print('Cost updated successfully in Firestore');
      if (mounted) {
        setState(() {
          _costUpdatedByString[stringName] = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cost updated to \$${newCost.toStringAsFixed(0)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating cost in Firestore: $e');
      if (mounted) {
        setState(() {
          if (previousCost != null) {
            _stringCosts[stringName] = previousCost;
          } else {
            _stringCosts.remove(stringName);
          }
          _costUpdatedByString[stringName] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating cost. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                                "Update String Types",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48), // To balance the back button
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Manage String Availability',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    const SizedBox(height: 20),
                    const Text(
                      'Toggle switches to control which string types are available to customers.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stringImages.length,
                      itemBuilder: (context, index) {
                          final stringName = _stringImages.keys.elementAt(index);
                          final imagePath = _stringImages[stringName]!;
                          final isInStock = _stringStatus[stringName] ?? true;
                            final isUpdated =
                              _costUpdatedByString[stringName] == true;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white.withOpacity(0.1),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:                             Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          imagePath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stringName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isInStock ? 'In Stock' : 'Out of Stock',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isInStock ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: isInStock,
                                      onChanged: (value) {
                                        print('Switch changed for $stringName: $value');
                                        _updateStringStatus(stringName, value);
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.red,
                                      inactiveTrackColor: Colors.red.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text(
                                      'Cost: \$',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _costControllers[stringName],
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) {
                                          if (_costUpdatedByString[stringName] ==
                                              true) {
                                            setState(() {
                                              _costUpdatedByString[stringName] =
                                                  false;
                                            });
                                          }
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'No Firestore cost',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: isUpdated
                                          ? null
                                          : () => _confirmStringCost(stringName),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isUpdated
                                            ? Colors.green
                                            : const Color(0xFFB3A369),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: Colors.green,
                                        disabledForegroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
                                        isUpdated ? 'Updated' : 'Update',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                              ),
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
