import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safecampus/view/auth_screens/auth_screen.dart'; // Replace with actual path to your login/auth screen
import 'package:safecampus/view/mainScreens/home_screen.dart'; // Import your HomeScreen

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  final List<Map<String, dynamic>> demoData = [
    {
      "illustration": "assets/logo.png",
      "title": "Seamless Management",
      "text": "Effortlessly track and manage campus incidents and reports with our user-friendly dashboard.",
    },

    {
      "illustration": "assets/logo.png",
      "title": "Anonymity",
      "text": "Freely share your thoughts with community.",
    },
    {

      "illustration": "assets/aa.jpg",
      "title": "Enhanced Security",
      "text": "Ensure safety with data encryption and secure access controls.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              height: 500,
              child: PageView.builder(
                controller: _pageController,
                itemCount: demoData.length,
                onPageChanged: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardContent(
                    illustration: demoData[index]['illustration'],
                    title: demoData[index]['title'],
                    text: demoData[index]['text'],
                  );
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedDot(isActive: _selectedIndex == index),
                ),
              ),
            ),
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: () async {
                if (_selectedIndex == demoData.length - 1) {
                  // Mark intro as completed
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isIntroCompleted', true);

                  // Navigate to login or home based on auth status
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FirebaseAuth.instance.currentUser == null
                          ? LandingPage() // Replace with actual landing/auth screen
                          : HomeScreen(),
                    ),
                  );
                } else {
                  _pageController.nextPage(
                      duration: Duration(milliseconds: 300), curve: Curves.ease);
                }
              },
              child: Text(
                _selectedIndex == demoData.length - 1 ? "Get Started" : "Next",
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  final String illustration, title, text;

  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.asset(
            illustration,
            fit: BoxFit.contain, // You can adjust the BoxFit as per your needs
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class AnimatedDot extends StatelessWidget {
  final bool isActive;

  const AnimatedDot({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.redAccent : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
