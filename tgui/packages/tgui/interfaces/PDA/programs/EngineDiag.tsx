import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const EngineDiagProgram: PdaProgram = {
  id: 'engine_diag',
  title: 'Engine Diag',
  icon: 'hard-drive',
  canRun: (ctx) => ctx.cartridgeType === 'engineering',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="hard-drive" /> ENGINE DIAG</div>
        <div className="PDAProgram__sub">Requires ENGI cartridge</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row"><div className="PDAProgram__k">Core</div><div className="PDAProgram__v">STABLE</div></div>
        <div className="PDAProgram__row"><div className="PDAProgram__k">Output</div><div className="PDAProgram__v">Normal</div></div>
      </div>
    </div>
  ),
};
