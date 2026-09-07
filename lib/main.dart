/// Application entry point bootstrapping ByteFlow.
library;

import 'package:flutter/material.dart';
import 'package:byteflow/app/app.dart';

export 'package:byteflow/app/app.dart';

/// Initializes framework bindings and launches the [ByteFlowApp].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ByteFlowApp());
}
