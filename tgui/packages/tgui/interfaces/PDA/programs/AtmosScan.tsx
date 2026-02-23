import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type Reading = {
  ok: boolean;
  pressure: number; // kPa
  temp: number;     // °C
  oxygen: number;   // %
  nitrogen: number; // %
  carbon_dioxide: number; // %
  other: number;    // %
};

function clamp(n: number, a: number, b: number) {
  return Math.max(a, Math.min(b, n));
}

function mkReading(): Reading {
  const ok = Math.random() > 0.12;
  if (!ok) {
    return {
      ok: false,
      pressure: 0,
      temp: 0,
      oxygen: 0,
      nitrogen: 0,
      carbon_dioxide: 0,
      other: 0,
    };
  }

  const pressure = clamp(101 + (Math.random() * 30 - 15), 60, 140);
  const temp = clamp(21 + (Math.random() * 16 - 8), -5, 60);

  // keep roughly sane totals
  const oxygen = clamp(20.5 + (Math.random() * 6 - 3), 10, 26);
  const carbon_dioxide = clamp(0.4 + (Math.random() * 2.0), 0, 8);
  const other = clamp((Math.random() < 0.08) ? (Math.random() * 6) : 0, 0, 10);
  const nitrogen = clamp(100 - oxygen - carbon_dioxide - other, 60, 90);

  return {
    ok: true,
    pressure: Math.round(pressure * 10) / 10,
    temp: Math.round(temp * 10) / 10,
    oxygen: Math.round(oxygen * 10) / 10,
    nitrogen: Math.round(nitrogen * 10) / 10,
    carbon_dioxide: Math.round(carbon_dioxide * 10) / 10,
    other: Math.round(other * 10) / 10,
  };
}

function classByRange(kind: 'pressure' | 'temp' | 'oxygen' | 'nitrogen' | 'co2', v: number): 'good' | 'average' | 'bad' {
  if (kind === 'pressure') {
    if (v < 80 || v > 120) return 'bad';
    if (v < 95 || v > 110) return 'average';
    return 'good';
  }
  if (kind === 'temp') {
    if (v < 5 || v > 35) return 'bad';
    if (v < 15 || v > 25) return 'average';
    return 'good';
  }
  if (kind === 'oxygen') {
    if (v < 17) return 'bad';
    if (v < 19) return 'average';
    return 'good';
  }
  if (kind === 'nitrogen') {
    if (v > 82) return 'bad';
    if (v > 80) return 'average';
    return 'good';
  }
  // co2
  if (v > 5) return 'bad';
  return 'good';
}

class AtmosScanApp extends Component<{ ctx: PdaProgramContext }> {
  private reading: Reading = mkReading();
  private busy = false;

  private refresh = () => {
    if (this.busy) return;
    this.busy = true;
    this.forceUpdate();

    window.setTimeout(() => {
      this.reading = mkReading();
      this.busy = false;
      this.forceUpdate();
    }, 280);
  };

  render() {
    const r = this.reading;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="wind" /> ATMOSPHERIC SCAN
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Portable sensor reading
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div style={{ display: 'flex', gap: 8 }}>
            <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />
          </div>

          <div style={{ marginTop: 10 }}>
            {!r.ok ? (
              <div style={{ color: '#f87171', fontWeight: 900 }}>
                Unable to get air reading
              </div>
            ) : (
              <>
                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Pressure</div>
                  <div className="PDAProgram__v">
                    <span className={classByRange('pressure', r.pressure)}>{r.pressure} kPa</span>
                  </div>
                </div>

                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Temperature</div>
                  <div className="PDAProgram__v">
                    <span className={classByRange('temp', r.temp)}>{r.temp} °C</span>
                  </div>
                </div>

                <div style={{ height: 8 }} />

                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Oxygen</div>
                  <div className="PDAProgram__v">
                    <span className={classByRange('oxygen', r.oxygen)}>{r.oxygen}%</span>
                  </div>
                </div>

                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Nitrogen</div>
                  <div className="PDAProgram__v">
                    <span className={classByRange('nitrogen', r.nitrogen)}>{r.nitrogen}%</span>
                  </div>
                </div>

                <div className="PDAProgram__row">
                  <div className="PDAProgram__k">Carbon Dioxide</div>
                  <div className="PDAProgram__v">
                    <span className={classByRange('co2', r.carbon_dioxide)}>{r.carbon_dioxide}%</span>
                  </div>
                </div>

                {r.other > 0 && (
                  <div className="PDAProgram__row">
                    <div className="PDAProgram__k">Unknown</div>
                    <div className="PDAProgram__v" style={{ color: '#f87171' }}>
                      {r.other}%
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        </div>

        <div className="PDAProgram__footerHint">
          Values are simulated.
        </div>
      </div>
    );
  }
}

export const AtmosScanProgram: PdaProgram = {
  id: 'atmos_scan',
  title: 'Atmos Scan',
  icon: 'wind',
  View: (ctx) => <AtmosScanApp ctx={ctx} />,
};
