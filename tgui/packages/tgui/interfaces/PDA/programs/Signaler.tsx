import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const SignalerApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const records = ctx.data?.records || {};

  const cartAct = (choice: string, payload?: Record<string, any>) =>
    ctx.act('cartridge_action', { choice, ...(payload || {}) });

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="tower-broadcast" /> REMOTE SIGNALING SYSTEM
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Frequency</div>
          <div className="PDAProgram__v">{records.signal_freq}</div>
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
          <Button content="-1" onClick={() => cartAct('Signal Frequency', { sfreq: '-10' })} />
          <Button content="-.2" onClick={() => cartAct('Signal Frequency', { sfreq: '-2' })} />
          <Button content="+.2" onClick={() => cartAct('Signal Frequency', { sfreq: '2' })} />
          <Button content="+1" onClick={() => cartAct('Signal Frequency', { sfreq: '10' })} />
        </div>

        <div className="PDAProgram__row" style={{ marginTop: 12 }}>
          <div className="PDAProgram__k">Code</div>
          <div className="PDAProgram__v">{records.signal_code}</div>
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
          <Button content="-5" onClick={() => cartAct('Signal Code', { scode: '-5' })} />
          <Button content="-1" onClick={() => cartAct('Signal Code', { scode: '-1' })} />
          <Button content="+1" onClick={() => cartAct('Signal Code', { scode: '1' })} />
          <Button content="+5" onClick={() => cartAct('Signal Code', { scode: '5' })} />
        </div>

        <div style={{ marginTop: 12 }}>
          <Button icon="satellite-dish" content="Send Signal" onClick={() => cartAct('Send Signal')} />
        </div>
      </div>
    </div>
  );
};

export const SignalerProgram: PdaProgram = {
  id: PDA_MODE.SIGNALER,
  title: 'Signaler',
  icon: 'tower-broadcast',
  View: (ctx) => <SignalerApp ctx={ctx} />,
};
