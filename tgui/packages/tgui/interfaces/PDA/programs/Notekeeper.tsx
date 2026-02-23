import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

class NotekeeperApp extends Component<{ ctx: PdaProgramContext }> {
  private notes = `• Shift goals:
  - Don't die
  - Don't trust the clown
  - Print forms responsibly

• TODO:
  - Check maintenance airlocks
  - Buy insulation gloves
  - Ping Engineering about power spikes`;

  private draft = '';
  private editing = false;

  private busy = false;
  private error: string | null = null;

  private startEdit = () => {
    this.editing = true;
    this.draft = this.notes;
    this.error = null;
    this.forceUpdate();
  };

  private cancelEdit = () => {
    this.editing = false;
    this.draft = '';
    this.error = null;
    this.forceUpdate();
  };

  private setDraft = (v: string) => {
    this.draft = v;
    this.forceUpdate();
  };

  private save = () => {
    if (this.busy) return;

    const text = (this.draft || '').trimEnd();

    this.busy = true;
    this.error = null;
    this.forceUpdate();

    // UI-only mock “save”
    window.setTimeout(() => {
      const fail = Math.random() < 0.12;
      if (fail) {
        this.busy = false;
        this.error = 'Write error: local storage unavailable.';
        this.forceUpdate();
        return;
      }

      this.notes = text || '(empty)';
      this.busy = false;
      this.editing = false;
      this.draft = '';
      this.forceUpdate();
    }, 350);
  };

  private clear = () => {
    if (this.busy) return;
    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      this.notes = '(empty)';
      this.busy = false;
      this.editing = false;
      this.draft = '';
      this.forceUpdate();
    }, 250);
  };

  render() {
    const { ctx } = this.props;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="file-lines" /> NOTEKEEPER
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Notes are local
          </div>
        </div>

        {!this.editing ? (
          <div className="PDAProgram__panel">
            {this.error && (
              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Error</div>
                <div className="PDAProgram__v" style={{ color: '#f87171' }}>{this.error}</div>
              </div>
            )}

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Owner</div>
              <div className="PDAProgram__v">{ctx.cartridgeType.toUpperCase()}</div>
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Notes</div>
              <div className="PDAProgram__v" style={{ fontWeight: 600, whiteSpace: 'pre-wrap' }}>
                {this.notes}
              </div>
            </div>

            <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
              <Button
                icon="pencil"
                content="Edit Notes"
                onClick={this.startEdit}
                disabled={this.busy}
              />
              <Button
                icon="trash"
                content="Clear"
                onClick={this.clear}
                disabled={this.busy}
              />
            </div>
          </div>
        ) : (
          <div className="PDAProgram__panel">
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Edit</div>
              <div className="PDAProgram__v">{this.busy ? 'SAVING…' : 'READY'}</div>
            </div>

            {this.error && (
              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Error</div>
                <div className="PDAProgram__v" style={{ color: '#f87171' }}>{this.error}</div>
              </div>
            )}

            <Input
              value={this.draft}
              placeholder="Notes…"
              onInput={(_, v) => this.setDraft(String(v))}
              // @ts-ignore
              multiline
              style={{ height: '180px' }}
            />

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 10 }}>
              <Button content="Cancel" onClick={this.cancelEdit} disabled={this.busy} />
              <Button icon="check" content="Save" onClick={this.save} disabled={this.busy} />
            </div>
          </div>
        )}
      </div>
    );
  }
}

export const NotekeeperProgram: PdaProgram = {
  id: 'notekeeper',
  title: 'Notekeeper',
  icon: 'file-lines',
  View: (ctx) => <NotekeeperApp ctx={ctx} />,
};
