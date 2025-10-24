import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'stringing_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'native_text_input.dart';
import 'string_status_manager.dart';

class StringingRequestPage extends StatefulWidget {
  const StringingRequestPage({super.key});

  @override
  State<StringingRequestPage> createState() => _StringingRequestPageState();
}

class _StringingRequestPageState extends State<StringingRequestPage> {
  int _totalSteps = 5;
  int _currentStep = 0;

  final TextEditingController _racketController = TextEditingController();
  String? _selectedRacketInfo;
  List<String> _racketRecommendations = [];
  
  bool _racketInfoEntered = false;
  
  bool _stringTypeSelected = false;
  bool _stringTensionCompleted = false;
  final TextEditingController _customStringController = TextEditingController();
  bool _showCustomStringInput = false;
  
  final TextEditingController _additionalQuestionsController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  List<String> _selectedRacketColors = [];
  int? _selectedTension;
  String? _selectedString;
  String? _selectedPaymentMethod;
  bool _acknowledgeTerms = false;

  bool _isConfirmHovered = false;
  bool _isStringContinueHovered = false;
  bool _isZelleHovered = false;
  bool _isCashHovered = false;
  bool _isAdditionalHovered = false;
  bool _isPaymentContinueHovered = false;
  bool _isSubmitHovered = false;

  Map<String, bool> _stringHoverStates = {};
  Map<String, bool> _stringStatus = {};

  final StringingRequest _request = StringingRequest();

  int _getCompletedQuestions() {
    int completed = 0;
    
    if (_racketInfoEntered) completed++;
    
    if (_selectedRacketColors.isNotEmpty) completed++;
    
    if (_request.gripColor.isNotEmpty) completed++;
    
    if (_stringTypeSelected) completed++;
    
    if (_stringTensionCompleted) completed++;
    
    if (_selectedPaymentMethod != null) completed++;
    
    if (_currentStep >= 4) completed++;
    
    if (_acknowledgeTerms) completed++;
    
    return completed;
  }

  int _getTotalQuestions() {
    return 8;
  }


  final Map<String, String> _stringImages = {
    "BG65 Ti\nWhite": "assets/images/strings/bg_65_ti_white.png",
    "BG65 Ti\nPink": "assets/images/strings/bg_65_ti_pink.png",
    "BG65 Ti\nYellow": "assets/images/strings/bg_65_ti_yellow.png",
    "BG80\nWhite": "assets/images/strings/bg_80_white.png",
    "BG80\nYellow": "assets/images/strings/bg_80_yellow.png",
    "Exbolt 63\nYellow": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite\nWhite/Red": "assets/images/strings/aerobite.png",
    "I have my own string": "",
  };


  final List<int> _tensionOptions = List.generate(11, (index) => 20 + index);
  int _tensionIndex = -1;

  List<String> _availableRackets = [];

  @override
  void initState() {
    super.initState();
    _racketController.addListener(_onRacketTextChanged);
    _loadRackets();
    _loadStringStatus();
  }

  void _loadStringStatus() {
    FirebaseFirestore.instance.collection('stringAvailability').snapshots().listen((snapshot) {
      if (mounted) {
        setState(() {
          for (var doc in snapshot.docs) {
            final stringName = _getStringNameFromDocumentId(doc.id);
            if (stringName != null && _stringImages.containsKey(stringName)) {
              _stringStatus[stringName] = doc.data()['availability'] ?? true;
            }
          }
        });
      }
    });
  }

  String? _getStringNameFromDocumentId(String docId) {
    final mapping = {
      'bg65_ti_white': 'BG65 Ti\nWhite',
      'bg65_ti_pink': 'BG65 Ti\nPink',
      'bg65_ti_yellow': 'BG65 Ti\nYellow',
      'bg80_white': 'BG80\nWhite',
      'bg80_yellow': 'BG80\nYellow',
      'exbolt_63_yellow': 'Exbolt 63\nYellow',
      'aerobite_white_red': 'Aerobite\nWhite/Red',
    };
    return mapping[docId];
  }

  Future<void> _loadRackets() async {
    try {
      final String racketData = await DefaultAssetBundle.of(context)
          .loadString('rackets.txt');
      final List<String> rackets = racketData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
      
      setState(() {
        _availableRackets = rackets;
      });
    } catch (e) {
      setState(() {
        _availableRackets = [
          "Yonex Arcsaber 11 Pro",
          "Yonex Arcsaber 7 Pro",
          "Yonex Astrox 77 Pro",
          "Yonex Astrox 88D Pro",
          "Yonex Astrox 88S Pro",
          "Yonex Astrox 99 Pro",
          "Yonex Astrox 100ZZ",
          "Yonex Nanoflare 700 Pro",
          "Victor Auraspeed 90K II",
          "Victor Thruster K Falcon",
          "Li Ning Axforce 90",
        ];
      });
    }
  }

  @override
  void dispose() {
    _racketController.dispose();
    _customStringController.dispose();
    _additionalQuestionsController.dispose();
    super.dispose();
  }

  void _onRacketTextChanged() {
    final text = _racketController.text.toLowerCase().trim();
    if (text.isEmpty) {
      setState(() {
        _racketRecommendations = [];
        _racketInfoEntered = false;
      });
      return;
    }

    if (_racketInfoEntered && _selectedRacketInfo != null && 
        _selectedRacketInfo!.toLowerCase().trim() != text) {
      setState(() {
        _racketInfoEntered = false;
      });
    }

    final inputWords = text.split(' ').where((word) => word.isNotEmpty).toList();
    
    final scoredRackets = _availableRackets.map((racket) {
      final racketLower = racket.toLowerCase();
      int score = 0;
      
      if (racketLower == text) {
        score = 1000;
      }
      else if (racketLower.startsWith(text)) {
        score = 500;
      }
      else if (racketLower.contains(text)) {
        score = 200;
      }
      
      for (final word in inputWords) {
        if (racketLower.contains(word)) {
          score += 50;
        }
        if (racketLower.startsWith(word)) {
          score += 25;
        }
      }
      
      return {'racket': racket, 'score': score};
    }).where((item) => (item['score']! as int) > 0).toList();

    scoredRackets.sort((a, b) => (b['score']! as int).compareTo(a['score']! as int));
    
    final recommendations = scoredRackets
        .take(5)
        .map((item) => item['racket'] as String)
        .toList();

    setState(() {
      _racketRecommendations = recommendations;
    });
  }

  void _selectRacketRecommendation(String racket) {
    setState(() {
      _racketController.text = racket;
      _selectedRacketInfo = racket;
      _racketRecommendations = [];
    });
  }

  bool _isStepComplete(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _racketInfoEntered && 
               _selectedRacketColors.isNotEmpty && 
               _request.gripColor.isNotEmpty;
      case 1:
        if (!_stringTypeSelected) return false;
        if (_selectedString == "I have my own string" && _showCustomStringInput) {
          return _customStringController.text.isNotEmpty && _tensionIndex >= 0;
        }
        return _tensionIndex >= 0;
      case 2:
        return _selectedPaymentMethod != null;
      case 3:
        return true;
      case 4:
        return _acknowledgeTerms;
      default:
        return false;
    }
  }

  bool _canNavigateToNext() {
    return _currentStep < _totalSteps - 1 && _isStepComplete(_currentStep);
  }

  bool _canNavigateToPrev() {
    return _currentStep > 0;
  }

  bool _isStringTensionEnabled() {
    if (!_stringTypeSelected) return false;
    if (_selectedString == "I have my own string" && _showCustomStringInput) {
      return _customStringController.text.isNotEmpty;
    }
    return true;
  }

  String _extractPrice(String stringName) {
    if (stringName == "I have my own string") {
      return "\$18";
    }
    final cost = _getStringCost(stringName);
    return "\$$cost";
  }

  int _getStringCost(String stringName) {
    if (stringName.startsWith("Custom: ")) {
      return 18;
    }
    if (stringName == "I have my own string") {
      return 18;
    }
    switch (stringName) {
      case "BG65 Ti\nWhite":
      case "BG65 Ti\nPink":
      case "BG65 Ti\nYellow":
        return 22;
      case "BG80\nWhite":
      case "BG80\nYellow":
        return 24;
      case "Exbolt 63\nYellow":
        return 25;
      case "Aerobite\nWhite/Red":
        return 26;
      default:
        return 20;
    }
  }


  void _nextStep() {
    if (_canNavigateToNext()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_canNavigateToPrev()) {
      setState(() {
        _currentStep--;
      });
    }
  }

  String _colorToName(Color color) {
    if (color == Colors.red) return "Red";
    if (color == Colors.blue) return "Blue";
    if (color == Colors.green) return "Green";
    if (color == Colors.yellow) return "Yellow";
    if (color == Colors.orange) return "Orange";
    if (color == Colors.purple) return "Purple";
    if (color == Colors.pink) return "Pink";
    if (color == Colors.black) return "Black";
    if (color == Colors.brown) return "Brown";
    if (color == Colors.white) return "White";
    if (color == Colors.grey) return "Gray";
    return "Custom Color";
  }

  Color _nameToColor(String colorName) {
    switch (colorName) {
      case "Red": return Colors.red;
      case "Orange": return Colors.orange;
      case "Yellow": return Colors.yellow;
      case "Green": return Colors.green;
      case "Blue": return Colors.blue;
      case "Purple": return Colors.purple;
      case "Brown": return Colors.brown;
      case "White": return Colors.white;
      case "Black": return Colors.black;
      case "Pink": return Colors.pink;
      case "Gray": return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildRacketInfoStep(),
      _buildStringAndTensionStep(),
      _buildPaymentStep(),
      _buildAdditionalQuestionsStep(),
      _buildSummaryStep(),
    ];

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
                        "Stringing Request Form",
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
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: steps[_currentStep],
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRacketInfoStep() {
    return SingleChildScrollView(
      key: const ValueKey("racketInfoStep"),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
            "Racket Information",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
            const Text(
            "Enter your racket information in the format: [Brand] [Series] [Model]",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 10),
            const Text(
            "Example: Yonex Arcsaber 11 Pro",
            style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          NativeTextInput(
            labelText: "Racket Information",
            hintText: "Type your racket name...",
            prefixIcon: Icons.sports_tennis,
            controller: _racketController,
            onChanged: (value) {
              _onRacketTextChanged();
            },
          ),
          if (_racketRecommendations.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "💡 Suggestions:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  ..._racketRecommendations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final recommendation = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectRacketRecommendation(recommendation),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB3A369),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    recommendation,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isConfirmHovered = true),
              onExit: (_) => setState(() => _isConfirmHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isConfirmHovered ? 1.05 : 1.0),
                child: ElevatedButton(
                  onPressed: _racketController.text.isNotEmpty ? () {
                    setState(() {
                      _racketInfoEntered = true;
                      _selectedRacketInfo = _racketController.text;
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3A369),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_racketInfoEntered ? "Confirmed" : "Confirm"),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Racket Color",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: _racketInfoEntered ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _racketInfoEntered 
                ? "Select up to 3 colors for your racket (minimum 1):"
                : "Please enter racket information first",
            style: TextStyle(
              fontSize: 16, 
              color: _racketInfoEntered ? Colors.white70 : Colors.orange,
              fontWeight: _racketInfoEntered ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (_racketInfoEntered) ...[
            Text(
              "Selected: ${_selectedRacketColors.length}/3 colors",
              style: TextStyle(
                fontSize: 14,
                color: _selectedRacketColors.isEmpty ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Opacity(
            opacity: _racketInfoEntered ? 1.0 : 0.5,
            child: _buildMultiColorPicker(
              selectedColors: _selectedRacketColors,
              onColorsChanged: _racketInfoEntered 
                  ? (colors) {
                      setState(() {
                        _selectedRacketColors = colors;
                        _request.racketColors = colors;
                      });
                    }
                  : (colors) {},
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedRacketColors.isNotEmpty 
                ? "Selected Racket Colors: ${_selectedRacketColors.join(', ')}"
                : "Please select at least one racket color",
            style: TextStyle(
              fontSize: 18,
              color: _racketInfoEntered ? 
                  (_selectedRacketColors.isNotEmpty ? Colors.white : Colors.orange) 
                  : Colors.white70,
              fontWeight: _selectedRacketColors.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            "Grip Color",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: (_racketInfoEntered && _selectedRacketColors.isNotEmpty) ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            !_racketInfoEntered 
                ? "Please enter racket information first"
                : _selectedRacketColors.isEmpty
                    ? "Please select racket colors first"
                    : "Select the color for your racket grip:",
            style: TextStyle(
              fontSize: 16, 
              color: !_racketInfoEntered 
                  ? Colors.orange
                  : _selectedRacketColors.isEmpty 
                      ? Colors.orange
                      : Colors.white70,
              fontWeight: (!_racketInfoEntered || _selectedRacketColors.isEmpty) 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 30),
          Opacity(
            opacity: (_racketInfoEntered && _selectedRacketColors.isNotEmpty) ? 1.0 : 0.5,
            child: _buildColorPicker(
              selectedColor: _request.gripColor,
              onColorChanged: (_racketInfoEntered && _selectedRacketColors.isNotEmpty) 
                  ? (colorName) {
                      setState(() {
                        _request.gripColor = colorName;
                        _selectedColor = _nameToColor(colorName);
                      });
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _nextStep();
                      });
                    }
                  : (colorName) {},
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _request.gripColor.isNotEmpty 
                ? "Selected Grip Color: ${_request.gripColor}"
                : (_racketInfoEntered && _selectedRacketColors.isNotEmpty)
                    ? "Please select a grip color"
                    : "Select racket colors first",
            style: TextStyle(
              fontSize: 18,
              color: _request.gripColor.isNotEmpty 
                  ? Colors.white
                  : (_racketInfoEntered && _selectedRacketColors.isNotEmpty)
                      ? Colors.orange
                      : Colors.white70,
              fontWeight: _request.gripColor.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
            ],
          ),
        ),
      );
  }

  Widget _buildColorPicker({required String selectedColor, required Function(String) onColorChanged}) {
    final Map<String, Color> colorOptions = {
      "Red": Colors.red,
      "Orange": Colors.orange,
      "Yellow": Colors.yellow,
      "Green": Colors.green,
      "Blue": Colors.blue,
      "Purple": Colors.purple,
      "Brown": Colors.brown,
      "White": Colors.white,
      "Black": Colors.black,
      "Pink": Colors.pink,
      "Gray": Colors.grey,
    };

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: colorOptions.entries.map((entry) {
        final colorName = entry.key;
        final colorValue = entry.value;
        final isSelected = selectedColor == colorName;

        return GestureDetector(
          onTap: () {
            onColorChanged(colorName);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorValue,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 3)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiColorPicker({required List<String> selectedColors, required Function(List<String>) onColorsChanged}) {
    final Map<String, Color> colorOptions = {
      "Red": Colors.red,
      "Orange": Colors.orange,
      "Yellow": Colors.yellow,
      "Green": Colors.green,
      "Blue": Colors.blue,
      "Purple": Colors.purple,
      "Brown": Colors.brown,
      "White": Colors.white,
      "Black": Colors.black,
      "Pink": Colors.pink,
      "Gray": Colors.grey,
    };

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: colorOptions.entries.map((entry) {
        final colorName = entry.key;
        final colorValue = entry.value;
        final isSelected = selectedColors.contains(colorName);

        return GestureDetector(
          onTap: () {
            List<String> newColors = List.from(selectedColors);
            if (isSelected) {
              newColors.remove(colorName);
            } else if (newColors.length < 3) {
              newColors.add(colorName);
            }
            onColorsChanged(newColors);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorValue,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.black, width: 3)
                  : Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }


  Widget _buildStringAndTensionStep() {
    final strings = [
      "BG65 Ti\nWhite",
      "BG65 Ti\nPink",
      "BG65 Ti\nYellow",
      "BG80\nWhite",
      "BG80\nYellow",
      "Exbolt 63\nYellow",
      "Aerobite\nWhite/Red",
      "I have my own string",
    ];

    return SingleChildScrollView(
      key: const ValueKey("stringAndTensionStep"),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            "String Type",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select the type of string for your racket:",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: strings.map((str) {
              String imagePath = _stringImages[str] ?? "";
              final isSelected = _selectedString == str;
              final isHovered = _stringHoverStates[str] ?? false;
              final price = _extractPrice(str);
              final showPrice = isHovered || isSelected;
              final isInStock = _stringStatus[str] ?? true;
              
              if (imagePath.isNotEmpty) {
                return GestureDetector(
                  onTap: isInStock ? () {
                    setState(() {
                      _selectedString = str;
                      _request.stringType = str;
                      _stringTypeSelected = true;
                      _showCustomStringInput = (str == "I have my own string");
                      if (!_showCustomStringInput) {
                        _customStringController.clear();
                      }
                    });
                  } : null,
                  child: MouseRegion(
                    onEnter: isInStock ? (_) => setState(() => _stringHoverStates[str] = true) : null,
                    onExit: isInStock ? (_) => setState(() => _stringHoverStates[str] = false) : null,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 4)
                            : Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                            blurRadius: isSelected ? 15 : 8,
                            spreadRadius: isSelected ? 2 : 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.asset(
                              imagePath, 
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            if (!isInStock)
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black.withOpacity(0.7),
                                child: const Center(
                                  child: Text(
                                    'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (isInStock && (isHovered || isSelected))
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.white.withOpacity(0.3),
                                child: Center(
                                  child: Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              else {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedString = str;
                      _request.stringType = str;
                      _stringTypeSelected = true;
                      _showCustomStringInput = (str == "I have my own string");
                      if (!_showCustomStringInput) {
                        _customStringController.clear();
                      }
                    });
                  },
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _stringHoverStates[str] = true),
                    onExit: (_) => setState(() => _stringHoverStates[str] = false),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 4)
                            : Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                            blurRadius: isSelected ? 15 : 8,
                            spreadRadius: isSelected ? 2 : 1,
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: isSelected ? 6 : 3,
                        color: showPrice 
                            ? const Color(0xFFB3A369).withOpacity(0.3)
                            : const Color(0xFFB3A369),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            if (!showPrice) ...[
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.sports_tennis, size: 60, color: Colors.white),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "I have my own string",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (showPrice)
                              Center(
                                child: Text(
                                  price,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ),
          if (_stringTypeSelected) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Selected: ${_request.stringType.startsWith("Custom: ") ? _request.stringType.substring(8) : _request.stringType.replaceAll('\n', ' ')}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_showCustomStringInput) ...[
            const SizedBox(height: 20),
            const Text(
              "Please specify what string you have: *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
          const Text(
            "Example: Yonex Nanogy 98",
            style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
          ),
            const SizedBox(height: 10),
            NativeTextInput(
              labelText: "Custom String Type *",
              hintText: "Enter the string you currently have...",
              prefixIcon: Icons.edit,
              controller: _customStringController,
              isRequired: true,
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _request.stringType = "Custom: $value";
                  } else {
                    _request.stringType = "I have my own string";
                  }
                });
              },
            ),
            if (_showCustomStringInput && _customStringController.text.isEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Please specify your custom string type to continue",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 40),
          Text(
            "String Tension",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: _isStringTensionEnabled() ? Colors.white : Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isStringTensionEnabled()
                ? "Select the tension for your strings (lbs):"
                : _showCustomStringInput && _customStringController.text.isEmpty
                    ? "Please specify your custom string type first"
                    : "Please select a string type first",
            style: TextStyle(
              fontSize: 16, 
              color: _isStringTensionEnabled() ? Colors.white70 : Colors.orange,
              fontWeight: _isStringTensionEnabled() ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Opacity(
            opacity: _isStringTensionEnabled() ? 1.0 : 0.5,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Slider(
                    value: _tensionIndex >= 0 ? _tensionIndex.toDouble() : 0.0,
                    min: 0,
                    max: (_tensionOptions.length - 1).toDouble(),
                    divisions: _tensionOptions.length - 1,
                    label: _tensionIndex >= 0 ? "${_tensionOptions[_tensionIndex]} lbs" : "Select tension",
                    activeColor: const Color(0xFFB3A369),
                    inactiveColor: Colors.white.withOpacity(0.3),
                    onChanged: _isStringTensionEnabled() ? (value) {
                      setState(() {
                        _tensionIndex = value.round();
                        _selectedTension = _tensionOptions[_tensionIndex];
                        _request.tension = _selectedTension;
                      });
                    } : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _tensionOptions
                        .map(
                          (t) => Text(
                            "$t", 
                            style: TextStyle(
                              fontSize: 12,
                              color: _isStringTensionEnabled() ? Colors.white : Colors.white70,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _tensionIndex >= 0 
                ? "Selected: ${_tensionOptions[_tensionIndex]} lbs"
                : _isStringTensionEnabled()
                    ? "Please select a tension"
                    : _showCustomStringInput && _customStringController.text.isEmpty
                        ? "Please specify your custom string type first"
                        : "Select string type first",
            style: TextStyle(
              fontSize: 18,
              color: _tensionIndex >= 0 
                  ? Colors.white 
                  : _isStringTensionEnabled()
                      ? Colors.orange 
                      : Colors.white70,
              fontWeight: _tensionIndex < 0 ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isStringContinueHovered = true),
              onExit: (_) => setState(() => _isStringContinueHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isStringContinueHovered ? 1.05 : 1.0),
                child: ElevatedButton(
                  onPressed: _isStepComplete(1) ? () {
                    setState(() {
                      _stringTensionCompleted = true;
                    });
                    _nextStep();
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3A369),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      );
  }



  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      key: const ValueKey("paymentStep"),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isZelleHovered = true),
                  onExit: (_) => setState(() => _isZelleHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()..scale(_isZelleHovered ? 1.05 : 1.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPaymentMethod = "Zelle";
                          _request.paymentMethod = _selectedPaymentMethod!;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3A369),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        minimumSize: Size(120, 80),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/zelle_logo.png',
                            height: 70,
                            width: 70,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Zelle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isCashHovered = true),
                  onExit: (_) => setState(() => _isCashHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()..scale(_isCashHovered ? 1.05 : 1.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPaymentMethod = "Cash";
                          _request.paymentMethod = _selectedPaymentMethod!;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3A369),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        minimumSize: Size(120, 80),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/cash_logo.png',
                            height: 70,
                            width: 70,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Cash',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (_selectedPaymentMethod != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB3A369).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB3A369).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedPaymentMethod == "Zelle" 
                          ? "Please Zelle Jonathan Gil at 770-595-7773 before pickup"
                          : "Please pay with exact change during pickup",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isPaymentContinueHovered = true),
              onExit: (_) => setState(() => _isPaymentContinueHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isPaymentContinueHovered ? 1.05 : 1.0),
                child: ElevatedButton(
                  onPressed: _isStepComplete(2) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3A369),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      );
  }

  Widget _buildAdditionalQuestionsStep() {
    return SingleChildScrollView(
      key: const ValueKey("additionalQuestionsStep"),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            "Is there anything else you would like me to know?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
         
          const SizedBox(height: 10),
          const Text(
            "(Optional)",
            style: TextStyle(fontSize: 14, color: Colors.orange, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          NativeTextInput(
            labelText: "Additional Questions",
            hintText: "Enter any questions or requests you may have...",
            prefixIcon: Icons.help_outline,
            controller: _additionalQuestionsController,
            maxLines: 3,
            minLines: 1,
            onChanged: (value) {
              setState(() {
                _request.additionalQuestions = value;
              });
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isAdditionalHovered = true),
              onExit: (_) => setState(() => _isAdditionalHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isAdditionalHovered ? 1.05 : 1.0),
                child: ElevatedButton(
                  onPressed: _isStepComplete(3) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3A369),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      key: const ValueKey("summaryStep"),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            "Summary",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text("Racket: ${_racketController.text}", style: const TextStyle(color: Colors.white)),
          Text("Racket Colors: ${_selectedRacketColors.join(', ')}", style: const TextStyle(color: Colors.white)),
          Text("Grip Color: ${_request.gripColor}", style: const TextStyle(color: Colors.white)),
          Text("Tension: ${_selectedTension ?? 'Not selected'} lbs", style: const TextStyle(color: Colors.white)),
          Text("String: ${_request.stringType.replaceAll('\n', ' ')}", style: const TextStyle(color: Colors.white)),
          Text("Cost: \$${_getStringCost(_request.stringType)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text("Payment Method: ${_request.paymentMethod}", style: const TextStyle(color: Colors.white)),
          if (_request.additionalQuestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text("Additional Questions/Concerns:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(_request.additionalQuestions, style: const TextStyle(color: Colors.white)),
          ],
          const SizedBox(height: 30),
          const Text(
            "By submitting my racket for stringing, I acknowledge and agree to the following:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "1. I confirm that my racket is not severely cracked, damaged, or in otherwise compromised condition at the time of drop-off.",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "2. I acknowledge that stringing at higher tensions increases the risk of frame damage and reduces string durability.",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "3. I accept that the stringer is not responsible for any racket breakage that may occur during or after stringing.",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "4. I understand that natural wear, tension loss, or string breakage are normal occurrences with use and are not the responsibility of the stringer.",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "5. I understand that all services are final, and no refunds will be issued once the racket has been strung to the customer's specifications.",
            style: TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              Checkbox(
                value: _acknowledgeTerms,
                activeColor: const Color(0xFFB3A369),
                onChanged: (value) {
                  setState(() {
                    _acknowledgeTerms = value!;
                  });
                },
              ),
              const Expanded(
                child: Text("I acknowledge the terms and conditions", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isSubmitHovered = true),
              onExit: (_) => setState(() => _isSubmitHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: Matrix4.identity()..scale(_isSubmitHovered ? 1.05 : 1.0),
                child: ElevatedButton(
                  onPressed: _acknowledgeTerms ? _submitRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB3A369),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Submit Stringing Request"),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
            ],
          ),
        ),
      );
  }

  Widget _buildSelectionCard({
    required String imagePath,
    required String label,
    double imageHeight = 60,
  }) {
    return SizedBox(
      width: 150,
      height: 180,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath.isNotEmpty)
              Image.asset(imagePath, height: imageHeight)
            else
              const Icon(Icons.sports_tennis, size: 50, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              icon: Icon(
                Icons.arrow_back, 
                size: 32,
                color: _canNavigateToPrev() ? const Color(0xFFB3A369) : Colors.grey.shade600,
              ),
              onPressed: _canNavigateToPrev() ? _prevStep : null,
            )
          else
            const SizedBox(width: 48),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_getCompletedQuestions() / _getTotalQuestions() * 100).round()}% Complete',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _getCompletedQuestions() / _getTotalQuestions(),
                    backgroundColor: Colors.grey[300],
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          
          if (_currentStep < _totalSteps - 1)
            IconButton(
              icon: Icon(
                Icons.arrow_forward, 
                size: 32,
                color: _canNavigateToNext() ? const Color(0xFFB3A369) : Colors.grey.shade600,
              ),
              onPressed: _canNavigateToNext() ? _nextStep : null,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }


  Future<void> _submitRequest() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You must be logged in to submit a request"),
          ),
        );
        return;
      }

      final uid = user.uid;
      final displayName = user.displayName ?? "Unknown User";
      final email = user.email ?? "";

      final nameParts = displayName.split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts.first : "";
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(" ")
          : "";

      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      await userDoc.set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }, SetOptions(merge: true));

      final requestData = {
        'racket': _racketController.text,
        'racketColors': _request.racketColors,
        'gripColor': _request.gripColor,
        'stringType': _request.stringType,
        'tension': _selectedTension ?? 0,
        'paymentMethod': _request.paymentMethod,
        'additionalInfo': _request.additionalQuestions,
        'cost': _getStringCost(_request.stringType),
        'paid': false,
        'progress': 'Not received',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await userDoc.collection('stringingRequests').add(requestData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stringing request submitted successfully!"),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting request: $e")));
    }
  }
}
