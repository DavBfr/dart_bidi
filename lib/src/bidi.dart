import 'dart:core';
import 'enums.dart';
import 'paragraph.dart';
import 'unicode_character_resolver.dart';

/// <summary>
/// Implementation of the BIDI algorithm, as described in http://www.unicode.org/reports/tr9/tr9-17.html
/// </summary>
/// <param name="logicalString">The original logical-ordered string.</param>
/// <returns>The visual representation of the string.</returns>
List<int> logicalToVisual(String logicalString) {
  final pars = splitStringToParagraphs(logicalString);
  final sb = List<int>();
  for (final p in pars) {
    sb.addAll(p.bidiText);
  }

  return sb;
}

/// <summary>
/// Implementation of the BIDI algorithm, as described in http://www.unicode.org/reports/tr9/tr9-17.html
/// </summary>
/// <param name="logicalString">The original logical-ordered string.</param>
/// <param name="indexes">Implies where the original characters are.</param>
/// <param name="lengths">Implies how many characters each original character occupies.</param>
/// <returns>The visual representation of the string.</returns>
String logicalToVisual2(
    String logicalString, List<int> indexes, List<int> lengths) {
  //Section 3:
  //1. seperate text into paragraphs
  //2. resulate each paragraph to its embeding levels of text
  //2.1 find the first character of type L, AL, or R.
  //3. reorder text elements

  //Section 3.3: Resolving Embedding Levels:
  //(1) determining the paragraph level.
  //(2) determining explicit embedding levels and directions.
  //(3) resolving weak types.
  //(4) resolving neutral types.
  //(5) resolving implicit embedding levels.

  indexes = List<int>();
  lengths = List<int>();

  List<Paragraph> pars = splitStringToParagraphs(logicalString);
  final sb = <int>[];
  for (Paragraph p in pars) {
    sb.addAll(p.bidiText);
    indexes.addAll(p.bidiIndexes);
    lengths.addAll(p.bidiIndexLengths);
  }

  return String.fromCharCodes(sb);
}

// 3.3.1.P1 - Split the text into separate paragraphs.
// A paragraph separator is kept with the previous paragraph.
// Within each paragraph, apply all the other rules of this algorithm.
List<Paragraph> splitStringToParagraphs(String logicalString) {
  List<Paragraph> ret = [];

  var sb = <int>[];
  for (var i = 0; i < logicalString.length; ++i) {
    final c = logicalString.codeUnits[i];
    final cType = getBidiCharacterType(c);
    if (cType == BidiCharacterType.B) {
      final p = Paragraph(sb);
      p.paragraphSeparator = c;
      ret.add(p);
      sb = [];
    } else {
      sb.add(c);
    }
  }
  if (sb.length > 0) // string ended without a paragraph separator
  {
    ret.add(Paragraph(sb));
  }
  return ret;
}
