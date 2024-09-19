# Understanding the reduce Method on Streams in Dart
This example demonstrates how to use the `reduce` function on a Dart `Stream` to process and accumulate values emitted over time. In this specific case, we're summing a series of integers emitted by a stream.

## Introduction
In Dart, streams are a way to work with asynchronous data sequences. They are particularly useful for handling data that arrives over time, such as user interactions, sensor readings, or data from network requests.

The `reduce` method is a powerful tool that allows you to combine the elements of a stream into a single value. This is similar to the `reduce` method on collections like `List`, but it works asynchronously with streams.

This example shows how to sum all the numbers emitted by a stream using the `reduce` method.

## The Code
### Generating a Stream of Numbers
```dart
Stream<int> getStreamOfNumbers() async* {
  const numbers = <int>[17, 32, 40, 32, 1, 23, -23, 43, 0, 1, 21, 33];

  for (final n in numbers) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield n;
  }
}
```

#### Explanation:
- Function: `getStreamOfNumbers()` is an asynchronous generator function that returns a `Stream<int>`.
- Numbers List: It defines a constant list of integers to emit.
- Async Iteration:
  - It loops over each number in the list.
  - Introduces a delay of 300 milliseconds before emitting each number to simulate asynchronous data arrival.
  - Uses `yield` to emit each number into the stream.

### Using the reduce Method
```dart
void main() {
  getStreamOfNumbers().reduce((sum, element) => sum + element).then((sum) {
    print('The total sum is: $sum');
  });
}
```

#### Explanation:
- Retrieve the Stream: Calls `getStreamOfNumbers()` to obtain the stream.
- Apply reduce: Uses the reduce method to accumulate the sum of all numbers emitted by the stream.
- The reducer function `(sum, element) => sum + element` specifies how to combine the elements.
- Handle the Future: The reduce method returns a `Future<int>` that completes with the final accumulated value.
- Print the Result: Once the future completes, it prints the total sum.

## Understanding the reduce Method
The `reduce` method on a stream applies a reducer function to each element of the stream, resulting in a single value once the stream is complete.

### Signature:
```dart
Future<T> reduce(T combine(T previous, T element));
```
- `T`: The type of elements in the stream.
- `combine`: A function that specifies how to combine the previous accumulated value with the current element.

### Behavior:
- The stream must emit at least one event; otherwise, the future returned by `reduce` will complete with an error (`StateError`).
- The reducer function is applied sequentially:
  - Starts with the first element as the initial value.
  - For each subsequent element, it applies the `combine` function, passing in the accumulated value and the current element.
- The future completes with the final accumulated value once the stream is done.

## How It Works
1. Stream Initialization:
- The `getStreamOfNumbers()` function is called, and the stream starts emitting numbers with a 300-millisecond delay between each.
2. Applying `reduce`:
- The `reduce` method listens to the stream.
It uses the first number emitted (`17`) as the initial accumulated value (`sum`).
3. Accumulating Values:
- For each subsequent number (`element`), the reducer function `sum + element` is called.
- The accumulated `sum` is updated with the result.
4. Completing the Future:
- After all numbers have been emitted and processed, the `reduce` method completes its future with the final `sum`.
5. Printing the Result:
- The `.then((sum) { ... })` callback is invoked with the total sum.
- The program prints the total sum to the console.