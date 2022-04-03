import 'dart:convert';

import '../fake/data.dart';

class BenchmarkHelper {
  final data = <String>[];
  final int iterations;

  BenchmarkHelper({
    this.iterations = 10,
  });

  void setup() {
    for (int i = 0; i < iterations; i++) {
      data.add(jsonEncode(fakeJsonData));
    }
  }

  Future<Stopwatch> run({
    required String name,
    required Future<void> Function(String data) f,
  }) async {
    final futures = <Future<void>>[];
    final watch = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      futures.add(
        f(data[i]),
      );
    }
    await Future.wait(futures);
    watch.stop();
    return watch;
  }
}
