import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const modeToText = (mode: number) => {
  if (mode === -1) return 'Waiting for response...';
  if (mode === 0) return 'Ready';
  if (mode === 1) return 'Apprehending target';
  if (mode === 2 || mode === 3) return 'Arresting target';
  if (mode === 4) return 'Starting patrol';
  if (mode === 5) return 'On Patrol';
  if (mode === 6) return 'Responding to summons';
  return 'Unknown';
};

const SecurityBotApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const beepsky = ctx.data?.records?.beepsky || {};
  const active = beepsky.active;

  const radioAct = (op: string, payload?: Record<string, any>) =>
    ctx.act('radio_action', { op, ...(payload || {}) });

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="gear" /> SECURITY BOT CONTROL
        </div>
      </div>

      <div className="PDAProgram__panel">
        {!active ? (
          <>
            {Number(beepsky.count || 0) === 0 && <div className="pda-bad">No bots found.</div>}
            {(beepsky.bots || []).map((bot, idx) => (
              <div key={idx} style={{ marginBottom: 8 }}>
                <Button
                  icon="circle-arrow-right"
                  content={`${bot.Name} (${bot.Location})`}
                  disabled={!bot.ref}
                  onClick={() => radioAct('control', { bot: bot.ref })}
                />
              </div>
            ))}
            <Button content="Scan for Bots" onClick={() => radioAct('scanbots')} />
          </>
        ) : (
          <>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Active</div>
              <div className="PDAProgram__v">{active}</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Location</div>
              <div className="PDAProgram__v">{beepsky.botstatus?.loca || '-'}</div>
            </div>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Mode</div>
              <div className="PDAProgram__v">{modeToText(Number(beepsky.botstatus?.mode ?? -1))}</div>
            </div>

            <div style={{ marginTop: 8, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button content="Stop Patrol" onClick={() => radioAct('stop')} />
              <Button content="Start Patrol" onClick={() => radioAct('go')} />
              <Button content="Summon Bot" onClick={() => radioAct('summon')} />
            </div>
            <div style={{ marginTop: 8 }}>
              <Button content="Return to Bot list" onClick={() => radioAct('botlist')} />
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export const SecurityBotProgram: PdaProgram = {
  id: PDA_MODE.SECURITY_BOT,
  title: 'Security Bot',
  icon: 'gear',
  View: (ctx) => <SecurityBotApp ctx={ctx} />,
};
