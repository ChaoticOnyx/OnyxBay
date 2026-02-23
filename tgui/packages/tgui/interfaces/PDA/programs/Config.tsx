import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';
import { pdaThemeStore, type PdaScreenTheme } from '../themeStore';

type ThemeItem = {
  id: PdaScreenTheme;
  label: string;
  hint: string;
};

const THEMES: ThemeItem[] = [
  { id: 'green', label: 'Green', hint: 'Classic CRT' },
  { id: 'amber', label: 'Amber', hint: 'Terminal / retro' },
  { id: 'cyan', label: 'Cyan', hint: 'Cold phosphor' },
  { id: 'white', label: 'White', hint: 'High contrast' },
  { id: 'gray', label: 'Gray', hint: 'Neutral / dim' },
];

class ConfigApp extends Component<{ ctx: PdaProgramContext }> {
  private getTheme(): PdaScreenTheme {
    return pdaThemeStore.get();
  }

  private setTheme = (t: PdaScreenTheme) => {
    pdaThemeStore.set(t);
    this.forceUpdate();
  };

  render() {
    const { ctx } = this.props;
    const theme = this.getTheme();

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="gear" /> CONFIGURATION
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Theme & basic shell status
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Flashlight</div>
            <div className="PDAProgram__v">{ctx.flashlightOn ? 'ON' : 'OFF'}</div>
          </div>
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Cartridge</div>
            <div className="PDAProgram__v">{ctx.hasCartridge ? ctx.cartridgeType.toUpperCase() : 'NONE'}</div>
          </div>
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Active Program</div>
            <div className="PDAProgram__v">{ctx.activeProgramId.toUpperCase()}</div>
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Monitor Theme</div>
            <div className="PDAProgram__v">{theme.toUpperCase()}</div>
          </div>

          <div className="PDAThemeGrid">
            {THEMES.map(t => {
              const active = t.id === theme;
              return (
                <button
                  key={t.id}
                  className={cx('PDAThemeBtn', active && 'is-active')}
                  onClick={() => this.setTheme(t.id)}
                  title={t.hint}
                >
                  <div className="PDAThemeBtn__top">
                    <span className="PDAThemeBtn__label">{t.label}</span>
                    {active && <Icon name="check" className="PDAThemeBtn__check" />}
                  </div>
                  <div className="PDAThemeBtn__hint">{t.hint}</div>
                </button>
              );
            })}
          </div>

          <div className="PDAProgram__footerHint">
            Theme is UI-only (no backend). Use HOME tab to return.
          </div>
        </div>
      </div>
    );
  }
}

export const ConfigProgram: PdaProgram = {
  id: 'config',
  title: 'CFG',
  icon: 'gear',
  View: (ctx) => <ConfigApp ctx={ctx} />,
};
