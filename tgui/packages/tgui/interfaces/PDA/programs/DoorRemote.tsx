import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Door = { id: string; name: string; locked: boolean };

class DoorRemoteApp extends Component<{ ctx: PdaProgramContext }> {
  private doors: Door[] = [
    { id: 'd1', name: 'Bridge Door', locked: true },
    { id: 'd2', name: 'Engineering Airlock', locked: false },
    { id: 'd3', name: 'Medbay Entrance', locked: false },
  ];

  private q = '';
  private busy = false;
  private error: string | null = null;

  private setQ = (v: string) => {
    this.q = v;
    this.forceUpdate();
  };

  private toggleDoor = (id: string) => {
    if (this.busy) return;
    const d = this.doors.find(x => x.id === id);
    if (!d) return;

    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.10;
      this.busy = false;

      if (fail) {
        this.error = `Door "${d.name}" did not respond.`;
      } else {
        d.locked = !d.locked;
      }
      this.forceUpdate();
    }, 260);
  };

  render() {
    const list = this.doors.filter(d => !this.q || d.name.toLowerCase().includes(this.q.toLowerCase()));

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="door-closed" /> REMOTE DOOR TOGGLE
          </div>
          <div className="PDAProgram__sub">UI-only mock • Access-controlled utility</div>
        </div>

        <div className="PDAProgram__panel">
          <Input
            value={this.q}
            placeholder="Filter doors…"
            onInput={(_, v) => this.setQ(String(v))}
          />

          {this.error && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 8, color: '#f87171', opacity: 1 }}>
              {this.error}
            </div>
          )}

          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {list.length === 0 ? (
              <div className="PDAProgram__footerHint">No doors.</div>
            ) : (
              list.map(d => (
                <Button
                  key={d.id}
                  icon={d.locked ? 'lock' : 'lock-open'}
                  content={`${d.name} — ${d.locked ? 'LOCKED' : 'UNLOCKED'}`}
                  onClick={() => this.toggleDoor(d.id)}
                  disabled={this.busy}
                />
              ))
            )}
          </div>
        </div>
      </div>
    );
  }
}

export const DoorRemoteProgram: PdaProgram = {
  id: 'door_remote',
  title: 'Toggle Door',
  icon: 'door-closed',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <DoorRemoteApp ctx={ctx} />,
};
