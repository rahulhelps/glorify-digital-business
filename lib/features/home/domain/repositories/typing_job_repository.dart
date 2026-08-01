abstract class TypingJobRepository {
  /// Fetch the typing job progress including verified referrals, available sets, and past sessions
  Future<Map<String, dynamic>> getTypingJobProgress();

  /// Submit the math quiz results, award the bonus, and save the session
  Future<void> completeMathSession({
    required int setNumber,
    required int correctCount,
    required List<Map<String, dynamic>> questions,
    required List<int> answers,
  });
}
