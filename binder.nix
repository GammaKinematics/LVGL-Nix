# LVGL Odin Bindings Generator
# Parses LVGL headers and generates Odin foreign import code
# All parsers use line-based approaches for safety on large files
{ pkgs ? import <nixpkgs> {}, lvglSrc }:
let
  lib = pkgs.lib;
  bindings = import ./bindings.nix { inherit lvglSrc; };

  # Read a header file from LVGL source and split into lines
  readHeader = header: builtins.readFile (lvglSrc + "/${header}");

  # Get lines from header (filtered to strings only)
  getLines = header:
    builtins.filter builtins.isString (builtins.split "\n" (readHeader header));

  # =============================================================================
  # String utilities
  # =============================================================================

  # Trim whitespace from both ends
  trim = lib.strings.trim;

  # Check if string contains substring (simple, no regex on large strings)
  contains = needle: haystack:
    builtins.match ".*${needle}.*" haystack != null;

  # Replace all occurrences
  replace = from: to: str:
    builtins.replaceStrings [from] [to] str;

  # =============================================================================
  # C to Odin expression conversion
  # =============================================================================

  # Convert C expression to Odin expression
  convertExpr = expr:
    let
      # Remove 'u' and 'U' suffixes from integer literals
      noSuffix = builtins.replaceStrings
        ["0u" "1u" "2u" "3u" "4u" "5u" "6u" "7u" "8u" "9u"
         "0U" "1U" "2U" "3U" "4U" "5U" "6U" "7U" "8U" "9U"]
        ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
         "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]
        expr;
      # Remove 'L' suffix
      noL = builtins.replaceStrings ["0L" "1L" "2L" "3L" "4L" "5L" "6L" "7L" "8L" "9L"]
                                    ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"] noSuffix;
    in trim noL;

  # =============================================================================
  # Type mapping
  # =============================================================================

  # Map C type to Odin type
  mapType = ctype:
    let
      cleaned = trim ctype;
      # Check for pointer
      isPointer = lib.hasSuffix "*" cleaned || contains "\\*" cleaned;
      # Check for const pointer (const char *, etc)
      isConstPointer = lib.hasPrefix "const " cleaned && isPointer;

      # Try direct lookup first
      direct = bindings.typeMap.${cleaned} or null;

      # Handle pointers
      baseType =
        if isConstPointer then
          let base = trim (builtins.replaceStrings ["const " "*"] ["" ""] cleaned);
          in bindings.typeMap."const ${base} *" or bindings.typeMap."${base} *" or null
        else if isPointer then
          let base = trim (replace "*" "" cleaned);
          in if bindings.typeMap ? "${base} *" then bindings.typeMap."${base} *"
             else if bindings.typeMap ? base then "^${bindings.typeMap.${base}}"
             else "^${base}"
        else null;
    in
      if direct != null then direct
      else if baseType != null then baseType
      else if isPointer then
        let base = trim (replace "*" "" (replace "const " "" cleaned));
        in "^${base}"
      else cleaned;

  # =============================================================================
  # Enum parsing (line-based)
  # =============================================================================

  # Parse an enum from header content
  parseEnum = { name, header }:
    let
      lines = getLines header;

      # Find line indices for enum boundaries
      # Look for "typedef enum {" or "typedef enum NAME {" before, and "} name;" after
      findEnumBounds = lines:
        let
          indexed = lib.imap0 (i: l: { inherit i; line = l; }) lines;
          # Find closing line "} name;"
          closingLines = builtins.filter (x: builtins.match "^[}] *${name} *;.*" (trim x.line) != null) indexed;
          closingIdx = if builtins.length closingLines >= 1 then (builtins.elemAt closingLines 0).i else -1;
          # Find opening line "typedef enum {" before closing
          beforeClosing = builtins.filter (x: x.i < closingIdx) indexed;
          openingLines = builtins.filter (x: builtins.match ".*typedef +enum.*[{].*" x.line != null) beforeClosing;
          openingIdx = if builtins.length openingLines >= 1
                       then (builtins.elemAt openingLines (builtins.length openingLines - 1)).i
                       else -1;
        in { start = openingIdx + 1; end = closingIdx; };

      bounds = findEnumBounds lines;

      # Error if enum not found
      check = if bounds.start < 0 || bounds.end <= bounds.start
              then throw "binder.nix: enum '${name}' not found in ${header}"
              else true;

      # Extract enum body lines (seq forces check evaluation)
      enumLines = builtins.seq check (lib.sublist bounds.start (bounds.end - bounds.start) lines);

      # Join lines and strip multi-line comments first, then re-split
      enumBodyRaw = lib.concatStringsSep "\n" enumLines;
      # Remove /* ... */ comments (including multi-line) - replace with empty
      stripMultiLineComments = str:
        let
          parts = builtins.split "/\\*[^*]*\\*+([^/*][^*]*\\*+)*/" str;
          strings = builtins.filter builtins.isString parts;
        in lib.concatStrings strings;
      enumBodyClean = stripMultiLineComments enumBodyRaw;
      cleanedLines = builtins.filter builtins.isString (builtins.split "\n" enumBodyClean);

      # Filter out comments and empty lines
      validLines = builtins.filter (l:
        let t = trim l; in
        t != "" &&
        !(lib.hasPrefix "//" t) &&
        !(lib.hasPrefix "*" t) &&
        !(lib.hasPrefix "#" t)
      ) cleanedLines;

      # Parse each enum member
      parseEnumMember = line:
        let
          # Remove line comments
          noComment = builtins.elemAt (builtins.split "//.*" line) 0;
          clean = trim (if builtins.isString noComment then noComment else "");
          # Remove trailing comma
          noComma = if lib.hasSuffix "," clean then builtins.substring 0 (builtins.stringLength clean - 1) clean else clean;

          # Split by '='
          parts = builtins.split " *= *" noComma;
          filtered = builtins.filter builtins.isString parts;

          memberName = if builtins.length filtered >= 1 then trim (builtins.elemAt filtered 0) else "";
          memberValue = if builtins.length filtered >= 2 then convertExpr (builtins.elemAt filtered 1) else null;
        in
          if memberName == "" || lib.hasPrefix "#" memberName then null
          else { name = memberName; value = memberValue; };

      members = builtins.filter (x: x != null) (map parseEnumMember validLines);

      # Generate Odin enum
      genMember = m:
        if m.value != null then "    ${m.name} = ${m.value},"
        else "    ${m.name},";

    in ''
${name} :: enum i32 {
${lib.concatStringsSep "\n" (map genMember members)}
}'';

  # =============================================================================
  # Struct parsing (line-based)
  # =============================================================================

  # Parse a struct from header content
  parseStruct = { name, header }:
    let
      lines = getLines header;

      # Find line indices for struct boundaries
      findStructBounds = lines:
        let
          indexed = lib.imap0 (i: l: { inherit i; line = l; }) lines;
          # Find closing line "} name;"
          closingLines = builtins.filter (x: builtins.match "^[}] *${name} *;.*" (trim x.line) != null) indexed;
          closingIdx = if builtins.length closingLines >= 1 then (builtins.elemAt closingLines 0).i else -1;
          # Find opening line "typedef struct {" before closing
          beforeClosing = builtins.filter (x: x.i < closingIdx) indexed;
          openingLines = builtins.filter (x: builtins.match ".*typedef +struct.*[{].*" x.line != null) beforeClosing;
          openingIdx = if builtins.length openingLines >= 1
                       then (builtins.elemAt openingLines (builtins.length openingLines - 1)).i
                       else -1;
        in { start = openingIdx + 1; end = closingIdx; };

      bounds = findStructBounds lines;

      # Error if struct not found
      check = if bounds.start < 0 || bounds.end <= bounds.start
              then throw "binder.nix: struct '${name}' not found in ${header}"
              else true;

      # Extract struct body lines (seq forces check evaluation)
      structLines = builtins.seq check (lib.sublist bounds.start (bounds.end - bounds.start) lines);

      # Filter out comments and empty lines
      validLines = builtins.filter (l:
        let t = trim l; in
        t != "" &&
        !(lib.hasPrefix "/*" t) &&
        !(lib.hasPrefix "//" t) &&
        !(lib.hasPrefix "*" t) &&
        !(lib.hasPrefix "#" t)
      ) structLines;

      # Parse each field
      parseField = line:
        let
          # Remove inline comments
          noComment = builtins.elemAt (builtins.split "/\\*.*\\*/" line) 0;
          clean = trim (if builtins.isString noComment then noComment else line);
          # Remove trailing semicolon
          noSemi = if lib.hasSuffix ";" clean then builtins.substring 0 (builtins.stringLength clean - 1) clean else clean;
          trimmed = trim noSemi;

          # Handle bit fields like "uint16_t blue : 5"
          noBitfield = builtins.elemAt (builtins.split " *:" trimmed) 0;
          finalClean = trim (if builtins.isString noBitfield then noBitfield else trimmed);

          # Split into type and name
          parts = builtins.filter (x: x != "" && builtins.isString x) (builtins.split " +" finalClean);
          numParts = builtins.length parts;

          fieldName = if numParts >= 1 then builtins.elemAt parts (numParts - 1) else "";
          fieldType = if numParts >= 2
                      then lib.concatStringsSep " " (lib.take (numParts - 1) parts)
                      else "";
        in
          if fieldName == "" || fieldType == "" || lib.hasPrefix "#" finalClean then null
          else { name = fieldName; type = mapType fieldType; };

      fields = builtins.filter (x: x != null) (map parseField validLines);

      # Generate Odin struct
      genField = f: "    ${f.name}: ${f.type},";

    in ''
${name} :: struct #packed {
${lib.concatStringsSep "\n" (map genField fields)}
}'';

  # =============================================================================
  # Typedef parsing (line-based)
  # =============================================================================

  parseTypedef = { name, header }:
    let
      lines = getLines header;

      # Find line containing "typedef X name;"
      matchingLines = builtins.filter (l:
        builtins.match ".*typedef +.+ +${name} *;.*" l != null
      ) lines;

      # Error if typedef not found
      check = if builtins.length matchingLines < 1
              then throw "binder.nix: typedef '${name}' not found in ${header}"
              else true;

      declLine = builtins.seq check (trim (builtins.elemAt matchingLines 0));

      # Parse just this line
      match = builtins.match ".*typedef +([^;]+) +${name} *;.*" declLine;
      baseType = if match != null then trim (builtins.elemAt match 0) else "unknown";
      odinType = mapType baseType;
    in "${name} :: ${odinType}";

  # =============================================================================
  # Macro parsing (line-based)
  # =============================================================================

  parseMacros = { pattern, header }:
    let
      lines = getLines header;

      # Check if line matches #define PATTERN VALUE
      parseLine = line:
        let
          trimmed = trim line;
          # Check if it's a #define
          isDefine = lib.hasPrefix "#define " trimmed;
          # Extract name and value
          match = builtins.match "#define +([A-Z_][A-Z0-9_]*) +(.*)" trimmed;
          macroName = if match != null then builtins.elemAt match 0 else "";
          macroValue = if match != null then trim (builtins.elemAt match 1) else "";
          # Check if name matches pattern
          nameMatches = builtins.match pattern macroName != null;
        in
          if isDefine && match != null && nameMatches && macroValue != ""
          then { name = macroName; value = macroValue; }
          else null;

      macros = builtins.filter (x: x != null) (map parseLine lines);

      # Generate Odin constant - detect if string or expression
      genMacro = m:
        if lib.hasPrefix "\"" m.value then "${m.name} :: ${m.value}"
        else "${m.name} :: ${convertExpr m.value}";

    in lib.concatStringsSep "\n" (map genMacro macros);

  # =============================================================================
  # Function parsing (line-based, handles multi-line declarations)
  # =============================================================================

  parseFunction = { name, header }:
    let
      lines = getLines header;
      indexedLines = lib.imap0 (i: l: { inherit i; line = l; }) lines;

      # Find lines containing the function declaration start
      # Look for "name(" pattern, excluding comments
      matchingLines = builtins.filter (x:
        let t = trim x.line; in
        builtins.match ".*${name} *[(].*" t != null &&
        !(lib.hasPrefix "//" t) &&
        !(lib.hasPrefix "*" t) &&
        !(lib.hasPrefix "/*" t)
      ) indexedLines;

      # Error if function not found
      checkFound = if builtins.length matchingLines < 1
                   then throw "binder.nix: function '${name}' not found in ${header}"
                   else true;

      startIdx = builtins.seq checkFound (builtins.elemAt matchingLines 0).i;

      # Collect lines until we find ");" (handles multi-line declarations)
      collectDecl = idx: acc:
        if idx >= builtins.length lines then acc
        else
          let
            currentLine = builtins.elemAt lines idx;
            newAcc = acc + " " + currentLine;
          in
            # Check if we have the complete declaration (ends with ; after closing paren)
            if builtins.match ".*[)];.*" newAcc != null then newAcc
            else if idx > startIdx + 5 then acc  # Safety limit: max 5 continuation lines
            else collectDecl (idx + 1) newAcc;

      # Get full declaration (possibly spanning multiple lines)
      fullDecl = trim (collectDecl startIdx "");

      # Normalize spaces in the declaration
      normalizedDecl = builtins.replaceStrings ["  " "\t"] [" " " "] fullDecl;

      # Parse the full declaration
      match = builtins.match "([a-zA-Z_][a-zA-Z0-9_* ]*) +${name} *[(]([^)]*)[)] *;?" normalizedDecl;

      # Error if we couldn't parse the declaration
      checkParse = if match == null
                   then throw "binder.nix: could not parse function '${name}' in ${header}. Declaration: ${normalizedDecl}"
                   else true;

      retTypeRaw = builtins.seq checkParse (trim (builtins.elemAt match 0));
      argsRaw = builtins.elemAt match 1;

      # Clean return type - remove attributes like LV_ATTRIBUTE_*
      retType =
        let
          cleaned = builtins.replaceStrings
            ["LV_ATTRIBUTE_TIMER_HANDLER " "LV_ATTRIBUTE_TICK_INC " "LV_ATTRIBUTE_FAST_MEM " "static inline "]
            ["" "" "" ""]
            retTypeRaw;
        in mapType (trim cleaned);

      # Parse arguments
      argList = if trim argsRaw == "void" || trim argsRaw == "" then []
                else builtins.filter (x: x != "" && builtins.isString x) (builtins.split " *, *" argsRaw);

      parseArg = arg:
        let
          trimmed = trim arg;
          # Split into type and name
          parts = builtins.filter (x: x != "" && builtins.isString x) (builtins.split " +" trimmed);
          numParts = builtins.length parts;
          # Last part is name (might have * prefix for pointers)
          rawName = if numParts >= 1 then builtins.elemAt parts (numParts - 1) else "";
          argName = builtins.replaceStrings ["*"] [""] rawName;
          # Everything else is type, plus any * from name
          typeBase = if numParts >= 2 then lib.concatStringsSep " " (lib.take (numParts - 1) parts) else "";
          hasPointerInName = lib.hasPrefix "*" rawName;
          argType = if hasPointerInName then typeBase + " *" else typeBase;
        in
          if argName == "" then null
          else { name = argName; type = mapType argType; };

      args = builtins.filter (x: x != null) (map parseArg argList);

      # Generate Odin function
      genArg = a: "${a.name}: ${a.type}";
      argsStr = lib.concatStringsSep ", " (map genArg args);
      retStr = if retType == "void" || retType == "" then "" else " -> ${retType}";

    in "    ${name} :: proc(${argsStr})${retStr} ---";

  # =============================================================================
  # Generate sections
  # =============================================================================

  # Opaque types
  genOpaqueTypes = types:
    lib.concatMapStringsSep "\n" (t: "${t} :: struct {}") types;

  # Typedefs
  genTypedefs = typedefs:
    lib.concatMapStringsSep "\n" parseTypedef typedefs;

  # Enums
  genEnums = enums:
    lib.concatStringsSep "\n\n" (map parseEnum enums);

  # Structs
  genStructs = structs:
    lib.concatStringsSep "\n\n" (map parseStruct structs);

  # Macros
  genMacros = macros:
    lib.concatStringsSep "\n\n" (map parseMacros macros);

  # Functions
  genFunctions = functions:
    lib.concatStringsSep "\n" (map parseFunction functions);

  # Aliases
  genAliases = aliases:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: type: "${name} :: ${type};") aliases);

  # =============================================================================
  # Final output
  # =============================================================================

  odinSource = ''
// LVGL Odin Bindings
// Auto-generated by LVGL-Nix/binder.nix
// Do not edit manually

package lvgl

// === Opaque Types ===
${genOpaqueTypes bindings.opaqueTypes}

// === Typedefs ===
${genTypedefs bindings.typedefs}

// === Macros ===
${genMacros bindings.macros}

// === Enums ===
${genEnums bindings.enums}

// === Structs ===
${genStructs bindings.structs}

// === Type Aliases ===
${genAliases bindings.aliases}

// === Foreign Functions ===
@(default_calling_convention = "c")
foreign {
${genFunctions bindings.functions}
}

${bindings.manual}
'';

in pkgs.writeText "lvgl.odin" odinSource
