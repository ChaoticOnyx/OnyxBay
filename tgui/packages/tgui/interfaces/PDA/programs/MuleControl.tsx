import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Mule = {
  ref: string;
  name: string;
  location: string;
  home: string;
  target: string;
  load: string;
  mode: 0 | 1 | 2 | 3;
};

function modeText(m: Mule['mode']) {
  if (m === 0) return 'Idle';
  if (m === 1) return 'Moving';
  if (m === 2) return 'Unloading';
  return 'Calculating path';
}

class MuleControlApp extends Component<{ ctx: PdaProgramContext }> {
  private mules: Mule[] = [
    { ref: 'm1', name: '01', location: 'Cargo Bay', home: 'Cargo Bay', target: 'Arrivals', load: '0 kg', mode: 0 },
    { ref: 'm2', name: '02', location: 'Hallway', home: 'Cargo Bay', target: 'Engineering', load: '45 kg', mode: 1 },
  ];

  private destDraft = '';
  private activeRef: string | null = null;

  private last: string | null = null;
  private error: string | null = null;

  private setActive = (ref: string) => {
    this.activeRef = ref;
    this.destDraft = '';
    this.error = null;
    this.last = null;
    this.forceUpdate();
  };

  private get active(): Mule | null {
    if (!this.activeRef) return null;
    return this.mules.find(m => m.ref === this.activeRef) || null;
  }

  private cmd = (command: 'Home' | 'SetD' | 'GoTD' | 'Stop') => {
    const m = this.active;
    if (!m) return;

    this.error = null;

    if (command === 'SetD') {
      const d = (this.destDraft || '').trim();
      if (!d) {
        this.error = 'Destination required.';
        this.forceUpdate();
        return;
      }
      m.target = d;
      this.last = `Destination set: ${d}`;
      this.forceUpdate();
      return;
    }

    if (command === 'Home') {
      m.target = m.home;
      m.mode = 1;
      this.last = 'Returning home.';
      this.forceUpdate();
      return;
    }

    if (command === 'GoTD') {
      m.mode = 1;
      this.last = `Moving to: ${m.target}`;
      this.forceUpdate();
      return;
    }

    // Stop
    m.mode = 0;
    this.last = 'Stopped.';
    this.forceUpdate();
  };

  render() {
    const active = this.active;

    return (
      <div className="PDAProgram PDAProgram--generic" style={{ height: '100%', minHeight: 0 }}>
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="truck" /> MULE CONTROL
          </div>
          <div className="PDAProgram__sub">UI-only mock • Delivery bot control</div>
        </div>

        <div style={{ display: 'flex', gap: 10, minHeight: 0, height: '100%' }}>
          <div className="PDAProgram__panel" style={{ width: 260, flex: '0 0 auto', overflow: 'auto' }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Mulebots</div>
              <div className="PDAProgram__v">{this.mules.length}</div>
            </div>

            <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {this.mules.map(m => (
                <Button
                  key={m.ref}
                  icon="circle-arrow-right"
                  content={`Mulebot #${m.name} (${modeText(m.mode)})`}
                  onClick={() => this.setActive(m.ref)}
                />
              ))}
            </div>
          </div>

          <div className="PDAProgram__panel" style={{ flex: '1 1 auto', minHeight: 0, overflow: 'auto' }}>
            {!active ? (
              <div className="PDAProgram__footerHint">Select a Mulebot.</div>
            ) : (
              <>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Mulebot</div>
                  <div className="PDAProgram__v">#{active.name}</div>
                </div>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Location</div>
                  <div className="PDAProgram__v">{active.location}</div>
                </div>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Home</div>
                  <div className="PDAProgram__v">{active.home}</div>
                </div>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Target</div>
                  <div className="PDAProgram__v">{active.target}</div>
                </div>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Load</div>
                  <div className="PDAProgram__v">{active.load}</div>
                </div>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Status</div>
                  <div className="PDAProgram__v">{modeText(active.mode)}</div>
                </div>

                <div style={{ marginTop: 12, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                  <Button content="Go home" onClick={() => this.cmd('Home')} />
                  <Button content="Go" onClick={() => this.cmd('GoTD')} />
                  <Button content="Stop" onClick={() => this.cmd('Stop')} />
                </div>

                <div style={{ marginTop: 12 }}>
                  <div className="PDAProgram__row">
                    <div className="PDAProgram__k">Set destination</div>
                    <div className="PDAProgram__v">—</div>
                  </div>
                  <Input
                    value={this.destDraft}
                    placeholder="e.g. Engineering"
                    onInput={(_, v) => { this.destDraft = String(v); this.forceUpdate(); }}
                  />
                  <div style={{ marginTop: 8 }}>
                    <Button content="Set destination" onClick={() => this.cmd('SetD')} />
                  </div>
                </div>

                {this.error && (
                  <div className="PDAProgram__footerHint" style={{ marginTop: 10, color: '#f87171', opacity: 1 }}>
                    {this.error}
                  </div>
                )}
                {this.last && (
                  <div className="PDAProgram__footerHint" style={{ marginTop: 10, opacity: 0.8 }}>
                    {this.last}
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      </div>
    );
  }
}

export const MuleControlProgram: PdaProgram = {
  id: 'mule_control',
  title: 'Mule Control',
  icon: 'truck',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <MuleControlApp ctx={ctx} />,
};
