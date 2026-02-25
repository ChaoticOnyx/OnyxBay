import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

const stringToUtf8Bytes = (str: string): number[] => {
  const encoder = new TextEncoder();
  const bytes = Array.from(encoder.encode(str));
  bytes.push(10); // \n

  return bytes;
};

const countUtf8Bytes = (str: string): number => {
  const encoder = new TextEncoder();

  return encoder.encode(str).length;
};

const isPrintable = (codePoint: number): boolean => {
  // C0
  if (codePoint < 32 && codePoint !== 9) return false;

  // DEL
  if (codePoint === 127) return false;

  // C1
  if (codePoint >= 0x80 && codePoint <= 0x9f) return false;

  // Unicode replacement character
  if (codePoint === 0xfffd) return false;

  return true;
};

const formatBadByte = (byte: number): string => {
  return `\u001b[7m[${byte.toString(16).padStart(2, '0')}]\u001b[0m`;
};

const decodeUtf8WithErrors = (bytes: number[]): string => {
  const result: string[] = [];
  let i = 0;

  while (i < bytes.length) {
    const byte = bytes[i];

    let seqLength: number;
    let codePoint: number;

    if ((byte & 0x80) === 0) {
      // ASCII (0xxxxxxx)
      seqLength = 1;
      codePoint = byte;
    } else if ((byte & 0xe0) === 0xc0) {
      // 2-byte (110xxxxx)
      seqLength = 2;
      codePoint = byte & 0x1f;
    } else if ((byte & 0xf0) === 0xe0) {
      // 3-byte (1110xxxx)
      seqLength = 3;
      codePoint = byte & 0x0f;
    } else if ((byte & 0xf8) === 0xf0) {
      // 4-byte (11110xxx)
      seqLength = 4;
      codePoint = byte & 0x07;
    } else {
      result.push(formatBadByte(byte));
      i++;

      continue;
    }

    if (i + seqLength > bytes.length) {
      for (let j = i; j < bytes.length; j++) {
        result.push(formatBadByte(bytes[j]));
      }

      break;
    }

    let valid = true;

    for (let j = 1; j < seqLength; j++) {
      const cont = bytes[i + j];

      if ((cont & 0xc0) !== 0x80) {
        valid = false;

        break;
      }

      codePoint = (codePoint << 6) | (cont & 0x3f);
    }

    if (!valid) {
      result.push(formatBadByte(byte));
      i++;

      continue;
    }

    const minCodePoints = [0, 0x80, 0x800, 0x10000];

    if (codePoint < minCodePoints[seqLength - 1]) {
      for (let j = 0; j < seqLength; j++) {
        result.push(formatBadByte(bytes[i + j]));
      }

      i += seqLength;

      continue;
    }

    if (codePoint > 0x10ffff || (codePoint >= 0xd800 && codePoint <= 0xdfff)) {
      for (let j = 0; j < seqLength; j++) {
        result.push(formatBadByte(bytes[i + j]));
      }

      i += seqLength;

      continue;
    }

    result.push(formatCodePoint(codePoint));
    i += seqLength;
  }

  return result.join('');
};

const formatCodePoint = (cp: number): string => {
  switch (cp) {
    case 0:
      return '';
    case 7:
      return '\u001b[7m[BEL]\u001b[0m';
    case 8:
      return '\u001b[7m[BS]\u001b[0m';
    case 9:
      return '    '; // Tab
    case 10:
      return '\n'; // LF
    case 13:
      return ''; // CR
    case 27:
      return '\u001b[7m[ESC]\u001b[0m';
    case 127:
      return '\u001b[7m[DEL]\u001b[0m';
  }

  // C0 (1-31, кроме обработанных выше)
  if (cp < 32) {
    return `\u001b[7m[${cp.toString(16).padStart(2, '0')}]\u001b[0m`;
  }

  // C1 (0x80-0x9F)
  if (cp >= 0x80 && cp <= 0x9f) {
    return `\u001b[7m[${cp.toString(16).padStart(2, '0')}]\u001b[0m`;
  }

  // Zero-width
  if (isInvisibleChar(cp)) {
    return `\u001b[7m[U+${cp.toString(16).padStart(4, '0')}]\u001b[0m`;
  }

  return String.fromCodePoint(cp);
};

const isInvisibleChar = (cp: number): boolean => {
  // Zero-width characters
  if (cp === 0x200b) return true; // ZERO WIDTH SPACE
  if (cp === 0x200c) return true; // ZERO WIDTH NON-JOINER
  if (cp === 0x200d) return true; // ZERO WIDTH JOINER
  if (cp === 0x2060) return true; // WORD JOINER
  if (cp === 0xfeff) return true; // BOM / ZERO WIDTH NO-BREAK SPACE

  if (cp === 0x00a0) return true; // NO-BREAK SPACE
  if (cp === 0x00ad) return true; // SOFT HYPHEN

  return false;
};

const renderWithEscapes = (text: string): any[] => {
  const result: any[] = [];
  const regex = /\u001b\[(\d*)m/g;

  let lastIndex = 0;
  let isInverted = false;
  let keyIndex = 0;

  const invertedStyle = { color: '#666666', fontSize: '11px' };

  let match: RegExpExecArray | null;
  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      const segment = text.slice(lastIndex, match.index);
      result.push(
        isInverted ? (
          <span key={keyIndex++} style={invertedStyle}>
            {segment}
          </span>
        ) : (
          <span key={keyIndex++}>{segment}</span>
        )
      );
    }

    const code = match[1];
    if (code === '7') isInverted = true;
    else if (code === '0' || code === '') isInverted = false;

    lastIndex = regex.lastIndex;
  }

  if (lastIndex < text.length) {
    const segment = text.slice(lastIndex);
    result.push(
      isInverted ? (
        <span key={keyIndex++} style={invertedStyle}>
          {segment}
        </span>
      ) : (
        <span key={keyIndex++}>{segment}</span>
      )
    );
  }

  return result;
};

const renderBuffer = (bytes: number[]): any => {
  if (!bytes || bytes.length === 0) {
    return <span style={{ color: '#666' }}>No output yet...</span>;
  }

  return renderWithEscapes(decodeUtf8WithErrors(bytes));
};

type SerialTerminalData = {
  buffer: number[];
  maxInputBytes: number;
  isActive: boolean;
};

export const SerialTerminal = (props: any, context: any) => {
  const { act, data } = useBackend<SerialTerminalData>(context);
  const { buffer, maxInputBytes, isActive } = data;

  const [inputValue, setInputValue] = useLocalState(context, 'input', '');

  const currentByteCount = countUtf8Bytes(inputValue) + 1;
  const isOverLimit = currentByteCount > maxInputBytes;
  const canSend = isActive && inputValue.length > 0 && !isOverLimit;

  const handleSend = (text: string) => {
    if (!text.length || countUtf8Bytes(text) + 1 > maxInputBytes) {
      return;
    }
    act('send', { bytes: stringToUtf8Bytes(text) });
    setInputValue('');
  };

  return (
    <Window width={650} height={500} title="Serial Terminal">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack align="center" justify="space-between">
              <Stack.Item>
                <Box
                  inline
                  color={isActive ? 'good' : 'bad'}
                  style={{ fontSize: '12px' }}
                >
                  {isActive ? '● Connected' : '○ Disconnected'}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item
            grow
            basis={0}
            style={{
              minHeight: 0,
              overflow: 'auto',
            }}
          >
            <Box
              style={{
                height: '100%',
                overflowY: 'auto',
                overflowX: 'hidden',
                backgroundColor: '#0a0a0a',
              }}
            >
              <Box
                as="pre"
                style={{
                  margin: 0,
                  padding: '8px',
                  fontFamily: '"Consolas", "Monaco", monospace',
                  fontSize: '13px',
                  lineHeight: '1.4',
                  whiteSpace: 'pre-wrap',
                  wordBreak: 'break-word',
                  color: '#f0f0f0',
                }}
              >
                {renderBuffer(buffer || [])}
              </Box>
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Box style={{ borderTop: '1px solid #333', paddingTop: '8px' }}>
              <Stack align="center">
                <Stack.Item grow>
                  <Input
                    fluid
                    disabled={!isActive}
                    placeholder={isActive ? 'Enter command...' : 'MCU not running'}
                    value={inputValue}
                    onInput={(_, value: string) => setInputValue(value)}
                    onEnter={(_, value: string) => {
                      if (canSend) handleSend(value);
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Box
                    inline
                    color={isOverLimit ? 'bad' : 'label'}
                    style={{
                      minWidth: '70px',
                      textAlign: 'right',
                      fontFamily: 'monospace',
                      fontSize: '11px',
                    }}
                  >
                    {currentByteCount}/{maxInputBytes}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="paper-plane"
                    disabled={!canSend}
                    onClick={() => handleSend(inputValue)}
                  >
                    Send
                  </Button>
                </Stack.Item>
              </Stack>
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
