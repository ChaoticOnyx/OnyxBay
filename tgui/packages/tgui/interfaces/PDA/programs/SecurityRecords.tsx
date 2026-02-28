import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type GeneralRecord = {
  name: string;
  sex: string;
  species: string;
  age: string;
  rank: string;
  fingerprint: string;
  p_stat: string;
  m_stat: string;
};

type SecurityRecord = {
  criminal: string;
  mi_crim: string;
  mi_crim_d: string;
  ma_crim: string;
  ma_crim_d: string;
  notes: string;
};

type RecordRow = {
  ref: string;
  name: string;
  general_exists: boolean;
  security_exists: boolean;
  general?: GeneralRecord;
  security?: SecurityRecord;
};

const SECURITY_ROWS: RecordRow[] = [
  {
    ref: 'sec-001',
    name: 'A. Kerr',
    general_exists: true,
    security_exists: true,
    general: {
      name: 'A. Kerr',
      sex: 'Female',
      species: 'Human',
      age: '35',
      rank: 'Head of Security',
      fingerprint: '0C41AC32',
      p_stat: 'Active',
      m_stat: 'Stable',
    },
    security: {
      criminal: 'None',
      mi_crim: 'None',
      mi_crim_d: 'N/A',
      ma_crim: 'None',
      ma_crim_d: 'N/A',
      notes: 'Trusted command staff.',
    },
  },
  {
    ref: 'sec-002',
    name: 'J. Doe',
    general_exists: true,
    security_exists: true,
    general: {
      name: 'J. Doe',
      sex: 'Male',
      species: 'Human',
      age: '27',
      rank: 'Assistant',
      fingerprint: 'B9017D44',
      p_stat: 'Active',
      m_stat: 'Agitated',
    },
    security: {
      criminal: 'Arrest',
      mi_crim: 'Trespass',
      mi_crim_d: 'Command hallway loitering',
      ma_crim: 'None',
      ma_crim_d: 'N/A',
      notes: 'Monitor repeat misconduct.',
    },
  },
  {
    ref: 'sec-003',
    name: 'Unidentified Subject',
    general_exists: false,
    security_exists: false,
  },
];

class SecurityRecordsApp extends Component<{ ctx: PdaProgramContext }> {
  private rows: RecordRow[] = SECURITY_ROWS;
  private activeRef: string | null = null;

  private select = (ref: string) => {
    this.activeRef = ref;
    this.forceUpdate();
  };

  private back = () => {
    this.activeRef = null;
    this.forceUpdate();
  };

  private get active(): RecordRow | null {
    if (!this.activeRef) return null;
    return this.rows.find(r => r.ref === this.activeRef) || null;
  }

  private line(label: string, value: string) {
    return (
      <div style={{ marginBottom: 2 }}>
        <span style={{ color: '#7dffb7', fontWeight: 900 }}>{label}: </span>
        <span style={{ color: '#cffff2' }}>{value}</span>
      </div>
    );
  }

  private renderList() {
    return (
      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Security Record List</div>
          <div className="PDAProgram__v">{this.rows.length}</div>
        </div>

        <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {this.rows.map(r => (
            <Button
              key={r.ref}
              icon="circle-arrow-right"
              content={r.name}
              onClick={() => this.select(r.ref)}
            />
          ))}
        </div>
      </div>
    );
  }

  private renderDetails(row: RecordRow) {
    return (
      <div className="PDAProgram__panel">
        <div style={{ marginBottom: 8 }}>
          <Button icon="arrow-left" content="Return to list" onClick={this.back} />
        </div>

        {!row.general_exists || !row.general ? (
          <div style={{ color: '#f87171', fontWeight: 900, marginBottom: 12 }}>
            General Record Lost!
          </div>
        ) : (
          <div style={{ marginBottom: 12 }}>
            {this.line('Name', row.general.name)}
            {this.line('Sex', row.general.sex)}
            {this.line('Species', row.general.species)}
            {this.line('Age', row.general.age)}
            {this.line('Rank', row.general.rank)}
            {this.line('Fingerprint', row.general.fingerprint)}
            {this.line('Physical Status', row.general.p_stat)}
            {this.line('Mental Status', row.general.m_stat)}
          </div>
        )}

        {!row.security_exists || !row.security ? (
          <div style={{ color: '#f87171', fontWeight: 900 }}>
            Security Record Lost!
          </div>
        ) : (
          <div>
            <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.08em', marginBottom: 6 }}>
              SECURITY DATA
            </div>
            {this.line('Criminal Status', row.security.criminal)}
            {this.line('Minor Crimes', row.security.mi_crim)}
            {this.line('Details', row.security.mi_crim_d)}
            {this.line('Major Crimes', row.security.ma_crim)}
            {this.line('Details', row.security.ma_crim_d)}
            {this.line('Important Notes', row.security.notes)}
          </div>
        )}
      </div>
    );
  }

  render() {
    const active = this.active;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="alert" /> SECURITY RECORDS
          </div>
          <div className="PDAProgram__sub">Legacy PDA mode 45/451 - UI-only mock</div>
        </div>

        {!active ? this.renderList() : this.renderDetails(active)}
      </div>
    );
  }
}

export const SecurityRecordsProgram: PdaProgram = {
  id: 'security_records',
  title: 'Security Records',
  icon: 'alert',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <SecurityRecordsApp ctx={ctx} />,
};
