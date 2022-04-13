import 'dart:async';
import 'dart:isolate';

import 'models/isolate_data.dart';
import 'models/isolate_error.dart';

typedef IsolateHelperCallback<T, Q> = Q Function(T data);

abstract class IsolateHelper<T, Q> {
  int _currentId = 0;
  late final ReceivePort _receivePort;
  final _waitingList = <int, Completer<Q>>{};
  late final SendPort _sendPort;
  final Completer<void> _initializationCompleter = Completer<void>();
  late final StreamSubscription<dynamic> _receivePortStream;
  late final Isolate _isolate;
  Capability? _resumeCapability;

  IsolateHelper({
    required IsolateHelperCallback<T, Q> isolateFunction,
    String debugName = '',
  }) {
    _receivePort = ReceivePort('ReceivePort for $debugName');
    Isolate.spawn(
      _isolatedFunction<T, Q>,
      [
        _receivePort.sendPort,
        isolateFunction,
        debugName,
      ],
      debugName: debugName,
    ).then((value) => _isolate = value);
    _receivePortStream = _receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
        _initializationCompleter.complete();
      } else if (message is IsolateData) {
        _waitingList.remove(message.id)!.complete(message.data);
      } else if (message is IsolateError) {
        _waitingList.remove(message.id)!.completeError(message.error);
      }
      if (_waitingList.isEmpty) {
        _resumeCapability = _isolate.pause();
      }
    });
  }

  Future<void> get awaitForInitialization => _initializationCompleter.future;

  bool get isInitialized => _initializationCompleter.isCompleted;

  Future<Q> compute(T data) {
    final id = _currentId++;
    final completer = Completer<Q>();
    _waitingList[id] = completer;
    if (_resumeCapability != null) {
      _isolate.resume(_resumeCapability!);
      _resumeCapability = null;
    }
    _sendPort.send(
      IsolateData<T>(id: id, data: data),
    );
    return completer.future;
  }

  Future<void> dispose() async {
    await _receivePortStream.cancel();
    _sendPort.send(null);
  }
}

void _isolatedFunction<T, Q>(List<dynamic> args) async {
  final sendPort = args[0] as SendPort;
  final isolateFunction = args[1];
  final debugName = args[2] as String;
  final receivePort = ReceivePort('ReceivePort for $debugName');

  sendPort.send(receivePort.sendPort);

  await for (final dataReceived in receivePort) {
    if (dataReceived == null) {
      break;
    }

    if (dataReceived is IsolateData) {
      try {
        final data = isolateFunction(dataReceived.data as T) as Q;
        sendPort.send(
          dataReceived.newDataForId<Q>(data),
        );
      } on Error catch (error) {
        sendPort.send(
          dataReceived.newErrorForId(error),
        );
      }
    }
  }
  receivePort.close();
  Isolate.exit();
}
