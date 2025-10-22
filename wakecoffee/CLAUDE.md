# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Wake Coffee is an iOS alarm app designed for both regular office workers and shift workers. It provides intuitive alarm management with two distinct modes: Regular Work (9-to-6 schedules) and Shift Work (2/3/4-shift patterns).

## Build & Run

```bash
# Build the project
xcodebuild -scheme wakecoffee -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -scheme wakecoffee -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean build
xcodebuild -scheme wakecoffee clean
```

Or simply open `wakecoffee.xcodeproj` in Xcode and run with Cmd+R.

## Architecture

This project follows **MVVM (Model-View-ViewModel)** architecture:

### Data Flow
1. **Views** observe **ViewModels** using `@StateObject` and `@Published` properties
2. **ViewModels** manage business logic and coordinate between **Services** and **Models**
3. **Services** (NotificationManager, DataManager) handle system interactions and persistence
4. **Models** define data structures (Alarm, WorkSchedule, AlarmStatistics)

### Key Architectural Patterns

**Two Work Modes**:
- `RegularWorkViewModel` manages 9-to-6 style schedules with before/during/after work periods
- `ShiftWorkViewModel` manages 2/3/4-shift patterns with automatic schedule calculation

**Notification Scheduling**:
- Regular alarms: Scheduled per weekday using `UNCalendarNotificationTrigger` with repeating triggers
- Shift alarms: Generated for next 30 days as non-repeating triggers based on calculated work days

**Data Persistence**:
- `DataManager.shared` uses UserDefaults with JSON encoding
- Separate storage for regular alarms, shift alarms, schedules, and statistics
- Auto-save on every ViewModel state change

### Critical Implementation Details

**Shift Pattern Calculation** (`ShiftWorkSchedule.getShiftTime(for:)`):
- Uses `daysSinceStart % cycleDays` to determine shift type for any date
- 2-shift: 2 days day shift → 2 days off
- 3-shift: 2 days day → 2 days night → 2 days off
- 4-shift: 2 days day → 2 days night → 2 days evening → 2 days off

**Alarm Purpose System**:
- `AlarmPurpose` enum defines 6 alarm types (water, stretch, medicine, coffee, eyeRest, walk)
- Each purpose has associated emoji icon used throughout UI
- Purpose determines alarm notification content and statistics grouping

**Work Period Color Coding**:
- Before work: Blue (`.blue.opacity(0.6)`)
- During work: Green (`.green.opacity(0.6)`)
- After work: Orange (`.orange.opacity(0.6)`)
- Consistently applied in timeline, dividers, and cards

## Project Structure

```
wakecoffee/
├── Models/              # Data structures (Codable, Equatable)
├── ViewModels/          # Business logic (@MainActor, ObservableObject)
├── Views/               # SwiftUI views organized by feature
│   ├── RegularWork/     # Timeline-based alarm management
│   ├── ShiftWork/       # Pattern-based alarm management
│   ├── Settings/        # App configuration
│   └── Statistics/      # Charts and completion tracking
├── Components/          # Reusable UI components
└── Services/            # System interaction (singleton pattern)
```

## Adding New Features

**New Alarm Purpose**:
1. Add case to `AlarmPurpose` enum in `Models/Alarm.swift`
2. Provide icon emoji in `icon` computed property
3. Purpose automatically appears in all alarm creation sheets

**New Shift Pattern**:
1. Add case to `ShiftType` enum in `Models/WorkSchedule.swift`
2. Define `cycleDays` for the pattern
3. Implement pattern logic in `ShiftWorkSchedule.getShiftTime(for:)`

**New Statistics**:
1. Add calculation method to `StatisticsViewModel`
2. Create view component in `Views/Statistics/`
3. Add to `StatisticsView` main scroll view

## Testing

Currently tests are scaffolded but not implemented. When adding tests:
- Use `wakecoffeeTests` target for unit tests
- Use `wakecoffeeUITests` target for UI tests
- Mock `NotificationManager` and `DataManager` for ViewModel tests

## Common Issues

**Notification Permissions**: App requests authorization on first launch via `AppDelegate`. If notifications don't work, check iOS Settings → wakecoffee → Notifications.

**Date Handling**: All alarm times use `Date` with only hour/minute components extracted. Be careful with time zone conversions.

**ViewModel Updates**: Changes to ViewModel published properties automatically trigger view updates and data persistence. Don't call save methods manually unless bypassing ViewModel.

## Design Philosophy

- **Simplicity**: UI must be intuitive with minimal settings
- **Visual Hierarchy**: Use color, spacing, and icons to guide users
- **Consistency**: Reuse components (AlarmCard, HeaderBar) across features
- **Accessibility**: All interactive elements have clear tap targets and labels
