import 'package:path/path.dart' as path;
import 'package:ssi/ssi.dart';
import 'package:test/test.dart';

void main() {
  late ServerSideIncludeProcessor ssi;

  setUp(() {
    ssi = ServerSideIncludeProcessor(verbose: false, autoMarkdown: false);
  });

  test('single file with includes (index.shtml)', () async {
    final lines = ssi.recursiveExpand(
      path.join('test', 'files', 'index.shtml'),
      0,
    );
    final result = lines.join('\n');

    expect(result, contains('<title>Document</title>'));
    expect(
      result,
      contains('<a href="https://en.wikipedia.org/wiki/Markdown">Markdown</a>'),
    );
    expect(result, contains('</html>'));
    expect(result, isNot(contains('<!--#include file="header.html"-->')));
  });

  test('simple set and echo (simple_echo.shtml)', () async {
    final lines =
        ssi
            .recursiveExpand(path.join('test', 'files', 'simple_echo.shtml'), 0)
            .toList();
    final result = lines.join('\n');

    expect(result, contains('<title>My Website</title>'));
    expect(lines.length, lessThan(3));
  });

  test('several files (variables_set.txt variables_echo.md)', () async {
    final lines = <String>[];
    lines.addAll(
      ssi.recursiveExpand(path.join('test', 'files', 'variables_set.txt'), 0),
    );
    lines.addAll(
      ssi.recursiveExpand(
        path.join('test', 'files', 'variables_echo.md'),
        0,
        convertMarkdown: true,
      ),
    );
    final result = lines.join('\n');

    expect(result, contains("<h1>Here's a test with variables</h1>"));
    expect(result, contains('<a href="https://filiph.net">link</a>'));
    expect(result, isNot(contains('<!--#echo var="url" -->')));
  });

  test('variables set inside includes (complex.shtml)', () async {
    final lines = ssi.recursiveExpand(
      path.join('test', 'files', 'complex.shtml'),
      0,
    );
    final result = lines.join('\n');

    expect(result, contains('<title>Document</title>'));
    expect(result, contains("<h1>Here's a test with variables</h1>"));
    expect(result, contains('<a href="https://filiph.net">link</a>'));
    expect(
      result,
      isNot(contains('<!--#set var="url" value="https://filiph.net" -->')),
    );
    expect(result, isNot(contains('<!--#echo var="url" -->')));
  });
}
