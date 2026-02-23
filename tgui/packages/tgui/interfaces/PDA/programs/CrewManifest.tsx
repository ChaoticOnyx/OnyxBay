import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';

type CrewRow = {
  id: string;
  name: string;
  job: string;
  dept: 'Command' | 'Security' | 'Engineering' | 'Medical' | 'Science' | 'Service' | 'Civilian';
  status: 'On Station' | 'Off Station' | 'Missing' | 'SSD';
};

const CREW_MOCK: CrewRow[] = [
  { id: '1', name: 'S. Batten', job: 'Captain', dept: 'Command', status: 'On Station' },
  { id: '2', name: 'M. Solus', job: 'Chief Medical Officer', dept: 'Medical', status: 'On Station' },
  { id: '3', name: "M. O'Brien", job: 'Chief Engineer', dept: 'Engineering', status: 'On Station' },
  { id: '4', name: 'I. Kessler', job: 'Head of Security', dept: 'Security', status: 'SSD' },
  { id: '5', name: 'J. Doe', job: 'Assistant', dept: 'Civilian', status: 'On Station' },
  { id: '6', name: 'L. Vance', job: 'Scientist', dept: 'Science', status: 'On Station' },
  { id: '7', name: 'P. Griggs', job: 'Station Engineer', dept: 'Engineering', status: 'Off Station' },
  { id: '8', name: 'A. Wren', job: 'Paramedic', dept: 'Medical', status: 'On Station' },
  { id: '9', name: 'B. Hauer', job: 'Bartender', dept: 'Service', status: 'On Station' },
  { id: '10', name: 'C. Tann', job: 'Janitor', dept: 'Service', status: 'Missing' },
];

class CrewManifestApp extends Component<{ ctx: PdaProgramContext }> {
  private q = '';
  private selectedId: string | null = null;

  private busy = false;
  private error: string | null = null;

  private refresh = () => {
    if (this.busy) return;
    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const fail = Math.random() < 0.10;
      this.busy = false;
      this.error = fail ? 'Manifest cache unavailable. Retry.' : null;
      this.forceUpdate();
    }, 300);
  };

  private setQuery = (v: string) => {
    this.q = v;
    this.forceUpdate();
  };

  private select = (id: string) => {
    this.selectedId = id;
    this.forceUpdate();
  };

  render() {
    const list = CREW_MOCK
      .filter(r => !this.q || `${r.name} ${r.job} ${r.dept}`.toLowerCase().includes(this.q.toLowerCase()))
      .slice()
      .sort((a, b) => a.dept.localeCompare(b.dept) || a.job.localeCompare(b.job) || a.name.localeCompare(b.name));

    const sel = this.selectedId ? CREW_MOCK.find(x => x.id === this.selectedId) || null : null;

    return (
      <div className="PDAProgram PDAProgram--generic" style={{ height: '100%', minHeight: 0 }}>
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="users" /> CREW MANIFEST
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • Cached station roster
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <Input
              value={this.q}
              placeholder="Search name / job / department…"
              onInput={(_, v) => this.setQuery(String(v))}
            />
            <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />
          </div>

          {this.error && (
            <div className="PDAProgram__row" style={{ marginTop: 8 }}>
              <div className="PDAProgram__k">Error</div>
              <div className="PDAProgram__v" style={{ color: '#f87171' }}>{this.error}</div>
            </div>
          )}
        </div>

        <div style={{ display: 'flex', gap: 10, minHeight: 0, height: '100%' }}>
          <div className="PDAProgram__panel" style={{ flex: '1 1 auto', minHeight: 0, overflow: 'auto' }}>
            {list.length === 0 ? (
              <div className="PDAProgram__footerHint">No entries found.</div>
            ) : (
              list.map(r => (
                <div
                  key={r.id}
                  className={cx('PDAProgram__listItem', this.selectedId === r.id && 'is-active')}
                  style={{
                    cursor: 'pointer',
                    padding: '6px 0',
                    outline: this.selectedId === r.id ? '1px solid rgba(79,255,153,0.25)' : 'none',
                  }}
                  onClick={() => this.select(r.id)}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', gap: 10 }}>
                    <div style={{ fontWeight: 800, color: '#aaffff' }}>{r.name}</div>
                    <div style={{ fontSize: 10, opacity: 0.6, textTransform: 'uppercase', letterSpacing: '0.10em' }}>
                      {r.dept}
                    </div>
                  </div>
                  <div style={{ fontSize: 11, opacity: 0.75 }}>{r.job}</div>
                </div>
              ))
            )}
          </div>

          <div className="PDAProgram__panel" style={{ width: 260, flex: '0 0 auto' }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Selected</div>
              <div className="PDAProgram__v">{sel ? sel.name : '—'}</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Job</div>
              <div className="PDAProgram__v">{sel ? sel.job : '—'}</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Dept</div>
              <div className="PDAProgram__v">{sel ? sel.dept : '—'}</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Status</div>
              <div className="PDAProgram__v">{sel ? sel.status : '—'}</div>
            </div>

            <div className="PDAProgram__footerHint" style={{ marginTop: 10 }}>
              Data is UI-only; backend wiring later.
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export const CrewManifestProgram: PdaProgram = {
  id: 'crew_manifest',
  title: 'Crew Manifest',
  icon: 'users',
  View: (ctx) => <CrewManifestApp ctx={ctx} />,
};
