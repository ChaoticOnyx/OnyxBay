import { Component, createVNode } from "inferno";
import * as monaco from "monaco-editor";
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { acquireHotKey, releaseHotKey, releaseHeldKeys } from "../hotkeys";

const BASIC26_LANGUAGE_ID = "basic26";

const basic26Language: monaco.languages.IMonarchLanguage = {
  defaultToken: "",
  tokenPostfix: ".basic26",

  keywords: ["IF", "ELSEIF", "ELSE", "ENDIF", "WHILE", "ENDWHILE", "GOTO"],

  keywordOperators: ["AND", "OR", "NOT"],

  preprocessor: [
    "#include",
    "#define",
    "#ifdef",
    "#ifndef",
    "#undef",
    "#endif",
    "#else",
  ],

  constants: ["NULL", "NAN", "INF"],

  operators: [
    "==",
    "!=",
    "<=",
    ">=",
    "<<",
    ">>",
    "<",
    ">",
    "+",
    "-",
    "*",
    "/",
    "%",
    "&",
    "|",
    "^",
    "~",
    "=",
  ],

  symbols: /[=><!~&|^+\-*/%]+/,

  number: /-?\d+\.\d*|-?\d+/,

  escapes:
    /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

  tokenizer: {
    root: [
      [
        /#\w+/,
        {
          cases: {
            "@preprocessor": "keyword.preprocessor",
            "@default": "identifier",
          },
        },
      ],

      [/\/\/.*$/, "comment"],

      [/\$[a-zA-Z_]\w*/, "variable.predefined"],

      [/@[a-zA-Z_]\w*/, "tag.address"],

      [/"/, "string", "@stringLiteral"],

      [/[a-zA-Z_]\w*(?=\s*:)/, "tag"],

      [
        /[a-zA-Z_]\w*/,
        {
          cases: {
            "@keywords": "keyword",
            "@keywordOperators": "keyword.operator",
            "@constants": "constant.language",
            "@default": "identifier",
          },
        },
      ],

      [/\d+\.\d*/, "number.float"],
      [/\d+/, "number"],

      [/==/, "operator"],
      [/!=/, "operator"],
      [/<=/, "operator"],
      [/>=/, "operator"],
      [/<</, "operator"],
      [/>>/, "operator"],
      [/[<>=+\-*/%&|^~]/, "operator"],

      [/[()]/, "delimiter.parenthesis"],
      [/,/, "delimiter.comma"],
      [/:/, "delimiter.colon"],
    ],

    stringLiteral: [
      [/[^\\"]+/, "string"],
      [/@escapes/, "string.escape"],
      [/\\./, "string.escape.invalid"],
      [/"/, "string", "@pop"],
    ],
  },
};

const basic26LanguageConfiguration: monaco.languages.LanguageConfiguration = {
  comments: {
    lineComment: "//",
  },

  brackets: [["(", ")"]],

  autoClosingPairs: [
    { open: '"', close: '"', notIn: ["string", "comment"] },
    { open: "(", close: ")", notIn: ["string", "comment"] },
  ],

  surroundingPairs: [
    { open: '"', close: '"' },
    { open: "(", close: ")" },
  ],

  indentationRules: {
    increaseIndentPattern: /^\s*(IF|WHILE|ELSE)\b.*$/i,
    decreaseIndentPattern: /^\s*(ENDIF|ENDWHILE|ELSE)\b.*$/i,
  },

  folding: {
    markers: {
      start: /^\s*(IF|WHILE|#ifdef|#ifndef)\b/i,
      end: /^\s*(ENDIF|ENDWHILE|#endif)\b/i,
    },
  },

  wordPattern: /(-?\d*\.\d\w*)|([#$@a-zA-Z_]\w*)/,
};

interface FunctionArg {
  name: string;
  type: string;
  doc?: string;
}

interface FunctionDef {
  name: string;
  args: FunctionArg[];
  returnType: string;
  doc: string;
}

interface VariableDef {
  name: string;
  type: string;
  doc: string;
}

interface DefineDef {
  name: string;
  value: string;
}

interface IncludeFile {
  name: string;
  doc: string;
  functions: FunctionDef[];
  variables: VariableDef[];
  defines: DefineDef[];
}

interface DeclarationsData {
  functions: FunctionDef[];
  variables: VariableDef[];
  files: IncludeFile[];
  defines: DefineDef[];
}

const declarationsStore: { current: DeclarationsData } = {
  current: {
    functions: [],
    variables: [],
    files: [],
    defines: [],
  },
};

interface SourceMap {
  outputLineStarts: number[];
}

const sourceMapStore: { current: SourceMap | null } = {
  current: null,
};

const BUILTIN_KEYWORDS: FunctionDef[] = [
  {
    name: "IF",
    args: [{ name: "condition", type: "int" }],
    returnType: "void",
    doc: "Begin a conditional block.\n\nIf `condition` is non-zero (truthy), the block between IF and the next ELSEIF, ELSE, or ENDIF is executed. Multiple conditions can be chained using ELSEIF or ELSE IF.",
  },
  {
    name: "ELSEIF",
    args: [{ name: "condition", type: "int" }],
    returnType: "void",
    doc: "An else-if branch of an IF block.\n\nCan also be written as two words: `ELSE IF`. The block executes if all previous IF/ELSEIF conditions were false (zero), and this `condition` is non-zero (truthy). Multiple ELSEIF branches can be chained.",
  },
  {
    name: "ELSE",
    args: [],
    returnType: "void",
    doc: "Else branch of an IF block.\n\nThe block between ELSE and ENDIF executes when all previous IF and ELSEIF conditions were false (zero). Can also be followed by IF to form an `ELSE IF` branch.",
  },
  {
    name: "ENDIF",
    args: [],
    returnType: "void",
    doc: "End of an IF/ELSEIF/ELSE conditional block.\n\nOnly a single ENDIF is required to close the entire chain, regardless of how many ELSEIF or ELSE branches are used.",
  },
  {
    name: "WHILE",
    args: [{ name: "condition", type: "int" }],
    returnType: "void",
    doc: "Begin a while loop.\n\nThe loop body repeats as long as `condition` is non-zero. The condition is evaluated before each iteration.",
  },
  {
    name: "ENDWHILE",
    args: [],
    returnType: "void",
    doc: "End of a WHILE loop block.",
  },
  {
    name: "GOTO",
    args: [{ name: "label", type: "string" }],
    returnType: "void",
    doc: "Unconditionally jump to a label.\n\nThe label must be defined in the same script using `name:` syntax.",
  },
  {
    name: "AND",
    args: [
      { name: "lhs", type: "int" },
      { name: "rhs", type: "int" },
    ],
    returnType: "int",
    doc: "Logical AND.\n\nReturns 1 if both operands are non-zero, otherwise 0.",
  },
  {
    name: "OR",
    args: [
      { name: "lhs", type: "int" },
      { name: "rhs", type: "int" },
    ],
    returnType: "int",
    doc: "Logical OR.\n\nReturns 1 if either operand is non-zero, otherwise 0.",
  },
  {
    name: "NOT",
    args: [{ name: "value", type: "int" }],
    returnType: "int",
    doc: "Logical NOT.\n\nReturns 1 if value is 0, otherwise 0.",
  },
];

let registered = false;

// All keycodes that keyCodeToByond() in hotkeys.ts can translate
// to BYOND key names - these are the ones that leak to the game.
const KEYCODES_TO_ACQUIRE: number[] = (() => {
  const codes: number[] = [];

  const addRange = (from: number, to: number) => {
    for (let i = from; i <= to; i++) {
      codes.push(i);
    }
  };

  addRange(8, 9); // Backspace, Tab
  addRange(13, 13); // Enter
  addRange(16, 18); // Shift, Ctrl, Alt
  addRange(19, 20); // Pause, CapsLock
  addRange(27, 27); // Escape
  addRange(32, 32); // Space
  addRange(33, 36); // PgUp, PgDn, End, Home
  addRange(37, 40); // Arrow keys
  addRange(45, 46); // Insert, Delete
  addRange(48, 57); // 0-9
  addRange(65, 90); // A-Z
  addRange(96, 105); // Numpad 0-9
  addRange(112, 123); // F1-F12
  addRange(186, 192); // ; = , - . / `
  addRange(219, 222); // [ \ ] '

  return codes;
})();

function formatSignature(fn: FunctionDef): string {
  const args = fn.args.map((a) => `${a.name}: ${a.type}`).join(", ");

  return `${fn.name}(${args}): ${fn.returnType}`;
}

function formatFunctionDoc(fn: FunctionDef): string {
  const sig = `**${fn.name}**(${fn.args.map((a) => `*${a.name}*: \`${a.type}\`${a.doc ? " - " + a.doc : ""}`).join(", ")}): \`${fn.returnType}\``;

  return `${sig}\n\n${fn.doc}`;
}

function formatVariableDoc(v: VariableDef): string {
  return `**${v.name}**: \`${v.type}\`\n\n${v.doc}`;
}

interface PreprocessResult {
  code: string;
  includedFiles: string[];
  sourceMap: SourceMap;
}

function splitLineSegments(text: string): { text: string; expand: boolean }[] {
  const segments: { text: string; expand: boolean }[] = [];
  let current = "";
  let inString = false;
  let i = 0;

  while (i < text.length) {
    const ch = text[i];

    if (!inString) {
      if (ch === '"') {
        if (current) {
          segments.push({ text: current, expand: true });
          current = "";
        }
        current = '"';
        inString = true;
      } else if (ch === "/" && i + 1 < text.length && text[i + 1] === "/") {
        if (current) {
          segments.push({ text: current, expand: true });
          current = "";
        }
        segments.push({ text: text.substring(i), expand: false });
        return segments;
      } else {
        current += ch;
      }
    } else {
      current += ch;
      if (ch === "\\" && i + 1 < text.length) {
        i++;
        current += text[i];
      } else if (ch === '"') {
        segments.push({ text: current, expand: false });
        current = "";
        inString = false;
      }
    }
    i++;
  }

  if (current) {
    segments.push({ text: current, expand: !inString });
  }

  return segments;
}

function expandMacros(
  text: string,
  defines: Map<string, string | null>,
): string {
  if (defines.size === 0) {
    return text;
  }

  for (let pass = 0; pass < 8; pass++) {
    const segments = splitLineSegments(text);
    let anyChange = false;

    for (const seg of segments) {
      if (!seg.expand) {
        continue;
      }

      for (const [key, value] of defines) {
        if (value === null) {
          continue;
        }

        const escapedKey = key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        const regex = new RegExp(`\\b${escapedKey}\\b`, "g");

        const newText = seg.text.replace(regex, value);

        if (newText !== seg.text) {
          seg.text = newText;
          anyChange = true;
        }
      }
    }

    if (!anyChange) {
      break;
    }

    text = segments.map((s) => s.text).join("");
  }

  return text;
}

function preprocess(rawCode: string): PreprocessResult {
  const lines = rawCode.split("\n");
  const outputLines: string[] = [];
  const defines = new Map<string, string | null>();
  const includedFiles = new Set<string>();
  const activeStack = [true];
  const outputLineStarts: number[] = [];

  const declarations = declarationsStore.current;

  const addFileDefines = (fileName: string) => {
    const file = declarations.files.find((f) => f.name === fileName);

    if (file) {
      for (const d of file.defines) {
        defines.set(d.name, d.value);
      }
    }
  };

  const isActive = () => activeStack[activeStack.length - 1];

  let outputOffset = 0;

  for (let lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    const line = lines[lineIdx];
    const trimmed = line.trim();

    outputLineStarts.push(outputOffset);

    if (trimmed.startsWith("#")) {
      const parts = trimmed.split(/\s+/);
      const directive = parts[0];

      switch (directive) {
        case "#include": {
          if (isActive()) {
            const match = trimmed.match(/^#include\s+"([^"]+)"\s*$/);

            if (match) {
              includedFiles.add(match[1]);
              addFileDefines(match[1]);
            }
          }

          break;
        }
        case "#define": {
          if (isActive()) {
            const defineMatch = trimmed.match(/^#define\s+(\S+)(?:\s+(.+))?/);

            if (defineMatch) {
              defines.set(defineMatch[1], defineMatch[2] || null);
            }
          }

          break;
        }
        case "#undef": {
          if (isActive()) {
            const name = parts[1];

            if (name) {
              defines.delete(name);
            }
          }

          break;
        }
        case "#ifdef": {
          const name = parts[1];
          activeStack.push(isActive() && defines.has(name || ""));

          break;
        }
        case "#ifndef": {
          const name = parts[1];
          activeStack.push(isActive() && !defines.has(name || ""));

          break;
        }
        case "#else": {
          if (activeStack.length > 1) {
            const parentActive = activeStack[activeStack.length - 2];
            const currentActive = activeStack[activeStack.length - 1];

            activeStack[activeStack.length - 1] =
              parentActive && !currentActive;
          }

          break;
        }
        case "#endif": {
          if (activeStack.length > 1) {
            activeStack.pop();
          }

          break;
        }
        default: {
          // Unknown directive — space-pad
          break;
        }
      }

      // Space-pad directive lines to preserve line count and positions
      const padded = " ".repeat(line.length);

      outputLines.push(padded);
      outputOffset += padded.length + 1;
    } else {
      if (isActive()) {
        const expanded = expandMacros(line, defines);

        outputLines.push(expanded);
        outputOffset += expanded.length + 1;
      } else {
        // Space-pad inactive lines to preserve line count and positions
        const padded = " ".repeat(line.length);

        outputLines.push(padded);
        outputOffset += padded.length + 1;
      }
    }
  }

  return {
    code: outputLines.join("\n"),
    includedFiles: Array.from(includedFiles),
    sourceMap: { outputLineStarts },
  };
}

function translateErrorPosition(
  pos: number,
  sourceMap: SourceMap,
): { lineNumber: number; column: number } {
  const starts = sourceMap.outputLineStarts;

  if (starts.length === 0) {
    return { lineNumber: 1, column: 1 };
  }

  // Binary search for the line containing pos
  let lo = 0;
  let hi = starts.length - 1;

  while (lo < hi) {
    const mid = (lo + hi + 1) >> 1;

    if (starts[mid] <= pos) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }

  const lineIdx = lo;
  const columnInOutput = pos - starts[lineIdx];

  // Line number is preserved (1-based), column is approximate for macro-expanded lines
  return {
    lineNumber: lineIdx + 1,
    column: columnInOutput + 1,
  };
}

function getIncludedFiles(model: monaco.editor.ITextModel): Set<string> {
  const included = new Set<string>();
  const lineCount = model.getLineCount();

  for (let i = 1; i <= lineCount; i++) {
    const line = model.getLineContent(i).trim();
    const match = line.match(/^#include\s+"([^"]+)"\s*$/);

    if (match) {
      included.add(match[1]);
    }
  }

  return included;
}

type CompileError = {
  message: string;
  pos: number;
};

type RuntimeError = {
  message: string;
  pos: number;
};

type EditorProps = {
  onEditorMount?: (editor: monaco.editor.IStandaloneCodeEditor) => void;
  compileErrors: CompileError[];
  runtimeErrors: RuntimeError[];
  declarations?: DeclarationsData;
};

type EditorState = {};

const STORAGE_KEY = "onyxbay_script_code";
const SAVE_DEBOUNCE_MS = 250;

class Editor extends Component<EditorProps, EditorState> {
  private containerRef: HTMLElement | null = null;
  private editor: monaco.editor.IStandaloneCodeEditor | null = null;
  private keysAcquired = false;
  private saveTimeout: number | null = null;

  constructor(props: EditorProps, context: any) {
    super(props, context);
  }

  private setRef = (el: HTMLElement | null) => {
    this.containerRef = el;
  };

  private acquireAllKeys() {
    if (this.keysAcquired) {
      return;
    }

    this.keysAcquired = true;

    for (const code of KEYCODES_TO_ACQUIRE) {
      acquireHotKey(code);
    }

    releaseHeldKeys();
  }

  private releaseAllKeys() {
    if (!this.keysAcquired) {
      return;
    }

    this.keysAcquired = false;

    for (const code of KEYCODES_TO_ACQUIRE) {
      releaseHotKey(code);
    }
  }

  private registerBASIC26Language(): void {
    if (registered) {
      return;
    }

    registered = true;

    monaco.languages.register({ id: BASIC26_LANGUAGE_ID });
    monaco.languages.setMonarchTokensProvider(
      BASIC26_LANGUAGE_ID,
      basic26Language,
    );

    monaco.languages.setLanguageConfiguration(
      BASIC26_LANGUAGE_ID,
      basic26LanguageConfiguration,
    );

    monaco.languages.registerCompletionItemProvider(
      BASIC26_LANGUAGE_ID,
      createCompletionItemProvider(),
    );

    monaco.languages.registerHoverProvider(
      BASIC26_LANGUAGE_ID,
      createHoverProvider(),
    );
  }

  componentDidMount() {
    const container = this.containerRef;

    if (!container) {
      return;
    }

    if (this.props.declarations) {
      declarationsStore.current = this.props.declarations;
    }

    this.registerBASIC26Language();

    const savedCode =
      localStorage.getItem(STORAGE_KEY) || 'PRINTF "Hello, world!"';

    this.editor = monaco.editor.create(container, {
      value: savedCode,
      language: BASIC26_LANGUAGE_ID,
      insertSpaces: false,
      theme: "vs-dark",
      fontSize: 12,
      fontFamily:
        "'JetBrains Mono', 'Fira Code', 'Cascadia Code', 'Consolas', monospace",
      fontLigatures: false,
      letterSpacing: 0.3,
      minimap: {
        enabled: false,
      },
      scrollBeyondLastLine: true,
      smoothScrolling: true,
      cursorBlinking: "smooth",
      cursorSmoothCaretAnimation: "on",
      renderLineHighlight: "all",
      renderWhitespace: "boundary",
      padding: {
        top: 8,
        bottom: 8,
      },
      automaticLayout: true,
      wordWrap: "off",
      tabSize: 4,
      formatOnPaste: true,
      scrollbar: {
        verticalScrollbarSize: 10,
        horizontalScrollbarSize: 10,
      },
      suggest: {
        showKeywords: true,
        showSnippets: true,
        showFunctions: true,
        showVariables: true,
        showConstants: true,
        showFiles: true,
      },
      quickSuggestions: {
        other: true,
        comments: false,
        strings: true,
      },
    });

    this.editor.onDidFocusEditorWidget(() => {
      this.acquireAllKeys();
    });

    this.editor.onDidBlurEditorWidget(() => {
      this.releaseAllKeys();
    });

    this.editor.onDidChangeModelContent(() => {
      sourceMapStore.current = null;

      if (this.saveTimeout) {
        clearTimeout(this.saveTimeout);
      }

      this.saveTimeout = window.setTimeout(() => {
        const code = this.editor?.getValue();

        if (code !== undefined) {
          localStorage.setItem(STORAGE_KEY, code);
        }
      }, SAVE_DEBOUNCE_MS);
    });

    window.addEventListener("resize", this.handleResize);

    if (this.props.onEditorMount) {
      this.props.onEditorMount(this.editor);
    }
  }

  componentWillUnmount() {
    sourceMapStore.current = null;

    if (this.saveTimeout) {
      clearTimeout(this.saveTimeout);
      this.saveTimeout = null;
    }

    this.releaseAllKeys();
    window.removeEventListener("resize", this.handleResize);

    const model = this.editor?.getModel();

    if (model) {
      monaco.editor.setModelMarkers(model, BASIC26_LANGUAGE_ID, []);
    }

    if (this.editor) {
      this.editor.dispose();
      this.editor = null;
    }
  }

  componentDidUpdate(prevProps: EditorProps) {
    if (
      this.props.compileErrors !== prevProps.compileErrors ||
      this.props.runtimeErrors !== prevProps.runtimeErrors
    ) {
      this.updateMarkers();
    }

    if (
      this.props.declarations &&
      this.props.declarations !== prevProps.declarations
    ) {
      declarationsStore.current = this.props.declarations;
    }
  }

  private updateMarkers() {
    if (!this.editor) {
      return;
    }

    const model = this.editor.getModel();

    if (!model) {
      return;
    }

    const sourceMap = sourceMapStore.current;

    const translatePos = (
      pos: number,
    ): { lineNumber: number; column: number } => {
      if (sourceMap) {
        return translateErrorPosition(pos, sourceMap);
      }

      const p = model!.getPositionAt(pos);
      return { lineNumber: p.lineNumber, column: p.column };
    };

    const error_markers: monaco.editor.IMarkerData[] = [];

    for (const error of this.props.compileErrors) {
      const { lineNumber, column } = translatePos(error.pos);

      error_markers.push({
        severity: monaco.MarkerSeverity.Error,
        message: error.message,
        startLineNumber: lineNumber,
        startColumn: column,
        endLineNumber: lineNumber,
        endColumn: column + 1,
      });
    }

    for (const error of this.props.runtimeErrors) {
      const { lineNumber, column } = translatePos(error.pos);

      error_markers.push({
        severity: monaco.MarkerSeverity.Error,
        message: error.message,
        startLineNumber: lineNumber,
        startColumn: column,
        endLineNumber: lineNumber,
        endColumn: column + 1,
      });
    }

    monaco.editor.setModelMarkers(model, BASIC26_LANGUAGE_ID, error_markers);
  }

  private handleResize = () => {
    this.editor?.layout();
  };

  render() {
    return createVNode(
      1,
      "div",
      "script-editor-container",
      null,
      1,
      null,
      null,
      this.setRef,
    );
  }
}

function findLabelsInModel(model: monaco.editor.ITextModel): string[] {
  const labels: string[] = [];
  const lineCount = model.getLineCount();

  for (let i = 1; i <= lineCount; i++) {
    const line = model.getLineContent(i).trim();
    const match = line.match(/^([a-zA-Z_]\w*)\s*:/);

    if (match) {
      labels.push(match[1]);
    }
  }

  return labels;
}

function createCompletionItemProvider(): monaco.languages.CompletionItemProvider {
  return {
    triggerCharacters: ["#", "$", "@", '"'],

    provideCompletionItems(model, position) {
      const data = declarationsStore.current;
      const word = model.getWordUntilPosition(position);
      const range = {
        startLineNumber: position.lineNumber,
        endLineNumber: position.lineNumber,
        startColumn: word.startColumn,
        endColumn: word.endColumn,
      };

      const lineContent = model.getLineContent(position.lineNumber);

      const includeMatch = lineContent.match(/^\s*#include\s+"([^"]*)"/);
      if (includeMatch) {
        const fileRange = {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: lineContent.indexOf('"') + 2,
          endColumn: position.column,
        };
        return {
          suggestions: data.files.map((f) => ({
            label: f.name,
            kind: monaco.languages.CompletionItemKind.File,
            insertText: f.name,
            range: fileRange,
            detail: "Include file",
            documentation: f.doc,
          })),
        };
      }

      const lineBeforeCursor = lineContent.substring(0, position.column - 1);
      const addressMatch = lineBeforeCursor.match(/@(\w*)$/);
      if (addressMatch) {
        const labels = findLabelsInModel(model);
        const labelRange = {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: position.column - addressMatch[1].length,
          endColumn: position.column,
        };

        return {
          suggestions: labels.map((label) => ({
            label: label,
            kind: monaco.languages.CompletionItemKind.Reference,
            insertText: label,
            range: labelRange,
            detail: "Label address",
            documentation: `Address of label \`${label}\`.\n\nEvaluates to the instruction index of \`${label}:\`.`,
          })),
        };
      }

      const isPreprocContext = !!lineContent.match(/^\s*#\w*$/);

      const suggestions: monaco.languages.CompletionItem[] = [];

      if (isPreprocContext) {
        const directives = [
          {
            label: "#include",
            insertText: '#include "$0"',
            doc: 'Include an external header file.\n\nSyntax: `#include "filename.b26h"`\n\nMakes the file\'s functions and variables available in the current scope.',
            detail: "Include header",
          },
          {
            label: "#define",
            insertText: "#define $0",
            doc: "Define a preprocessor constant.\n\nSyntax: `#define NAME value`\n\nThe token NAME is replaced with value throughout the script.",
            detail: "Define constant",
          },
          {
            label: "#ifdef",
            insertText: "#ifdef $0",
            doc: "Begin a conditional block that compiles only if the given name is defined.\n\nMust be closed with `#endif`.",
            detail: "If defined",
          },
          {
            label: "#ifndef",
            insertText: "#ifndef $0",
            doc: "Begin a conditional block that compiles only if the given name is NOT defined.\n\nMust be closed with `#endif`.",
            detail: "If not defined",
          },
          {
            label: "#undef",
            insertText: "#undef $0",
            doc: "Undefine a previously defined preprocessor constant.",
            detail: "Undefine constant",
          },
          {
            label: "#endif",
            insertText: "#endif",
            doc: "End a preprocessor conditional block (#ifdef / #ifndef).",
            detail: "End conditional",
          },
          {
            label: "#else",
            insertText: "#else",
            doc: "Else branch for a preprocessor conditional (#ifdef / #ifndef).",
            detail: "Else branch",
          },
        ];

        for (const d of directives) {
          suggestions.push({
            label: d.label,
            kind: monaco.languages.CompletionItemKind.Snippet,
            insertText: d.insertText,
            insertTextRules:
              monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            range,
            detail: d.detail,
            documentation: d.doc,
          });
        }

        return { suggestions };
      }

      for (const kw of BUILTIN_KEYWORDS) {
        suggestions.push({
          label: kw.name,
          kind: monaco.languages.CompletionItemKind.Keyword,
          insertText: kw.args.length > 0 ? `${kw.name} ` : kw.name,
          range,
          detail: formatSignature(kw),
          documentation: formatFunctionDoc(kw),
        });
      }

      const logicalOps: {
        name: string;
        args: string[];
        ret: string;
        doc: string;
      }[] = [
        {
          name: "AND",
          args: ["lhs: int", "rhs: int"],
          ret: "int",
          doc: "Logical AND.\n\nReturns 1 if both operands are non-zero, otherwise 0.",
        },
        {
          name: "OR",
          args: ["lhs: int", "rhs: int"],
          ret: "int",
          doc: "Logical OR.\n\nReturns 1 if either operand is non-zero, otherwise 0.",
        },
        {
          name: "NOT",
          args: ["value: int"],
          ret: "int",
          doc: "Logical NOT.\n\nReturns 1 if value is 0, otherwise 0.",
        },
      ];

      for (const op of logicalOps) {
        suggestions.push({
          label: op.name,
          kind: monaco.languages.CompletionItemKind.Operator,
          insertText: `${op.name} `,
          range,
          detail: `${op.name}(${op.args.join(", ")}): ${op.ret}`,
          documentation: op.doc,
        });
      }

      const builtinConstants: { name: string; type: string; doc: string }[] = [
        {
          name: "NULL",
          type: "null",
          doc: "Represents a null value.\n\nUsed to initialise or clear a variable to the null type.",
        },
        { name: "NAN", type: "float", doc: "Not-a-Number (IEEE 754 NaN)." },
        {
          name: "INF",
          type: "float",
          doc: "Positive infinity (IEEE 754 ∞). Use -INF for negative infinity.",
        },
      ];

      for (const c of builtinConstants) {
        suggestions.push({
          label: c.name,
          kind: monaco.languages.CompletionItemKind.Constant,
          insertText: c.name,
          range,
          detail: `constant: ${c.type}`,
          documentation: c.doc,
        });
      }

      const includedFiles = getIncludedFiles(model);

      for (const fn of data.functions) {
        const argPlaceholders = fn.args
          .map((a, i) => `\${${i + 1}:${a.name}}`)
          .join(", ");

        suggestions.push({
          label: fn.name,
          kind: monaco.languages.CompletionItemKind.Function,
          insertText:
            fn.args.length > 0 ? `${fn.name} ${argPlaceholders}` : fn.name,
          insertTextRules:
            monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          range,
          detail: formatSignature(fn),
          documentation: formatFunctionDoc(fn),
        });
      }

      for (const v of data.variables) {
        suggestions.push({
          label: v.name,
          kind: monaco.languages.CompletionItemKind.Variable,
          insertText: v.name,
          range,
          detail: `variable: ${v.type}`,
          documentation: formatVariableDoc(v),
        });
      }

      for (const d of data.defines) {
        suggestions.push({
          label: d.name,
          kind: monaco.languages.CompletionItemKind.Constant,
          insertText: d.name,
          range,
          detail: `#define ${d.name}`,
          documentation: `Value: \`${d.value}\``,
        });
      }

      for (const file of data.files) {
        if (!includedFiles.has(file.name)) {
          continue;
        }

        for (const fn of file.functions) {
          const argPlaceholders = fn.args
            .map((a, i) => `\${${i + 1}:${a.name}}`)
            .join(", ");

          suggestions.push({
            label: fn.name,
            kind: monaco.languages.CompletionItemKind.Function,
            insertText:
              fn.args.length > 0 ? `${fn.name} ${argPlaceholders}` : fn.name,
            insertTextRules:
              monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            range,
            detail: formatSignature(fn),
            documentation: `*(from ${file.name})*\n\n${formatFunctionDoc(fn)}`,
          });
        }

        for (const v of file.variables) {
          suggestions.push({
            label: v.name,
            kind: monaco.languages.CompletionItemKind.Variable,
            insertText: v.name,
            range,
            detail: `variable: ${v.type}`,
            documentation: `*(from ${file.name})*\n\n${formatVariableDoc(v)}`,
          });
        }

        for (const d of file.defines) {
          suggestions.push({
            label: d.name,
            kind: monaco.languages.CompletionItemKind.Constant,
            insertText: d.name,
            range,
            detail: `#define ${d.name} (from ${file.name})`,
            documentation: `Value: \`${d.value}\``,
          });
        }
      }

      return { suggestions };
    },
  };
}

function createHoverProvider(): monaco.languages.HoverProvider {
  return {
    provideHover(model, position) {
      const data = declarationsStore.current;
      const word = model.getWordAtPosition(position);

      if (!word) {
        return null;
      }

      const wordUpper = word.word.toUpperCase();

      for (const kw of BUILTIN_KEYWORDS) {
        if (kw.name === wordUpper) {
          return {
            range: new monaco.Range(
              position.lineNumber,
              word.startColumn,
              position.lineNumber,
              word.endColumn,
            ),
            contents: [{ value: formatFunctionDoc(kw) }],
          };
        }
      }

      const logicalOpDocs: Record<string, string> = {
        AND: "**AND**(*lhs*: `int`, *rhs*: `int`): `int`\n\nLogical AND.\n\nReturns 1 if both operands are non-zero, otherwise 0.",
        OR: "**OR**(*lhs*: `int`, *rhs*: `int`): `int`\n\nLogical OR.\n\nReturns 1 if either operand is non-zero, otherwise 0.",
        NOT: "**NOT**(*value*: `int`): `int`\n\nLogical NOT.\n\nReturns 1 if value is 0, otherwise 0.",
      };

      if (logicalOpDocs[wordUpper]) {
        return {
          range: new monaco.Range(
            position.lineNumber,
            word.startColumn,
            position.lineNumber,
            word.endColumn,
          ),
          contents: [{ value: logicalOpDocs[wordUpper] }],
        };
      }

      const constantDocs: Record<string, string> = {
        NULL: "**NULL**: `null`\n\nRepresents a null value.\n\nUsed to initialise or clear a variable to the null type.",
        NAN: "**NAN**: `float`\n\nNot-a-Number (IEEE 754 NaN).",
        INF: "**INF**: `float`\n\nPositive infinity (IEEE 754 ∞). Use -INF for negative infinity.",
      };

      if (constantDocs[wordUpper]) {
        return {
          range: new monaco.Range(
            position.lineNumber,
            word.startColumn,
            position.lineNumber,
            word.endColumn,
          ),
          contents: [{ value: constantDocs[wordUpper] }],
        };
      }

      for (const fn of data.functions) {
        if (fn.name.toUpperCase() === wordUpper) {
          return {
            range: new monaco.Range(
              position.lineNumber,
              word.startColumn,
              position.lineNumber,
              word.endColumn,
            ),
            contents: [{ value: formatFunctionDoc(fn) }],
          };
        }
      }

      for (const v of data.variables) {
        if (v.name.toUpperCase() === wordUpper) {
          return {
            range: new monaco.Range(
              position.lineNumber,
              word.startColumn,
              position.lineNumber,
              word.endColumn,
            ),
            contents: [{ value: formatVariableDoc(v) }],
          };
        }
      }

      for (const d of data.defines) {
        if (d.name.toUpperCase() === wordUpper) {
          return {
            range: new monaco.Range(
              position.lineNumber,
              word.startColumn,
              position.lineNumber,
              word.endColumn,
            ),
            contents: [
              { value: `**${d.name}**: \`#define\`\n\nValue: \`${d.value}\`` },
            ],
          };
        }
      }

      const includedFiles = getIncludedFiles(model);

      for (const file of data.files) {
        if (!includedFiles.has(file.name)) {
          continue;
        }

        for (const fn of file.functions) {
          if (fn.name.toUpperCase() === wordUpper) {
            return {
              range: new monaco.Range(
                position.lineNumber,
                word.startColumn,
                position.lineNumber,
                word.endColumn,
              ),
              contents: [
                { value: `*(from ${file.name})*\n\n${formatFunctionDoc(fn)}` },
              ],
            };
          }
        }

        for (const v of file.variables) {
          if (v.name.toUpperCase() === wordUpper) {
            return {
              range: new monaco.Range(
                position.lineNumber,
                word.startColumn,
                position.lineNumber,
                word.endColumn,
              ),
              contents: [
                { value: `*(from ${file.name})*\n\n${formatVariableDoc(v)}` },
              ],
            };
          }
        }

        for (const d of file.defines) {
          if (d.name.toUpperCase() === wordUpper) {
            return {
              range: new monaco.Range(
                position.lineNumber,
                word.startColumn,
                position.lineNumber,
                word.endColumn,
              ),
              contents: [
                {
                  value: `**${d.name}**: \`#define\` *(from ${file.name})*\n\nValue: \`${d.value}\``,
                },
              ],
            };
          }
        }
      }

      return null;
    },
  };
}

const OUTPUT_HEADER_HEIGHT = 28;
const OUTPUT_RESIZE_HANDLE_HEIGHT = 4;
const OUTPUT_MIN_HEIGHT =
  60 + OUTPUT_HEADER_HEIGHT + OUTPUT_RESIZE_HANDLE_HEIGHT;
const OUTPUT_DEFAULT_HEIGHT = 150;

type ScriptEditorData = {
  output?: string[];
  compile_errors: CompileError[];
  runtime_errors: RuntimeError[];
  is_on: boolean;
  messages: string[];
  declarations?: DeclarationsData;
};

type ScriptEditorState = {
  outputCollapsed: boolean;
  outputHeight: number;
};

export class ScriptEditor extends Component<any, ScriptEditorState> {
  private editorInstance: monaco.editor.IStandaloneCodeEditor | null = null;
  private actFn: any = null;
  private isResizing = false;
  private outputRef: HTMLElement | null = null;
  private resizeStartY = 0;
  private resizeStartHeight = 0;

  constructor(props: any, context: any) {
    super(props, context);

    this.state = {
      outputCollapsed: false,
      outputHeight: OUTPUT_DEFAULT_HEIGHT,
    };
  }

  componentDidMount() {
    window.addEventListener("mousemove", this.handleResizeMove);
    window.addEventListener("mouseup", this.handleResizeEnd);
  }

  componentWillUnmount() {
    window.removeEventListener("mousemove", this.handleResizeMove);
    window.removeEventListener("mouseup", this.handleResizeEnd);
  }

  private handleEditorMount = (editor: monaco.editor.IStandaloneCodeEditor) => {
    this.editorInstance = editor;
  };

  private handleCompile = () => {
    const rawCode = this.editorInstance?.getValue() || "";
    const result = preprocess(rawCode);

    sourceMapStore.current = result.sourceMap;

    const model = this.editorInstance?.getModel();
    if (model) {
      monaco.editor.setModelMarkers(model, BASIC26_LANGUAGE_ID, []);
    }

    if (this.actFn) {
      this.actFn("compile", {
        code: result.code,
        included_files: result.includedFiles,
      });
    }

    this.editorInstance?.focus();
  };

  private handleStart = () => {
    if (this.actFn) {
      this.actFn("start");
    }
  };

  private handleStop = () => {
    if (this.actFn) {
      this.actFn("stop");
    }
  };

  private handleToggleOutput = () => {
    this.setState({ outputCollapsed: !this.state.outputCollapsed });
  };

  private handleResizeStart = (e: any) => {
    e.preventDefault();

    this.isResizing = true;
    this.resizeStartY = e.clientY;
    this.resizeStartHeight = this.state.outputHeight;
  };

  private handleResizeMove = (e: MouseEvent) => {
    if (!this.isResizing) {
      return;
    }

    const delta = this.resizeStartY - e.clientY;
    const rootEl = this.outputRef?.parentElement;
    const available = rootEl
      ? rootEl.clientHeight - 40
      : window.innerHeight - 80;

    const maxHeight = Math.max(OUTPUT_MIN_HEIGHT, available);
    const newHeight = Math.max(
      OUTPUT_MIN_HEIGHT,
      Math.min(maxHeight, this.resizeStartHeight + delta),
    );

    this.setState({ outputHeight: newHeight });
  };

  private handleResizeEnd = () => {
    this.isResizing = false;
  };

  render() {
    const { act, data } = useBackend<ScriptEditorData>(this.context);
    this.actFn = act;

    const { outputCollapsed, outputHeight } = this.state;

    return (
      <Window title="Script Editor" width={800} height={600}>
        <Window.Content fitted>
          <div className="script-editor-root">
            {/* ---- Toolbar ---- */}
            <div className="script-editor-toolbar">
              <button
                type="button"
                className="script-editor-btn-compile"
                onClick={this.handleCompile}
                title="Compile (upload to MCU)"
              >
                <svg
                  viewBox="0 0 16 16"
                  width="14"
                  height="14"
                  className="script-editor-btn-compile__icon"
                >
                  <path d="M3.5 2v12l10-6z" />
                </svg>
                Compile
              </button>

              <div className="script-editor-toolbar__separator" />

              <button
                type="button"
                className={
                  "script-editor-btn-start" +
                  (data.is_on ? " script-editor-btn--disabled" : "")
                }
                onClick={this.handleStart}
                disabled={data.is_on}
                title="Start MCU"
              >
                {/* codicon debug-start */}
                <svg
                  viewBox="0 0 16 16"
                  width="14"
                  height="14"
                  className="script-editor-btn-start__icon"
                >
                  <path d="M4 2v12l9-6z" />
                </svg>
                Start
              </button>

              <button
                type="button"
                className={
                  "script-editor-btn-stop" +
                  (!data.is_on ? " script-editor-btn--disabled" : "")
                }
                onClick={this.handleStop}
                disabled={!data.is_on}
                title="Stop MCU"
              >
                {/* codicon debug-stop */}
                <svg
                  viewBox="0 0 16 16"
                  width="14"
                  height="14"
                  className="script-editor-btn-stop__icon"
                >
                  <path d="M4 4h8v8H4z" />
                </svg>
                Stop
              </button>

              <div className="script-editor-toolbar__spacer" />

              <div
                className={
                  "script-editor-status" +
                  (data.is_on
                    ? " script-editor-status--on"
                    : " script-editor-status--off")
                }
              >
                <span className="script-editor-status__dot" />
                {data.is_on ? "Running" : "Stopped"}
              </div>
            </div>

            {/* ---- Editor ---- */}
            <div className="script-editor-center">
              <Editor
                compileErrors={data.compile_errors}
                runtimeErrors={data.runtime_errors}
                onEditorMount={this.handleEditorMount}
                declarations={data.declarations}
              />
            </div>

            {/* ---- Output panel ---- */}
            <div
              ref={(el) => {
                this.outputRef = el;
              }}
              className={
                "script-editor-output" +
                (outputCollapsed ? " script-editor-output--collapsed" : "")
              }
              style={
                outputCollapsed ? undefined : { height: `${outputHeight}px` }
              }
            >
              {/* Resize handle */}
              {!outputCollapsed && (
                <div
                  className="script-editor-output-resize-handle"
                  onMouseDown={this.handleResizeStart}
                />
              )}

              {/* Header */}
              <div
                className="script-editor-output-header"
                onClick={this.handleToggleOutput}
              >
                {outputCollapsed ? (
                  <svg
                    viewBox="0 0 16 16"
                    width="14"
                    height="14"
                    className="script-editor-output-header__icon"
                  >
                    <path d="M6 4l4 4-4 4z" />
                  </svg>
                ) : (
                  <svg
                    viewBox="0 0 16 16"
                    width="14"
                    height="14"
                    className="script-editor-output-header__icon"
                  >
                    <path d="M4 6l4 4 4-4z" />
                  </svg>
                )}
                Output
              </div>

              {/* Content */}
              {!outputCollapsed && (
                <div className="script-editor-output-content">
                  {data.messages.length === 0 ? (
                    <span className="script-editor-output-content__placeholder">
                      No output.
                    </span>
                  ) : (
                    data.messages.map((line, i) => (
                      <div
                        key={i}
                        className="script-editor-output-content__line"
                      >
                        {line}
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>
          </div>
        </Window.Content>
      </Window>
    );
  }
}
