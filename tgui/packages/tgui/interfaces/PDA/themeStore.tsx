export type PdaScreenTheme =
  | 'green'
  | 'amber'
  | 'cyan'
  | 'white'
  | 'gray';

type Listener = () => void;

class ThemeStore {
  private theme: PdaScreenTheme = 'green';
  private listeners: Listener[] = [];

  get(): PdaScreenTheme {
    return this.theme;
  }

  set(next: PdaScreenTheme) {
    if (next === this.theme) return;
    this.theme = next;
    this.listeners.forEach(fn => fn());
  }

  subscribe(fn: Listener) {
    this.listeners.push(fn);
    return () => {
      const idx = this.listeners.indexOf(fn);
      if (idx >= 0) this.listeners.splice(idx, 1);
    };
  }
}

export const pdaThemeStore = new ThemeStore();
