import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Sensor = { id: string; name_tag: string };
type ApcRow = { name: string; cell_charge: number; total_load: number };

const SENSORS: Sensor[] = [
  { id: 'ss2', name_tag: 'SUBSTATION_2' },
  { id: 'eng', name_tag: 'ENGINE_ROOM' },
  { id: 'sci', name_tag: 'SCIENCE_WING' },
];

function mkApcs(seed: number): ApcRow[] {
  const base = (seed % 7) + 1;
  return [
    { name: 'Hallway APC', cell_charge: 70 + base, total_load: 12 + base },
    { name: 'Engineering APC', cell_charge: 55 + base, total_load: 20 + base * 2 },
    { name: 'Atmos APC', cell_charge: 63 + base, total_load: 18 + base },
  ];
}

class PowerMonitorApp extends Component<{ ctx: PdaProgramContext }> {
  private stage: 'select' | 'reading' = 'select';
  private selected: Sensor | null = null;

  private busy = false;
  private error: string | null = null;

  private apcs: ApcRow[] = [];
  private total_avail = 0;
  private total_used_all = 0;

  private select = (s: Sensor) => {
    this.selected = s;
    this.stage = 'reading';
    this.refresh();
  };

  private back = () => {
    this.stage = 'select';
    this.selected = null;
    this.error = null;
    this.forceUpdate();
  };

  private refresh = () => {
    if (!this.selected || this.busy) return;

    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.15;
      this.busy = false;

      if (fail) {
        this.error = 'Unable to contact sensor controller! Please retry.';
        this.forceUpdate();
        return;
      }

      const seed = Date.now();
      this.apcs = mkApcs(seed);
      this.total_used_all = Math.round(this.apcs.reduce((a, r) => a + r.total_load, 0) * 10) / 10;
      this.total_avail = Math.round((this.total_used_all + 35 + (seed % 10)) * 10) / 10;

      this.forceUpdate();
    }, 350);
  };

  render() {
    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="bolt" /> POWER MONITOR
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Engineering cartridge utility
          </div>
        </div>

        {this.stage === 'select' ? (
          <div className="PDAProgram__panel">
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Available Sensors</div>
              <div className="PDAProgram__v">{SENSORS.length}</div>
            </div>

            <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {SENSORS.map(s => (
                <Button
                  key={s.id}
                  icon="plus"
                  content={s.name_tag}
                  onClick={() => this.select(s)}
                />
              ))}
            </div>
          </div>
        ) : (
          <div className="PDAProgram__panel">
            <div style={{ display: 'flex', gap: 8, marginBottom: 10 }}>
              <Button icon="arrow-left" content="Back" onClick={this.back} />
              <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />
            </div>

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Sensor</div>
              <div className="PDAProgram__v">{this.selected?.name_tag}</div>
            </div>

            {this.error ? (
              <div className="PDAProgram__footerHint" style={{ marginTop: 10, color: '#f87171', opacity: 1 }}>
                {this.error}
              </div>
            ) : (
              <>
                <div style={{ marginTop: 10 }}>
                  <table style={{ width: '100%', fontSize: 12, borderCollapse: 'collapse' }}>
                    <thead style={{ opacity: 0.65, textTransform: 'uppercase', letterSpacing: '0.10em', fontSize: 10 }}>
                      <tr>
                        <th style={{ textAlign: 'left', padding: '4px 0' }}>Area</th>
                        <th style={{ textAlign: 'right', padding: '4px 0' }}>Cell %</th>
                        <th style={{ textAlign: 'right', padding: '4px 0' }}>Load</th>
                      </tr>
                    </thead>
                    <tbody>
                      {this.apcs.map((r, i) => (
                        <tr key={i} style={{ borderBottom: '1px solid rgba(79,255,153,0.08)' }}>
                          <td style={{ padding: '6px 0' }}>{r.name}</td>
                          <td style={{ padding: '6px 0', textAlign: 'right' }}>{r.cell_charge}%</td>
                          <td style={{ padding: '6px 0', textAlign: 'right' }}>{r.total_load}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div style={{ marginTop: 10, fontSize: 12, fontWeight: 800, color: '#aaffff' }}>
                  Available: {this.total_avail}
                  <br />
                  Load: {this.total_used_all}
                </div>
              </>
            )}
          </div>
        )}
      </div>
    );
  }
}

export const PowerMonitorProgram: PdaProgram = {
  id: 'power_monitor',
  title: 'Power Monitor',
  icon: 'bolt',
  canRun: (ctx) => ctx.cartridgeType === 'engineering',
  View: (ctx) => <PowerMonitorApp ctx={ctx} />,
};
