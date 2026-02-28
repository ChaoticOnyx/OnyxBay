import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const renderLoc = (entry, emptyText: string) => {
  if (!entry || Number(entry.x) === 0) {
    return <span className="pda-bad">{emptyText}</span>;
  }
  return (
    <span>
      ({entry.x} / {entry.y}) - {entry.dir} - Status: {entry.status}
    </span>
  );
};

const JanitorLocatorApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const janitor = ctx.data?.records?.janitor || {};

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="broom" /> JANITORIAL SUPPLIES LOCATOR
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Current Location</div>
          <div className="PDAProgram__v">
            {janitor.user_loc?.x
              ? `${janitor.user_loc.x} / ${janitor.user_loc.y}`
              : 'Unknown'}
          </div>
        </div>

        <div style={{ marginTop: 8 }}>
          <div>Mops: {renderLoc(janitor.mops?.[0], 'Unable to locate Mop')}</div>
          <div>Buckets: {renderLoc(janitor.buckets?.[0], 'Unable to locate Water Buckets')}</div>
          <div>Clean Bots: {renderLoc(janitor.cleanbots?.[0], 'Unable to locate Clean Bots')}</div>
          <div>Carts: {renderLoc(janitor.carts?.[0], 'Unable to locate Janitorial Cart')}</div>
        </div>
      </div>
    </div>
  );
};

export const JanitorLocatorProgram: PdaProgram = {
  id: PDA_MODE.JANITOR_LOCATOR,
  title: 'Custodial Locator',
  icon: 'broom',
  View: (ctx) => <JanitorLocatorApp ctx={ctx} />,
};
