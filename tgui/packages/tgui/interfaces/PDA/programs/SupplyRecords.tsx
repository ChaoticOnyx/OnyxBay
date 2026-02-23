import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Order = { Number: number; Name: string; OrderedBy: string; Comment: string };

class SupplyRecordsApp extends Component<{ ctx: PdaProgramContext }> {
  private shuttle_moving = false;
  private shuttle_eta = '00:04';
  private shuttle_loc = 'Cargo Bay';

  private approved: Order[] = [
    { Number: 1201, Name: 'Engineering Materials', OrderedBy: "M. O'Brien", Comment: 'Urgent: cable & metal' },
    { Number: 1204, Name: 'Medical Supplies', OrderedBy: 'M. Solus', Comment: '' },
  ];

  private requests: Order[] = [
    { Number: 1210, Name: 'Kitchen Bulk Crate', OrderedBy: 'B. Hauer', Comment: 'Don’t ask.' },
  ];

  private busy = false;
  private error: string | null = null;

  private refresh = () => {
    if (this.busy) return;
    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.08;
      if (fail) {
        this.error = 'Cargo console unreachable.';
      } else {
        this.shuttle_moving = Math.random() < 0.45;
        this.shuttle_eta = `00:0${Math.floor(1 + Math.random() * 8)}`;
        this.shuttle_loc = this.shuttle_moving ? 'En route' : 'Cargo Bay';
      }
      this.busy = false;
      this.forceUpdate();
    }, 320);
  };

  renderOrders(list: Order[], emptyText: string) {
    if (!list.length) {
      return <span style={{ opacity: 0.75 }}>{emptyText}</span>;
    }
    return (
      <div style={{ whiteSpace: 'pre-wrap' }}>
        {list.map(o => (
          <div key={o.Number} style={{ marginBottom: 10 }}>
            <span style={{ color: '#aaffff', fontWeight: 900 }}>#{o.Number}</span>
            {' '}— {o.Name} approved by {o.OrderedBy}
            {o.Comment ? (
              <div style={{ opacity: 0.8, marginTop: 2 }}>{o.Comment}</div>
            ) : null}
          </div>
        ))}
      </div>
    );
  }

  render() {
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="box" /> SUPPLY RECORD INTERLINK
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Quartermaster utility (mapped to admin cartridge)
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
            <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />
          </div>

          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Location</div>
            <div className="PDAProgram__v">
              {this.shuttle_moving ? `Moving to dock (${this.shuttle_eta})` : `Shuttle at ${this.shuttle_loc}`}
            </div>
          </div>

          {this.error && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, color: '#f87171', opacity: 1 }}>
              {this.error}
            </div>
          )}

          <div style={{ marginTop: 12 }}>
            <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.10em' }}>CURRENT APPROVED ORDERS</div>
            <div style={{ marginTop: 8 }}>
              {this.renderOrders(this.approved, 'No current approved orders')}
            </div>

            <div style={{ marginTop: 14, color: '#aaffff', fontWeight: 900, letterSpacing: '0.10em' }}>CURRENT REQUESTED ORDERS</div>
            <div style={{ marginTop: 8 }}>
              {this.renderOrders(this.requests, 'No current requested orders')}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export const SupplyRecordsProgram: PdaProgram = {
  id: 'supply_records',
  title: 'Supply Records',
  icon: 'box',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <SupplyRecordsApp ctx={ctx} />,
};
