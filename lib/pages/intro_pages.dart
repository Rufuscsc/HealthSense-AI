import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Lottie.network(
                  'https://lottie.host/4b3d7640-f6b1-4ea2-b87a-473e711304be/ObLBXYpW1S.json',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  "Smart Symptom Checker",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Subtitle
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  "Tell HealthSense AI how you feel, and instantly receive "
                      "intelligent insights based on your symptoms.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}


class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Lottie.network(
                  'https://lottie.host/a064032a-42da-47e6-9017-a1a6712e9653/rQYiH9lbJg.json',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),
              const Center(
                child: Text(
                  "AI-Powered Predictions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  "Our large language model analyzes your symptoms to estimate possible illnesses with high accuracy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}


class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Lottie.network(
                  'https://lottie.host/f190ce9e-bc41-4cfb-af33-843ff359c9c4/KvUVHkC5iL.json',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "Personalized Health Advice",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Receive simple steps, guidance, and recommendations tailored to your condition anytime, anywhere.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

