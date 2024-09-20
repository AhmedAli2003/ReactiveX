# Understanding yield vs. yield*
In Dart, `yield` and `yield*` are used within generator functions to produce a sequence of values. There are two types of generator functions:
- Synchronous Generator Functions: Use `Iterable` and `sync*`.
- Asynchronous Generator Functions: Use `Stream` and `async*`.
`yield`: Emits a single value.
`yield*`: Delegates to another generator (an `Iterable` or `Stream`), yielding all of its values.

## Using yield* with Streams
When working with asynchronous streams (`Stream`), you can use `async*` functions to create stream generators. Within these functions, you can use `yield*` to consume another stream and emit its events as part of your stream.

Syntax:
```dart
Stream<T> myAsyncGenerator() async* {
  // Some code...
  yield value;     // Emits a single value.
  yield* anotherStream;  // Emits all values from anotherStream.
}
```
Explanation:
- `yield value;`: Adds a single event to the stream.
- `yield* anotherStream;`: Subscribes to anotherStream and emits all its events into your stream.

## Why Use yield*?
- Code Reusability: If you have an existing stream that you want to include in your new stream, `yield*` allows you to do this without manually listening to the other stream and forwarding events.
- Simplification: It simplifies the code by delegating event emission to another stream, making your generator functions cleaner and more readable.
- Event Order Preservation: Events from the delegated stream are emitted in order, seamlessly integrated into your stream.

## Practical Example
Let's consider an example to illustrate how `yield*` works with streams.

### Scenario
- You have a stream of integers.
- You want to create a new stream that:
  - Emits all the numbers from the first stream.
  - Adds additional numbers before and after.

### Implementation
```dart
Stream<int> numberStream() async* {
  // Emit numbers from 1 to 5 with a delay.
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(milliseconds: 500));
    yield i;
  }
}

Stream<int> enhancedNumberStream() async* {
  // Emit a starting value.
  yield 0;

  // Delegate to another stream using yield*.
  yield* numberStream();

  // Emit an ending value.
  yield 6;
}

void main() async {
  // Listen to the enhanced stream and print each number.
  await for (final number in enhancedNumberStream()) {
    print(number);
  }
}
```
### Output:
```dart
0
1
2
3
4
5
6
```
### Explanation:
1. `numberStream()` Function:
   - An `async*` function that emits numbers from 1 to 5.
   - Uses `yield` to emit each number after a 500-millisecond delay.
2. `enhancedNumberStream()` Function:
   - Also an async* function.
   - `yield 0;`: Emits the starting value 0.
   - `yield* numberStream();`: Delegates to `numberStream()`, emitting all its numbers (1 to 5).
   - `yield 6;`: Emits the ending value 6.
3. `main()` Function:
   - Uses an asynchronous `for` loop (`await for`) to listen to `enhancedNumberStream()` and prints each number as it is received.

### Detailed Breakdown
Using `yield*` to Include Another Stream
- Delegation with `yield*`: When you write `yield* numberStream();`, you're telling Dart to:
  - Subscribe to `numberStream()`.
  - Emit all events from `numberStream()` as part of `enhancedNumberStream()`.
  - Wait for `numberStream()` to complete before moving on.
- Event Flow:
  1. Emit 0.
  2. Delegate to `numberStream()`:
   - Emits 1 to 5, each after a 500-millisecond delay.
  3. After `numberStream()` completes, emit 6.

### Alternative Without yield*
If you didn't use `yield*`, you would need to manually listen to `numberStream()` and forward its events:
```dart
Stream<int> enhancedNumberStream() async* {
  yield 0;

  // Manually listen to numberStream and yield each event.
  await for (final number in numberStream()) {
    yield number;
  }

  yield 6;
}
```
- Drawbacks:
  - Slightly more verbose.
  - Less expressive than using `yield*`.

## Error Handling

### Option 1: Using `handleError`
Here we don't use `throw` keyword, instead we `yield* Stream.error(Exception())`. 
```dart
Stream<int> faultyNumberStream() async* {
  for (int i = 1; i <= 5; i++) {
    if (i == 3) {
      // Emit an error event instead of throwing.
      yield* Stream.error(Exception('An error occurred at number $i'));
    } else {
      yield i;
    }
  }
}

Stream<int> safeNumberStream() async* {
  yield 0;

  // Use handleError to catch errors from the stream.
  yield* faultyNumberStream().handleError((error) {
    print('Caught an error: $error');
    // Note: Since we can't yield inside handleError, we need another approach.
  });

  yield 6;
}

void main() async {
  await for (final number in safeNumberStream()) {
    print(number);
  }
}
```
#### Output:
```dart
0
1
2
Caught an error: Exception: An error occurred at number 3
4
5
6
```
#### Limitations:
This way, we cannot yield a new value like (-1) from `handleError` directly.

### Option 2: Manually Iterating Over the Stream with `await for`
To have full control over error handling and to emit alternative values, you can manually iterate over the stream.
```dart
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
```
#### Output:
```dart
0
1
2
Caught an error: Exception: An error occurred at number 3
-1
6
```
Here we can emit alternative values when an error occurs.
#### Limitations:
The stream will stop emitting values after the error is thrown.

### Option 3: Using `StreamTransformer`
Alternatively, you can use a `StreamTransformer` to handle errors and possibly replace error events with data events.
```dart
import 'dart:async';

Stream<int> faultyNumberStream() async* {
  for (int i = 1; i <= 5; i++) {
    if (i == 3) {
      yield* Stream.error(Exception('An error occurred at number $i'));
    }
    yield i;
  }
}

StreamTransformer<T, T> errorHandlerTransformer<T>(T replacementValue) {
  return StreamTransformer<T, T>.fromHandlers(
    handleError: (error, stackTrace, sink) {
      print('Caught an error: $error');
      // Emit a replacement value instead of the error.
      sink.add(replacementValue);
    },
  );
}

Stream<int> safeNumberStream() async* {
  yield 0;
  yield* faultyNumberStream().transform(errorHandlerTransformer(-1));
  yield 6;
}

void main() async {
  await for (final number in safeNumberStream()) {
    print(number);
  }
}
```
#### Output:
```dart
0
1
2
Caught an error: Exception: An error occurred at number 3
-1
3
4
5
6
```
- Allows you to replace error events with alternative data.
- The stream continues emitting subsequent events after the error.

### Key Points About Error Handling with Streams
- Errors in Streams Are Not Exceptions:
  - Errors emitted by streams are asynchronous error events.
  - They don't behave like exceptions that can be caught with `try-catch` around `yield*`.
- Handling Errors in Streams:
  - Use stream methods like `handleError`, `transform`, or manually process events with `await for` and `try-catch`.
  - Decide whether to emit alternative values, skip errors, or terminate the stream.
- Limitations of `handleError`:
  - The `handleError` method allows you to handle errors but doesn't let you emit new data events directly within its callback.
  - If you need to emit alternative data, consider using a `StreamTransformer` or manual iteration.

### Practical Recommendations
- Use `await for` with `try-catch` When You Need to Emit Alternative Values:
  - This method gives you the most control.
  - You can catch errors and decide how to proceed, including emitting alternative values or stopping the iteration.
- Use `handleError` for Simple Error Logging or Handling:
  - If you don't need to emit alternative values, `handleError` can be sufficient.
  - Remember that you can't yield inside `handleError`.
- Use `StreamTransformer` to Replace Errors with Data:
  - If you want to convert error events into data events, a transformer is suitable.
  - This allows the stream to continue emitting subsequent events after an error.