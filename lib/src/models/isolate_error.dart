import 'isolate_info.dart';

class IsolateError extends IsolateInfo {
  final Error error;

  const IsolateError({
    required int id,
    required this.error,
  }) : super(id: id);
}
