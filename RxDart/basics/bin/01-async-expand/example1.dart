// This program demonstrates how to use `asyncExpand` to process streams sequentially.
// For each word emitted from a stream of words, we generate a stream of its characters.
// Each word and character is emitted after a delay to simulate asynchronous operations.

// Type aliases for better readability.
typedef Word = String;
typedef Character = String;

// Generates a stream of words, emitting one word every second.
Stream<Word> getWords() async* {
  // List of words to emit.
  const words = <Word>['Driver', 'Family', 'Program'];

  // Iterate over each word.
  for (final word in words) {
    // Simulate a delay before emitting the word.
    await Future.delayed(const Duration(seconds: 1));
    yield word; // Emit the word into the stream.
  }
}

// Generates a stream of characters from a given word, emitting one character every second.
Stream<Character> getCharacters(Word word) async* {
  // Split the word into individual characters.
  final characters = word.split('');

  // Iterate over each character.
  for (final char in characters) {
    // Simulate a delay before emitting the character.
    await Future.delayed(const Duration(seconds: 1));
    yield char; // Emit the character into the stream.
  }
}

void main() async {
  // Obtain the stream of words.
  final words = getWords();

  // Use `asyncExpand` to process each word sequentially.
  // For each word, we get a stream of its characters.
  final characters = words.asyncExpand(
    (word) => getCharacters(word),
  );

  // Listen to the combined stream of characters and print each character as it arrives.
  await for (final char in characters) {
    print(char);
  }
}

/* Output Overview
Time (seconds) | Output
------------------------
1              | (word 'Driver' emitted)
2              | D
3              | r
4              | i
5              | v
6              | e
7              | r
8              | (word 'Family' emitted)
9              | F
10             | a
11             | m
12             | i
13             | l
14             | y
15             | (word 'Program' emitted)
16             | P
17             | r
18             | o
19             | g
20             | r
21             | a
22             | m
*/