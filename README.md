# 🏥 HealthSense AI  
### Smart Health Assistant for University Students

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Gemini](https://img.shields.io/badge/Google%20Gemini-AI-green?logo=google)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

HealthSense AI is an intelligent mobile-based health assistant designed to help university students assess early symptoms and make informed health decisions. The application leverages Artificial Intelligence to analyze user-described symptoms and provide probabilistic illness predictions with confidence scores, while emphasizing privacy, speed, and ethical use.

> ⚠️ **Disclaimer**: HealthSense AI is a preliminary diagnostic tool and does not replace professional medical advice. Always consult a qualified healthcare provider for serious or persistent symptoms.

---

## 📱 Project Overview

Many students delay seeking medical care due to uncertainty, academic workload, or limited access to healthcare facilities. HealthSense AI bridges this gap by offering instant, AI-powered symptom analysis and actionable health guidance for common student illnesses such as malaria, typhoid, flu, and cold.

Users describe symptoms in natural language and receive AI-generated illness predictions with confidence scores to guide urgency and next steps.

---

## ✨ Key Features

- 📝 **Natural Language Symptom Input**  
  Describe symptoms freely without rigid checklists.

- 🧠 **AI-Powered Illness Prediction**  
  Powered by Google Gemini Large Language Models.

- 📊 **Confidence-Based Results**  
  Each prediction includes a likelihood percentage.

- 🔒 **Secure Medical Records**  
  Firebase Authentication and Cloud Firestore ensure data privacy.

- ⚡ **Fast Response Time**  
  Optimized for low-latency feedback.

- 🎓 **Student-Focused Design**  
  Tailored to common health challenges in university environments.

---

## 🏗️ System Architecture

HealthSense AI follows a **serverless client-server architecture**:

- **Frontend**: Flutter (Dart) with Material Design 3  
- **AI Engine**: Google Generative AI SDK (Gemini 2.5 Flash)  
- **Backend**: Firebase Authentication & Cloud Firestore (NoSQL)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-----|-----------|
| Frontend | Flutter (Dart) |
| AI Engine | Google Gemini API |
| Backend | Firebase |
| Database | Cloud Firestore |
| Design | Material Design 3 |

---

## 🚀 Getting Started

### Install Dependencies
```bash
flutter pub get
````

### Configure API Key

Add your Gemini API key in:

```text
lib/services/ai_service.dart
```

```dart
const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

### Run the Application

```bash
flutter run
```


## 🧪 Testing and Quality Assurance

A hybrid testing strategy was adopted to ensure system reliability:

### ✅ Unit Testing

* Tested prompt construction and response parsing logic.

### ⚙️ System Testing

* Verified response latency below **1.2 seconds**.

### 🔐 Security Testing

* Ensured proper data isolation using **Firebase Security Rules**.

---

## 📸 Screenshots & Demo

> 📌 *Replace the placeholders below with actual screenshots or GIFs from your app.*

### 📱 App Screenshots

| Home Screen                   | Symptom Input                   | Prediction Result                 |
| ----------------------------- | ------------------------------- | --------------------------------- |
| ![Home](https://github.com/Rufuscsc/HealthSense-AI/blob/master/screenshot/homepage.png) | ![Input](https://github.com/Rufuscsc/HealthSense-AI/blob/master/screenshot/symptomspage.png) | ![Result](https://github.com/Rufuscsc/HealthSense-AI/blob/master/screenshot/resultpage.png) |

### 🎥 Demo GIF

<img src="https://github.com/Rufuscsc/HealthSense-AI/blob/master/screenshot/demo.gif" width="300" />

---

## 📌 Project Scope & Limitations

### Scope

* Early symptom assessment
* Common student illnesses
* Mobile-based self-assessment
* Secure health data storage

### Limitations

* Not a replacement for professional medical diagnosis
* Accuracy depends on user-provided symptom quality
* Limited to predefined illness categories

---

## 🎓 Academic Information

* **Author**: Wellens Rufus
* **Matric No**: 222517
* **Department**: Computer Science
* **Academic Year**: 2024/2025
* **Project Type**: Final Year Project (UI)

---

## 📜 License

This project is developed strictly for academic purposes.

---

## ⭐ Acknowledgements

Special appreciation to academic supervisors and mentors for their guidance and support throughout the development of this project.
