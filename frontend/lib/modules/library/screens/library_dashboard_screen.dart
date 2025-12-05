import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../modules/teacher/widgets/stat_card.dart';
import '../../../provider/login_signup/login_provider.dart';
import '../../../utils/custom_colors.dart';
import '../../../utils/extensions.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/user_utils.dart';
import '../../../widgets/custom_widgets/custom_form_dialog.dart';
import '../../../widgets/custom_widgets/custom_main_screen_with_appbar.dart';
import '../../../widgets/custom_widgets/custom_sliding_segmented_control.dart';
import '../../../widgets/custom_widgets/custom_text_field.dart';
import '../models/library_models.dart';
import '../providers/library_dashboard_provider.dart';
import '../providers/library_filter_provider.dart';
import '../providers/library_tab_provider.dart';
import '../widgets/book_inventory_card.dart';
import '../widgets/issued_book_card.dart';
import '../widgets/library_chart_widgets.dart';
import '../widgets/overdue_book_card.dart';

class LibraryDashboardScreen extends StatefulWidget {
  const LibraryDashboardScreen({super.key});

  @override
  State<LibraryDashboardScreen> createState() => _LibraryDashboardScreenState();
}

class _LibraryDashboardScreenState extends State<LibraryDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryDashboardProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginProvider>().currentUser;
    final libraryProvider = context.watch<LibraryDashboardProvider>();
    final isMobile = context.isMobile;

    // Extract user information
    final userInitials = user != null ? UserUtils.getInitials(user.name) : 'LI';
    final userName = user?.name ?? 'Librarian';
    // This would come from institution data

    return Stack(
      children: [
        CustomMainScreenWithAppbar(
          title: context.translate('library_management'),
          appBarConfig: AppBarConfig.librarian(
            userInitials: userInitials,
            userName: userName,
            libraryName: context.translate('central_library'),
            onNotificationIconPressed: () {
              // Notification handler
            },
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await libraryProvider.refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons for desktop only (at top right)
                  if (!isMobile) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_buildActionButtons(context)],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Statistics Cards
                  _buildStatsSection(isMobile, libraryProvider),
                  const SizedBox(height: 24),

                  // Tab Content with Sliding Segmented Control
                  _buildLibraryManagementSection(libraryProvider),
                ],
              ),
            ),
          ),
        ),
        // Floating action button for mobile
        if (isMobile)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _showMobileActionsSheet(context),
              backgroundColor: CustomAppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _showMobileActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CustomAppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: CustomAppColors.primary,
                    ),
                  ),
                  title: Text(context.translate('add_new_book')),
                  subtitle: Text(context.translate('add_book_to_inventory')),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddBookDialog(context);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.download_outlined,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  title: Text(context.translate('generate_report')),
                  subtitle: Text(context.translate('export_library_data')),
                  onTap: () {
                    Navigator.pop(context);
                    _showGenerateReportDialog(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatsSection(bool isMobile, LibraryDashboardProvider provider) {
    if (provider.isLoadingStats) {
      return _buildStatsLoading(isMobile);
    }

    if (provider.statsError != null) {
      return _buildErrorCard(provider.statsError!);
    }

    final stats = provider.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    if (isMobile) {
      // Mobile: 2x2 grid with Wrap for better control
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            child: StatCard(
              title: context.translate('total_books'),
              value: stats.totalBooks.toString(),
              subtitle:
                  '${stats.addedThisMonth} ${context.translate("added_this_month")}',
              backgroundColor: const Color(0xFF8B5CF6),
              iconColor: const Color(0xFF8B5CF6),
              icon: Icons.menu_book_rounded,
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            child: StatCard(
              title: context.translate('available_books'),
              value: stats.availableBooks.toString(),
              subtitle:
                  '${stats.availablePercentage.toStringAsFixed(1)}% ${context.translate("available")}',
              backgroundColor: const Color(0xFF10B981),
              iconColor: const Color(0xFF10B981),
              icon: Icons.check_circle_outline,
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            child: StatCard(
              title: context.translate('books_issued'),
              value: stats.booksIssued.toString(),
              subtitle: context.translate(
                'to_members',
                params: {'count': stats.membersCount.toString()},
              ),
              backgroundColor: const Color(0xFF3B82F6),
              iconColor: const Color(0xFF3B82F6),
              icon: Icons.library_books_outlined,
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            child: StatCard(
              title: context.translate('overdue_books'),
              value: stats.overdueBooks.toString(),
              subtitle: context.translate('require_immediate_action'),
              backgroundColor: const Color(0xFFEF4444),
              iconColor: const Color(0xFFEF4444),
              icon: Icons.warning_amber_rounded,
            ),
          ),
        ],
      );
    }

    // Desktop: 4x1 grid
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: context.translate('total_books'),
            value: stats.totalBooks.toString(),
            subtitle:
                '${stats.addedThisMonth} ${context.translate("added_this_month")}',
            backgroundColor: const Color(0xFF8B5CF6),
            iconColor: const Color(0xFF8B5CF6),
            icon: Icons.menu_book_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: context.translate('available_books'),
            value: stats.availableBooks.toString(),
            subtitle:
                '${stats.availablePercentage.toStringAsFixed(1)}% ${context.translate("available")}',
            backgroundColor: const Color(0xFF10B981),
            iconColor: const Color(0xFF10B981),
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: context.translate('books_issued'),
            value: stats.booksIssued.toString(),
            subtitle: context.translate(
              'to_members',
              params: {'count': stats.membersCount.toString()},
            ),
            backgroundColor: const Color(0xFF3B82F6),
            iconColor: const Color(0xFF3B82F6),
            icon: Icons.library_books_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: context.translate('overdue_books'),
            value: stats.overdueBooks.toString(),
            subtitle: context.translate('require_immediate_action'),
            backgroundColor: const Color(0xFFEF4444),
            iconColor: const Color(0xFFEF4444),
            icon: Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoading(bool isMobile) {
    final loadingCard = Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );

    if (isMobile) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          4,
          (index) => SizedBox(
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            child: loadingCard,
          ),
        ),
      );
    }

    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index > 0 ? 16 : 0),
            child: loadingCard,
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryManagementSection(LibraryDashboardProvider provider) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sliding Segmented Control
          Consumer<LibraryTabProvider>(
            builder:
                (context, tabProvider, child) =>
                    CustomSlidingSegmentedControl<LibraryTab>(
                      segments: {
                        LibraryTab.issuedBooks: context.translate(
                          'issued_books',
                        ),
                        LibraryTab.bookInventory: context.translate(
                          'book_inventory',
                        ),
                        LibraryTab.analytics: context.translate('analytics'),
                        LibraryTab.overdue: context.translate('overdue'),
                      },
                      initialValue: tabProvider.selectedTab,
                      onValueChanged: (value) {
                        tabProvider.setTab(value);
                      },
                    ),
          ),

          const SizedBox(height: 24),

          // Tab Content
          Consumer<LibraryTabProvider>(
            builder:
                (context, tabProvider, child) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey<LibraryTab>(tabProvider.selectedTab),
                    child: switch (tabProvider.selectedTab) {
                      LibraryTab.issuedBooks => _buildIssuedBooksTab(provider),
                      LibraryTab.bookInventory => _buildInventoryTab(provider),
                      LibraryTab.analytics => _buildAnalyticsTab(provider),
                      LibraryTab.overdue => _buildOverdueTab(provider),
                    },
                  ),
                ),
          ),
        ],
      );

  Widget _buildActionButtons(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton.icon(
        onPressed: () => _showAddBookDialog(context),
        icon: const Icon(Icons.add, size: 18),
        label: Text(context.translate('add_book')),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomAppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      const SizedBox(width: 12),
      OutlinedButton.icon(
        onPressed: () => _showGenerateReportDialog(context),
        icon: const Icon(Icons.download_outlined, size: 18),
        label: Text(context.translate('library_report')),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF64748B),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    ],
  );

  Widget _buildIssuedBooksTab(LibraryDashboardProvider provider) {
    if (provider.isLoadingIssuedBooks) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.issuedBooksError != null) {
      return _buildErrorCard(provider.issuedBooksError!);
    }

    final issuedBooks = provider.issuedBooks ?? [];

    if (issuedBooks.isEmpty) {
      return _buildEmptyState('No books currently issued');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        ...issuedBooks.map((issue) => IssuedBookCard(bookIssue: issue)),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    final isMobile = context.isMobile;
    final filterProvider = context.watch<LibraryFilterProvider>();

    return Row(
      children: [
        Expanded(
          flex: isMobile ? 1 : 2,
          child: CustomTextField(
            hintText: 'Search by book title or student name...',
            prefixButtonIcon: ButtonIcon(
              icon: 'assets/images/icons/search.svg',
              color: const Color(0xFF64748B),
            ),
            onChanged: filterProvider.setSearchQuery,
          ),
        ),
        const SizedBox(width: 12),
        if (!isMobile) ...[
          _buildFilterDropdown(
            value: filterProvider.selectedCategory,
            items: const [
              'All Categories',
              'Science',
              'Mathematics',
              'Literature',
              'History',
              'Arts',
              'Others',
            ],
            onChanged: (value) {
              if (value != null) {
                filterProvider.setCategory(value);
              }
            },
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            value: filterProvider.selectedStatus,
            items: const ['All Status', 'Active', 'Overdue', 'Returned'],
            onChanged: (value) {
              if (value != null) {
                filterProvider.setStatus(value);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE2E8F0)),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
    ),
    child: DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
      items:
          items
              .map(
                (String itemValue) => DropdownMenuItem<String>(
                  value: itemValue,
                  child: Text(itemValue),
                ),
              )
              .toList(),
      onChanged: onChanged,
    ),
  );

  Widget _buildInventoryTab(LibraryDashboardProvider provider) {
    if (provider.isLoadingInventory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.inventoryError != null) {
      return _buildErrorCard(provider.inventoryError!);
    }

    final inventory = provider.inventory ?? [];

    if (inventory.isEmpty) {
      return _buildEmptyState('No books in inventory');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        ...inventory.map((book) => BookInventoryCard(book: book)),
      ],
    );
  }

  Widget _buildAnalyticsTab(LibraryDashboardProvider provider) {
    if (provider.isLoadingAnalytics) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.analyticsError != null) {
      return _buildErrorCard(provider.analyticsError!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Library Activity',
          style: TextStyle(
            fontSize: context.isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        MonthlyActivityChart(activityData: provider.monthlyActivity),
        const SizedBox(height: 24),
        Text(
          'Popular Book Categories',
          style: TextStyle(
            fontSize: context.isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        CategoryDistributionChart(categoryData: provider.categoryDistribution),
      ],
    );
  }

  Widget _buildOverdueTab(LibraryDashboardProvider provider) {
    if (provider.isLoadingOverdueBooks) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.overdueError != null) {
      return _buildErrorCard(provider.overdueError!);
    }

    final overdueBooks = provider.overdueBooks ?? [];

    if (overdueBooks.isEmpty) {
      return _buildEmptyState('No overdue books');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...overdueBooks.map((overdue) => OverdueBookCard(overdueBook: overdue)),
      ],
    );
  }

  Widget _buildErrorCard(String error) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(error, style: const TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    ),
  );

  Widget _buildEmptyState(String message) => Container(
    padding: const EdgeInsets.all(48),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    ),
  );

  void _showAddBookDialog(BuildContext context) {
    var selectedCategory = 'Select category';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CustomFormDialog(
          title: 'Add New Book',
          subtitle: 'Enter book details to add it to the library inventory',
          headerIcon: Icons.menu_book,
          confirmText: 'Add Book',
          confirmColor: CustomAppColors.primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomTextField(
                label: 'Book Title',
                hintText: 'Enter book title',
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Author',
                      hintText: 'Author name',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'ISBN',
                      hintText: '978-0-123456-78-9',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormDropdownField<String>(
                      label: 'Category',
                      hint: 'Select category',
                      value: selectedCategory == 'Select category'
                          ? null
                          : selectedCategory,
                      items: const [
                        'Science',
                        'Mathematics',
                        'Literature',
                        'History',
                        'Arts',
                        'Others',
                      ]
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value ?? 'Select category';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: CustomTextField(
                      label: 'Publish Year',
                      hintText: '2024',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Total Copies',
                      hintText: 'Number of copies',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Shelf Number',
                      hintText: 'e.g., A-15',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                label: 'Description (Optional)',
                hintText: 'Brief description of the book',
                maxLines: 2,
              ),
            ],
          ),
          onConfirm: () {
            // Handle add book
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    var selectedReportType = 'Complete Inventory';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CustomFormDialog(
          title: 'Generate Library Report',
          subtitle: 'Choose report type and format',
          headerIcon: Icons.download_outlined,
          showActions: false,
          maxWidth: 500,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormDropdownField<String>(
                label: 'Report Type',
                value: selectedReportType,
                items: const [
                  'Complete Inventory',
                  'Issued Books',
                  'Overdue Books',
                  'Available Books',
                  'Analytics Report',
                ]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedReportType = value ?? 'Complete Inventory';
                  });
                },
              ),
              const SizedBox(height: 24),
              const FormFieldLabel(label: 'Export Format'),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildExportFormatButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF Report',
                    color: const Color(0xFFEF4444),
                  ),
                  _buildExportFormatButton(
                    icon: Icons.table_chart,
                    label: 'Excel Sheet',
                    color: const Color(0xFF10B981),
                  ),
                  _buildExportFormatButton(
                    icon: Icons.insert_drive_file,
                    label: 'CSV File',
                    color: const Color(0xFF3B82F6),
                  ),
                  _buildExportFormatButton(
                    icon: Icons.print,
                    label: 'Print View',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportFormatButton({
    required IconData icon,
    required String label,
    required Color color,
  }) => OutlinedButton(
    onPressed: () {
      // Handle export
      Navigator.pop(context);
    },
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
