import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const AtmosScanProgram: PdaProgram = {
  id: 'atmos_scan',
  title: 'Atmos Scan',
  icon: 'wind',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="wind" /> ATMOS SCAN</div>
        <div className="PDAProgram__sub">Mock sensor readout • backend-ready</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row"><div className="PDAProgram__k">O2</div><div className="PDAProgram__v">21%</div></div>
        <div className="PDAProgram__row"><div className="PDAProgram__k">CO2</div><div className="PDAProgram__v">0.04%</div></div>
        <div className="PDAProgram__row"><div className="PDAProgram__k">Pressure</div><div className="PDAProgram__v">101 kPa</div></div>
      </div>
    </div>
  ),
};
