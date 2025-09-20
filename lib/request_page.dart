import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'stringing_request.dart';

class StringingRequestPage extends StatefulWidget {
  const StringingRequestPage({super.key});

  @override
  State<StringingRequestPage> createState() => _StringingRequestPageState();
}

class _StringingRequestPageState extends State<StringingRequestPage> {
  int _totalSteps = 8;
  int _currentStep = 0;

  String? _selectedBrand;
  String? _selectedRacket;
  String? _selectedWeightClass;
  Color _selectedColor = Colors.blue;
  int _selectedTension = 24;
  String? _selectedString;
  String? _selectedPaymentMethod;
  bool _acknowledgeTerms = false;

  final StringingRequest _request = StringingRequest(
    tension: 24,
    gripColor: 'Blue',
  );

  final Map<String, List<String>> _brandToSeries = {
    "Yonex": ["Nanoflare", "Astrox", "Arcsaber"],
    "Victor": ["Thruster", "Auraspeed", "Jetspeed"],
    "Li-Ning": ["Turbocharging", "Aeronaut", "Tectonic"],
  };

  final Map<String, List<String>> _seriesToRackets = {
    "Nanoflare": ["Racket 1", "Racket 2", "Racket 3"],
    "Astrox": ["Racket 1", "Racket 2", "Racket 3"],
    "Arcsaber": ["Arcsaber 11 Pro", "Arcsaber 7 Pro"],
    "Thruster": ["Racket 1", "Racket 2"],
    "Auraspeed": ["Racket 1", "Racket 2"],
    "Jetspeed": ["Racket 1", "Racket 2"],
    "Turbocharging": ["Racket 1", "Racket 2"],
    "Aeronaut": ["Racket 1", "Racket 2"],
    "Tectonic": ["Racket 1", "Racket 2"],
  };

  final Map<String, String> _arcsaberImages = {
    "Arcsaber 11 Pro": "assets/images/rackets/yonex_arcsaber_11_pro.png",
    "Arcsaber 7 Pro": "assets/images/rackets/yonex_arcsaber_7_pro.png",
  };

  final Map<String, String> _stringImages = {
    "BG65 Ti": "assets/images/strings/bg_65_ti_white.png",
    "BG80": "assets/images/strings/bg_80_white.png",
    "Exbolt 63": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite": "assets/images/strings/aerobite.png",
    "No string needed": "",
  };

  final List<String> _weightClasses = ["2U", "3U", "4U", "5U", "6U", "7U"];
  int _weightIndex = 2;

  final List<int> _tensionOptions = List.generate(11, (index) => 20 + index);
  int _tensionIndex = 4;

  void _nextStep() {
    setState(() {
      if (_currentStep < _totalSteps - 1) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
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
    return "Custom Color";
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildBrandStep(),
      _buildRacketStep(),
      _buildWeightStep(),
      _buildTensionStep(),
      _buildStringStep(),
      _buildColorStep(),
      _buildPaymentStep(),
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

  Widget _buildBrandStep() {
    final brands = ["Yonex", "Victor", "Li-Ning"];
    return Center(
      key: const ValueKey("brandStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select a Brand",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: brands.map((brand) {
              String imagePath =
                  "assets/images/brands/${brand.toLowerCase().replaceAll('-', '_')}_logo.png";
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBrand = brand;
                    _request.brand = brand;
                    _currentStep = 1;
                  });
                },
                child: _buildSelectionCard(imagePath: imagePath, label: brand),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRacketStep() {
    if (_selectedBrand == null)
      return const Center(child: Text("Please select a brand first"));

    List<String> rackets = [];
    if (_selectedBrand == "Yonex") {
      rackets = ["Racket 1", "Racket 2", "Arcsaber 11 Pro", "Arcsaber 7 Pro"];
    } else if (_selectedBrand == "Victor") {
      rackets = ["Racket 1", "Racket 2"];
    } else if (_selectedBrand == "Li-Ning") {
      rackets = ["Racket 1", "Racket 2"];
    }

    return Center(
      key: const ValueKey("racketStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select a Racket ($_selectedBrand)",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: rackets.map((racket) {
              String imagePath = _arcsaberImages[racket] ?? "";
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRacket = racket;
                    _request.racket = racket;
                    _nextStep();
                  });
                },
                child: _buildSelectionCard(
                  imagePath: imagePath,
                  label: racket,
                  imageHeight: imagePath.isNotEmpty ? 120 : 60,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightStep() {
    return Center(
      key: const ValueKey("weightStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select Racket Weight",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Slider(
              value: _weightIndex.toDouble(),
              min: 0,
              max: (_weightClasses.length - 1).toDouble(),
              divisions: _weightClasses.length - 1,
              label: _weightClasses[_weightIndex],
              onChanged: (value) {
                setState(() {
                  _weightIndex = value.round();
                  _selectedWeightClass = _weightClasses[_weightIndex];
                  _request.weightClass = _selectedWeightClass!;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selected: ${_weightClasses[_weightIndex]}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _nextStep, child: const Text("Confirm")),
        ],
      ),
    );
  }

  Widget _buildTensionStep() {
    return Center(
      key: const ValueKey("tensionStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select String Tension (lbs)",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Slider(
                  value: _tensionIndex.toDouble(),
                  min: 0,
                  max: (_tensionOptions.length - 1).toDouble(),
                  divisions: _tensionOptions.length - 1,
                  label: "${_tensionOptions[_tensionIndex]} lbs",
                  onChanged: (value) {
                    setState(() {
                      _tensionIndex = value.round();
                      _selectedTension = _tensionOptions[_tensionIndex];
                      _request.tension = _selectedTension;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _tensionOptions
                      .map(
                        (t) => Text("$t", style: const TextStyle(fontSize: 12)),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selected: ${_tensionOptions[_tensionIndex]} lbs",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _nextStep, child: const Text("Confirm")),
        ],
      ),
    );
  }

  Widget _buildStringStep() {
    final strings = [
      "BG65 Ti",
      "BG80",
      "Exbolt 63",
      "Aerobite",
      "No string needed",
    ];
    return Center(
      key: const ValueKey("stringStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select a String",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: strings.map((str) {
              String imagePath = _stringImages[str] ?? "";
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedString = str;
                    _request.stringType = str;
                    _nextStep();
                  });
                },
                child: _buildSelectionCard(
                  imagePath: imagePath,
                  label: str,
                  imageHeight: imagePath.isNotEmpty ? 80 : 50,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorStep() {
    final Map<String, Color> colorOptions = {
      "Red": Colors.red,
      "Blue": Colors.blue,
      "Green": Colors.green,
      "Yellow": Colors.yellow,
      "Sky Blue": Colors.lightBlue,
      "Purple": Colors.purple,
      "Orange": Colors.orange,
      "Black": Colors.black,
      "White": Colors.white,
    };

    return Center(
      key: const ValueKey("colorStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Select Grip Color",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: colorOptions.entries.map((entry) {
              final colorName = entry.key;
              final colorValue = entry.value;
              final isSelected = _request.gripColor == colorName;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _request.gripColor = colorName;
                    _selectedColor = colorValue;
                    _nextStep();
                  });
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
          ),
          const SizedBox(height: 20),
          Text(
            "Selected: ${_request.gripColor}",
            style: const TextStyle(fontSize: 18),
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
                    _nextStep();
                  });
                },
                child: const Text("Zelle"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedPaymentMethod = "Cash";
                    _request.paymentMethod = _selectedPaymentMethod!;
                    _nextStep();
                  });
                },
                child: const Text("Cash"),
              ),
            ],
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
          Text("Racket: ${_request.brand} ${_request.racket}"),
          Text("Weight: ${_request.weightClass}"),
          Text("Tension: ${_request.tension} lbs"),
          Text("String: ${_request.stringType}"),
          Text("Grip Color: ${_request.gripColor}"),
          Text("Payment Method: ${_request.paymentMethod}"),
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
              onPressed: _acknowledgeTerms
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Stringing request submitted!"),
                        ),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  : null,
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
              onPressed: _prevStep,
            )
          else
            const SizedBox(width: 48),
          if (_currentStep < _totalSteps - 1)
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 32),
              onPressed: _nextStep,
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
}
