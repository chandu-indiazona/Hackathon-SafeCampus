# Safe Campus

### **Empowering Safety and Anonymity for Girl Students in Universities**

---

## **Project Overview**

**Safe Campus** is a mobile application designed to address the critical issue of harassment faced by girl students in universities. From verbal abuse to stalking and cyber harassment, the app provides a safe platform for victims to report, seek support, and stay connected. With a focus on anonymity, it encourages open communication, ensures privacy, and fosters a safer campus environment.

---

## **Solution Summary**

**Safe Campus** empowers students with tools to report harassment, request immediate assistance, and access community resources in an anonymous, secure, and user-friendly manner. The app bridges the gap between students and authorities, enabling faster response times and creating a strong support network within universities.

---

## **Key Features**

### **1. Login and Anonymity**
- Simple email and password login.
- No verification process to ensure anonymity.
- Unique IDs assigned to users to maintain privacy.

### **2. SOS**
- Sends an immediate alert with the student's name, phone number, and current location to the community chat, including admins and university officials.
- Location link opens directly in Google Maps for easy navigation.

### **3. Report Incident**
- Easy-to-use form to report incidents with optional fields for:
  - **Incident Type** (Dropdown).
  - **Location** (Dropdown).
  - **Description** (Optional).
  - **Culprit Details**.
  - **Media Uploads** (Screenshots or other files).
- Student-friendly design ensures accessibility.

### **4. Track Complaints**
- Displays the status of complaints: **Unresolved**, **Processing**, or **Solved**, with color-coded statuses.
- Shows timestamps and additional admin comments for transparency.

### **5. Resources**
- Provides essential resources for girl students, such as:
  - Anti-harassment policies.
  - Mental health support.
  - Other useful materials.

### **6. Community Chat**
- A platform for anonymous discussions among students, admins, and officials.
- Fake names are assigned to users for posts (except SOS messages).
- Ensures 100% anonymity with no tracking of unique IDs.

### **7. Emergency Numbers**
- A comprehensive list of emergency contacts for quick access during critical situations.

---

## **Technology Stack**

- **Frontend**: Flutter
- **Backend**: Firebase (for email authentication and file storage)
- **IDE**: Android Studio

---

## **Setup & Installation**

### **System Requirements**
- Flutter SDK installed.
- Android Studio with emulator setup.
- Node.js (optional for Firebase CLI tools).

### **Steps to Run the App**
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd safe-campus
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Connect to Firebase:
   - Add your `google-services.json` file to the `android/app` directory.
   - Configure `.env` file as per the sample.
4. Run the app:
   ```bash
   flutter run
   ```

---

## **Sample Data**

### **Environment Variables**
Provide the following in a `.env` file:
```env
FIREBASE_API_KEY=<your-firebase-api-key>
FIREBASE_AUTH_DOMAIN=<your-firebase-auth-domain>
FIREBASE_PROJECT_ID=<your-firebase-project-id>
```

### **Login Credentials**
Sample login credentials are available in `login.txt` for testing both apps:
- **Safe Campus (Student App):**
  ```
  Email: student1@example.com
  Password: student123
  ```
- **Campus Admin (Admin App):**
  ```
  Email: admin1@example.com
  Password: admin123
  ```

---

## **Folder Structure**
- `frontend/` - Flutter app code.
- `backend/` - Firebase functions (if applicable).
- `docs/` - Documentation and assets.

---

## **Future Scope**
- Integration with AI to analyze complaint trends and suggest preventive measures.
- Real-time chat translation for multilingual campuses.
- Gamification features to reward students for community engagement.
- Offline mode for emergency features.

---

## **Team**
- **Your Name** - Developer & Designer
- **Team Member Name (if any)** - Role (e.g., Backend Developer)

---

## **Acknowledgements**
- University support for testing and validation.
- Flutter and Firebase for seamless development.
- Hackathon mentors for their guidance.

---

## **License**
This project is licensed under the [MIT License](LICENSE).
