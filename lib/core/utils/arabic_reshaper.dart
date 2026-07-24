class ArabicLetter {
  final int code;
  final int isolated;
  final int finalForm;
  final int initial;
  final int medial;

  const ArabicLetter(this.code, this.isolated, this.finalForm, this.initial, this.medial);
}

final Map<int, ArabicLetter> arabicLetters = {
  // Hamza
  0x0621: const ArabicLetter(0x0621, 0xFE80, 0xFE80, 0xFE80, 0xFE80),
  // Alif Madda
  0x0622: const ArabicLetter(0x0622, 0xFE81, 0xFE82, 0xFE81, 0xFE82),
  // Alif Hamza Above
  0x0623: const ArabicLetter(0x0623, 0xFE83, 0xFE84, 0xFE83, 0xFE84),
  // Waw Hamza Above
  0x0624: const ArabicLetter(0x0624, 0xFE85, 0xFE86, 0xFE85, 0xFE86),
  // Alif Hamza Below
  0x0625: const ArabicLetter(0x0625, 0xFE87, 0xFE88, 0xFE87, 0xFE88),
  // Ya Hamza Above (Yeh with Hamza)
  0x0626: const ArabicLetter(0x0626, 0xFE89, 0xFE8A, 0xFE8B, 0xFE8C),
  // Alif
  0x0627: const ArabicLetter(0x0627, 0xFE8D, 0xFE8E, 0xFE8D, 0xFE8E),
  // Beh
  0x0628: const ArabicLetter(0x0628, 0xFE8F, 0xFE90, 0xFE91, 0xFE92),
  // Teh Marbuta
  0x0629: const ArabicLetter(0x0629, 0xFE93, 0xFE94, 0xFE93, 0xFE94),
  // Teh
  0x062A: const ArabicLetter(0x062A, 0xFE95, 0xFE96, 0xFE97, 0xFE98),
  // Theh
  0x062B: const ArabicLetter(0x062B, 0xFE99, 0xFE9A, 0xFE9B, 0xFE9C),
  // Jeem
  0x062C: const ArabicLetter(0x062C, 0xFE9D, 0xFE9E, 0xFE9F, 0xFEA0),
  // Hah
  0x062D: const ArabicLetter(0x062D, 0xFEA1, 0xFEA2, 0xFEA3, 0xFEA4),
  // Khav
  0x062E: const ArabicLetter(0x062E, 0xFEA5, 0xFEA6, 0xFEA7, 0xFEA8),
  // Dal
  0x062F: const ArabicLetter(0x062F, 0xFEA9, 0xFEAA, 0xFEA9, 0xFEAA),
  // Thal
  0x0630: const ArabicLetter(0x0630, 0xFEAB, 0xFEAC, 0xFEAB, 0xFEAC),
  // Ra
  0x0631: const ArabicLetter(0x0631, 0xFEAD, 0xFEAE, 0xFEAD, 0xFEAE),
  // Zain
  0x0632: const ArabicLetter(0x0632, 0xFEAF, 0xFEB0, 0xFEAF, 0xFEB0),
  // Seen
  0x0633: const ArabicLetter(0x0633, 0xFEB1, 0xFEB2, 0xFEB3, 0xFEB4),
  // Sheen
  0x0634: const ArabicLetter(0x0634, 0xFEB5, 0xFEB6, 0xFEB7, 0xFEB8),
  // Sad
  0x0635: const ArabicLetter(0x0635, 0xFEB9, 0xFEBA, 0xFEBB, 0xFEBC),
  // Dad
  0x0636: const ArabicLetter(0x0636, 0xFEBD, 0xFEBE, 0xFEBF, 0xFEC0),
  // Tah
  0x0637: const ArabicLetter(0x0637, 0xFEC1, 0xFEC2, 0xFEC3, 0xFEC4),
  // Zah
  0x0638: const ArabicLetter(0x0638, 0xFEC5, 0xFEC6, 0xFEC7, 0xFEC8),
  // Ain
  0x0639: const ArabicLetter(0x0639, 0xFEC9, 0xFECA, 0xFECB, 0xFECC),
  // Ghain
  0x063A: const ArabicLetter(0x063A, 0xFECD, 0xFECE, 0xFECF, 0xFED0),
  // Feh
  0x0641: const ArabicLetter(0x0641, 0xFED1, 0xFED2, 0xFED3, 0xFED4),
  // Qaf
  0x0642: const ArabicLetter(0x0642, 0xFED5, 0xFED6, 0xFED7, 0xFED8),
  // Kaf
  0x0643: const ArabicLetter(0x0643, 0xFED9, 0xFEDA, 0xFEDB, 0xFEDC),
  // Lam
  0x0644: const ArabicLetter(0x0644, 0xFEDD, 0xFEDE, 0xFEDF, 0xFEE0),
  // Meem
  0x0645: const ArabicLetter(0x0645, 0xFEE1, 0xFEE2, 0xFEE3, 0xFEE4),
  // Noon
  0x0646: const ArabicLetter(0x0646, 0xFEE5, 0xFEE6, 0xFEE7, 0xFEE8),
  // Heh
  0x0647: const ArabicLetter(0x0647, 0xFEE9, 0xFEEA, 0xFEEB, 0xFEEC),
  // Waw
  0x0648: const ArabicLetter(0x0648, 0xFEED, 0xFEEE, 0xFEED, 0xFEEE),
  // Alif Maqsura
  0x0649: const ArabicLetter(0x0649, 0xFEEF, 0xFEF0, 0xFEEF, 0xFEF0),
  // Yeh
  0x064A: const ArabicLetter(0x064A, 0xFEF1, 0xFEF2, 0xFEF3, 0xFEF4),
};

bool canConnectLeft(int charCode) {
  // Can connect to the left/following char?
  return const [
    0x0626, // Ya Hamza
    0x0628, // Beh
    0x062A, // Teh
    0x062B, // Theh
    0x062C, // Jeem
    0x062D, // Hah
    0x062E, // Khav
    0x0633, // Seen
    0x0634, // Sheen
    0x0635, // Sad
    0x0636, // Dad
    0x0637, // Tah
    0x0638, // Zah
    0x0639, // Ain
    0x063A, // Ghain
    0x0641, // Feh
    0x0642, // Qaf
    0x0643, // Kaf
    0x0644, // Lam
    0x0645, // Meem
    0x0646, // Noon
    0x0647, // Heh
    0x064A, // Yeh
  ].contains(charCode);
}

bool canConnectRight(int charCode) {
  // Can connect to the right/previous char?
  // Hamza (0x0621) cannot connect to its right
  return arabicLetters.containsKey(charCode) && charCode != 0x0621;
}

String shapeArabic(String text) {
  if (text.isEmpty) return text;

  // 1. Convert to a list of character codes
  List<int> codes = text.codeUnits;
  
  // 2. Pre-process to handle Lam-Alif ligatures
  List<int> processedCodes = [];
  int i = 0;
  while (i < codes.length) {
    int current = codes[i];
    if (current == 0x0644 && i + 1 < codes.length) { // Lam
      int next = codes[i + 1];
      int? ligature;
      if (next == 0x0622) { // Alif Madda
        ligature = 0xFEF5;
      } else if (next == 0x0623) { // Alif Hamza Above
        ligature = 0xFEF7;
      } else if (next == 0x0625) { // Alif Hamza Below
        ligature = 0xFEF9;
      } else if (next == 0x0627) { // Alif
        ligature = 0xFEFB;
      }
      
      if (ligature != null) {
        bool linkRight = processedCodes.isNotEmpty && canConnectLeft(processedCodes.last);
        if (linkRight) {
          processedCodes.add(ligature + 1); // Final form
        } else {
          processedCodes.add(ligature); // Isolated form
        }
        i += 2;
        continue;
      }
    }
    processedCodes.add(current);
    i++;
  }

  // 3. Shape the characters
  List<int> shapedCodes = List.filled(processedCodes.length, 0);
  for (int j = 0; j < processedCodes.length; j++) {
    int current = processedCodes[j];
    
    // If it's already a shaped Lam-Alif ligature, keep it
    if (current >= 0xFEF5 && current <= 0xFEFC) {
      shapedCodes[j] = current;
      continue;
    }
    
    ArabicLetter? letter = arabicLetters[current];
    if (letter == null) {
      shapedCodes[j] = current;
      continue;
    }
    
    // Determine connectivity
    bool linkRight = false;
    if (j > 0) {
      int prev = processedCodes[j - 1];
      if (!(prev >= 0xFEF5 && prev <= 0xFEFC)) {
        linkRight = canConnectLeft(prev);
      }
    }
    
    bool linkLeft = false;
    if (j < processedCodes.length - 1) {
      int next = processedCodes[j + 1];
      bool isNextArabic = canConnectRight(next) || (next >= 0xFEF5 && next <= 0xFEFC);
      if (isNextArabic) {
        linkLeft = canConnectLeft(current);
      }
    }
    
    // Select form
    if (linkRight && linkLeft) {
      shapedCodes[j] = letter.medial;
    } else if (linkRight) {
      shapedCodes[j] = letter.finalForm;
    } else if (linkLeft) {
      shapedCodes[j] = letter.initial;
    } else {
      shapedCodes[j] = letter.isolated;
    }
  }

  return String.fromCharCodes(shapedCodes);
}

enum _Direction { rtl, ltr, neutral }

class _TextRun {
  final bool isRtl;
  final String text;
  _TextRun(this.isRtl, this.text);
}

bool _hasArabic(String text) {
  for (int i = 0; i < text.length; i++) {
    int code = text.codeUnitAt(i);
    if ((code >= 0x0600 && code <= 0x06FF) || (code >= 0xFE70 && code <= 0xFEFF)) {
      return true;
    }
  }
  return false;
}

_Direction _getCharDirection(int code) {
  // Eastern Arabic digits (0x0660 to 0x0669) are read LTR
  if (code >= 0x0660 && code <= 0x0669) {
    return _Direction.ltr;
  }
  // Arabic character codes
  if ((code >= 0x0600 && code <= 0x06FF) || (code >= 0xFE70 && code <= 0xFEFF)) {
    return _Direction.rtl;
  }
  // English letters
  if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122)) {
    return _Direction.ltr;
  }
  // Digits (weak LTR)
  if (code >= 48 && code <= 57) {
    return _Direction.ltr;
  }
  // Others (neutral)
  return _Direction.neutral;
}

String adjustArabicTextForPdf(String text) {
  if (text.isEmpty) return text;
  
  // 1. If text contains no Arabic characters at all, return it unmodified.
  if (!_hasArabic(text)) {
    return text;
  }
  
  final len = text.length;
  final List<_Direction> resolved = List.filled(len, _Direction.neutral);
  
  // 2. Assign initial directions
  for (int i = 0; i < len; i++) {
    resolved[i] = _getCharDirection(text.codeUnitAt(i));
  }
  
  // 3. Resolve neutral character directions
  int i = 0;
  while (i < len) {
    if (resolved[i] == _Direction.neutral) {
      int start = i;
      while (i < len && resolved[i] == _Direction.neutral) {
        i++;
      }
      int end = i;
      
      // Determine surrounding strong directions
      _Direction beforeDir = _Direction.rtl; // Paragraph default is RTL
      for (int k = start - 1; k >= 0; k--) {
        _Direction d = _getCharDirection(text.codeUnitAt(k));
        if (d != _Direction.neutral) {
          beforeDir = d;
          break;
        }
      }
      
      _Direction afterDir = _Direction.rtl; // Paragraph default is RTL
      for (int k = end; k < len; k++) {
        _Direction d = _getCharDirection(text.codeUnitAt(k));
        if (d != _Direction.neutral) {
          afterDir = d;
          break;
        }
      }
      
      // If neutrals are bounded on both sides by LTR, resolve to LTR
      _Direction finalDir = (beforeDir == _Direction.ltr && afterDir == _Direction.ltr)
          ? _Direction.ltr
          : _Direction.rtl;
          
      for (int k = start; k < end; k++) {
        resolved[k] = finalDir;
      }
    } else {
      i++;
    }
  }
  
  // 4. Segment into runs of LTR or RTL
  final List<_TextRun> runs = [];
  int start = 0;
  bool currentIsRtl = resolved[0] == _Direction.rtl;
  for (int j = 1; j < len; j++) {
    bool isRtl = resolved[j] == _Direction.rtl;
    if (isRtl != currentIsRtl) {
      runs.add(_TextRun(currentIsRtl, text.substring(start, j)));
      start = j;
      currentIsRtl = isRtl;
    }
  }
  runs.add(_TextRun(currentIsRtl, text.substring(start)));
  
  // 5. Process and reshape runs
  final List<String> processedRuns = [];
  for (final run in runs) {
    if (!run.isRtl) {
      processedRuns.add(run.text);
    } else {
      // Shape Arabic text first
      final shaped = shapeArabic(run.text);
      // Reverse character sequence and mirror brackets/parentheses
      final List<int> reversedCodes = [];
      for (int idx = shaped.length - 1; idx >= 0; idx--) {
        int code = shaped.codeUnitAt(idx);
        // Mirror brackets & parentheses
        if (code == 0x0028) { // '('
          code = 0x0029; // ')'
        } else if (code == 0x0029) { // ')'
          code = 0x0028; // '('
        } else if (code == 0x005B) { // '['
          code = 0x005D; // ']'
        } else if (code == 0x005D) { // ']'
          code = 0x005B; // '['
        } else if (code == 0x007B) { // '{'
          code = 0x007D; // '}'
        } else if (code == 0x007D) { // '}'
          code = 0x007B; // '{'
        } else if (code == 0x003C) { // '<'
          code = 0x003E; // '>'
        } else if (code == 0x003E) { // '>'
          code = 0x003C; // '<'
        }
        reversedCodes.add(code);
      }
      processedRuns.add(String.fromCharCodes(reversedCodes));
    }
  }
  
  // 6. Concatenate runs in reverse order of segment list
  return processedRuns.reversed.join('');
}