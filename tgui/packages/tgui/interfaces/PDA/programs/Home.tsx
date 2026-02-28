import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext, PdaProgramId } from '../types';
import { cx } from '../types';

type AppTile = {
  id: PdaProgramId;
  icon: string;
  label: string;
  highlight?: boolean;
  canShow?: (ctx: PdaProgramContext) => boolean;
};

const hasAccess = (ctx: PdaProgramContext, key: string) =>
  !!ctx.data?.cartridge?.access?.[key];

const APP_TILES: AppTile[] = [
  { id: PDA_MODE.NOTEKEEPER, icon: 'file-lines', label: 'Notekeeper' },
  { id: PDA_MODE.MESSENGER, icon: 'comment', label: 'Messenger' },
  { id: PDA_MODE.CREW_MANIFEST, icon: 'users', label: 'Crew Manifest' },
  { id: PDA_MODE.NEWS_FEED, icon: 'radio', label: 'News' },

  { id: PDA_MODE.ATMOS_SCAN, icon: 'wind', label: 'Atmospheric Scan' },
  { id: PDA_MODE.STATUS_DISPLAY, icon: 'display', label: 'Status Display', highlight: true, canShow: (ctx) => hasAccess(ctx, 'access_status_display') },
  { id: PDA_MODE.SIGNALER, icon: 'tower-broadcast', label: 'Signaler System', highlight: true, canShow: (ctx) => ctx.data?.cartridge?.radio === 2 },
  { id: PDA_MODE.DOOR_REMOTE, icon: 'door-closed', label: 'Toggle Door', canShow: (ctx) => hasAccess(ctx, 'access_remote_door') },
  { id: PDA_MODE.POWER_MONITOR, icon: 'bolt', label: 'Power Monitor', highlight: true, canShow: (ctx) => hasAccess(ctx, 'access_engine') },
  { id: PDA_MODE.SUPPLY_RECORDS, icon: 'box', label: 'Supply Records', canShow: (ctx) => hasAccess(ctx, 'access_quartermaster') },
  { id: PDA_MODE.MULE_CONTROL, icon: 'truck', label: 'Delivery Bot Control', canShow: (ctx) => hasAccess(ctx, 'access_quartermaster') },
  { id: PDA_MODE.MEDICAL_RECORDS, icon: 'plus', label: 'Medical Records', canShow: (ctx) => hasAccess(ctx, 'access_medical') },
  { id: PDA_MODE.SECURITY_RECORDS, icon: 'alert', label: 'Security Records', canShow: (ctx) => hasAccess(ctx, 'access_security') },
  { id: PDA_MODE.SECURITY_BOT, icon: 'gear', label: 'Security Bot Control', canShow: (ctx) => hasAccess(ctx, 'access_security') },
  { id: PDA_MODE.JANITOR_LOCATOR, icon: 'broom', label: 'Custodial Locator', canShow: (ctx) => hasAccess(ctx, 'access_janitor') },
  { id: PDA_MODE.HONK_SYNTH, icon: 'face-grin-squint', label: 'Honk Synthesizer', canShow: (ctx) => hasAccess(ctx, 'access_clown') },
];

const HomeApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const data = ctx.data || {};
  const scanmode = Number(data.scanmode || 0);

  return (
    <div className="PDAProgram PDAProgram--home">
      <div className="PDAScreen__card">
        <div className="PDAScreen__cardTop">
          <div className="PDAScreen__cardK">LOCAL TIME</div>
          <div className="PDAScreen__cardTime">{data.stationTime || ctx.timeText}</div>
        </div>

        <div className="PDAScreen__grid">
          <div className="PDAScreen__k">OWNER</div>
          <div className="PDAScreen__v">{data.owner ? `${data.owner}, ${data.ownjob || ''}` : 'No owner'}</div>

          <div className="PDAScreen__k">ID</div>
          <div className="PDAScreen__id">{data.idLink || '--------'}</div>
        </div>

        <div style={{ marginTop: 10, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <Button
            icon="id-card"
            content={data.idInserted ? 'Eject/Insert ID' : 'Insert ID'}
            onClick={() => ctx.act('choice', { choice: 'Authenticate' })}
          />
          {!!data.idInserted && (
            <Button
              icon="rotate"
              content="Update PDA Info"
              onClick={() => ctx.act('choice', { choice: 'UpdateInfo' })}
            />
          )}
        </div>
      </div>

      <div className="PDAScreen__group">
        <div className="PDAScreen__h">GENERAL</div>
        <div className="PDAScreen__apps">
          {APP_TILES.slice(0, 4).map((tile) => (
            <PDAAppTile key={tile.id} tile={tile} ctx={ctx} />
          ))}
        </div>
      </div>

      <div className="PDAScreen__group">
        <div className="PDAScreen__h">UTILITIES</div>
        <div className="PDAScreen__apps">
          {APP_TILES.slice(4).map((tile) => (
            <PDAAppTile key={tile.id} tile={tile} ctx={ctx} />
          ))}
        </div>

        <div style={{ marginTop: '10px' }}>
          <div className="PDAScreen__h" style={{ marginTop: '6px' }}>SCANNERS</div>

          <div className="PDAProgram__panel">
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Reagent Scanner</div>
              <div className="PDAProgram__v">{scanmode === 3 ? 'ON' : 'OFF'}</div>
            </div>
            <Button
              content={scanmode === 3 ? 'Disable Reagent Scanner' : 'Enable Reagent Scanner'}
              icon="flask"
              disabled={!hasAccess(ctx, 'access_reagent_scanner')}
              onClick={() => ctx.act('choice', { choice: 'Reagent Scan' })}
            />

            <div style={{ height: '8px' }} />

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Halogen Counter</div>
              <div className="PDAProgram__v">{scanmode === 4 ? 'ON' : 'OFF'}</div>
            </div>
            <Button
              content={scanmode === 4 ? 'Disable Halogen Counter' : 'Enable Halogen Counter'}
              icon="radiation"
              disabled={!hasAccess(ctx, 'access_engine')}
              onClick={() => ctx.act('choice', { choice: 'Halogen Counter' })}
            />

            <div style={{ height: '8px' }} />

            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Gas Scanner</div>
              <div className="PDAProgram__v">{scanmode === 5 ? 'ON' : 'OFF'}</div>
            </div>
            <Button
              content={scanmode === 5 ? 'Disable Gas Scanner' : 'Enable Gas Scanner'}
              icon="wind"
              disabled={!hasAccess(ctx, 'access_atmos')}
              onClick={() => ctx.act('choice', { choice: 'Gas Scan' })}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export const HomeProgram: PdaProgram = {
  id: PDA_MODE.HOME,
  title: 'HOME',
  icon: 'house',
  View: (ctx) => <HomeApp ctx={ctx} />,
};

const PDAAppTile = (props: { tile: AppTile; ctx: PdaProgramContext }) => {
  const { tile, ctx } = props;

  const visible = tile.canShow ? tile.canShow(ctx) : true;
  if (!visible) {
    return null;
  }

  const disabled = !ctx.hasCartridge || !ctx.isOn;
  return (
    <button
      className={cx('PDAApp', tile.highlight && 'is-highlight')}
      disabled={disabled}
      onClick={() => ctx.setActiveProgram(tile.id)}
      title={tile.label}
    >
      <div className="PDAApp__icon"><Icon name={tile.icon} /></div>
      <div className="PDAApp__label">{tile.label}</div>
      <div className="PDAApp__hover" />
    </button>
  );
};
