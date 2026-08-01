import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:global_earn/features/auth/data/models/user_model.dart';
import 'package:global_earn/features/home/presentation/screens/verification_plan_screen.dart';

class PremiumBlurGuard extends StatelessWidget {
  final String featureName;
  final Widget child;
  final UserModel user;

  const PremiumBlurGuard({
    Key? key,
    required this.featureName,
    required this.child,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. FETCH USER STATUS
    final bool hasAccess = user.isVerified;
    final bool isPending = user.isPending;

    // 2. IF USER HAS ACCESS, RENDER SCREEN NORMALLY
    if (hasAccess) {
      return child;
    }

    // 3. IF NO ACCESS, RENDER THE BLURRED INTERCEPTOR LAYOUT
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Base Layer: The actual target screen but heavily blurred and non-clickable
          AbsorbPointer(
            absorbing: true,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: child,
            ),
          ),
          
          // Darkish tint overlay over the blur
          Container(color: Colors.black.withOpacity(0.05)),

          // Premium Modal Dialog Centered Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPending ? "ভেরিফিকেশন পর্যালোচনাধীন" : "একাউন্ট ভেরিফিকেশন প্রয়োজন",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPending 
                            ? "আপনার একাউন্ট ভেরিফিকেশন বর্তমানে পর্যালোচনাধীন আছে। অনুগ্রহ করে অপেক্ষা করুন।"
                            : "এই ফিচারটি ব্যবহার করতে আপনার একাউন্টটি ভেরিফাই করুন।",
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isPending)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => VerificationPlanScreen(user: user)),
                                );
                              },
                              child: const Text(
                                "একাউন্ট ভেরিফাই করুন",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          if (!isPending)
                            const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "এখনই নয়, পরে করব",
                              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToFeature({
  required BuildContext context,
  required UserModel user,
  required String featureName,
  required bool isImplemented,  // true = screen ready, false = coming soon
  required Widget targetScreen,
}) {
  final bool hasAccess = user.isVerified;

  // If the user has access but the feature is not implemented, show the coming soon snackbar.
  if (!isImplemented && hasAccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$featureName ফিচারটি খুব শীঘ্রই আসছে! আমাদের সাথেই থাকুন।"),
        backgroundColor: Colors.blue,
      ),
    );
    return;
  }

  // If the feature is implemented, or if the user is unverified,
  // push to the PremiumBlurGuard which handles showing the target screen or the verification overlay.
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (_) => PremiumBlurGuard(
        featureName: featureName,
        user: user,
        child: targetScreen,
      ),
    ),
  );
}
