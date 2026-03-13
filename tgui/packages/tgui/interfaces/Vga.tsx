import { Component } from "inferno";
import { useBackend } from "../backend";
import { Window } from "../layouts";

const I16_MIN = -32768;
const I16_MAX = 32767;
const PAL_SIZE = 256 * 3;
const SCALE = 2;
const CANVAS_ID = "vga-canvas";
const DEFAULT_WIDTH = 160;
const DEFAULT_HEIGHT = 120;
const DEFAULT_MAX_MESSAGES_PER_SEC = 60;
const MAX_QUEUE_SIZE = 512;

const SCANCODE_MAP: Record<string, number> = {
  KeyA: 0x04,
  KeyB: 0x05,
  KeyC: 0x06,
  KeyD: 0x07,
  KeyE: 0x08,
  KeyF: 0x09,
  KeyG: 0x0a,
  KeyH: 0x0b,
  KeyI: 0x0c,
  KeyJ: 0x0d,
  KeyK: 0x0e,
  KeyL: 0x0f,
  KeyM: 0x10,
  KeyN: 0x11,
  KeyO: 0x12,
  KeyP: 0x13,
  KeyQ: 0x14,
  KeyR: 0x15,
  KeyS: 0x16,
  KeyT: 0x17,
  KeyU: 0x18,
  KeyV: 0x19,
  KeyW: 0x1a,
  KeyX: 0x1b,
  KeyY: 0x1c,
  KeyZ: 0x1d,
  Digit1: 0x1e,
  Digit2: 0x1f,
  Digit3: 0x20,
  Digit4: 0x21,
  Digit5: 0x22,
  Digit6: 0x23,
  Digit7: 0x24,
  Digit8: 0x25,
  Digit9: 0x26,
  Digit0: 0x27,
  Enter: 0x28,
  Escape: 0x29,
  Backspace: 0x2a,
  Tab: 0x2b,
  Space: 0x2c,
  Minus: 0x2d,
  Equal: 0x2e,
  BracketLeft: 0x2f,
  BracketRight: 0x30,
  Backslash: 0x31,
  Semicolon: 0x33,
  Quote: 0x34,
  Backquote: 0x35,
  Comma: 0x36,
  Period: 0x37,
  Slash: 0x38,
  CapsLock: 0x39,
  ScrollLock: 0x47,
  NumLock: 0x53,
  F1: 0x3a,
  F2: 0x3b,
  F3: 0x3c,
  F4: 0x3d,
  F5: 0x3e,
  F6: 0x3f,
  F7: 0x40,
  F8: 0x41,
  F9: 0x42,
  F10: 0x43,
  F11: 0x44,
  F12: 0x45,
  PrintScreen: 0x46,
  Pause: 0x48,
  Insert: 0x49,
  Home: 0x4a,
  PageUp: 0x4b,
  Delete: 0x4c,
  End: 0x4d,
  PageDown: 0x4e,
  ArrowRight: 0x4f,
  ArrowLeft: 0x50,
  ArrowDown: 0x51,
  ArrowUp: 0x52,
  NumpadDivide: 0x54,
  NumpadMultiply: 0x55,
  NumpadSubtract: 0x56,
  NumpadAdd: 0x57,
  NumpadEnter: 0x58,
  Numpad1: 0x59,
  Numpad2: 0x5a,
  Numpad3: 0x5b,
  Numpad4: 0x5c,
  Numpad5: 0x5d,
  Numpad6: 0x5e,
  Numpad7: 0x5f,
  Numpad8: 0x60,
  Numpad9: 0x61,
  Numpad0: 0x62,
  NumpadDecimal: 0x63,
  ControlLeft: 0xe0,
  ShiftLeft: 0xe1,
  AltLeft: 0xe2,
  MetaLeft: 0xe3,
  ControlRight: 0xe4,
  ShiftRight: 0xe5,
  AltRight: 0xe6,
  MetaRight: 0xe7,
  AudioVolumeMute: 0x7f,
  AudioVolumeUp: 0x80,
  AudioVolumeDown: 0x81,
};

const MOUSE_BUTTON_MAP: Record<number, number> = {
  0: 1, // left
  1: 3, // middle
  2: 2, // right
};

function getModifiers(e: KeyboardEvent): number {
  let mod = 0;
  if (e.shiftKey) mod |= 1;
  if (e.ctrlKey) mod |= 2;
  if (e.altKey) mod |= 4;
  if (e.metaKey) mod |= 8;
  if (e.getModifierState("CapsLock")) mod |= 16;
  if (e.getModifierState("NumLock")) mod |= 32;
  return mod;
}

function clampI16(v: number): number {
  return Math.max(I16_MIN, Math.min(I16_MAX, v));
}

// Token-bucket rate limiter with a unified ordered queue.
//
// * If budget is available and the queue is empty - sends immediately.
// * Consecutive mouse_move / wheel events in the queue are merged.
// * On overflow the oldest low-priority (move/wheel) entry is dropped;
//   if none exist the oldest entry of any kind is dropped.
// * flush() bypasses rate limiting (used only for cleanup on blur /
//   pointer-lock loss - typically a handful of key-release events).

type QueuedEvent =
  | { kind: "key"; params: Record<string, any> }
  | { kind: "mouse_btn"; params: Record<string, any> }
  | { kind: "mouse_move"; dx: number; dy: number }
  | { kind: "wheel"; sdx: number; sdy: number };

class EventThrottle {
  private readonly act: (action: string, params?: Record<string, any>) => void;
  private readonly maxPerSec: number;
  private readonly maxBurst: number;

  private tokens: number;
  private lastRefillTime: number;
  private queue: QueuedEvent[] = [];
  private drainTimer: ReturnType<typeof setTimeout> | null = null;

  constructor(
    act: (action: string, params?: Record<string, any>) => void,
    maxPerSec: number,
  ) {
    this.act = act;
    this.maxPerSec = Math.max(1, maxPerSec);
    this.maxBurst = Math.max(1, Math.min(10, Math.floor(this.maxPerSec / 10)));
    this.tokens = this.maxBurst;
    this.lastRefillTime = performance.now();
  }

  private refillTokens(): void {
    const now = performance.now();
    const elapsed = now - this.lastRefillTime;
    this.tokens = Math.min(
      this.maxBurst,
      this.tokens + (elapsed / 1000) * this.maxPerSec,
    );
    this.lastRefillTime = now;
  }

  private tryConsume(): boolean {
    this.refillTokens();
    if (this.tokens >= 1) {
      this.tokens -= 1;
      return true;
    }
    return false;
  }

  private scheduleDrain(): void {
    if (this.drainTimer !== null) {
      return;
    }

    this.drainTimer = setTimeout(
      () => {
        this.drainTimer = null;
        this.drain();
      },
      Math.ceil(1000 / this.maxPerSec),
    );
  }

  private drain(): void {
    while (this.queue.length > 0 && this.tryConsume()) {
      this.dispatch(this.queue.shift()!);
    }

    if (this.queue.length > 0) {
      this.scheduleDrain();
    }
  }

  private dispatch(event: QueuedEvent): void {
    switch (event.kind) {
      case "key":
        this.act("key", event.params);
        break;

      case "mouse_btn":
        this.act("mouse", event.params);
        break;

      case "mouse_move":
        if (event.dx !== 0 || event.dy !== 0) {
          this.act("mouse", {
            t: 3,
            b: 0,
            dx: clampI16(event.dx),
            dy: clampI16(event.dy),
            sdx: 0,
            sdy: 0,
          });
        }
        break;

      case "wheel": {
        const sdx = Math.sign(event.sdx);
        const sdy = Math.sign(event.sdy);

        if (sdx !== 0 || sdy !== 0) {
          this.act("mouse", { t: 4, b: 0, dx: 0, dy: 0, sdx, sdy });
        }
        break;
      }
    }
  }

  private enqueue(event: QueuedEvent): void {
    // Fast path: send immediately when the queue is empty and we have budget
    if (this.queue.length === 0 && this.tryConsume()) {
      this.dispatch(event);
      return;
    }

    // Try to merge with the last queued event of the same kind
    if (this.queue.length > 0) {
      const last = this.queue[this.queue.length - 1];

      if (event.kind === "mouse_move" && last.kind === "mouse_move") {
        last.dx += event.dx;
        last.dy += event.dy;
        return;
      }

      if (event.kind === "wheel" && last.kind === "wheel") {
        last.sdx += event.sdx;
        last.sdy += event.sdy;
        return;
      }
    }

    // Enforce queue size limit
    if (this.queue.length >= MAX_QUEUE_SIZE) {
      const dropIdx = this.queue.findIndex(
        (e) => e.kind === "mouse_move" || e.kind === "wheel",
      );
      this.queue.splice(dropIdx !== -1 ? dropIdx : 0, 1);
    }

    this.queue.push(event);
    this.scheduleDrain();
  }

  key(params: Record<string, any>): void {
    this.enqueue({ kind: "key", params });
  }

  mouseButton(params: Record<string, any>): void {
    this.enqueue({ kind: "mouse_btn", params });
  }

  mouseMove(dx: number, dy: number): void {
    if (dx === 0 && dy === 0) {
      return;
    }

    this.enqueue({ kind: "mouse_move", dx, dy });
  }

  wheel(sdx: number, sdy: number): void {
    if (sdx === 0 && sdy === 0) {
      return;
    }

    this.enqueue({ kind: "wheel", sdx, sdy });
  }

  /** Send all queued events immediately, bypassing rate limits (cleanup). */
  flush(): void {
    if (this.drainTimer !== null) {
      clearTimeout(this.drainTimer);
      this.drainTimer = null;
    }

    while (this.queue.length > 0) {
      this.dispatch(this.queue.shift()!);
    }
  }

  /** Discard all pending events and stop timers. */
  destroy(): void {
    if (this.drainTimer !== null) {
      clearTimeout(this.drainTimer);
      this.drainTimer = null;
    }

    this.queue.length = 0;
  }
}

type VgaData = {
  supports_color?: number;
  width?: number;
  height?: number;
  max_messages_per_sec?: number;
  turned_on?: number;
};

type VgaDisplayProps = {
  width: number;
  height: number;
  supports_color: boolean;
  maxMessagesPerSec: number;
  turnedOn: boolean;
  act: (action: string, params?: Record<string, any>) => void;
  onCaptureChange?: (captured: boolean) => void;
};

type VgaDisplayState = {
  lastFrameSize: number;
};

class VgaDisplay extends Component<VgaDisplayProps, VgaDisplayState> {
  private canvasRef: HTMLCanvasElement | null = null;
  private ctx: CanvasRenderingContext2D | null = null;
  private imageData: ImageData | null = null;
  private subscribed: boolean = false;
  private pressedKeys: Set<number> = new Set();
  private mouseSubPixelX: number = 0;
  private mouseSubPixelY: number = 0;
  private throttle: EventThrottle | null = null;

  state: VgaDisplayState = {
    lastFrameSize: 0,
  };

  componentDidMount() {
    this.throttle = new EventThrottle(
      this.props.act,
      this.props.maxMessagesPerSec,
    );

    this.setupCanvas();
    this.ensureSubscribed();
    this.setupInputListeners();
    document.addEventListener("pointerlockchange", this.onPointerLockChange);
  }

  componentDidUpdate(prevProps: VgaDisplayProps) {
    const { width, height, turnedOn } = this.props;

    if (prevProps.width !== width || prevProps.height !== height) {
      this.setupCanvas();
    }

    if (!turnedOn && this.ctx !== null) {
      this.ctx.clearRect(0, 0, width, height);
    }
  }

  componentWillUnmount() {
    this.cleanupInputListeners();
    document.removeEventListener("pointerlockchange", this.onPointerLockChange);
    this.throttle?.destroy();
    this.throttle = null;
    this.canvasRef = null;
    this.ctx = null;
    this.imageData = null;
  }

  private setupCanvas() {
    const canvas = document.getElementById(CANVAS_ID) as HTMLCanvasElement;

    if (!canvas) {
      return;
    }

    this.canvasRef = canvas;
    this.ctx = canvas.getContext("2d");
    this.imageData = null;
  }

  private ensureSubscribed() {
    if (this.subscribed) {
      return;
    }

    this.subscribed = true;

    Byond.binarySubscribe(async (data: ArrayBuffer) => {
      try {
        const raw = await this.decompressZlib(data);
        this.renderFrame(raw);
      } catch (err) {
        console.error("VGA: decompression failed", err);
      }
    });
  }

  private async decompressZlib(compressed: ArrayBuffer): Promise<Uint8Array> {
    const ds = new DecompressionStream("deflate");
    const stream = new Blob([compressed]).stream().pipeThrough(ds);
    return new Uint8Array(await new Response(stream).arrayBuffer());
  }

  private renderFrame(raw: Uint8Array) {
    const { width, height, supports_color } = this.props;
    const fbSize = width * height;
    const expectedSize = PAL_SIZE + fbSize;

    if (raw.byteLength !== expectedSize) {
      console.error(
        `VGA: unexpected frame size ${raw.byteLength}, expected ${expectedSize}`,
      );
      return;
    }

    if (!this.canvasRef || !this.ctx) {
      this.setupCanvas();

      if (!this.canvasRef || !this.ctx) {
        return;
      }
    }

    if (this.canvasRef.width !== width || this.canvasRef.height !== height) {
      this.canvasRef.width = width;
      this.canvasRef.height = height;
      this.imageData = null;
    }

    if (!this.imageData) {
      this.imageData = this.ctx.createImageData(width, height);
    }

    const rgba = this.imageData.data;

    if (supports_color) {
      for (let i = 0; i < fbSize; i++) {
        const palOffset = raw[PAL_SIZE + i] * 3;
        const j = i << 2;
        rgba[j] = raw[palOffset];
        rgba[j + 1] = raw[palOffset + 1];
        rgba[j + 2] = raw[palOffset + 2];
        rgba[j + 3] = 255;
      }
    } else {
      for (let i = 0; i < fbSize; i++) {
        const palOffset = raw[PAL_SIZE + i] * 3;
        const j = i << 2;
        const gray =
          (raw[palOffset] * 77 +
            raw[palOffset + 1] * 150 +
            raw[palOffset + 2] * 29) >>
          8;
        rgba[j] = gray;
        rgba[j + 1] = gray;
        rgba[j + 2] = gray;
        rgba[j + 3] = 255;
      }
    }

    this.ctx.putImageData(this.imageData, 0, 0);
    this.setState({ lastFrameSize: raw.byteLength });
  }

  private isCaptured(): boolean {
    return (
      this.canvasRef !== null && document.pointerLockElement === this.canvasRef
    );
  }

  private setupInputListeners() {
    const c = this.canvasRef;

    if (!c) {
      return;
    }

    c.addEventListener("keydown", this.onKeyDown);
    c.addEventListener("keyup", this.onKeyUp);
    c.addEventListener("blur", this.onBlur);
    c.addEventListener("mousedown", this.onMouseDown);
    c.addEventListener("mouseup", this.onMouseUp);
    c.addEventListener("mousemove", this.onMouseMove);
    c.addEventListener("wheel", this.onWheel, { passive: false });
    c.addEventListener("contextmenu", this.onContextMenu);
  }

  private cleanupInputListeners() {
    const c = this.canvasRef;

    if (!c) {
      return;
    }

    c.removeEventListener("keydown", this.onKeyDown);
    c.removeEventListener("keyup", this.onKeyUp);
    c.removeEventListener("blur", this.onBlur);
    c.removeEventListener("mousedown", this.onMouseDown);
    c.removeEventListener("mouseup", this.onMouseUp);
    c.removeEventListener("mousemove", this.onMouseMove);
    c.removeEventListener("wheel", this.onWheel);
    c.removeEventListener("contextmenu", this.onContextMenu);
  }

  private onPointerLockChange = () => {
    const captured = this.isCaptured();
    this.props.onCaptureChange?.(captured);

    if (captured) {
      this.canvasRef?.focus();
    } else {
      this.releaseAllKeys();
      this.mouseSubPixelX = 0;
      this.mouseSubPixelY = 0;
    }
  };

  private releaseAllKeys() {
    if (!this.throttle) {
      return;
    }

    for (const sc of this.pressedKeys) {
      this.throttle.key({ t: 2, sc, mod: 0 });
    }

    this.pressedKeys.clear();
    this.throttle.flush();
  }

  private onKeyDown = (e: KeyboardEvent) => {
    if (!this.isCaptured()) {
      return;
    }

    if (e.repeat) {
      e.preventDefault();
      return;
    }

    const sc = SCANCODE_MAP[e.code];

    if (sc === undefined) {
      return;
    }

    e.preventDefault();

    this.pressedKeys.add(sc);
    this.throttle?.key({ t: 1, sc, mod: getModifiers(e) });
  };

  private onKeyUp = (e: KeyboardEvent) => {
    if (!this.isCaptured()) {
      return;
    }

    const sc = SCANCODE_MAP[e.code];

    if (sc === undefined) {
      return;
    }

    e.preventDefault();

    this.pressedKeys.delete(sc);
    this.throttle?.key({ t: 2, sc, mod: getModifiers(e) });
  };

  private onBlur = () => {
    this.releaseAllKeys();
    this.mouseSubPixelX = 0;
    this.mouseSubPixelY = 0;
  };

  private onMouseDown = (e: MouseEvent) => {
    e.preventDefault();

    if (!this.isCaptured()) {
      this.canvasRef?.requestPointerLock();
      return;
    }

    const b = MOUSE_BUTTON_MAP[e.button] ?? 0;

    if (b === 0) {
      return;
    }

    this.throttle?.mouseButton({
      t: 1,
      b,
      dx: 0,
      dy: 0,
      sdx: 0,
      sdy: 0,
    });
  };

  private onMouseUp = (e: MouseEvent) => {
    if (!this.isCaptured()) {
      return;
    }

    e.preventDefault();

    const b = MOUSE_BUTTON_MAP[e.button] ?? 0;

    if (b === 0) {
      return;
    }

    this.throttle?.mouseButton({
      t: 2,
      b,
      dx: 0,
      dy: 0,
      sdx: 0,
      sdy: 0,
    });
  };

  private onMouseMove = (e: MouseEvent) => {
    if (!this.isCaptured()) {
      return;
    }

    this.mouseSubPixelX += e.movementX;
    this.mouseSubPixelY += e.movementY;

    const dx = Math.trunc(this.mouseSubPixelX / SCALE);
    const dy = Math.trunc(this.mouseSubPixelY / SCALE);

    this.mouseSubPixelX -= dx * SCALE;
    this.mouseSubPixelY -= dy * SCALE;

    this.throttle?.mouseMove(dx, dy);
  };

  private onWheel = (e: WheelEvent) => {
    if (!this.isCaptured()) {
      return;
    }

    e.preventDefault();

    this.throttle?.wheel(Math.sign(e.deltaX), Math.sign(e.deltaY));
  };

  private onContextMenu = (e: Event) => {
    e.preventDefault();
  };

  render() {
    const { width, height } = this.props;

    return (
      <canvas
        id={CANVAS_ID}
        width={width}
        height={height}
        tabIndex={0}
        style={{
          width: `${width * SCALE}px`,
          height: `${height * SCALE}px`,
          "image-rendering": "pixelated",
          display: "block",
          margin: "0 auto",
          background: "#000",
          outline: "none",
        }}
      />
    );
  }
}

type VgaPageProps = {
  data: VgaData;
  act: (action: string, params?: Record<string, any>) => void;
};

type VgaPageState = {
  captured: boolean;
};

class VgaPage extends Component<VgaPageProps, VgaPageState> {
  state: VgaPageState = { captured: false };

  handleCaptureChange = (captured: boolean) => {
    this.setState({ captured });
  };

  render() {
    const { data, act } = this.props;
    const { captured } = this.state;

    const width = data.width || DEFAULT_WIDTH;
    const height = data.height || DEFAULT_HEIGHT;
    const supports_color = data.supports_color !== 0;
    const maxMessagesPerSec =
      (data.max_messages_per_sec || DEFAULT_MAX_MESSAGES_PER_SEC) - 20;
    const turnedOn = (data.turned_on === 1 ? true : null) ?? false;

    const title = captured
      ? "Display - Captured"
      : "Display - Click to capture";

    return (
      <Window
        title={title}
        width={width * SCALE + 40}
        height={height * SCALE + 60}
      >
        <Window.Content>
          <VgaDisplay
            act={act}
            width={width}
            height={height}
            supports_color={supports_color}
            maxMessagesPerSec={maxMessagesPerSec}
            turnedOn={turnedOn}
            onCaptureChange={this.handleCaptureChange}
          />
        </Window.Content>
      </Window>
    );
  }
}

export const Vga = (props: any, context: any) => {
  const { act, data } = useBackend<VgaData>(context);
  return <VgaPage data={data} act={act} />;
};
