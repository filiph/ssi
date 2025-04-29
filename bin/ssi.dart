import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/ssi.dart';
import 'package:ssi/version.dart';

Future<int> main(List<String> arguments) async {
  final argParser =
      ArgParser(allowTrailingOptions: true, usageLineLength: 80)
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Print this usage information.',
        )
        ..addFlag(
          'verbose',
          abbr: 'v',
          negatable: false,
          help: 'Show additional command output.',
        )
        ..addFlag(
          'root-markdown',
          defaultsTo: true,
          help:
              'When one of the provided paths has a Markdown extension '
              '(${_markdownExtensions.join(', ')}), '
              "automatically assume it's Markdown and convert it.",
        )
        ..addFlag('version', negatable: false, help: 'Print the tool version.');

  final bool verbose;
  final bool rootMarkdown;
  final List<String> templatePaths;

  try {
    final ArgResults results = argParser.parse(arguments);

    // Process the parsed arguments.
    if (results.flag('help')) {
      _printUsage(argParser);
      return 0;
    }
    if (results.flag('version')) {
      print('ssi version: $version');
      return 0;
    }
    verbose = results.flag('verbose');
    rootMarkdown = results.flag('root-markdown');

    if (results.rest.isEmpty) {
      print('You must provide at least one template file.');
      _printUsage(argParser);
      return 2;
    }
    templatePaths = results.rest;

    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    _printUsage(argParser);
    return 2;
  }

  final ssi = ServerSideIncludeProcessor(verbose: verbose);

  try {
    for (final templatePath in templatePaths) {
      final convertMarkdown = rootMarkdown && _isMarkdownPath(templatePath);
      if (verbose && convertMarkdown) {
        print('[VERBOSE] Detected root markdown file: $templatePath');
      }

      final lines = ssi.recursiveExpand(
        templatePath,
        0,
        convertMarkdown: convertMarkdown,
      );

      for (final line in lines) {
        if (line == Directive.magicNoOutputSequence) continue;
        print(line);
      }
    }
  } catch (e, s) {
    stderr.writeln('Error when expanding: $e');
    stderr.writeln('Stacktrace:\n$s');
    return 1;
  }

  return 0;
}

void _printUsage(ArgParser argParser) {
  print('Usage: ssi <flags> template.file [another.file [...]]');
  print(argParser.usage);
}

bool _isMarkdownPath(String filePath) {
  final extension = path.extension(filePath);
  return _markdownExtensions.contains(extension);
}

List<String> _markdownExtensions = [
  '.markdown',
  '.md',
  '.mdown',
  '.mdwn',
  '.mkd',
  '.mkdn',
];
