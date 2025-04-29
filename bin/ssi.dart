import 'dart:io';

import 'package:args/args.dart';
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/markdown_filenames.dart';
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
              'When one of the files provided on the command line '
              'has a Markdown extension '
              '(${markdownExtensions.join(', ')}), '
              "automatically assume it's Markdown and convert it.",
        )
        ..addFlag(
          'auto-markdown',
          defaultsTo: false,
          help:
              'When an file included with the #include directive '
              'has a Markdown extension '
              '(${markdownExtensions.join(', ')}), '
              "automatically assume it's Markdown and convert it. "
              "This is off by default because we can't assume you're trying "
              "to build an HTML file.",
        )
        ..addFlag('version', negatable: false, help: 'Print the tool version.');

  final bool verbose;
  final bool rootMarkdown;
  final bool autoMarkdown;
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
    autoMarkdown = results.flag('auto-markdown');

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

  final ssi = ServerSideIncludeProcessor(
    verbose: verbose,
    autoMarkdown: autoMarkdown,
  );

  try {
    for (final templatePath in templatePaths) {
      final convertMarkdown = rootMarkdown && isMarkdownPath(templatePath);
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
