import 'dart:io';

// Step 1: Create a Stream of File Paths
// First, you'll need a stream that emits the file paths of the 10 large files you want to read.
Stream<String> filePathsStream(List<String> filePaths) async* {
  for (final path in filePaths) {
    yield path;
  }
}

// Step 2: Use asyncExpand to Read Each File
// Use asyncExpand to process each file path. For each file, read its contents as a stream.

Stream<List<int>> readFilesSequentially(Stream<String> pathsStream) {
  // asyncExpand: Ensures that the next file is not read until the current file's stream has completed.
  return pathsStream.asyncExpand((filePath) {
    final file = File(filePath);
    print('Reading file: $filePath');
    // Opens the file for reading as a stream of bytes.
    return file.openRead(); // Returns a Stream<List<int>>
  });
}

// Step 3: Write the Contents to a Single Output File
// Now, you can write the data from the combined stream into a single output file.
void writeToFile(Stream<List<int>> dataStream, String outputFilePath) {
  final outputFile = File(outputFilePath);
  final sink = outputFile.openWrite();

  dataStream.listen(
    (data) {
      sink.add(data); // Writes data to the output file.
    },
    onError: (error) {
      print('Error occurred: $error');
    },
    onDone: () async {
      // Called when the stream has completed, ensuring the sink is properly closed.
      await sink.flush();
      await sink.close();
      print('All files have been read and data written to $outputFilePath');
    },
  );
}

void main() {
  // List of file paths to read
  const filePaths = <String>[
    '../../assets/async-expand/file1.txt',
    '../../assets/async-expand/file2.txt',
    '../../assets/async-expand/file3.txt',
  ];

  final pathsStream = filePathsStream(filePaths);
  final dataStream = readFilesSequentially(pathsStream);

  const outputFilePath = '../../assets/async-expand/combined_output.txt';
  writeToFile(dataStream, outputFilePath);
}
