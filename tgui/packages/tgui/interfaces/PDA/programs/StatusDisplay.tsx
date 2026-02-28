import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const StatusDisplayApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const records = ctx.data?.records || {};
  const cartAct = (statdisp: string, extra?: Record<string, any>) =>
    ctx.act('cartridge_action', { choice: 'Status', statdisp, ...(extra || {}) });

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="display" /> STATUS DISPLAYS INTERLINK
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <Button icon="trash" content="Clear" onClick={() => cartAct('blank')} />
          <Button icon="clock" content="Local Time" onClick={() => cartAct('time')} />
          <Button icon="shuttle-space" content="Shuttle ETA" onClick={() => cartAct('shuttle')} />
          <Button icon="message" content="Message" onClick={() => cartAct('message')} />
        </div>

        <div style={{ marginTop: 12 }}>
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Message line 1</div>
            <div className="PDAProgram__v">{records.message1}</div>
          </div>
          <Button icon="pencil" content="Set line 1" onClick={() => cartAct('setmsg1')} />
        </div>

        <div style={{ marginTop: 12 }}>
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Message line 2</div>
            <div className="PDAProgram__v">{records.message2}</div>
          </div>
          <Button icon="pencil" content="Set line 2" onClick={() => cartAct('setmsg2')} />
        </div>

        <div style={{ marginTop: 12, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <Button icon="circle" content="None" onClick={() => cartAct('image', { image: 'default' })} />
          <Button icon="shield" content="Red Alert" onClick={() => cartAct('redalert')} />
          <Button icon="lock" content="Lockdown" onClick={() => cartAct('image', { image: 'lockdown' })} />
          <Button icon="radiation" content="Biohazard" onClick={() => cartAct('image', { image: 'biohazard' })} />
        </div>
      </div>
    </div>
  );
};

export const StatusDisplayProgram: PdaProgram = {
  id: PDA_MODE.STATUS_DISPLAY,
  title: 'Status Display',
  icon: 'display',
  View: (ctx) => <StatusDisplayApp ctx={ctx} />,
};
