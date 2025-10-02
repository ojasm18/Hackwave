# SyncSphere - Event Management Platform

A cross-platform event management app built with Flutter, Supabase, and Google Gemini AI. SyncSphere provides role-based dashboards for organizers, attendees, vendors, and sponsors with features like QR check-ins, real-time announcements, gamification, and AI assistance.

## Features

### 🎯 For Organizers
- Real-time event analytics (attendees, tasks, vendors, sponsors)
- QR code-based check-in system
- Announcement broadcasts
- SOS alert monitoring
- Vendor task management

### 🎟️ For Attendees
- Personalized event agenda
- QR check-in codes
- Live announcements
- Feedback & polls
- Gamification (points, badges, leaderboard)
- AI-powered event assistant

### 💼 For Sponsors
- ROI dashboard with real-time metrics
- Booth visit tracking
- Lead generation analytics

## 🚀 Tech Stack
- **Frontend**: Flutter (Material 3)
- **Backend**: Supabase (Auth, Realtime, Postgres)
- **AI**: Google Gemini
- **State Management**: Riverpod
- **Charts**: fl_chart
- **QR**: qr_flutter & mobile_scanner

## 🛠️ Setup

1. **Clone the repository**
   ```bash
   git clone [your-repo-url]
   cd flutter_application_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d chrome \
     --dart-define=SUPABASE_URL=your_supabase_url \
     --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key \
     --dart-define=GEMINI_API_KEY=your_gemini_api_key
   ```

## 🔧 Environment Variables
Create a `.env` file or use command-line arguments:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GEMINI_API_KEY=your_gemini_api_key
```

## 📱 Screens
- Splash & Onboarding
- Authentication (Email/Password)
- Role-based dashboards
- QR Scanner
- AI Chat Interface
- Analytics & Reports

## 📚 Documentation
- [Supabase Setup Guide](https://supabase.com/docs/guides/getting-started)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Google Gemini API](https://ai.google.dev/)

## 🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License
[MIT](https://choosealicense.com/licenses/mit/)
