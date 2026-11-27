import 'package:flutter_riverpod/flutter_riverpod.dart';

final clockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    final msUntilNextSecond = 1000 - (DateTime.now().millisecond % 1000) + 10;
    await Future<void>.delayed(Duration(milliseconds: msUntilNextSecond));
    yield DateTime.now();
  }
});
