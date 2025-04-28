# Quizpp - Flutter Quiz App
[![Demo Video]](assets/quizAppVideo_Aman_Agrawal.mp4)

## 📌 Overview
Quizpp is a Flutter-based quiz application that allows users to register, log in, and participate in quizzes. It features Firebase authentication, real-time data storage, and a responsive UI.

## 🚀 Features
- User authentication (Sign Up, Login, Logout) with Firebase
- Profile management
- Dynamic quiz interface
- Real-time database integration
- Responsive and clean UI

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Authentication, Firestore Database
- **State Management:** Provider / Riverpod (optional)
- **Navigation:** Named Routes / GoRouter

## 📷 Screenshots
(Add relevant screenshots here)

## 🎯 Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/MARSHMELLO-4/QuizApp.git
   ```
2. Navigate to the project directory:
   ```sh
   cd quizpp
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Configure Firebase:
   - Set up Firebase in your project
   - Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS)
   - Place them in the respective `android/app` and `ios/Runner` directories
5. Run the app:
   ```sh
   flutter run
   ```

## 📂 Project Structure
```
quizpp/
│-- lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── home_screen.dart
│   │   ├── profile_screen.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── text_field.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   ├── models/
│   │   ├── user_model.dart
```

## 📝 Contributing
Contributions are welcome! Feel free to fork the repo, create a new branch, and submit a pull request.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact
For any inquiries or support, contact Aman Agrawal aman2004agrawal@gmail.com

