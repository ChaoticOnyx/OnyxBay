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

type SecurityRecord = {
  criminal?: string;
  mi_crim?: string;
  mi_crim_d?: string;
  ma_crim?: string;
  ma_crim_d?: string;
  notes?: string;
};

type SecurityListItem = {
  Name?: string;
  ref?: string;
};

const line = (label: string, value: string | undefined) => (
  <div style={{ marginBottom: 2 }}>
    <span style={{ color: '#7dffb7', fontWeight: 900 }}>{label}: </span>
    <span style={{ color: '#cffff2' }}>{value || '-'}</span>
  </div>
);

const SecurityRecordsApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const mode = String(ctx.data?.mode || PDA_MODE.SECURITY_RECORDS);
  const records = ctx.data?.records || {};
  const rows: SecurityListItem[] = records.security_records || [];

  const general: GeneralRecord | undefined = records.general;
  const security: SecurityRecord | undefined = records.security;
  const generalExists = !!records.general_exists && !!general;
  const securityExists = !!records.security_exists && !!security;

  const cartAct = (choice: string, payload?: Record<string, any>) =>
    ctx.act('cartridge_action', { choice, ...(payload || {}) });

  const isDetails = mode === PDA_MODE.SECURITY_RECORD;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="alert" /> SECURITY RECORDS
        </div>
        <div className="PDAProgram__sub">Legacy PDA mode 45/451</div>
      </div>

      {!isDetails ? (
        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Security Record List</div>
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
                onClick={() => cartAct('Security Records', { target: r.ref })}
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

          {!securityExists ? (
            <div style={{ color: '#f87171', fontWeight: 900 }}>
              Security Record Lost!
            </div>
          ) : (
            <div>
              <div style={{ color: '#aaffff', fontWeight: 900, letterSpacing: '0.08em', marginBottom: 6 }}>
                SECURITY DATA
              </div>
              {line('Criminal Status', security?.criminal)}
              {line('Minor Crimes', security?.mi_crim)}
              {line('Details', security?.mi_crim_d)}
              {line('Major Crimes', security?.ma_crim)}
              {line('Details', security?.ma_crim_d)}
              {line('Important Notes', security?.notes)}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export const SecurityRecordsProgram: PdaProgram = {
  id: PDA_MODE.SECURITY_RECORDS,
  title: 'Security Records',
  icon: 'alert',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_security,
  View: (ctx) => <SecurityRecordsApp ctx={ctx} />,
};
