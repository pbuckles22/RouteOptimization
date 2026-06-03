import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'golden_comparator.dart';

/// Use 2% pixel-difference threshold for golden tests. See TEST_PLAN.md.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final current = goldenFileComparator;
  if (current is LocalFileComparator) {
    goldenFileComparator = LocalFileComparatorWithThreshold(
      current.basedir.resolve('golden_test.dart'),
      0.02,
    );
  }
  await testMain();
}
