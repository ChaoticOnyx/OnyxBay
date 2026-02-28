import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const CrewManifestApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const manifestHtml = String(ctx.data?.crew_manifest || '<i>No manifest available.</i>');

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="users" /> CREW MANIFEST
        </div>
        <div className="PDAProgram__sub">Station roster</div>
      </div>

      <div className="PDAProgram__panel">
        <div dangerouslySetInnerHTML={{ __html: manifestHtml }} />
      </div>
    </div>
  );
};

export const CrewManifestProgram: PdaProgram = {
  id: PDA_MODE.CREW_MANIFEST,
  title: 'Crew Manifest',
  icon: 'users',
  View: (ctx) => <CrewManifestApp ctx={ctx} />,
};
