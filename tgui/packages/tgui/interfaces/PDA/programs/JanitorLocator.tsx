import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Loc = { x: number; y: number; dir: string; status: string };

function rndLoc(label: string): Loc {
  const ok = Math.random() > 0.18;
  if (!ok) return { x: 0, y: 0, dir: '—', status: `Unable to locate ${label}` };
  return {
    x: 20 + Math.floor(Math.random() * 180),
    y: 20 + Math.floor(Math.random() * 180),
    dir: ['N', 'S', 'E', 'W'][Math.floor(Math.random() * 4)],
    status: ['OK', 'Low', 'Idle', 'Active'][Math.floor(Math.random() * 4)],
  };
}

class JanitorLocatorApp extends Component<{ ctx: PdaProgramContext }> {
  private user = { x: 0, y: 0 };

  private mops: Loc[] = [];
  private buckets: Loc[] = [];
  private cleanbots: Loc[] = [];
  private carts: Loc[] = [];

  private busy = false;

  componentDidMount() {
    this.refresh();
  }

  private refresh = () => {
    if (this.busy) return;
    this.busy = true;
    this.forceUpdate();

    window.setTimeout(() => {
      const userOk = Math.random() > 0.12;
      this.user = userOk
        ? { x: 20 + Math.floor(Math.random() * 180), y: 20 + Math.floor(Math.random() * 180) }
        : { x: 0, y: 0 };

      this.mops = [rndLoc('Mop')];
      this.buckets = [rndLoc('Water Bucket')];
      this.cleanbots = [rndLoc('Clean Bot')];
      this.carts = [rndLoc('Janitorial Cart')];

      this.busy = false;
      this.forceUpdate();
    }, 320);
  };

  private renderLoc(labelGood: string, l: Loc, suffix?: string) {
    if (l.x === 0) {
      return <span style={{ color: '#f87171', fontWeight: 900 }}>{l.status}</span>;
    }
    return (
      <span style={{ color: '#aaffff', fontWeight: 800 }}>
        ({l.x} / {l.y}) — {l.dir} — Status: {l.status}{suffix ? ` — ${suffix}` : ''}
      </span>
    );
  }

  render() {
    const userText = this.user.x === 0
      ? <span style={{ color: '#f87171', fontWeight: 900 }}>Unknown</span>
      : <span style={{ color: '#aaffff', fontWeight: 900 }}>{this.user.x} / {this.user.y}</span>;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="broom" /> JANITORIAL SUPPLIES LOCATOR
          </div>
          <div className="PDAProgram__sub">UI-only mock • Cartridge utility</div>
        </div>

        <div className="PDAProgram__panel">
          <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />

          <div style={{ marginTop: 12 }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Current Location</div>
              <div className="PDAProgram__v">{userText}</div>
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Mop</div>
              <div className="PDAProgram__v">{this.renderLoc('Mop Location', this.mops[0])}</div>
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Water Bucket</div>
              <div className="PDAProgram__v">{this.renderLoc('Bucket Location', this.buckets[0], 'Water Level: ' + this.buckets[0].status)}</div>
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Clean Bot</div>
              <div className="PDAProgram__v">{this.renderLoc('Clean Bot Location', this.cleanbots[0])}</div>
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Janitorial Cart</div>
              <div className="PDAProgram__v">{this.renderLoc('Cart Location', this.carts[0])}</div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export const JanitorLocatorProgram: PdaProgram = {
  id: 'janitor_locator',
  title: 'Custodial Locator',
  icon: 'broom',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <JanitorLocatorApp ctx={ctx} />,
};
