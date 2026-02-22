import { Icon } from '../../../components';
import type { PdaProgram, PdaProgramContext, PdaProgramId } from '../types';
import { cx } from '../types';

type AppTile = {
  id: PdaProgramId;
  icon: string;
  label: string;
  highlight?: boolean;
  canShow?: (ctx: PdaProgramContext) => boolean;
};

const APP_TILES: AppTile[] = [
  { id: 'notekeeper', icon: 'file-lines', label: 'Notekeeper' },
  { id: 'messenger', icon: 'comment', label: 'Messenger' },
  { id: 'crew_manifest', icon: 'users', label: 'Crew Manifest' },
  { id: 'news_feed', icon: 'radio', label: 'News Feed' },

  { id: 'atmos_scan', icon: 'wind', label: 'Atmos Scan' },

  {
    id: 'health_scan',
    icon: 'heart-pulse',
    label: 'Health Scan',
    highlight: true,
    canShow: (ctx) => ctx.cartridgeType === 'medical',
  },
  {
    id: 'engine_diag',
    icon: 'hard-drive',
    label: 'Engine Diag',
    highlight: true,
    canShow: (ctx) => ctx.cartridgeType === 'engineering',
  },
  {
    id: 'security',
    icon: 'shield-halved',
    label: 'Security',
    highlight: true,
    canShow: (ctx) => ctx.cartridgeType === 'admin',
  },

  { id: 'storage', icon: 'database', label: 'Storage' },
];

const computeOwner = (cartridgeType: PdaProgramContext['cartridgeType']) => {
  if (cartridgeType === 'admin') return 'S. Batten, Captain';
  if (cartridgeType === 'medical') return 'M. Solus, CMO';
  if (cartridgeType === 'engineering') return "M. O'Brien, CE";
  return 'J. Doe, Assistant';
};

const computeIdSuffix = (cartridgeType: PdaProgramContext['cartridgeType']) =>
  cartridgeType.substring(0, 2).toUpperCase();

export const HomeProgram: PdaProgram = {
  id: 'home',
  title: 'HOME',
  icon: 'house',
  View: (ctx) => {
    const owner = computeOwner(ctx.cartridgeType);
    const idSuffix = computeIdSuffix(ctx.cartridgeType);

    return (
      <div className="PDAProgram PDAProgram--home">
        <div className="PDAScreen__card">
          <div className="PDAScreen__cardTop">
            <div className="PDAScreen__cardK">LOCAL TIME</div>
            <div className="PDAScreen__cardTime">{ctx.timeText}</div>
          </div>

          <div className="PDAScreen__grid">
            <div className="PDAScreen__k">OWNER</div>
            <div className="PDAScreen__v">{owner}</div>

            <div className="PDAScreen__k">ID</div>
            <div className="PDAScreen__id">NCC-1701-{idSuffix}</div>
          </div>
        </div>

        <div className="PDAScreen__group">
          <div className="PDAScreen__h">GENERAL</div>
          <div className="PDAScreen__apps">
            {APP_TILES.slice(0, 4).map(tile => (
              <PDAAppTile key={tile.id} tile={tile} ctx={ctx} />
            ))}
          </div>
        </div>

        <div className="PDAScreen__group">
          <div className="PDAScreen__h">UTILITIES</div>
          <div className="PDAScreen__apps">
            {APP_TILES.slice(4).map(tile => (
              <PDAAppTile key={tile.id} tile={tile} ctx={ctx} />
            ))}
          </div>
        </div>
      </div>
    );
  },
};

function PDAAppTile(props: { tile: AppTile; ctx: PdaProgramContext }) {
  const { tile, ctx } = props;

  const visible = tile.canShow ? tile.canShow(ctx) : true;
  if (!visible) return null;

  const disabled = !ctx.hasCartridge || !ctx.isOn;
  const canRun = !disabled; // UI-only сейчас (в реестре можно усилить)

  return (
    <button
      className={cx('PDAApp', tile.highlight && 'is-highlight')}
      disabled={!canRun}
      onClick={() => ctx.setActiveProgram(tile.id)}
      title={tile.label}
    >
      <div className="PDAApp__icon"><Icon name={tile.icon} /></div>
      <div className="PDAApp__label">{tile.label}</div>
      <div className="PDAApp__hover" />
    </button>
  );
}
