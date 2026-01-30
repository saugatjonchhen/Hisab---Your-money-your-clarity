# Interactive Pie Chart Feature: A Deep Dive into Expense Visualization

## Overview

The pie chart feature is a sophisticated data visualization component built into the Transactions page of our finance app. It provides users with an intuitive, interactive way to understand their spending patterns by breaking down expenses by category. This feature combines the power of the **fl_chart** library with custom painting techniques to create a polished, professional visualization experience.

## Key Features

### 1. **Interactive Touch Response**
- Users can tap on pie chart segments to highlight them
- Touched segments expand slightly (from 80px to 90px radius) for visual feedback
- Real-time interaction using Flutter's touch event system

### 2. **Custom Label System**
- Smart label positioning with automatic overlap resolution
- Leader lines connecting segments to labels
- Color-coded labels matching their respective segments
- Percentage display for each category

### 3. **Comprehensive Analysis Tab**
- Summary grid showing Income, Expense, Savings, and Investment totals
- Detailed expense breakdown by category
- Legend with category names, percentages, and amounts
- Link to detailed analytics page for deeper insights

## Technical Architecture

### Core Technologies

#### 1. **fl_chart Library (v0.68.0)**
The foundation of our pie chart implementation. This Flutter charting library provides:
- `PieChart` widget for rendering the chart
- `PieChartData` for configuration
- `PieChartSectionData` for individual segments
- `PieTouchData` for interaction handling

#### 2. **Custom Painter Pattern**
We implemented a custom `PieChartLabelPainter` that extends Flutter's `CustomPainter` to:
- Draw leader lines from segments to labels
- Position labels intelligently to avoid overlaps
- Render text with proper styling and alignment

#### 3. **State Management with Riverpod**
- `ConsumerStatefulWidget` for reactive state management
- Watches transaction and category data streams
- Automatically updates when data changes

### Implementation Details

#### Data Processing Pipeline

```dart
// 1. Filter transactions by date range (if selected)
final filtered = transactions.where((t) {
  if (_dateRange == null) return true;
  return (t.date.isAfter(_dateRange!.start.subtract(const Duration(seconds: 1))) &&
      t.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
}).toList();

// 2. Aggregate expenses by category
final Map<String, double> categorySpending = {};
for (var t in widget.transactions) {
  if (t.type == 'expense') {
    expense += t.amount;
    categorySpending[t.categoryId] = (categorySpending[t.categoryId] ?? 0) + t.amount;
  }
}

// 3. Sort categories by spending amount (descending)
final sortedCategories = categorySpending.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));
```

#### Pie Chart Configuration

**Key Parameters:**
- `startDegreeOffset: -90` - Starts the chart from the top (12 o'clock position)
- `sectionsSpace: 0` - No gaps between segments
- `centerSpaceRadius: 0` - Full pie chart (not a donut)
- `borderSide: BorderSide(color: Colors.black12, width: 1)` - Subtle separators between segments

**Touch Interaction:**
```dart
pieTouchData: PieTouchData(
  touchCallback: (FlTouchEvent event, pieTouchResponse) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        touchedIndex = -1;
        return;
      }
      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
    });
  },
)
```

#### Custom Label Painter Algorithm

The `PieChartLabelPainter` implements a sophisticated label positioning system:

**Step 1: Calculate Initial Positions**
```dart
for (var item in items) {
  final sweepAngle = (item.value / total) * 2 * math.pi;
  final midAngle = currentAngle + sweepAngle / 2;
  
  // Anchor point at chart edge
  final anchorRadius = radius;
  final anchorX = center.dx + anchorRadius * math.cos(midAngle);
  final anchorY = center.dy + anchorRadius * math.sin(midAngle);
  
  // Ideal label position (outside the chart)
  final labelRadius = radius + 40;
  final idealX = center.dx + labelRadius * math.cos(midAngle);
  final idealY = center.dy + labelRadius * math.sin(midAngle);
}
```

**Step 2: Resolve Overlaps**
- Labels are grouped by side (left/right)
- Sorted by vertical position
- Minimum spacing of 28px enforced
- Overlapping labels are pushed down to maintain readability

**Step 3: Draw Leader Lines**
The leader line consists of three segments:
1. **Radial segment**: From chart edge outward (15px)
2. **Angled segment**: To the label position
3. **Horizontal tail**: 20px horizontal line for label attachment

```dart
final path = Path();
path.moveTo(pos.anchor.dx, pos.anchor.dy);

// Segment 1: Clear the chart
final clearRadius = radius + 15;
final clearX = center.dx + clearRadius * math.cos(pos.midAngle);
final clearY = center.dy + clearRadius * math.sin(pos.midAngle);
path.lineTo(clearX, clearY);

// Segment 2: Angle to label
path.lineTo(pos.finalPos.dx, pos.finalPos.dy);

// Segment 3: Horizontal tail
final tailEnd = Offset(
  pos.finalPos.dx + (pos.isRightSide ? 20 : -20), 
  pos.finalPos.dy
);
path.lineTo(tailEnd.dx, tailEnd.dy);

canvas.drawPath(path, paint);
```

### Data Models

#### ChartLabelItem
```dart
class ChartLabelItem {
  final double value;      // Expense amount
  final Color color;       // Category color
  final String text;       // "Category Name\nXX.X%"
}
```

#### _LabelPos (Internal)
```dart
class _LabelPos {
  final ChartLabelItem item;
  final double midAngle;        // Angle at segment center
  final Offset anchor;          // Point on chart edge
  final Offset idealPos;        // Desired label position
  final bool isRightSide;       // Left or right of center
  Offset finalPos;              // Actual position after overlap resolution
}
```

## User Interface Components

### Summary Grid
A 2x2 grid displaying:
- **Income** (green, arrow down icon)
- **Expense** (red, arrow up icon)
- **Savings** (blue, savings icon)
- **Investment** (purple, trending up icon)

Each card features:
- Color-coded background with 10% opacity
- Matching border with 20% opacity
- Icon and label
- Formatted currency amount

### Pie Chart Visualization
- **Height**: 400px (increased to accommodate labels)
- **Radius**: 80px (base), 90px (touched)
- **Positioning**: Centered in container
- **Labels**: External with leader lines

### Legend Section
Below the chart, a scrollable list showing:
- Color indicator (12px circle)
- Category name
- Percentage of total expenses
- Absolute amount

### Navigation
"View Detailed Analytics" button links to `DetailedStatsPage` for comprehensive analysis.

## Design Decisions

### Why Custom Labels?
The built-in fl_chart labels had limitations:
- Limited positioning control
- Overlap issues with many categories
- Less flexibility in styling

Our custom painter provides:
- Precise control over label placement
- Smart overlap resolution
- Professional appearance with leader lines
- Better use of available space

### Color Consistency
- Each category has a unique color stored in the database
- Colors are used consistently across:
  - Pie chart segments
  - Leader lines
  - Legend indicators
  - Transaction list items

### Performance Optimization
- `shouldRepaint()` only triggers on data changes
- Efficient overlap resolution algorithm
- Minimal canvas redraws

## Code Organization

### File Structure
```
lib/features/transactions/presentation/pages/all_transactions_page.dart
├── AllTransactionsPage (Main widget)
│   ├── History Tab
│   └── Analysis Tab
├── MultiSectionAnalysis (Analysis implementation)
│   ├── Summary Grid
│   ├── Pie Chart with Custom Labels
│   └── Legend
├── ChartLabelItem (Data model)
├── PieChartLabelPainter (Custom painter)
└── _LabelPos (Internal positioning helper)
```

### Dependencies
```yaml
dependencies:
  fl_chart: ^0.68.0          # Charting library
  flutter_riverpod: ^2.6.1   # State management
  intl: ^0.19.0              # Date formatting
```

## Usage Flow

1. **User navigates** to Transactions page
2. **Selects** Analysis tab
3. **Views** summary grid with totals
4. **Interacts** with pie chart (tap to highlight)
5. **Reads** labels via leader lines
6. **Scrolls** through legend for details
7. **Optionally** filters by date range
8. **Navigates** to detailed analytics if needed

## Future Enhancements

Potential improvements could include:
- Animation on chart load
- Export chart as image
- Comparison mode (month-over-month)
- Drill-down to category transactions
- Custom color themes
- Accessibility improvements (screen reader support)

## Conclusion

This pie chart feature demonstrates the power of combining third-party libraries with custom Flutter painting to create a polished, professional data visualization. The implementation balances functionality, performance, and user experience, providing users with clear insights into their spending patterns while maintaining the app's modern aesthetic.

The modular design makes it easy to maintain and extend, while the custom label system ensures readability even with many expense categories. This feature is a cornerstone of the app's analytics capabilities, helping users make informed financial decisions.

---

**Technologies Used:**
- Flutter SDK
- fl_chart library
- Custom Canvas painting
- Riverpod state management
- Dart math library
- Material Design principles

**Key Files:**
- `all_transactions_page.dart` - Main implementation
- `transaction_model.dart` - Data models
- `category_model.dart` - Category definitions
- `transaction_provider.dart` - Data providers
