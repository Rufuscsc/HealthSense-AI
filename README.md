# 🏥 HealthSense AI: Smart Health Assistant

[cite_start]**HealthSense AI** is an intelligent mobile diagnostic assistant designed specifically for university students[cite: 7, 82]. [cite_start]It bridges the gap between early symptoms and medical action by providing instant, AI-driven illness predictions and actionable health advice[cite: 82, 311].

---

## ✨ Key Features

* [cite_start]**Natural Language Symptom Entry**: Describe how you feel in your own words; no rigid checklists are required[cite: 86, 121].
* [cite_start]**Gemini-Powered Inference**: Leverages Large Language Models (LLMs) to analyze unstructured symptoms with **92% accuracy** for common tropical diseases[cite: 82, 173, 220].
* [cite_start]**Probabilistic Predictions**: Receive a diagnosis with a **Confidence Score** (e.g., "88% likelihood of Malaria") to help you understand the urgency[cite: 87, 307].
* [cite_start]**Secure Medical History**: All entries are stored in Cloud Firestore using strict **Row-Level Security (RLS)** to ensure your health data remains private and isolated[cite: 88, 202].
* [cite_start]**Context-Aware Advice**: Tailored recommendations for common student health issues like Malaria, Typhoid, and Flu[cite: 193, 307].

---

## 🚀 System Architecture

[cite_start]The application follows a modern **Serverless Client-Server** pattern[cite: 160]:

* [cite_start]**Frontend**: Built with **Flutter (Dart)** using **Material Design 3** for a fast, intuitive UI[cite: 86, 159].
* [cite_start]**AI Engine**: Integrated via the **Google Generative AI SDK** using the **Gemini 2.5 Flash** model[cite: 161, 194].
* [cite_start]**Backend**: Powered by **Firebase** for Authentication and **Cloud Firestore** for real-time data persistence[cite: 160, 162].



---

## 🛠️ Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable version)
* A [Google Gemini API Key](https://aistudio.google.com/app/apikey)
* A [Firebase Project](https://console.firebase.google.com/)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone [https://github.com/Rufuscsc/HealthSense-AI.git](https://github.com/Rufuscsc/HealthSense-AI.git)
    cd HealthSense-AI
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Environment Setup**: Add your Gemini API Key to your configuration file (e.g., `lib/services/ai_service.dart`):
    ```dart
    const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
    ```
4.  **Run the application**:
    ```bash
    flutter run
    ```

---

## 🧪 Testing and Quality

[cite_start]This project employs a **Hybrid Testing Strategy** to ensure medical-grade reliability[cite: 217]:

* [cite_start]**Unit Testing**: 100% pass rate on critical prompt construction and JSON parsing logic[cite: 218, 230].
* [cite_start]**System Testing**: Verified **<1.2s latency** for instant user feedback[cite: 220].
* [cite_start]**Security Testing**: Robust data isolation confirmed through **Firebase Security Rules**[cite: 221, 254].

---

## 👥 Author
* [cite_start]**Wellens Rufus** (Matric No: 222517) [cite: 4, 5]
* [cite_start]**Supervisor**: Prof. Adebola K. [cite: 6]
* [cite_start]**Department**: Department of Computer Science, Academic Year 2024/2025 [cite: 1, 3]

---

## 📜 License
This project is my final year project in UI.

> **Disclaimer**: *HealthSense AI is a preliminary diagnostic tool and does not replace professional medical advice. [cite_start]Always consult a qualified healthcare provider for critical symptoms[cite: 79, 291].*
