import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'stringing_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _customStringController = TextEditingController();
  bool _showCustomStringInput = false;
  
  final TextEditingController _additionalQuestionsController = TextEditingController();
  
  Color _selectedColor = Colors.blue;
  Color _selectedRacketColor = Colors.blue;
  int _selectedTension = 24;
  String? _selectedString;
  String? _selectedPaymentMethod;
  bool _acknowledgeTerms = false;

  final StringingRequest _request = StringingRequest(
    tension: 24,
  );


  final Map<String, String> _stringImages = {
    "BG65 Ti White\n(\$22)": "assets/images/strings/bg_65_ti_white.png",
    "BG80\n(\$24)": "assets/images/strings/bg_80_white.png",
    "Exbolt 63 Yellow\n(\$25)": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite White/Red\n(\$26)": "assets/images/strings/aerobite.png",
    "I have my own string\n(\$18)": "",
  };


  final List<int> _tensionOptions = List.generate(11, (index) => 20 + index);
  int _tensionIndex = 4;

  List<String> _availableRackets = [];

  @override
  void initState() {
    super.initState();
    _racketController.addListener(_onRacketTextChanged);
    _loadRackets();
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
      
      print('Loaded ${rackets.length} rackets from rackets.txt');
      setState(() {
        _availableRackets = rackets;
      });
    } catch (e) {
      print('Error loading rackets.txt: $e');
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
      });
      return;
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
               _request.racketColor.isNotEmpty && 
               _request.gripColor.isNotEmpty;
      case 1:
        if (!_stringTypeSelected) return false;
        if (_selectedString == "I have my own string\n(\$18)" && _showCustomStringInput) {
          return _customStringController.text.isNotEmpty;
        }
        return true;
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
      appBar: AppBar(title: const Text("I Need Stringing")),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: steps[_currentStep],
            ),
          ),
          _buildNavigation(),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildRacketInfoStep() {
    return SingleChildScrollView(
      key: const ValueKey("racketInfoStep"),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Racket Information",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Enter your racket information in the format: [Brand] [Model] [Racket] [Weight]",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            "Example: Yonex Arcsaber 11 Pro 3U",
            style: TextStyle(fontSize: 14, color: Colors.blue, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _racketController,
            decoration: const InputDecoration(
              labelText: "Racket Information",
              hintText: "Type your racket name...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sports_tennis),
            ),
            style: const TextStyle(fontSize: 16),
          ),
          if (_racketRecommendations.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              "Recommendations:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._racketRecommendations.map((recommendation) => 
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.recommend),
                  title: Text(recommendation),
                  onTap: () => _selectRacketRecommendation(recommendation),
                ),
              ),
            ),
          ],
          if (_racketInfoEntered) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Racket info entered: ${_racketController.text}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _racketController.text.isNotEmpty ? () {
                setState(() {
                  _racketInfoEntered = true;
                  _selectedRacketInfo = _racketController.text;
                });
              } : null,
              child: Text(_racketInfoEntered ? "Confirm Racket Info" : "Continue"),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "Racket Color",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: _racketInfoEntered ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _racketInfoEntered 
                ? "Select the color of your racket:"
                : "Please enter racket information first",
            style: TextStyle(
              fontSize: 16, 
              color: _racketInfoEntered ? Colors.grey : Colors.orange,
              fontWeight: _racketInfoEntered ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Opacity(
            opacity: _racketInfoEntered ? 1.0 : 0.5,
            child: _buildColorPicker(
              selectedColor: _request.racketColor,
              onColorChanged: (colorName) {
                setState(() {
                  _request.racketColor = colorName;
                  _selectedRacketColor = _nameToColor(colorName);
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _request.racketColor.isNotEmpty 
                ? "Selected Racket Color: ${_request.racketColor}"
                : "Please select a racket color",
            style: TextStyle(
              fontSize: 18,
              color: _racketInfoEntered ? 
                  (_request.racketColor.isNotEmpty ? Colors.black : Colors.orange) 
                  : Colors.grey,
              fontWeight: _request.racketColor.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            "Grip Color",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: (_racketInfoEntered && _request.racketColor.isNotEmpty) ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            !_racketInfoEntered 
                ? "Please enter racket information first"
                : _request.racketColor.isEmpty
                    ? "Please select racket color first"
                    : "Select the color for your racket grip:",
            style: TextStyle(
              fontSize: 16, 
              color: !_racketInfoEntered 
                  ? Colors.orange
                  : _request.racketColor.isEmpty 
                      ? Colors.orange
                      : Colors.grey,
              fontWeight: (!_racketInfoEntered || _request.racketColor.isEmpty) 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 30),
          Opacity(
            opacity: (_racketInfoEntered && _request.racketColor.isNotEmpty) ? 1.0 : 0.5,
            child: _buildColorPicker(
              selectedColor: _request.gripColor,
              onColorChanged: (_racketInfoEntered && _request.racketColor.isNotEmpty) 
                  ? (colorName) {
                      setState(() {
                        _request.gripColor = colorName;
                        _selectedColor = _nameToColor(colorName);
                      });
                    }
                  : (colorName) {},
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _request.gripColor.isNotEmpty 
                ? "Selected Grip Color: ${_request.gripColor}"
                : (_racketInfoEntered && _request.racketColor.isNotEmpty)
                    ? "Please select a grip color"
                    : "Select racket color first",
            style: TextStyle(
              fontSize: 18,
              color: _request.gripColor.isNotEmpty 
                  ? Colors.black
                  : (_racketInfoEntered && _request.racketColor.isNotEmpty)
                      ? Colors.orange
                      : Colors.grey,
              fontWeight: _request.gripColor.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _isStepComplete(0) ? _nextStep : null,
              child: const Text("Continue"),
            ),
          ),
        ],
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


  Widget _buildStringAndTensionStep() {
    final strings = [
      "BG65 Ti White\n(\$22)",
      "BG80\n(\$24)",
      "Exbolt 63 Yellow\n(\$25)",
      "Aerobite White/Red\n(\$26)",
      "I have my own string\n(\$18)",
    ];

    return SingleChildScrollView(
      key: const ValueKey("stringAndTensionStep"),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "String Type",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select the type of string for your racket:",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: strings.map((str) {
              String imagePath = _stringImages[str] ?? "";
              final isSelected = _selectedString == str;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedString = str;
                    _request.stringType = str;
                    _stringTypeSelected = true;
                    _showCustomStringInput = (str == "I have my own string\n(\$18)");
                    if (!_showCustomStringInput) {
                      _customStringController.clear();
                    }
                  });
                },
                child: Container(
                  width: 150,
                  height: 180,
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    elevation: isSelected ? 6 : 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imagePath.isNotEmpty)
                          Image.asset(imagePath, height: 80)
                        else
                          const Icon(Icons.sports_tennis, size: 50, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          str, 
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_stringTypeSelected) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "String type selected: $_selectedString",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
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
              "Please specify what string you have:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          const Text(
            "Example: Yonex Nanogy 98",
            style: TextStyle(fontSize: 14, color: Colors.blue, fontStyle: FontStyle.italic),
          ),
            const SizedBox(height: 10),
            TextField(
              controller: _customStringController,
              decoration: const InputDecoration(
                labelText: "Custom String Type",
                hintText: "Enter the string you currently have...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _request.stringType = "Custom: $value";
                  } else {
                      _request.stringType = "I have my own string\n(\$18)";
                  }
                });
              },
            ),
          ],
          const SizedBox(height: 40),
          Text(
            "String Tension",
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: _stringTypeSelected ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _stringTypeSelected 
                ? "Select the tension for your strings (lbs):"
                : "Please select a string type first",
            style: TextStyle(
              fontSize: 16, 
              color: _stringTypeSelected ? Colors.grey : Colors.orange,
              fontWeight: _stringTypeSelected ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Opacity(
            opacity: _stringTypeSelected ? 1.0 : 0.5,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Slider(
                    value: _tensionIndex.toDouble(),
                    min: 0,
                    max: (_tensionOptions.length - 1).toDouble(),
                    divisions: _tensionOptions.length - 1,
                    label: "${_tensionOptions[_tensionIndex]} lbs",
                    onChanged: _stringTypeSelected ? (value) {
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
                              color: _stringTypeSelected ? Colors.black : Colors.grey,
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
            "Selected: ${_tensionOptions[_tensionIndex]} lbs",
            style: TextStyle(
              fontSize: 18,
              color: _stringTypeSelected ? Colors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _isStepComplete(1) ? _nextStep : null,
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPaymentStep() {
    return Center(
      key: const ValueKey("paymentStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPaymentMethod = "Zelle";
                    _request.paymentMethod = _selectedPaymentMethod!;
                  });
                },
                child: const Text("Zelle"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPaymentMethod = "Cash";
                    _request.paymentMethod = _selectedPaymentMethod!;
                  });
                },
                child: const Text("Cash"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _isStepComplete(2) ? _nextStep : null,
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalQuestionsStep() {
    return SingleChildScrollView(
      key: const ValueKey("additionalQuestionsStep"),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Is there anything else you would like me to know?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
         
          const SizedBox(height: 10),
          const Text(
            "(Optional)",
            style: TextStyle(fontSize: 14, color: Colors.orange, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _additionalQuestionsController,
            decoration: const InputDecoration(
              labelText: "Additional Questions",
              hintText: "Enter any questions or requests you may have...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.help_outline),
            ),
            maxLines: 4,
            style: const TextStyle(fontSize: 16),
            onChanged: (value) {
              setState(() {
                _request.additionalQuestions = value;
              });
            },
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: _isStepComplete(3) ? _nextStep : null,
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      key: const ValueKey("summaryStep"),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text("Racket: ${_racketController.text}"),
          Text("Racket Color: ${_request.racketColor}"),
          Text("Grip Color: ${_request.gripColor}"),
          Text("Tension: ${_request.tension} lbs"),
          Text("String: ${_request.stringType}"),
          Text("Payment Method: ${_request.paymentMethod}"),
          if (_request.additionalQuestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text("Additional Questions/Concerns:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_request.additionalQuestions),
          ],
          const SizedBox(height: 30),
          const Text(
            "Terms & Conditions:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "By submitting this stringing request, you agree to our service policies and terms. "
            "Please ensure all information above is correct before submitting.",
          ),
          Row(
            children: [
              Checkbox(
                value: _acknowledgeTerms,
                onChanged: (value) {
                  setState(() {
                    _acknowledgeTerms = value!;
                  });
                },
              ),
              const Expanded(
                child: Text("I acknowledge the terms and conditions"),
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              onPressed: _acknowledgeTerms ? _submitRequest : null,
              child: const Text("Submit Stringing Request"),
            ),
          ),
          const SizedBox(height: 50),
        ],
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
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 32),
              onPressed: _canNavigateToPrev() ? _prevStep : null,
            )
          else
            const SizedBox(width: 48),
          if (_currentStep < _totalSteps - 1)
            IconButton(
              icon: Icon(
                Icons.arrow_forward, 
                size: 32,
                color: _canNavigateToNext() ? null : Colors.grey,
              ),
              onPressed: _canNavigateToNext() ? _nextStep : null,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: (_currentStep + 1) / _totalSteps,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
        minHeight: 8,
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
        'racketColor': _request.racketColor,
        'gripColor': _request.gripColor,
        'stringType': _request.stringType,
        'tension': _request.tension,
        'paymentMethod': _request.paymentMethod,
        'additionalInfo': _request.additionalQuestions,
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
