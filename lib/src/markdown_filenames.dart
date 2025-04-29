import 'package:path/path.dart' as path;

bool isMarkdownPath(String filePath) {
  final extension = path.extension(filePath);
  return markdownExtensions.contains(extension);
}

List<String> markdownExtensions = [
  '.markdown',
  '.md',
  '.mdown',
  '.mdwn',
  '.mkd',
  '.mkdn',
];
