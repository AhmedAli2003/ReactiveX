// This program demonstrates how to use the `reduce` method on a stream of integers.
// It sums all the numbers emitted by the stream and prints the total sum.

// Generates a stream of integers, emitting one number every 300 milliseconds.
Stream<int> getStreamOfNumbers() async* {
  // A list of integers to emit.
  const numbers = <int>[17, 32, 40, 32, 1, 23, -23, 43, 0, 1, 21, 33];

  // Iterate over each number in the list.
  for (final n in numbers) {
    // Simulate an asynchronous delay before emitting each number.
    await Future.delayed(const Duration(milliseconds: 300));
    yield n; // Emit the number into the stream.
  }
}

void main() {
  // Call the function to get the stream of numbers.
  final numberStream = getStreamOfNumbers();

  // Use the `reduce` method to accumulate the sum of all numbers in the stream.
  // The `reduce` method returns a Future that completes with the final result.
  numberStream.reduce((sum, element) => sum + element).then((totalSum) {
    // Once the Future completes, print the total sum.
    print('The total sum is: $totalSum');
  });
}
