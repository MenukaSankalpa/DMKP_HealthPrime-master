import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/data/models/health_record.dart';

class AiService {
  static const String _apiKey = 'AIzaSyDzOpx2NyvxdRKDEzGMh1NOMWHNVjSArgc';

  Future<String> getHealthInsights(RecordsProvider recordsProvider, double? height, double? weight) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      // Data
      final steps = recordsProvider.getAverage('steps');
      final sleep = recordsProvider.getAverage('sleep');
      final water = recordsProvider.getAverage('water');
      final calories = recordsProvider.getAverage('calories');
      final workout = recordsProvider.getAverage('workout');
      final mood = recordsProvider.getAverage('mood');

      String bmiContext = "";
      if (height != null && weight != null && height > 0 && weight > 0) {
        double bmi = weight / ((height / 100) * (height / 100));
        bmiContext = "User Stats for context: Height: ${height}cm, Weight: ${weight}kg, BMI: ${bmi.toStringAsFixed(1)}.";
      }

      // Prompt
      final prompt = '''
        Act as a professional health coach. Analyze the following average health stats for a user:
        - Steps: $steps (Goal: 10000)
        - Sleep: $sleep hours (Goal: 8.0)
        - Water: $water ml (Goal: 2000)
        - Calories Burned: $calories (Goal: 500)
        - Workout Minutes: $workout (Goal: 60)
        - Mood Score: $mood/10
        $bmiContext

        Provide a response in exactly this structure (do not use markdown **bold** syntax, just plain text with clear separation headers):
        
        SUMMARY
        [Write a 2-3 sentence summary of their overall performance.]

        STRENGTHS
        [Provide 3 or more bullet points of what they are doing well based on the stats  ( use • symbol for bullets ).]

        IMPROVEMENTS
        [Provide 3 or more bullet points on specific areas to improve.]

        SUGGESTIONS
        [Provide 3 or more specific, actionable recommendations tailored to their stats and BMI if available  ( use • symbol for bullets ).]

        MOTIVATION
        [A short, 1 sentence motivational quote or message.]
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? "Unable to generate insights at this time.";
    } catch (e) {
      throw "AI Service Error: $e";
    }
  }
}