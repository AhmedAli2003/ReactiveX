Stream<int> streamA() async* {
  yield* Stream.fromIterable([1, 2, 3]);
}

Stream<int> streamB() async* {
  yield* Stream.fromIterable([4, 5, 6]);
}

Stream<int> combinedStream() async* {
  yield* streamA();
  yield* streamB();
}

void main() async {
  await for (final number in combinedStream()) {
    print(number);
  }
}
