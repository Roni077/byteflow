/// Riverpod state management for per-application network usage tracking.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/utils/time_utils.dart';
import 'package:byteflow/models/app_network_usage.dart';
import 'package:byteflow/services/native_bridge.dart';

/// State snapshot representing the per-app data consumption screen state.
@immutable
class AppUsageState {
  /// Creates an [AppUsageState] snapshot.
  const AppUsageState({
    this.isLoading = false,
    this.hasPermission = true,
    this.apps = const <AppNetworkUsage>[],
    this.selectedTimeRange = AppUsageTimeRange.today,
    this.sortOption = AppUsageSortOption.totalUsage,
    this.filterOption = AppUsageFilterOption.all,
    this.searchQuery = '',
    this.errorMessage,
  });

  /// Whether a data retrieval query is in progress.
  final bool isLoading;

  /// Whether the user has granted the Android PACKAGE_USAGE_STATS permission.
  final bool hasPermission;

  /// Raw list of apps returned from the native layer for the current time range.
  final List<AppNetworkUsage> apps;

  /// The currently active time range filter.
  final AppUsageTimeRange selectedTimeRange;

  /// The sorting criteria applied to the list.
  final AppUsageSortOption sortOption;

  /// The category filter (All, User, System).
  final AppUsageFilterOption filterOption;

  /// Active text query used to filter applications by name or package.
  final String searchQuery;

  /// Error message if an operation failed.
  final String? errorMessage;

  /// Returns applications filtered by query and category, then sorted.
  List<AppNetworkUsage> get filteredApps {
    final query = searchQuery.trim().toLowerCase();

    final filtered = apps.where((app) {
      // 1. Filter by category
      switch (filterOption) {
        case AppUsageFilterOption.userOnly:
          if (app.isSystemApp) return false;
        case AppUsageFilterOption.systemOnly:
          if (!app.isSystemApp) return false;
        case AppUsageFilterOption.all:
          break;
      }

      // 2. Filter by search query
      if (query.isNotEmpty) {
        final matchesName = app.appName.toLowerCase().contains(query);
        final matchesPackage = app.packageName.toLowerCase().contains(query);
        if (!matchesName && !matchesPackage) return false;
      }

      return true;
    }).toList();

    // 3. Sort
    switch (sortOption) {
      case AppUsageSortOption.totalUsage:
        filtered.sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
      case AppUsageSortOption.download:
        filtered.sort((a, b) => b.rxBytes.compareTo(a.rxBytes));
      case AppUsageSortOption.upload:
        filtered.sort((a, b) => b.txBytes.compareTo(a.txBytes));
      case AppUsageSortOption.appName:
        filtered.sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
    }

    return filtered;
  }

  /// Total aggregated data consumption across all currently filtered apps.
  int get totalFilteredBytes =>
      filteredApps.fold(0, (sum, item) => sum + item.totalBytes);

  /// Highest single app usage in the filtered list (used for progress ratio calculation).
  int get maxAppBytes =>
      filteredApps.isEmpty ? 0 : filteredApps.map((a) => a.totalBytes).reduce((a, b) => a > b ? a : b);

  /// Creates a copy of this state with updated parameters.
  AppUsageState copyWith({
    bool? isLoading,
    bool? hasPermission,
    List<AppNetworkUsage>? apps,
    AppUsageTimeRange? selectedTimeRange,
    AppUsageSortOption? sortOption,
    AppUsageFilterOption? filterOption,
    String? searchQuery,
    String? errorMessage,
  }) {
    return AppUsageState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      apps: apps ?? this.apps,
      selectedTimeRange: selectedTimeRange ?? this.selectedTimeRange,
      sortOption: sortOption ?? this.sortOption,
      filterOption: filterOption ?? this.filterOption,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

/// State notifier managing per-app usage queries, permission checks, and filters.
class AppUsageNotifier extends StateNotifier<AppUsageState> {
  /// Initializes the [AppUsageNotifier] and loads initial usage.
  AppUsageNotifier({required this.nativeBridge}) : super(const AppUsageState()) {
    loadUsage();
  }

  /// Interop bridge connecting to native platform channels.
  final NativeBridge nativeBridge;

  /// Checks permission and retrieves usage data for the specified or current time range.
  Future<void> loadUsage({AppUsageTimeRange? range}) async {
    final activeRange = range ?? state.selectedTimeRange;
    state = state.copyWith(isLoading: true, errorMessage: null, selectedTimeRange: activeRange);

    final permitted = await nativeBridge.hasUsagePermission();
    if (!permitted) {
      state = state.copyWith(
        isLoading: false,
        hasPermission: false,
        apps: const <AppNetworkUsage>[],
      );
      return;
    }

    final (start, end) = switch (activeRange) {
      AppUsageTimeRange.today => TimeUtils.todayRange(),
      AppUsageTimeRange.yesterday => TimeUtils.yesterdayRange(),
      AppUsageTimeRange.last7Days => TimeUtils.last7DaysRange(),
      AppUsageTimeRange.last30Days => TimeUtils.last30DaysRange(),
      AppUsageTimeRange.currentMonth => TimeUtils.currentMonthRange(),
    };

    try {
      final apps = await nativeBridge.getAppUsage(start, end);
      state = state.copyWith(
        isLoading: false,
        hasPermission: true,
        apps: apps,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refreshes the usage data using the current time range.
  Future<void> refresh() => loadUsage();

  /// Checks the current permission state without reloading usage if already granted.
  Future<void> checkPermission() async {
    final permitted = await nativeBridge.hasUsagePermission();
    if (permitted != state.hasPermission) {
      if (permitted) {
        await loadUsage();
      } else {
        state = state.copyWith(hasPermission: false);
      }
    }
  }

  /// Opens the system Usage Access Settings.
  Future<void> openUsageSettings() async {
    await nativeBridge.openUsageSettings();
  }

  /// Changes the active time range and reloads app usage statistics.
  void setTimeRange(AppUsageTimeRange range) {
    if (state.selectedTimeRange == range) return;
    loadUsage(range: range);
  }

  /// Changes the sort option.
  void setSortOption(AppUsageSortOption sort) {
    if (state.sortOption == sort) return;
    state = state.copyWith(sortOption: sort);
  }

  /// Changes the app category filter (All, User, System).
  void setFilterOption(AppUsageFilterOption filter) {
    if (state.filterOption == filter) return;
    state = state.copyWith(filterOption: filter);
  }

  /// Updates the real-time search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

/// Provider exposing the [AppUsageNotifier] and its state.
final appUsageProvider =
    StateNotifierProvider<AppUsageNotifier, AppUsageState>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  return AppUsageNotifier(nativeBridge: bridge);
});
