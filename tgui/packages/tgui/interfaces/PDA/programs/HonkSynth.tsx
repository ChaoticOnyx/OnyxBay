import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const HonkSynthApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const charges = Number(ctx.data?.cartridge?.charges || 0);

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="face-grin-squint" /> HONK SYNTHESIZER
        </div>
        <div className="PDAProgram__sub">Cartridge utility</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Viral Charges</div>
          <div className="PDAProgram__v">{charges}</div>
        </div>

        <div style={{ marginTop: 10 }}>
          <Button
            icon="bullhorn"
            content="Play Honk"
            onClick={() => ctx.act('choice', { choice: 'Honk' })}
          />
        </div>
      </div>
    </div>
  );
};

export const HonkSynthProgram: PdaProgram = {
  id: PDA_MODE.HONK_SYNTH,
  title: 'Honk Synth',
  icon: 'face-grin-squint',
  canRun: (ctx) => !!ctx.data?.cartridge?.access?.access_clown,
  View: (ctx) => <HonkSynthApp ctx={ctx} />,
};
