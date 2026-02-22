import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const SecurityProgram: PdaProgram = {
  id: 'security',
  title: 'Security',
  icon: 'shield-halved',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="shield-halved" /> SECURITY</div>
        <div className="PDAProgram__sub">Requires ADMIN cartridge</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__listItem">Access: GRANTED</div>
        <div className="PDAProgram__listItem">Alerts: NONE</div>
      </div>
    </div>
  ),
};
