import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const NotekeeperProgram: PdaProgram = {
  id: 'notekeeper',
  title: 'Notekeeper',
  icon: 'file-lines',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="file-lines" /> NOTEKEEPER</div>
        <div className="PDAProgram__sub">Mock notes list • backend-ready</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__listItem">• Remember to encrypt comms.</div>
        <div className="PDAProgram__listItem">• Check atmos readings after shift change.</div>
        <div className="PDAProgram__listItem">• Refill printer paper (PDA dock).</div>
      </div>
    </div>
  ),
};
