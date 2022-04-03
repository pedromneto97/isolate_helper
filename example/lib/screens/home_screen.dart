import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/benchmark.dart';
import '../utils/json_decode_helper.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String jsonDecoderHelperResult = '';
  String computeResult = '';

  void runTests() {
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await JsonDecoderHelper.I.awaitForInitialization;
      final benchmark = BenchmarkHelper(iterations: 20)..setup();
      Stopwatch stopwatch = await benchmark.run(f: JsonDecoderHelper.I.compute, name: 'JsonDecoderHelper');
      jsonDecoderHelperResult = 'JsonDecoderHelper: ${stopwatch.elapsedMilliseconds}ms';
      stopwatch = await benchmark.run(f: (data) => compute(jsonDecode, data), name: 'compute');
      computeResult = 'compute: ${stopwatch.elapsedMilliseconds}ms';

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (jsonDecoderHelperResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  jsonDecoderHelperResult,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            if (computeResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  computeResult,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ElevatedButton(
              onPressed: runTests,
              child: const Text('Run tests'),
            ),
          ],
        ),
      ),
    );
  }
}
