Stream<int> faultyNumberStream() async* {
  for (int i = 1; i <= 5; i++) {
    if (i == 3) {
      throw Exception('An error occurred at number $i');
    }
    yield i;
  }
}

Stream<int> safeNumberStream() async* {
  yield 0;

  try {
    await for (final value in faultyNumberStream()) {
      yield value;
    }
  } catch (e) {
    print('Caught an error: $e');
    // You can yield an alternative value here.
    yield -1;
  }

  yield 6;
}

void main() async {
  await for (final number in safeNumberStream()) {
    print(number);
  }
}