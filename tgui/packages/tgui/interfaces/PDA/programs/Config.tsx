import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const ConfigProgram: PdaProgram = {
  id: 'config',
  title: 'CFG',
  icon: 'gear',
  View: (ctx) => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="gear" /> CONFIGURATION
        </div>
        <div className="PDAProgram__sub">
          UI-only mock • Ready for backend wiring
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Flashlight</div>
          <div className="PDAProgram__v">{ctx.flashlightOn ? 'ON' : 'OFF'}</div>
        </div>
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Cartridge</div>
          <div className="PDAProgram__v">{ctx.hasCartridge ? ctx.cartridgeType.toUpperCase() : 'NONE'}</div>
        </div>
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Active Program</div>
          <div className="PDAProgram__v">{ctx.activeProgramId.toUpperCase()}</div>
        </div>
      </div>

      <div className="PDAProgram__footerHint">
        Use HOME tab to return.
      </div>
    </div>
  ),
};
