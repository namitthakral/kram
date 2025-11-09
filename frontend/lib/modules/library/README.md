# Library Management Module

A comprehensive library management module for the EdVerse educational platform. This module provides a complete interface for librarians to manage books, track issues, monitor overdue books, and view analytics.

## Features

### 📊 Dashboard with 4 Main Tabs

1. **Issued Books** - Track all currently issued books with student information
2. **Book Inventory** - Complete catalog of all books with availability status
3. **Analytics** - Visual charts showing monthly activity and category distribution
4. **Overdue Books** - Monitor overdue books with fine calculations

### 📈 Statistics Cards

- Total Books (with monthly additions)
- Available Books (with percentage)
- Books Issued (with member count)
- Overdue Books (requiring action)

### 🎨 UI Features

- **Responsive Design** - Works on mobile, tablet, and desktop
- **Tab Navigation** - Easy switching between different views
- **Search Functionality** - Search books and students
- **Real-time Updates** - Pull to refresh support
- **Beautiful Charts** - Bar charts for monthly activity and donut charts for categories
- **Action Buttons** - Add new books and generate reports

## Module Structure

```
lib/modules/library/
├── models/
│   └── library_models.dart          # Data models for books, issues, stats
├── providers/
│   ├── library_dashboard_provider.dart  # State management for dashboard
│   └── library_tab_provider.dart        # Tab navigation state
├── services/
│   └── library_service.dart         # API service with mock data
├── screens/
│   └── library_dashboard_screen.dart    # Main dashboard screen
├── widgets/
│   ├── book_inventory_card.dart     # Book card with availability
│   ├── issued_book_card.dart        # Issued book card with student info
│   ├── overdue_book_card.dart       # Overdue book card with fines
│   └── library_chart_widgets.dart   # Analytics charts
└── README.md                         # This file
```

## Usage

### For Librarians (Role ID: 3)

The library dashboard is automatically available in the navigation when a user with the Librarian role logs in.

### Navigation

The module is registered in `role_navigation_config.dart` and appears as the home screen for librarians with additional tabs for book management.

### State Management

The module uses Provider for state management:
- `LibraryDashboardProvider` - Manages all data loading and state
- `LibraryTabProvider` - Handles tab navigation state

Both providers are registered globally in `main.dart`.

## Design Pattern

This module follows the same architectural patterns as other modules in the EdVerse app:

1. **Models** - Define data structures
2. **Providers** - Manage state and business logic
3. **Services** - Handle data fetching (currently mock data)
4. **Widgets** - Reusable UI components
5. **Screens** - Main pages that compose widgets

## Mock Data

Currently, the module uses mock data from `LibraryService`. To connect to a real backend:

1. Update `LibraryService` methods to make actual API calls
2. Update the endpoint URLs in the service
3. Ensure the backend API matches the model structures

## Color Scheme

The library module uses a consistent color scheme:
- **Purple** (#8B5CF6) - Total Books
- **Green** (#10B981) - Available Books / Returned
- **Blue** (#3B82F6) - Books Issued
- **Red** (#EF4444) - Overdue Books / Alerts
- **Orange** (#F59E0B) - History
- **Cyan** (#06B6D4) - Others

## Key Components

### Library Dashboard Screen

The main screen with:
- App bar with librarian information
- Statistics cards grid
- Tab navigation
- Dynamic content based on selected tab
- Bottom action buttons (Add Book, Generate Report)

### Book Cards

Three types of cards for different purposes:
- **BookInventoryCard** - Shows book details with availability progress
- **IssuedBookCard** - Shows issued book with student and due date
- **OverdueBookCard** - Shows overdue information with fine calculation

### Charts

- **MonthlyActivityChart** - Bar chart showing issued, returned, and overdue trends
- **CategoryDistributionChart** - Donut chart showing book distribution by category

## Dialog Actions

### Add Book Dialog
- Form to add new books to the inventory
- Fields: Title, Author, Category, etc.

### Generate Report Dialog
- Select report type (Complete Inventory, Issued Books, Overdue Books)
- Export options (PDF, Excel, CSV)

## Future Enhancements

Potential features to add:
- [ ] Real-time search filtering
- [ ] Book reservation system
- [ ] QR code scanning for quick issue/return
- [ ] Email/SMS notifications for overdue books
- [ ] Fine payment integration
- [ ] Book recommendation system
- [ ] Digital library resources
- [ ] Reading history analytics
- [ ] Student reading patterns

## API Integration

When ready to connect to the backend, update these service methods:

```dart
// In library_service.dart
Future<LibraryStats> getLibraryStats() async {
  // Replace mock data with actual API call
  final response = await ApiService().get('/library/stats');
  return LibraryStats.fromJson(response.data);
}
```

## Testing

To test the library module:
1. Log in with a Librarian role (Role ID: 3)
2. The library dashboard should appear as the home screen
3. Navigate through different tabs
4. Pull to refresh to reload data
5. Try search functionality
6. Click action buttons to see dialogs

## Dependencies

- **flutter** - UI framework
- **provider** - State management
- **Material Design** - UI components

No additional packages required - uses existing app dependencies.

## Support

For issues or questions about the library module, please refer to the main EdVerse documentation or contact the development team.


