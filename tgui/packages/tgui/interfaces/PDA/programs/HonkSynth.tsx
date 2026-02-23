import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

class HonkSynthApp extends Component<{ ctx: PdaProgramContext }> {
  private last: string | null = null;
  private error: string | null = null;
  private busy = false;

  private play = (preset: string) => {
    if (this.busy) return;
    this.busy = true;
    this.error = null;
    this.last = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.08;
      this.busy = false;
      if (fail) this.error = 'Horn module jammed. Try again.';
      else this.last = `HONK (${preset}) emitted.`;
      this.forceUpdate();
    }, 220);
  };

  render() {
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="face-grin-squint" /> HONK SYNTHESIZER
          </div>
          <div className="PDAProgram__sub">UI-only mock • Cartridge gimmick</div>
        </div>

        <div className="PDAProgram__panel">
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <Button content="Standard" onClick={() => this.play('standard')} />
            <Button content="Sad" onClick={() => this.play('sad')} />
            <Button content="Tri-Honk" onClick={() => this.play('tri')} />
            <Button content="Airhorn" onClick={() => this.play('airhorn')} />
          </div>

          {this.busy && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, opacity: 0.8 }}>
              Processing…
            </div>
          )}
          {this.last && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, opacity: 0.8 }}>
              {this.last}
            </div>
          )}
          {this.error && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, color: '#f87171', opacity: 1 }}>
              {this.error}
            </div>
          )}
        </div>
      </div>
    );
  }
}

export const HonkSynthProgram: PdaProgram = {
  id: 'honk_synth',
  title: 'Honk Synth',
  icon: 'face-grin-squint',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <HonkSynthApp ctx={ctx} />,
};
