import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const CrewManifestProgram: PdaProgram = {
  id: 'crew_manifest',
  title: 'Crew Manifest',
  icon: 'users',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="users" /> CREW MANIFEST</div>
        <div className="PDAProgram__sub">Mock list • backend-ready</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__listItem">Captain — S. Batten</div>
        <div className="PDAProgram__listItem">Chief Engineer — M. O&apos;Brien</div>
        <div className="PDAProgram__listItem">Chief Medical Officer — M. Solus</div>
        <div className="PDAProgram__listItem">Assistant — J. Doe</div>
      </div>
    </div>
  ),
};
