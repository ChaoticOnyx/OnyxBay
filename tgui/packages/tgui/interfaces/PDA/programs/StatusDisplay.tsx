import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Mode = 'blank' | 'time' | 'shuttle' | 'message' | 'alert' | 'image:default' | 'image:lockdown' | 'image:biohazard';

class StatusDisplayApp extends Component<{ ctx: PdaProgramContext }> {
  private mode: Mode = 'blank';
  private msg1 = 'NSS EXODUS';
  private msg2 = 'ALL SYSTEMS NOMINAL';

  private editLine: 1 | 2 | null = null;
  private draft = '';

  private last: string | null = null;

  private setMode = (m: Mode) => {
    this.mode = m;
    this.last = `Status set: ${m}`;
    this.forceUpdate();
  };

  private openEdit = (line: 1 | 2) => {
    this.editLine = line;
    this.draft = line === 1 ? this.msg1 : this.msg2;
    this.forceUpdate();
  };

  private closeEdit = () => {
    this.editLine = null;
    this.draft = '';
    this.forceUpdate();
  };

  private applyEdit = () => {
    const v = (this.draft || '').trim();
    if (this.editLine === 1) this.msg1 = v || '';
    if (this.editLine === 2) this.msg2 = v || '';
    this.last = `Message line ${this.editLine} updated`;
    this.editLine = null;
    this.draft = '';
    this.forceUpdate();
  };

  render() {
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="display" /> STATUS DISPLAYS INTERLINK
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Broadcast presets
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Mode</div>
            <div className="PDAProgram__v">{this.mode}</div>
          </div>

          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 8 }}>
            <Button icon="trash" content="Clear" onClick={() => this.setMode('blank')} />
            <Button icon="clock" content="Local Time" onClick={() => this.setMode('time')} />
            <Button icon="shuttle-space" content="Shuttle ETA" onClick={() => this.setMode('shuttle')} />
            <Button icon="message" content="Message" onClick={() => this.setMode('message')} />
          </div>

          <div style={{ marginTop: 12 }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Message line 1</div>
              <div className="PDAProgram__v" style={{ fontSize: 11, fontWeight: 800 }}>{this.msg1 || '—'}</div>
            </div>
            <div style={{ marginTop: 6 }}>
              <Button icon="pencil" content="Set line 1" onClick={() => this.openEdit(1)} />
            </div>

            <div className="PDAProgram__row" style={{ marginTop: 12 }}>
              <div className="PDAProgram__k">Message line 2</div>
              <div className="PDAProgram__v" style={{ fontSize: 11, fontWeight: 800 }}>{this.msg2 || '—'}</div>
            </div>
            <div style={{ marginTop: 6 }}>
              <Button icon="pencil" content="Set line 2" onClick={() => this.openEdit(2)} />
            </div>
          </div>

          <div style={{ marginTop: 14 }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Alert</div>
              <div className="PDAProgram__v">Presets</div>
            </div>

            <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 8 }}>
              <Button icon="triangle-exclamation" content="None" onClick={() => this.setMode('image:default')} />
              <Button icon="shield" content="Security Level" onClick={() => this.setMode('alert')} />
              <Button icon="lock" content="Lockdown" onClick={() => this.setMode('image:lockdown')} />
              <Button icon="radiation" content="Biohazard" onClick={() => this.setMode('image:biohazard')} />
            </div>
          </div>

          {this.last && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 12, opacity: 0.8 }}>
              {this.last}
            </div>
          )}
        </div>

        {this.editLine && (
          <div className="PdaMessengerModal" onClick={this.closeEdit}>
            <div className="PdaMessengerModal__card" onClick={(e) => e.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="pencil" /> Set Message Line {this.editLine}
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Text</div>
                  <Input
                    value={this.draft}
                    placeholder="Enter message…"
                    onInput={(_, v) => { this.draft = String(v); this.forceUpdate(); }}
                    onKeyDown={(e: KeyboardEvent) => {
                      // @ts-ignore
                      if (e.key === 'Enter') this.applyEdit();
                    }}
                  />
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeEdit} />
                <Button content="Apply" icon="check" onClick={this.applyEdit} />
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }
}

export const StatusDisplayProgram: PdaProgram = {
  id: 'status_display',
  title: 'Status Display',
  icon: 'display',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <StatusDisplayApp ctx={ctx} />,
};
