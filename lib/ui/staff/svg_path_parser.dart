// Copyright 2026 Tuner Project Authors. All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// Lightweight, zero-dependency SVG path parser supporting M/m, L/l, C/c, and Z/z commands.
///
/// Designed to parse Gonville vector clef definitions directly into Flutter [Path] objects.
class SvgPathParser {
  static final RegExp _tokenRegex = RegExp(
    r'([a-zA-Z])|([-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?)',
  );

  /// Parses an SVG path data string into a [Path] with [PathFillType.evenOdd].
  static Path parse(String svgPathData) {
    final path = Path()..fillType = PathFillType.evenOdd;
    final matches = _tokenRegex.allMatches(svgPathData);
    final tokens = <String>[];
    for (final match in matches) {
      tokens.add(match.group(0)!);
    }

    var i = 0;
    var currentX = 0.0;
    var currentY = 0.0;
    var startX = 0.0;
    var startY = 0.0;
    String lastCommand = '';

    while (i < tokens.length) {
      final token = tokens[i];
      final isCommand = RegExp(r'[a-zA-Z]').hasMatch(token);

      final String command;
      if (isCommand) {
        command = token;
        lastCommand = command;
        i++;
      } else {
        // Repeated coordinates under the previous command
        if (lastCommand == 'M') {
          command = 'L';
        } else if (lastCommand == 'm') {
          command = 'l';
        } else {
          command = lastCommand;
        }
      }

      switch (command) {
        case 'M':
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.moveTo(x, y);
          currentX = x;
          currentY = y;
          startX = x;
          startY = y;
          break;

        case 'm':
          final dx = double.parse(tokens[i++]);
          final dy = double.parse(tokens[i++]);
          path.relativeMoveTo(dx, dy);
          currentX += dx;
          currentY += dy;
          startX = currentX;
          startY = currentY;
          break;

        case 'L':
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.lineTo(x, y);
          currentX = x;
          currentY = y;
          break;

        case 'l':
          final dx = double.parse(tokens[i++]);
          final dy = double.parse(tokens[i++]);
          path.relativeLineTo(dx, dy);
          currentX += dx;
          currentY += dy;
          break;

        case 'C':
          final x1 = double.parse(tokens[i++]);
          final y1 = double.parse(tokens[i++]);
          final x2 = double.parse(tokens[i++]);
          final y2 = double.parse(tokens[i++]);
          final x = double.parse(tokens[i++]);
          final y = double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, x, y);
          currentX = x;
          currentY = y;
          break;

        case 'c':
          final dx1 = double.parse(tokens[i++]);
          final dy1 = double.parse(tokens[i++]);
          final dx2 = double.parse(tokens[i++]);
          final dy2 = double.parse(tokens[i++]);
          final dx = double.parse(tokens[i++]);
          final dy = double.parse(tokens[i++]);
          path.relativeCubicTo(dx1, dy1, dx2, dy2, dx, dy);
          currentX += dx;
          currentY += dy;
          break;

        case 'Z':
        case 'z':
          path.close();
          currentX = startX;
          currentY = startY;
          break;

        default:
          // Ignore unsupported tokens gracefully
          break;
      }
    }

    return path;
  }
}
