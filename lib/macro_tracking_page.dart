import 'package:fit_app/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class MacroTrackingPage extends StatefulWidget {
  const MacroTrackingPage({super.key});

  @override
  State<MacroTrackingPage> createState() => _MacroTrackingPageState();
}

class _MacroTrackingPageState extends State<MacroTrackingPage> {
  double carbs = 0;
  double protein = 0;
  double calories = 0;
  double fat = 0;
  List<Map<String, dynamic>> meals = [];
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Variables for meal input
  double mealCarbs = 0;
  double mealProtein = 0;
  double mealCalories = 0;
  double mealFat = 0;

  void _addMeal(String name, double mealCarbs, double mealProtein,
      double mealCalories, double mealFat) {
    setState(() {
      meals.add({
        'name': name,
        'carbs': mealCarbs,
        'protein': mealProtein,
        'calories': mealCalories,
        'fat': mealFat,
      });

      carbs += mealCarbs;
      protein += mealProtein;
      calories += mealCalories;
      fat += mealFat;
    });
  }

  Future<void> _captureAndRecognizeText() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Parse the recognized text to extract nutritional information
      Map<String, double> nutritionInfo =
          _parseNutritionInfo(recognizedText.text);

      // Update the text fields with the extracted information
      setState(() {
        mealCarbs = nutritionInfo['carbs'] ?? 0;
        mealProtein = nutritionInfo['protein'] ?? 0;
        mealCalories = nutritionInfo['calories'] ?? 0;
        mealFat = nutritionInfo['fat'] ?? 0;
      });
    }
  }

  Map<String, double> _parseNutritionInfo(String text) {
    Map<String, double> info = {};
    RegExp carbsRegex = RegExp(r'Carbohydrates?[:\s]+(\d+\.?\d*)');
    RegExp proteinRegex = RegExp(r'Protein[:\s]+(\d+\.?\d*)');
    RegExp caloriesRegex = RegExp(r'Calories?[:\s]+(\d+\.?\d*)');
    RegExp fatRegex = RegExp(r'Fat[:\s]+(\d+\.?\d*)');

    info['carbs'] = _extractValue(text, carbsRegex);
    info['protein'] = _extractValue(text, proteinRegex);
    info['calories'] = _extractValue(text, caloriesRegex);
    info['fat'] = _extractValue(text, fatRegex);

    return info;
  }

  double _extractValue(String text, RegExp regex) {
    final match = regex.firstMatch(text);
    return match != null ? double.tryParse(match.group(1) ?? '0') ?? 0 : 0;
  }

  void _showAddMealDialog() {
  String mealName = '';

  showDialog(
    context: context,
    barrierColor: Colors.black26, // Less dark barrier
    barrierDismissible: true, // Allow dismissing by tapping outside
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Meal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      mealName = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Carbs',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: mealCarbs.toString()),
                    onChanged: (value) {
                      mealCarbs = double.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Protein',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: mealProtein.toString()),
                    onChanged: (value) {
                      mealProtein = double.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: mealCalories.toString()),
                    onChanged: (value) {
                      mealCalories = double.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Fat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: mealFat.toString()),
                    onChanged: (value) {
                      mealFat = double.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _captureAndRecognizeText();
                      setState(() {}); // Refresh the dialog to show updated values
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Nutrition Label'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (mealName.isNotEmpty) {
                            _addMeal(mealName, mealCarbs, mealProtein, mealCalories, mealFat);
                            // Clear the fields after adding the meal
                            mealName = '';
                            mealCarbs = 0;
                            mealProtein = 0;
                            mealCalories = 0;
                            mealFat = 0;
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  double get totalMacros => carbs + protein + calories + fat;

  
  @override
  Widget build(BuildContext context) {
    double carbsPercentage = totalMacros > 0 ? (carbs / totalMacros) * 100 : 0;
    double proteinPercentage = totalMacros > 0 ? (protein / totalMacros) * 100 : 0;
    double caloriesPercentage = totalMacros > 0 ? (calories / totalMacros) * 100 : 0;
    double fatPercentage = totalMacros > 0 ? (fat / totalMacros) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Macro Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Daily Intake",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  meals.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No meals added yet.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              constraints: const BoxConstraints(
                                maxWidth: 120,
                                maxHeight: 120,
                              ),
                              child: PieChart(
                                PieChartData(
                                  startDegreeOffset: 0,
                                  sections: [
                                    PieChartSectionData(
                                      value: carbsPercentage,
                                      color: Colors.blue,
                                      title: '${carbsPercentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      radius: 40,
                                    ),
                                    PieChartSectionData(
                                      value: proteinPercentage,
                                      color: Colors.red,
                                      title: '${proteinPercentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      radius: 40,
                                    ),
                                    PieChartSectionData(
                                      value: caloriesPercentage,
                                      color: Colors.orangeAccent,
                                      title: '${caloriesPercentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      radius: 40,
                                    ),
                                    PieChartSectionData(
                                      value: fatPercentage,
                                      color: Colors.green,
                                      title: '${fatPercentage.toStringAsFixed(1)}%',
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      radius: 40,
                                    ),
                                  ],
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Carbs: ${carbsPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  'Protein: ${proteinPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                Text(
                                  'Calories: ${caloriesPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.orangeAccent),
                                ),
                                Text(
                                  'Fat: ${fatPercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return Card(
                    child: ListTile(
                      title: Text(meal['name']),
                      subtitle: Text(
                        'Carbs: ${meal['carbs']}g, Protein: ${meal['protein']}g, Calories: ${meal['calories']} kcal, Fat: ${meal['fat']}g',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'addMeal',  // Added unique hero tag
              onPressed: _showAddMealDialog,
              child: const Icon(Icons.add),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'chat',  // Added unique hero tag
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              child: const Icon(Icons.chat),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
