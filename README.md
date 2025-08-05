# LearnMate - AI-Powered Learning Assistant

A sleek, minimalistic Flutter app that provides an AI-powered learning experience with interactive teaching sessions and flash note summaries.

## Features

### 🔐 Authentication Screen
- Clean, animated login interface
- Email/password validation
- Sign In/Sign Up functionality
- Smooth transitions and loading states

### 🏠 Home Screen
- Interactive prompt input with chat-style interface
- Animated floating topic suggestion chips
- Beautiful gradient backgrounds
- "Teach Me 📚" submission button

### 🎥 Avatar Video Screen
- Animated AI avatar with pulsing effects
- Audio playback controls (play, pause, seek)
- Progress tracking and duration display
- Live lecture interface with AI teacher name
- Skip to flash notes functionality

### 📝 Flash Notes Screen
- Expandable FAQ cards with smooth animations
- Color-coded question categories
- Statistics display (questions count, estimated time)
- Save notes functionality

## App Flow

1. **Authentication** → User logs in or signs up
2. **Home Screen** → User enters learning topic or selects from suggestions
3. **Video Screen** → AI avatar teaches the topic with audio
4. **Flash Notes** → User reviews key points in FAQ format

## Design Features

- **Material 3 Design System** with rounded corners and soft shadows
- **Pastel Color Palette** with gradient backgrounds
- **Smooth Animations** throughout the app
- **Responsive Layout** for Android, iOS, and web
- **Clean Typography** without external icon dependencies

## Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── screens/
│   ├── auth_screen.dart     # Authentication interface
│   ├── home_screen.dart     # Topic input and suggestions
│   ├── video_screen.dart    # AI teaching session
│   └── flash_notes.dart     # FAQ summary page
└── widgets/
    ├── prompt_input.dart    # Custom text input widget
    └── faq_card.dart        # Expandable FAQ card widget
```

## Dependencies

- `flutter`: Core Flutter framework
- `audioplayers`: Audio playback functionality
- `lottie`: Animation support
- `http`: HTTP requests for API integration

## Backend Integration (Future)

The app is designed to integrate with a FastAPI backend using Groq API:

### API Endpoint: `/generate_lesson`
**Request:**
```json
{
  "prompt": "User's learning topic"
}
```

**Response:**
```json
{
  "audioUrl": "https://example.com/audio.mp3",
  "avatarName": "Prof. Nova",
  "flashNotes": [
    {"q": "What is X?", "a": "Explanation..."},
    {"q": "How does X work?", "a": "Explanation..."}
  ]
}
```

## Getting Started

1. **Install Flutter** (if not already installed)
2. **Clone the repository**
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## Customization

### Colors
The app uses a custom color scheme defined in `main.dart`:
- Primary: `#6B73FF` (Purple-blue)
- Secondary: `#FF6B9D` (Pink)
- Tertiary: `#4ECDC4` (Teal)

### Animations
All animations use Flutter's built-in animation controllers with custom curves for smooth, professional transitions.

### Themes
The app supports Material 3 theming with custom input decorations, card themes, and button styles.

## Future Enhancements

- [ ] Backend API integration
- [ ] User authentication with real database
- [ ] Audio recording and playback
- [ ] Offline mode support
- [ ] User progress tracking
- [ ] Favorite topics and notes
- [ ] Dark mode support
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.


