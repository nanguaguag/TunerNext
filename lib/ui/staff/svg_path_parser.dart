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
        } else if (lastCommand.isNotEmpty) {
          command = lastCommand;
        } else {
          // Orphan numeric token with no preceding command
          i++;
          continue;
        }
      }

      switch (command) {
        case 'M':
          if (i + 1 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x = double.tryParse(tokens[i++]) ?? 0.0;
          final y = double.tryParse(tokens[i++]) ?? 0.0;
          path.moveTo(x, y);
          currentX = x;
          currentY = y;
          startX = x;
          startY = y;
          break;

        case 'm':
          if (i + 1 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final dx = double.tryParse(tokens[i++]) ?? 0.0;
          final dy = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeMoveTo(dx, dy);
          currentX += dx;
          currentY += dy;
          startX = currentX;
          startY = currentY;
          break;

        case 'L':
          if (i + 1 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x = double.tryParse(tokens[i++]) ?? 0.0;
          final y = double.tryParse(tokens[i++]) ?? 0.0;
          path.lineTo(x, y);
          currentX = x;
          currentY = y;
          break;

        case 'l':
          if (i + 1 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final dx = double.tryParse(tokens[i++]) ?? 0.0;
          final dy = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeLineTo(dx, dy);
          currentX += dx;
          currentY += dy;
          break;

        case 'H':
          if (i >= tokens.length) {
            break;
          }
          final x = double.tryParse(tokens[i++]) ?? 0.0;
          path.lineTo(x, currentY);
          currentX = x;
          break;

        case 'h':
          if (i >= tokens.length) {
            break;
          }
          final dx = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeLineTo(dx, 0.0);
          currentX += dx;
          break;

        case 'V':
          if (i >= tokens.length) {
            break;
          }
          final y = double.tryParse(tokens[i++]) ?? 0.0;
          path.lineTo(currentX, y);
          currentY = y;
          break;

        case 'v':
          if (i >= tokens.length) {
            break;
          }
          final dy = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeLineTo(0.0, dy);
          currentY += dy;
          break;

        case 'C':
          if (i + 5 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = double.tryParse(tokens[i++]) ?? 0.0;
          final y1 = double.tryParse(tokens[i++]) ?? 0.0;
          final x2 = double.tryParse(tokens[i++]) ?? 0.0;
          final y2 = double.tryParse(tokens[i++]) ?? 0.0;
          final x = double.tryParse(tokens[i++]) ?? 0.0;
          final y = double.tryParse(tokens[i++]) ?? 0.0;
          path.cubicTo(x1, y1, x2, y2, x, y);
          currentX = x;
          currentY = y;
          break;

        case 'c':
          if (i + 5 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final dx1 = double.tryParse(tokens[i++]) ?? 0.0;
          final dy1 = double.tryParse(tokens[i++]) ?? 0.0;
          final dx2 = double.tryParse(tokens[i++]) ?? 0.0;
          final dy2 = double.tryParse(tokens[i++]) ?? 0.0;
          final dx = double.tryParse(tokens[i++]) ?? 0.0;
          final dy = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeCubicTo(dx1, dy1, dx2, dy2, dx, dy);
          currentX += dx;
          currentY += dy;
          break;

        case 'Q':
          if (i + 3 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = double.tryParse(tokens[i++]) ?? 0.0;
          final y1 = double.tryParse(tokens[i++]) ?? 0.0;
          final x = double.tryParse(tokens[i++]) ?? 0.0;
          final y = double.tryParse(tokens[i++]) ?? 0.0;
          path.quadraticBezierTo(x1, y1, x, y);
          currentX = x;
          currentY = y;
          break;

        case 'q':
          if (i + 3 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final dx1 = double.tryParse(tokens[i++]) ?? 0.0;
          final dy1 = double.tryParse(tokens[i++]) ?? 0.0;
          final dx = double.tryParse(tokens[i++]) ?? 0.0;
          final dy = double.tryParse(tokens[i++]) ?? 0.0;
          path.relativeQuadraticBezierTo(dx1, dy1, dx, dy);
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
          // Ignore unsupported tokens gracefully and advance i if it was not already advanced
          if (!isCommand) {
            i++;
          }
          break;
      }
    }

    return path;
  }
}
