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
    "Exbolt 63\nYellow": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite\nWhite/Red": "assets/images/strings/aerobite.png",
  };

  Map<String, bool> _stringStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  Future<void> _initializeStatus() async {
    final statusManager = StringStatusManager();
    Map<String, bool> tempStatus = {};
    
    for (String stringName in _stringImages.keys) {
      tempStatus[stringName] = await statusManager.isInStock(stringName);
    }
    
    if (mounted) {
      setState(() {
        _stringStatus = tempStatus;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await StringStatusManager().testFirestoreConnection();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Test Connection'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await StringStatusManager().initializeStringAvailability();
                            await _initializeStatus(); // Reload the status after initialization
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB3A369),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Initialize Collection'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stringImages.length,
                      itemBuilder: (context, index) {
                          final stringName = _stringImages.keys.elementAt(index);
                          final imagePath = _stringImages[stringName]!;
                          final isInStock = _stringStatus[stringName] ?? true;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white.withOpacity(0.1),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
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
                              ),
                          );
                        },
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Version 1.2.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
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
