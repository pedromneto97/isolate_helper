# isolate_helper

Flutter library to reduce boilerplate for long-running isolates.

## Getting started

To use this library, add the following to your `pubspec.yaml`:

```yaml
  isolate_helper: ^0.1.0
```

## Usage

Create a class that extends `IsolateHelper`:

```dart
import 'dart:convert';

import 'package:isolate_helper/isolate_helper.dart';

class JsonDecoderHelper extends IsolateHelper<String, Map<String, dynamic>> {
  JsonDecoderHelper._()
      : super(
          isolateFunction: decode,
          debugName: 'jsonDecode',
        );
}

DecodedJsonType decode(String data) => jsonDecode(data);

```
