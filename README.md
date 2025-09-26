# Ed-verse 🎓

A modern educational platform built with a monorepo architecture featuring:
- **Backend**: Node.js with TypeScript and Express
- **Frontend**: Flutter for cross-platform mobile and web applications

## 🏗️ Project Structure

```
ed-verse/
├── backend/                 # Node.js TypeScript API
│   ├── src/
│   │   ├── controllers/     # Route controllers
│   │   ├── middleware/      # Express middleware
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── types/          # TypeScript type definitions
│   │   ├── utils/          # Utility functions
│   │   └── index.ts        # Application entry point
│   ├── tests/              # Backend tests
│   ├── package.json        # Backend dependencies
│   ├── tsconfig.json       # TypeScript configuration
│   └── .env.example        # Environment variables template
├── frontend/               # Flutter application
│   ├── lib/
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable widgets
│   │   ├── services/       # API services
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── utils/          # Utility functions
│   │   └── main.dart       # Flutter app entry point
│   ├── assets/             # Images, fonts, icons
│   ├── test/               # Frontend tests
│   ├── pubspec.yaml        # Flutter dependencies
│   └── analysis_options.yaml # Dart linting rules
├── docs/                   # Documentation
├── scripts/                # Build and deployment scripts
└── package.json           # Root package.json for monorepo scripts
```

## 🚀 Quick Start

### Prerequisites

Make sure you have the following installed:
- **Node.js** (v18+) and **npm** (v9+)
- **Flutter** (v3.10+) - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Git**

### 1. Clone the Repository

```bash
git clone https://github.com/namitthakral/ed-verse.git
cd ed-verse
```

### 2. Install Dependencies

```bash
# Install root dependencies and backend dependencies
npm run setup
```

### 3. Environment Setup

```bash
# Copy environment template for backend
cp backend/.env.example backend/.env
# Edit the .env file with your configuration
```

### 4. Development

```bash
# Start both backend and frontend in development mode
npm run dev

# Or start them separately:
npm run dev:backend    # Starts backend on http://localhost:3000
npm run dev:frontend   # Starts Flutter app
```

## 🛠️ Available Scripts

### Root Level Scripts

```bash
npm run dev             # Start both backend and frontend
npm run build           # Build both projects
npm run test            # Run all tests
npm run lint            # Lint backend code
npm run clean           # Clean all build artifacts
npm run setup           # Install all dependencies
```

### Backend Scripts

```bash
cd backend
npm run dev             # Start development server with hot reload
npm run build           # Build TypeScript to JavaScript
npm run start           # Start production server
npm run test            # Run Jest tests
npm run lint            # Run ESLint
npm run lint:fix        # Fix ESLint errors automatically
```

### Frontend Scripts

```bash
cd frontend
flutter run             # Run on connected device/emulator
flutter run -d web      # Run on web
flutter build web       # Build for web
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app
flutter test            # Run tests
flutter analyze         # Analyze code
```

## 🔧 Development Workflow

### Backend Development

1. **API Development**: Add routes in `backend/src/routes/`
2. **Business Logic**: Implement services in `backend/src/services/`
3. **Controllers**: Handle requests in `backend/src/controllers/`
4. **Middleware**: Add custom middleware in `backend/src/middleware/`
5. **Types**: Define TypeScript interfaces in `backend/src/types/`

### Frontend Development

1. **Screens**: Create new screens in `frontend/lib/screens/`
2. **Widgets**: Build reusable components in `frontend/lib/widgets/`
3. **State Management**: Use Riverpod providers in `frontend/lib/providers/`
4. **API Integration**: Implement services in `frontend/lib/services/`
5. **Models**: Define data models in `frontend/lib/models/`

## 📱 Platform Support

The Flutter frontend supports:
- **Web** (Progressive Web App)
- **Android** (Native mobile app)
- **iOS** (Native mobile app)

## 🧪 Testing

### Backend Testing
- **Framework**: Jest with ts-jest
- **Location**: `backend/tests/`
- **Run**: `cd backend && npm test`

### Frontend Testing
- **Framework**: Flutter Test
- **Location**: `frontend/test/`
- **Run**: `cd frontend && flutter test`

## 📦 Deployment

### Backend Deployment
The backend can be deployed to any Node.js hosting service:
- Build: `cd backend && npm run build`
- Start: `npm start`

### Frontend Deployment
- **Web**: `cd frontend && flutter build web`
- **Android**: `cd frontend && flutter build apk`
- **iOS**: `cd frontend && flutter build ios`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

1. **Flutter not found**: Make sure Flutter is installed and added to PATH
2. **Node.js version**: Ensure you're using Node.js v18 or higher
3. **Port conflicts**: Backend runs on port 3000 by default (configurable via .env)

### Getting Help

- Check the [Issues](https://github.com/namitthakral/ed-verse/issues) page
- Create a new issue if you find a bug
- Refer to [Flutter documentation](https://flutter.dev/docs)
- Refer to [Node.js documentation](https://nodejs.org/docs)

---

Built with ❤️ by [Namit Thakral](https://github.com/namitthakral)
