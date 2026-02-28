import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const modeText = (mode: number) => {
  if (mode === 0) return 'Idle';
  if (mode === 1) return 'Moving';
  if (mode === 2) return 'Unloading';
  return 'Calculating path';
};

const MuleControlApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const bots = ctx.data?.records?.mulebots || [];
  const count = Number(ctx.data?.records?.mulebotcount || 0);

  const cmd = (ref: string, command: string) =>
    ctx.act('cartridge_action', { choice: 'MULEbot', ref, command });

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="truck" /> MULE CONTROL
        </div>
      </div>

      <div className="PDAProgram__panel">
        {!count && <div className="pda-bad">No bots found.</div>}

        {bots.map((bot, idx) => (
          <div key={idx} style={{ marginBottom: 12 }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Mulebot #{bot.name}</div>
              <div className="PDAProgram__v">{modeText(Number(bot.mode || 0))}</div>
            </div>
            <div>Location: {bot.location}</div>
            <div>Home: {bot.home}</div>
            <div>Target: {bot.target}</div>
            <div>Load: {bot.load}</div>

            <div style={{ marginTop: 8, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
              <Button content="Go home" onClick={() => cmd(bot.ref, 'Home')} />
              <Button content="Set destination" onClick={() => cmd(bot.ref, 'SetD')} />
              <Button content="Go" onClick={() => cmd(bot.ref, 'GoTD')} />
              <Button content="Stop" onClick={() => cmd(bot.ref, 'Stop')} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export const MuleControlProgram: PdaProgram = {
  id: PDA_MODE.MULE_CONTROL,
  title: 'Mule Control',
  icon: 'truck',
  View: (ctx) => <MuleControlApp ctx={ctx} />,
};
