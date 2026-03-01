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

const line = (icon: string, label: string, value: string | undefined) => (
  <div className="PDAProgram__recordLine">
    <div className="PDAProgram__recordKey">
      <Icon name={icon} />
      <span>{label}</span>
    </div>
    <div className="PDAProgram__recordValue">{value || '-'}</div>
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
                icon="user"
                content={r.Name || 'Unknown'}
                onClick={() => cartAct('Medical Records', { target: r.ref })}
              />
            ))}
          </div>
        </div>
      ) : (
        <div className="PDAProgram__panel">
          <div style={{ marginBottom: 8 }}>
            <Button icon="arrow-left" content="Return to list" onClick={() => ctx.act('return')} />
          </div>

          {!generalExists ? (
            <div style={{ color: '#f87171', fontWeight: 900, marginBottom: 12 }}>
              General Record Lost!
            </div>
          ) : (
            <div className="PDAProgram__readableBox" style={{ marginBottom: 12 }}>
              {line('id-card', 'Name', general?.name)}
              {line('venus-mars', 'Sex', general?.sex)}
              {line('paw', 'Species', general?.species)}
              {line('hourglass', 'Age', general?.age)}
              {line('briefcase', 'Rank', general?.rank)}
              {line('fingerprint', 'Fingerprint', general?.fingerprint)}
              {line('heartbeat', 'Physical Status', general?.p_stat)}
              {line('brain', 'Mental Status', general?.m_stat)}
            </div>
          )}

          {!medicalExists ? (
            <div style={{ color: '#f87171', fontWeight: 900 }}>
              Medical Record Lost!
            </div>
          ) : (
            <div className="PDAProgram__readableBox is-medical">
              <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.08em', marginBottom: 10 }}>
                MEDICAL DATA
              </div>
              {line('droplet', 'Blood Type', medical?.b_type)}
              {line('bandage', 'Minor Disabilities', medical?.mi_dis)}
              {line('clipboard', 'Minor Details', medical?.mi_dis_d)}
              {line('triangle-exclamation', 'Major Disabilities', medical?.ma_dis)}
              {line('clipboard', 'Major Details', medical?.ma_dis_d)}
              {line('triangle-exclamation', 'Allergies', medical?.alg)}
              {line('clipboard', 'Allergy Details', medical?.alg_d)}
              {line('virus', 'Current Disease', medical?.cdi)}
              {line('clipboard', 'Disease Details', medical?.cdi_d)}
              {line('book', 'Important Notes', medical?.notes)}
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
