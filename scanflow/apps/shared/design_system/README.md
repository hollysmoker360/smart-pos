# ScanFlow Flutter design system

Shared Flutter theme, color tokens, and reusable components for ScanFlow
applications. Use `ScanFlowTheme.light` for the Material theme and
`ScanFlowColors` for role-specific UI that needs a design token.

```dart
import 'package:scanflow_design_system/scanflow_design_system.dart';

MaterialApp(theme: ScanFlowTheme.light);
```

Applications depend on this package by local path so the design system remains
versioned with the repository.
