import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const MANIFEST_SECTIONS = [
  { key: 'heads', title: 'Heads of Staff', className: 'is-command', icon: 'star' },
  { key: 'spt', title: 'Command Support', className: 'is-support', icon: 'clipboard' },
  { key: 'sci', title: 'Research', className: 'is-research', icon: 'flask' },
  { key: 'sec', title: 'Security', className: 'is-security', icon: 'shield' },
  { key: 'eng', title: 'Engineering', className: 'is-engineering', icon: 'wrench' },
  { key: 'med', title: 'Medical', className: 'is-medical', icon: 'heart' },
  { key: 'sup', title: 'Cargo', className: 'is-cargo', icon: 'box' },
  { key: 'exp', title: 'Exploration', className: 'is-exploration', icon: 'compass' },
  { key: 'srv', title: 'Provisioning', className: 'is-service', icon: 'utensils' },
  { key: 'civ', title: 'Civilian', className: 'is-civilian', icon: 'user' },
  { key: 'misc', title: 'Miscellaneous', className: 'is-misc', icon: 'ellipsis-h' },
  { key: 'bot', title: 'Silicon', className: 'is-silicon', icon: 'robot' },
] as const;

const CrewManifestApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const manifestHtml = String(ctx.data?.crew_manifest || '<i>No manifest available.</i>');
  const manifestData = ctx.data?.crew_manifest_data || {};

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="users" /> CREW MANIFEST
        </div>
        <div className="PDAProgram__sub">Station roster</div>
      </div>

      {!!MANIFEST_SECTIONS.some((section) => (manifestData[section.key] || []).length) ? (
        <div className="PDAProgram__manifestGrid">
          {MANIFEST_SECTIONS.map((section) => {
            const entries = manifestData[section.key] || [];
            if (!entries.length) {
              return null;
            }
            return (
              <div key={section.key} className={`PDAProgram__manifestCard ${section.className}`}>
                <div className="PDAProgram__manifestHead">
                  <Icon name={section.icon} />
                  <span>{section.title}</span>
                </div>
                <div className="PDAProgram__manifestBody">
                  {entries.map((entry, index) => (
                    <div key={`${section.key}-${index}`} className="PDAProgram__manifestRow">
                      <div className="PDAProgram__manifestName">{entry.name}</div>
                      <div className="PDAProgram__manifestRank">{entry.rank}</div>
                      <div className="PDAProgram__manifestStatus">{entry.status || 'Unknown'}</div>
                    </div>
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      ) : (
        <div className="PDAProgram__panel">
          <div dangerouslySetInnerHTML={{ __html: manifestHtml }} />
        </div>
      )}
    </div>
  );
};

export const CrewManifestProgram: PdaProgram = {
  id: PDA_MODE.CREW_MANIFEST,
  title: 'Crew Manifest',
  icon: 'users',
  View: (ctx) => <CrewManifestApp ctx={ctx} />,
};
