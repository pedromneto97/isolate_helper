import 'isolate_error.dart';
import 'isolate_info.dart';

class IsolateData<T> extends IsolateInfo {
  final T data;

  const IsolateData({
    required int id,
    required this.data,
  }) : super(id: id);

  IsolateData<Q> newDataForId<Q>(Q data) => IsolateData<Q>(
        id: id,
        data: data,
      );

  IsolateError newErrorForId(Error error) => IsolateError(
        id: id,
        error: error,
      );
}
