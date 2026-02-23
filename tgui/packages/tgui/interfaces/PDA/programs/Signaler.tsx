import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

class SignalerApp extends Component<{ ctx: PdaProgramContext }> {
  private freq = 145.9;
  private code = 30;

  private busy = false;
  private last: string | null = null;
  private error: string | null = null;

  private nudgeFreq = (delta: number) => {
    this.freq = Math.round((this.freq + delta) * 10) / 10;
    if (this.freq < 100.0) this.freq = 100.0;
    if (this.freq > 999.9) this.freq = 999.9;
    this.forceUpdate();
  };

  private nudgeCode = (delta: number) => {
    this.code += delta;
    if (this.code < 1) this.code = 1;
    if (this.code > 100) this.code = 100;
    this.forceUpdate();
  };

  private send = () => {
    if (this.busy) return;
    this.busy = true;
    this.last = null;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.10;
      this.busy = false;
      if (fail) {
        this.error = 'Transmit failed: no carrier.';
      } else {
        this.last = `Signal sent @ ${this.freq.toFixed(1)} / code ${this.code}`;
      }
      this.forceUpdate();
    }, 350);
  };

  render() {
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="tower-broadcast" /> REMOTE SIGNALING SYSTEM
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Cartridge utility
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Frequency</div>
            <div className="PDAProgram__v">{this.freq.toFixed(1)}</div>
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
            <Button content="-1" onClick={() => this.nudgeFreq(-1)} />
            <Button content="-.2" onClick={() => this.nudgeFreq(-0.2)} />
            <Button content="+.2" onClick={() => this.nudgeFreq(+0.2)} />
            <Button content="+1" onClick={() => this.nudgeFreq(+1)} />
          </div>

          <div className="PDAProgram__row" style={{ marginTop: 12 }}>
            <div className="PDAProgram__k">Code</div>
            <div className="PDAProgram__v">{this.code}</div>
          </div>

          <div style={{ display: 'flex', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
            <Button content="-5" onClick={() => this.nudgeCode(-5)} />
            <Button content="-1" onClick={() => this.nudgeCode(-1)} />
            <Button content="+1" onClick={() => this.nudgeCode(+1)} />
            <Button content="+5" onClick={() => this.nudgeCode(+5)} />
          </div>

          <div style={{ marginTop: 12 }}>
            <Button icon="satellite-dish" content={this.busy ? 'Sending…' : 'Send Signal'} onClick={this.send} />
          </div>

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

export const SignalerProgram: PdaProgram = {
  id: 'signaler',
  title: 'Signaler',
  icon: 'tower-broadcast',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <SignalerApp ctx={ctx} />,
};
