import 'dart:convert';

import 'package:isolate_helper/isolate_helper.dart';

typedef DecodedJsonType = Map<String, dynamic>;

class JsonDecoderHelper extends IsolateHelper<String, DecodedJsonType> {
  JsonDecoderHelper._()
      : super(
          isolateFunction: decode,
          debugName: 'jsonDecode',
        );

  static JsonDecoderHelper? _instance;

  static JsonDecoderHelper get I => _instance ??= JsonDecoderHelper._();
}

DecodedJsonType decode(String data) => jsonDecode(data);
