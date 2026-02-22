import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const StorageProgram: PdaProgram = {
  id: 'storage',
  title: 'Storage',
  icon: 'database',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="database" /> STORAGE</div>
        <div className="PDAProgram__sub">Mock files • backend-ready</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__listItem">/docs/shift_log.txt</div>
        <div className="PDAProgram__listItem">/notes/personal.memo</div>
        <div className="PDAProgram__listItem">/cache/sensors.bin</div>
      </div>
    </div>
  ),
};
