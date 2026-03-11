import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Terminal } from '@xterm/xterm';
import '@xterm/xterm/css/xterm.css';

const TERM_COLS = 80;
const TERM_ROWS = 24;

const stringToUtf8Bytes = (str: string): number[] => {
  const encoder = new TextEncoder();
  const bytes = Array.from(encoder.encode(str));
  bytes.push(10); // newline terminator for line mode
  return bytes;
};

const countUtf8Bytes = (str: string): number => {
  return new TextEncoder().encode(str).length;
};

type SerialTerminalData = {
  buffer: number[];
  bufferStart: number;
  maxInputBytes: number;
  isActive: boolean;
  rawMode: boolean;
};

type XTermProps = {
  buffer: number[];
  bufferStart: number;
  isActive: boolean;
  rawMode: boolean;
  maxInputBytes: number;
  onSend: (bytes: number[]) => void;
};

type XTermState = {
  inputByteCount: number;
};

class XTermDisplay extends Component<XTermProps, XTermState> {
  private containerEl: HTMLDivElement | null = null;
  private terminal: Terminal | null = null;
  private lastBufferStart: number = 0;
  private writtenLength: number = 0;

  // Line-mode input state
  private inputBuffer: string = '';
  private inputEchoActive: boolean = false;

  state: XTermState = {
    inputByteCount: 1,
  };

  componentDidMount() {
    const { isActive, rawMode } = this.props;

    this.terminal = new Terminal({
      theme: {
        background: '#141414',
        foreground: '#d6d6d6',
        cursor: '#d6d6d6',
        cursorAccent: '#141414',
        selectionBackground: 'rgba(255, 255, 255, 0.18)',
        selectionForeground: '#ffffff',
        black: '#1b1b1b',
        red: '#e74c3c',
        green: '#2ecc71',
        yellow: '#e5c07b',
        blue: '#61afef',
        magenta: '#c678dd',
        cyan: '#56b6c2',
        white: '#d6d6d6',
        brightBlack: '#666666',
        brightRed: '#f44747',
        brightGreen: '#6fd76f',
        brightYellow: '#f0c674',
        brightBlue: '#528bff',
        brightMagenta: '#d670d6',
        brightCyan: '#67cddc',
        brightWhite: '#ffffff',
      },
      cols: TERM_COLS,
      rows: TERM_ROWS,
      fontSize: 13,
      fontFamily: '"Consolas", "Monaco", "Courier New", monospace',
      convertEol: true,
      disableStdin: false,
      cursorBlink: isActive,
      cursorStyle: rawMode ? 'block' : 'bar',
      scrollback: rawMode ? 0 : 5000, // No scrollback in raw mode
    });

    if (this.containerEl) {
      this.terminal.open(this.containerEl);
    }

    this.terminal.onData((data) => this.handleInput(data));

    const { buffer, bufferStart } = this.props;
    this.lastBufferStart = bufferStart;

    if (buffer && buffer.length > 0) {
      this.terminal.write(new Uint8Array(buffer));
      this.writtenLength = buffer.length;
    }
  }

  componentDidUpdate(prevProps: XTermProps) {
    const { buffer, bufferStart, isActive, rawMode } = this.props;

    // Handle active state changes
    if (prevProps.isActive !== isActive && this.terminal) {
      this.terminal.options.cursorBlink = isActive;
    }

    // Handle raw mode transitions
    if (prevProps.rawMode !== rawMode && this.terminal) {
      if (rawMode) {
        // Entering raw mode
        // 1. Clear any pending line-mode echo
        if (this.inputEchoActive) {
          this.terminal.write('\x1b8\x1b[J');
          this.inputEchoActive = false;
        }
        
        this.inputBuffer = '';
        
        // 2. Reset terminal completely for clean slate
        this.terminal.reset();
        this.terminal.clear();
        
        // 3. Configure for raw mode
        this.terminal.options.scrollback = 0;
        this.terminal.options.cursorStyle = 'block';
        
        // 4. Reset tracking state
        this.writtenLength = 0;
        this.lastBufferStart = bufferStart;
        
        this.setState({ inputByteCount: 1 });
      } else {
        // Leaving raw mode
        this.terminal.options.scrollback = 5000;
        this.terminal.options.cursorStyle = 'bar';
        
        // Show cursor again (raw mode apps might hide it)
        this.terminal.write('\x1b[?25h');
      }
      
      // Don't process buffer changes in same update after mode switch
      return;
    }

    // Handle buffer reset (empty buffer)
    if (!buffer || buffer.length === 0) {
      if (this.writtenLength > 0 || this.lastBufferStart !== bufferStart) {
        this.terminal?.reset();
        this.writtenLength = 0;
        this.lastBufferStart = bufferStart;
        this.inputEchoActive = false;

        // Re-echo pending line-mode input after reset
        if (!rawMode && this.inputBuffer.length > 0 && isActive) {
          this.terminal?.write('\x1b7');
          this.terminal?.write(this.inputBuffer);
          this.inputEchoActive = true;
        }
      }
      return;
    }

    // Handle buffer trimming
    if (bufferStart !== this.lastBufferStart) {
      const cutAmount = bufferStart - this.lastBufferStart;
      this.writtenLength = Math.max(0, this.writtenLength - cutAmount);
      this.lastBufferStart = bufferStart;
    }

    // Write new buffer bytes
    if (buffer.length > this.writtenLength) {
      // In line mode, clear echo before writing server data
      if (!rawMode && this.inputEchoActive) {
        this.terminal?.write('\x1b8\x1b[J');
        this.inputEchoActive = false;
      }

      const newBytes = buffer.slice(this.writtenLength);
      this.terminal?.write(new Uint8Array(newBytes));
      this.writtenLength = buffer.length;

      // Re-echo pending line-mode input after server output (line mode only)
      if (!rawMode && this.inputBuffer.length > 0) {
        this.terminal?.write('\x1b7');
        this.terminal?.write(this.inputBuffer);
        this.inputEchoActive = true;
      }
    }
  }

  componentWillUnmount() {
    this.terminal?.dispose();
    this.terminal = null;
  }

  private handleInput(data: string) {
    const { isActive, maxInputBytes, onSend, rawMode } = this.props;

    if (!isActive || !this.terminal) {
      return;
    }

    // Raw mode: send every keystroke immediately, no local echo
    if (rawMode) {
      const encoder = new TextEncoder();
      const bytes = Array.from(encoder.encode(data));

      if (bytes.length > 0 && bytes.length <= maxInputBytes) {
        onSend(bytes);
      }
      return;
    }

    // Line mode: buffer input, local echo, send on Enter
    let changed = false;

    for (const char of data) {
      const code = char.charCodeAt(0);

      if (code === 13 || code === 10) {
        // Enter — send the buffered line
        if (this.inputBuffer.length > 0) {
          const bytes = stringToUtf8Bytes(this.inputBuffer);

          if (bytes.length <= maxInputBytes) {
            if (this.inputEchoActive) {
              this.terminal.write('\x1b8\x1b[J');
              this.inputEchoActive = false;
            }

            this.inputBuffer = '';
            onSend(bytes);
            changed = true;
          }
        }
      } else if (code === 127 || code === 8) {
        // Backspace
        if (this.inputBuffer.length > 0) {
          this.inputBuffer = this.inputBuffer.slice(0, -1);

          if (this.inputBuffer.length === 0 && this.inputEchoActive) {
            this.terminal.write('\x1b8\x1b[J');
            this.inputEchoActive = false;
          } else {
            this.terminal.write('\b \b');
          }

          changed = true;
        }
      } else if (code >= 32) {
        // Printable character
        const newInput = this.inputBuffer + char;
        const newByteCount = countUtf8Bytes(newInput) + 1;

        if (newByteCount <= maxInputBytes) {
          if (!this.inputEchoActive) {
            this.terminal.write('\x1b7');
            this.inputEchoActive = true;
          }

          this.inputBuffer = newInput;
          this.terminal.write(char);
          changed = true;
        }
      }
    }

    if (changed) {
      this.setState({
        inputByteCount: countUtf8Bytes(this.inputBuffer) + 1,
      });
    }
  }

  render() {
    const { isActive, rawMode, maxInputBytes } = this.props;
    const { inputByteCount } = this.state;

    return (
      <div>
        <div
          ref={(el: HTMLDivElement | null) => {
            this.containerEl = el;
          }}
        />
        <div
          style={{
            padding: '2px 8px',
            backgroundColor: '#252525',
            borderTop: '1px solid #3a3a3a',
            fontFamily: '"Consolas", monospace',
            fontSize: '11px',
            lineHeight: '18px',
            overflow: 'hidden',
          }}
        >
          <span
            style={{
              float: 'left',
              color: isActive ? '#4ec54e' : '#db4b4b',
            }}
          >
            {isActive ? '● Connected' : '○ Disconnected'}
          </span>
          <span style={{ float: 'right' }}>
            {rawMode ? (
              <span style={{ color: '#e5c07b' }}>⚡ Raw</span>
            ) : (
              <span
                style={{
                  color:
                    inputByteCount >= maxInputBytes ? '#db4b4b' : '#888888',
                }}
              >
                {inputByteCount}/{maxInputBytes} bytes
              </span>
            )}
          </span>
        </div>
      </div>
    );
  }
}

export const SerialTerminal = (props: any, context: any) => {
  const { act, data } = useBackend<SerialTerminalData>(context);
  const { buffer, bufferStart, maxInputBytes, isActive, rawMode } = data;

  return (
    <Window title="Serial Terminal" width={680} height={440}>
      <Window.Content>
        <XTermDisplay
          buffer={buffer || []}
          bufferStart={bufferStart || 0}
          isActive={isActive}
          rawMode={rawMode || false}
          maxInputBytes={maxInputBytes}
          onSend={(bytes) => act('send', { bytes })}
        />
      </Window.Content>
    </Window>
  );
};
