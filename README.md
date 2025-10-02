# Travel Buddy - Flutter Mobile App

A comprehensive travel management mobile application built with Flutter using the MVC (Model-View-Controller) architecture pattern. This app integrates with a Laravel backend API to provide complete travel planning and management functionality.

## Features

### Authentication
- **OTP-based Registration**: Send and verify OTP for account creation
- **Login/Logout**: Secure authentication with JWT tokens
- **Password Reset**: Forgot password functionality with OTP verification
- **Persistent Sessions**: Automatic login with stored tokens

### Trip Management
- **Create Trips**: Add new travel plans with destination, dates, and notes
- **View Trips**: Browse all your trips with status indicators (Upcoming, Ongoing, Completed)
- **Edit Trips**: Update trip details and notes
- **Delete Trips**: Remove unwanted trips
- **Trip Details**: Comprehensive trip information view

### Document Management
- **Upload Documents**: Add travel documents (passports, tickets, etc.)
- **Document Gallery**: View all uploaded documents for each trip
- **Multiple Sources**: Upload from camera, gallery, or file system
- **Document Organization**: Documents are organized by trip

### User Profile
- **Profile Management**: View and edit user information
- **Account Settings**: Update name, phone, and address
- **Account Deletion**: Complete account removal functionality

## Architecture

### MVC Pattern Implementation

#### Models (`lib/models/`)
- `user.dart` - User data model
- `trip.dart` - Trip data model  
- `document.dart` - Document data model
- `api_response.dart` - API response wrapper models

#### Views (`lib/views/`)
- **Authentication Views**:
  - `welcome_screen.dart` - App landing page
  - `login_screen.dart` - User login
  - `register_screen.dart` - User registration
  - `otp_verification_screen.dart` - OTP verification and password reset

- **Home Views**:
  - `home_screen.dart` - Main app screen with navigation
  - `trip_list_screen.dart` - List of all trips
  - `trip_detail_screen.dart` - Individual trip details
  - `add_trip_screen.dart` - Create new trip
  - `edit_trip_screen.dart` - Edit existing trip
  - `profile_screen.dart` - User profile management
  - `document_list_screen.dart` - Trip documents management

#### Controllers (`lib/controllers/`)
- `auth_controller.dart` - Authentication logic and state management
- `trip_controller.dart` - Trip CRUD operations and state management
- `profile_controller.dart` - User profile management
- `document_controller.dart` - Document upload and management

#### Services (`lib/services/`)
- `api_service.dart` - HTTP API communication with Laravel backend
- `storage_service.dart` - Local storage management (SharedPreferences)

#### Widgets (`lib/widgets/`)
- `custom_widgets.dart` - Reusable UI components (CustomTextField, CustomButton, CustomCard)
- `common_widgets.dart` - Common UI elements (LoadingWidget, ErrorWidget, EmptyStateWidget)

#### Configuration (`lib/config/`)
- `api_config.dart` - API endpoints and configuration

## API Integration

The app integrates with your Laravel backend using the following endpoints:

### Authentication APIs
- `POST /api/send-otp` - Send OTP to email
- `POST /api/verify-otp` - Verify OTP code
- `POST /api/register` - User registration
- `POST /api/login` - User login
- `POST /api/forgot-password` - Send password reset OTP
- `POST /api/reset-password` - Reset password with OTP

### Profile APIs
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile
- `DELETE /api/profile` - Delete user account

### Trip Management APIs
- `POST /api/trips` - Create new trip
- `GET /api/trips` - Get all user trips
- `GET /api/trips/{id}` - Get specific trip
- `PUT /api/trips/{id}` - Update trip
- `DELETE /api/trips/{id}` - Delete trip

### Document APIs
- `POST /api/trips/{id}/documents` - Upload document to trip
- `GET /api/trips/{id}/documents` - Get trip documents

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0                    # HTTP client for API calls
  provider: ^6.1.1                 # State management
  shared_preferences: ^2.2.2       # Local storage
  go_router: ^12.1.3               # Navigation
  form_validator: ^2.1.1           # Form validation
  image_picker: ^1.0.4             # Image/document picker
  path_provider: ^2.1.2            # File handling
  flutter_spinkit: ^5.2.0          # Loading indicators
  intl: ^0.19.0                    # Date formatting
  fluttertoast: ^8.2.4             # Toast messages
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Laravel backend running on `http://127.0.0.1:8000`

### Installation

1. **Clone the repository**
   ```bash
   git clone <https://github.com/hussainahmad402/Travel-Buddy-App.git>
   cd travelbuddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Update `lib/config/api_config.dart` if your Laravel backend runs on a different URL

4. **Run the app**
   ```bash
   flutter run
   ```

## State Management

The app uses the **Provider** package for state management, following the MVC pattern:

- **Controllers** extend `ChangeNotifier` and manage app state
- **Views** use `Consumer` widgets to listen to state changes
- **Models** represent data structures
- **Services** handle external communication

## UI/UX Features

- **Material Design 3**: Modern, consistent UI following Material Design guidelines
- **Responsive Design**: Adapts to different screen sizes
- **Loading States**: Visual feedback during API calls
- **Error Handling**: User-friendly error messages
- **Empty States**: Helpful guidance when no data is available
- **Pull-to-Refresh**: Easy data refresh functionality
- **Form Validation**: Real-time input validation
- **Toast Notifications**: Non-intrusive user feedback

## Security Features

- **JWT Token Authentication**: Secure API communication
- **Token Storage**: Encrypted local storage of authentication tokens
- **Input Validation**: Client-side validation for all user inputs
- **Error Handling**: Secure error messages without exposing sensitive information

## Future Enhancements

- Push notifications for trip reminders
- Offline mode with data synchronization
- Trip sharing functionality
- Advanced document management (PDF viewer, annotations)
- Travel expense tracking
- Weather integration
- Maps integration for destinations
- Social features (trip sharing, reviews)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## Support

For support and questions, please contact the development team or create an issue in the repository.#
