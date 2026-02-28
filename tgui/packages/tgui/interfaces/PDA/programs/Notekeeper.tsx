import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const NotekeeperApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const note = String(ctx.data?.note || '');

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="file-lines" /> NOTEKEEPER
        </div>
        <div className="PDAProgram__sub">Legacy note storage</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Notes</div>
          <div className="PDAProgram__v" style={{ whiteSpace: 'pre-wrap' }}>
            {note || '(empty)'}
          </div>
        </div>

        <div style={{ marginTop: 10 }}>
          <Button
            icon="pencil"
            content="Edit Notes"
            onClick={() => ctx.act('choice', { choice: 'Edit' })}
          />
        </div>
      </div>
    </div>
  );
};

export const NotekeeperProgram: PdaProgram = {
  id: PDA_MODE.NOTEKEEPER,
  title: 'Notekeeper',
  icon: 'file-lines',
  View: (ctx) => <NotekeeperApp ctx={ctx} />,
};
