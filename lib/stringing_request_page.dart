import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class StringingRequestPage extends StatefulWidget {
  const StringingRequestPage({super.key});

  @override
  State<StringingRequestPage> createState() => _StringingRequestPageState();
}

class _StringingRequestPageState extends State<StringingRequestPage> {
  int _currentStep = 0;
  String? _selectedBrand;
  String? _selectedSeries;
  String? _selectedRacket;
  String? _selectedWeightClass;
  Color _selectedColor = Colors.blue;
  int _selectedTension = 24; // New tension selection
  String? _selectedString;

  // Brand → Series mapping
  final Map<String, List<String>> _brandToSeries = {
    "Yonex": ["Nanoflare", "Astrox", "Arcsaber"],
    "Victor": ["Thruster", "Auraspeed", "Jetspeed"],
    "Li-Ning": ["Turbocharging", "Aeronaut", "Tectonic"],
  };

  // Series → Rackets mapping
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

  // Yonex Arcsaber images
  final Map<String, String> _arcsaberImages = {
    "Arcsaber 11 Pro": "assets/images/rackets/yonex_arcsaber_11_pro.png",
    "Arcsaber 7 Pro": "assets/images/rackets/yonex_arcsaber_7_pro.png",
  };

  final Map<String, String> _stringImages = {
    "BG65 Ti": "assets/images/strings/bg_65_ti_white.png",
    "BG80": "assets/images/strings/bg_80_white.png",
    "Exbolt 63": "assets/images/strings/exbolt_63_yellow.png",
    "Aerobite": "assets/images/strings/aerobite.png",
    "No string needed": "", // No image for this option
  };

  // Weight classes
  final List<String> _weightClasses = ["2U", "3U", "4U", "5U", "6U", "7U"];
  int _weightIndex = 2; // Default to "4U" (index 2)

  final List<int> _tensionOptions = List.generate(
    11,
    (index) => 20 + index,
  ); // 20-30 lbs
  int _tensionIndex = 4; // Default to 24 lbs (index 4)

  void _nextStep() {
    setState(() {
      if (_currentStep < 6) _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _buildBrandStep(),
      _buildSeriesStep(),
      _buildRacketStep(),
      _buildWeightStep(),
      _buildTensionStep(),
      _buildStringStep(),
      _buildColorStep(),
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

  // Step 1: Select Brand
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
              String imagePath;
              if (brand == "Yonex") {
                imagePath = "assets/images/brands/yonex_logo.png";
              } else if (brand == "Victor") {
                imagePath = "assets/images/brands/victor_logo.png";
              } else {
                imagePath = "assets/images/brands/li_ning_logo.png";
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBrand = brand;
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

  // Step 2: Select Series
  Widget _buildSeriesStep() {
    if (_selectedBrand == null) {
      return const Center(
        key: ValueKey("seriesStep"),
        child: Text("Please select a brand first"),
      );
    }

    final seriesOptions = _brandToSeries[_selectedBrand]!;

    return Center(
      key: const ValueKey("seriesStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select a Series ($_selectedBrand)",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: seriesOptions.map((series) {
              String imagePath = "";
              if (series == "Nanoflare") {
                imagePath =
                    "assets/images/yonex_series/yonex_nanoflare_logo.png";
              } else if (series == "Astrox") {
                imagePath = "assets/images/yonex_series/yonex_astrox_logo.png";
              } else if (series == "Arcsaber") {
                imagePath =
                    "assets/images/yonex_series/yonex_arcsaber_logo.png";
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeries = series;
                    _currentStep = 2;
                  });
                },
                child: _buildSelectionCard(imagePath: imagePath, label: series),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 3: Select Racket
  Widget _buildRacketStep() {
    if (_selectedSeries == null) {
      return const Center(
        key: ValueKey("racketStep"),
        child: Text("Please select a series first"),
      );
    }

    final rackets = _seriesToRackets[_selectedSeries]!;

    return Center(
      key: const ValueKey("racketStep"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select a Racket ($_selectedSeries)",
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
                    _currentStep = 3;
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

  // Step 4: Select Weight
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
            width: MediaQuery.of(context).size.width * 0.5, // 50% width
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
            width: MediaQuery.of(context).size.width * 0.5, // 50% width
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
                    });
                  },
                ),
                // Tick labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _tensionOptions.map((t) {
                    return Text("$t", style: const TextStyle(fontSize: 12));
                  }).toList(),
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

  // Step: Select String
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
                    _nextStep(); // Move to next step after selection
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

  // Step 5: Select Grip Color
  Widget _buildColorStep() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                pickerAreaHeightPercent: 0.7,
                enableAlpha: false,
                displayThumbColor: true,
              ),
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Shared selection card builder
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

  // Navigation controls
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
          if (_currentStep < 6)
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

  // Progress bar
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LinearProgressIndicator(
        value: (_currentStep + 1) / 7,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
        minHeight: 8,
      ),
    );
  }
}
