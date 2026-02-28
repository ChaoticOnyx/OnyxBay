import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

type GeneralRecord = {
  name?: string;
  sex?: string;
  species?: string;
  age?: string;
  rank?: string;
  fingerprint?: string;
  p_stat?: string;
  m_stat?: string;
};

type MedicalRecord = {
  b_type?: string;
  mi_dis?: string;
  mi_dis_d?: string;
  ma_dis?: string;
  ma_dis_d?: string;
  alg?: string;
  alg_d?: string;
  cdi?: string;
  cdi_d?: string;
  notes?: string;
};

type MedicalListItem = {
  Name?: string;
  ref?: string;
};

const line = (label: string, value: string | undefined) => (
  <div style={{ marginBottom: 2 }}>
    <span style={{ color: '#7dffb7', fontWeight: 900 }}>{label}: </span>
    <span style={{ color: '#cffff2' }}>{value || '-'}</span>
  </div>
);

const MedicalRecordsApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const mode = String(ctx.data?.mode || PDA_MODE.MEDICAL_RECORDS);
  const records = ctx.data?.records || {};
  const rows: MedicalListItem[] = records.medical_records || [];

  const general: GeneralRecord | undefined = records.general;
  const medical: MedicalRecord | undefined = records.medical;
  const generalExists = !!records.general_exists && !!general;
  const medicalExists = !!records.medical_exists && !!medical;

  const cartAct = (choice: string, payload?: Record<string, any>) =>
    ctx.act('cartridge_action', { choice, ...(payload || {}) });

  const isDetails = mode === PDA_MODE.MEDICAL_RECORD;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="plus" /> MEDICAL RECORDS
        </div>
        <div className="PDAProgram__sub">Legacy PDA mode 44/441</div>
      </div>

      {!isDetails ? (
        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Medical Record List</div>
            <div className="PDAProgram__v">{rows.length}</div>
          </div>

          <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
            {rows.length === 0 && (
              <div className="PDAProgram__footerHint">No records found.</div>
            )}
            {rows.map((r, i) => (
              <Button
                key={`${r.ref || r.Name || 'record'}-${i}`}
                icon="circle-arrow-right"
                content={r.Name || 'Unknown'}
                onClick={() => cartAct('Medical Records', { target: r.ref })}
              />
            ))}
          </div>
        </div>
      ) : (
        <div className="PDAProgram__panel">
          <div style={{ marginBottom: 8 }}>
            <Button icon="arrow-left" content="Return to list" onClick={() => ctx.act('choice', { choice: 'Return' })} />
          </div>

          {!generalExists ? (
            <div style={{ color: '#f87171', fontWeight: 900, marginBottom: 12 }}>
              General Record Lost!
            </div>
          ) : (
            <div style={{ marginBottom: 12 }}>
              {line('Name', general?.name)}
              {line('Sex', general?.sex)}
              {line('Species', general?.species)}
              {line('Age', general?.age)}
              {line('Rank', general?.rank)}
              {line('Fingerprint', general?.fingerprint)}
              {line('Physical Status', general?.p_stat)}
              {line('Mental Status', general?.m_stat)}
            </div>
          )}

          {!medicalExists ? (
            <div style={{ color: '#f87171', fontWeight: 900 }}>
              Medical Record Lost!
            </div>
          ) : (
            <div>
              <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.08em', marginBottom: 6 }}>
                MEDICAL DATA
              </div>
              {line('Blood Type', medical?.b_type)}
              {line('Minor Disabilities', medical?.mi_dis)}
              {line('Details', medical?.mi_dis_d)}
              {line('Major Disabilities', medical?.ma_dis)}
              {line('Details', medical?.ma_dis_d)}
              {line('Allergies', medical?.alg)}
              {line('Details', medical?.alg_d)}
              {line('Current Disease', medical?.cdi)}
              {line('Details', medical?.cdi_d)}
              {line('Important Notes', medical?.notes)}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export const MedicalRecordsProgram: PdaProgram = {
  id: PDA_MODE.MEDICAL_RECORDS,
  title: 'Medical Records',
  icon: 'plus',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_medical,
  View: (ctx) => <MedicalRecordsApp ctx={ctx} />,
};
