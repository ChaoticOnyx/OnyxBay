import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const HealthScanProgram: PdaProgram = {
  id: 'health_scan',
  title: 'Health Scan',
  icon: 'heart-pulse',
  canRun: (ctx) => ctx.cartridgeType === 'medical',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="heart-pulse" /> HEALTH SCAN</div>
        <div className="PDAProgram__sub">Requires MED cartridge</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row"><div className="PDAProgram__k">Status</div><div className="PDAProgram__v">OK</div></div>
        <div className="PDAProgram__row"><div className="PDAProgram__k">Pulse</div><div className="PDAProgram__v">72 bpm</div></div>
      </div>
    </div>
  ),
};
