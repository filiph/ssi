import 'package:path/path.dart' as path;

/// List of common extensions for markdown files.
const List<String> markdownExtensions = [
  '.markdown',
  '.md',
  '.mdown',
  '.mdwn',
  '.mkd',
  '.mkdn',
  '.text',
];

/// Returns `true` if the given [filePath] is a markdown file (based
/// on its extension, such as `.md`).
bool isMarkdownPath(String filePath) {
  final extension = path.extension(filePath);
  return markdownExtensions.contains(extension);
}
