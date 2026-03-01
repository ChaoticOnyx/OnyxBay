import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const DoorRemoteApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const remoteDoorId = String(ctx.data?.cartridge?.remote_door_id || '');

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="door-closed" /> REMOTE DOOR TOGGLE
        </div>
        <div className="PDAProgram__sub">Access-controlled utility</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Linked Door Group</div>
          <div className="PDAProgram__v">{remoteDoorId || 'Configured on cartridge'}</div>
        </div>

        <div style={{ marginTop: 10 }}>
          <Button
            icon="right-left"
            content="Toggle Door Group"
            onClick={() => ctx.act('toggle_door')}
          />
        </div>
      </div>
    </div>
  );
};

export const DoorRemoteProgram: PdaProgram = {
  id: PDA_MODE.DOOR_REMOTE,
  title: 'Toggle Door',
  icon: 'door-closed',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_remote_door,
  View: (ctx) => <DoorRemoteApp ctx={ctx} />,
};
