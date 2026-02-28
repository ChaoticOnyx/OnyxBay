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

type MedicalRecord = {
  b_type: string;
  mi_dis: string;
  mi_dis_d: string;
  ma_dis: string;
  ma_dis_d: string;
  alg: string;
  alg_d: string;
  cdi: string;
  cdi_d: string;
  notes: string;
};

type RecordRow = {
  ref: string;
  name: string;
  general_exists: boolean;
  medical_exists: boolean;
  general?: GeneralRecord;
  medical?: MedicalRecord;
};

const MEDICAL_ROWS: RecordRow[] = [
  {
    ref: 'med-001',
    name: 'M. Solus',
    general_exists: true,
    medical_exists: true,
    general: {
      name: 'M. Solus',
      sex: 'Female',
      species: 'Human',
      age: '41',
      rank: 'Chief Medical Officer',
      fingerprint: '4A2B88C9',
      p_stat: 'Active',
      m_stat: 'Stable',
    },
    medical: {
      b_type: 'O+',
      mi_dis: 'None',
      mi_dis_d: 'N/A',
      ma_dis: 'None',
      ma_dis_d: 'N/A',
      alg: 'Ibuprofen',
      alg_d: 'Mild rash',
      cdi: 'None',
      cdi_d: 'N/A',
      notes: 'Cleared for full duty.',
    },
  },
  {
    ref: 'med-002',
    name: "M. O'Brien",
    general_exists: true,
    medical_exists: true,
    general: {
      name: "M. O'Brien",
      sex: 'Male',
      species: 'Human',
      age: '38',
      rank: 'Chief Engineer',
      fingerprint: 'F13D9A70',
      p_stat: 'Injured',
      m_stat: 'Stable',
    },
    medical: {
      b_type: 'A-',
      mi_dis: 'Hearing loss',
      mi_dis_d: 'Left ear, industrial accident',
      ma_dis: 'None',
      ma_dis_d: 'N/A',
      alg: 'Latex',
      alg_d: 'Contact irritation',
      cdi: 'None',
      cdi_d: 'N/A',
      notes: 'Recommend periodic hearing treatment.',
    },
  },
  {
    ref: 'med-003',
    name: 'Unknown Assistant',
    general_exists: true,
    medical_exists: false,
    general: {
      name: 'Unknown Assistant',
      sex: 'Unknown',
      species: 'Human',
      age: '??',
      rank: 'Assistant',
      fingerprint: 'NO MATCH',
      p_stat: 'Unknown',
      m_stat: 'Unknown',
    },
  },
];

class MedicalRecordsApp extends Component<{ ctx: PdaProgramContext }> {
  private rows: RecordRow[] = MEDICAL_ROWS;
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
          <div className="PDAProgram__k">Medical Record List</div>
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

        {!row.medical_exists || !row.medical ? (
          <div style={{ color: '#f87171', fontWeight: 900 }}>
            Medical Record Lost!
          </div>
        ) : (
          <div>
            <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.08em', marginBottom: 6 }}>
              MEDICAL DATA
            </div>
            {this.line('Blood Type', row.medical.b_type)}
            {this.line('Minor Disabilities', row.medical.mi_dis)}
            {this.line('Details', row.medical.mi_dis_d)}
            {this.line('Major Disabilities', row.medical.ma_dis)}
            {this.line('Details', row.medical.ma_dis_d)}
            {this.line('Allergies', row.medical.alg)}
            {this.line('Details', row.medical.alg_d)}
            {this.line('Current Disease', row.medical.cdi)}
            {this.line('Details', row.medical.cdi_d)}
            {this.line('Important Notes', row.medical.notes)}
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
            <Icon name="plus" /> MEDICAL RECORDS
          </div>
          <div className="PDAProgram__sub">Legacy PDA mode 44/441 - UI-only mock</div>
        </div>

        {!active ? this.renderList() : this.renderDetails(active)}
      </div>
    );
  }
}

export const MedicalRecordsProgram: PdaProgram = {
  id: 'medical_records',
  title: 'Medical Records',
  icon: 'plus',
  canRun: (ctx) => ctx.cartridgeType === 'medical' || ctx.cartridgeType === 'admin',
  View: (ctx) => <MedicalRecordsApp ctx={ctx} />,
};
