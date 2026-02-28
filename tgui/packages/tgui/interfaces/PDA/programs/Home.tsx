import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
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
  // General (старый PDA)
  { id: 'notekeeper', icon: 'file-lines', label: 'Notekeeper' },
  { id: 'messenger', icon: 'comment', label: 'Messenger' },
  { id: 'crew_manifest', icon: 'users', label: 'Crew Manifest' },
  { id: 'news_feed', icon: 'radio', label: 'News' },

  // Utilities (старый PDA)
  { id: 'atmos_scan', icon: 'wind', label: 'Atmospheric Scan' },

  // Cartridge utilities from old PDA (показываем по canShow)
  { id: 'status_display', icon: 'display', label: 'Status Display', highlight: true, canShow: (ctx) => ctx.cartridgeType === 'admin' },
  { id: 'signaler', icon: 'tower-broadcast', label: 'Signaler System', highlight: true, canShow: (ctx) => ctx.cartridgeType === 'admin' },
  { id: 'door_remote', icon: 'door-closed', label: 'Toggle Door', canShow: (ctx) => ctx.cartridgeType === 'admin' },

  { id: 'power_monitor', icon: 'bolt', label: 'Power Monitor', highlight: true, canShow: (ctx) => ctx.cartridgeType === 'engineering' },

  { id: 'supply_records', icon: 'box', label: 'Supply Records', canShow: (ctx) => ctx.cartridgeType === 'admin' },
  { id: 'mule_control', icon: 'truck', label: 'Delivery Bot Control', canShow: (ctx) => ctx.cartridgeType === 'admin' },
  { id: 'medical_records', icon: 'plus', label: 'Medical Records', canShow: (ctx) => ctx.cartridgeType === 'medical' || ctx.cartridgeType === 'admin' },
  { id: 'security_records', icon: 'alert', label: 'Security Records', canShow: (ctx) => ctx.cartridgeType === 'admin' },
  { id: 'security_bot', icon: 'gear', label: 'Security Bot Control', canShow: (ctx) => ctx.cartridgeType === 'admin' },

  { id: 'janitor_locator', icon: 'broom', label: 'Custodial Locator', canShow: (ctx) => ctx.cartridgeType === 'admin' },

  { id: 'honk_synth', icon: 'face-grin-squint', label: 'Honk Synthesizer', canShow: (ctx) => ctx.cartridgeType === 'admin' },
];

const computeOwner = (cartridgeType: PdaProgramContext['cartridgeType']) => {
  if (cartridgeType === 'admin') return 'S. Batten, Captain';
  if (cartridgeType === 'medical') return 'M. Solus, CMO';
  if (cartridgeType === 'engineering') return "M. O'Brien, CE";
  return 'J. Doe, Assistant';
};

const computeIdSuffix = (cartridgeType: PdaProgramContext['cartridgeType']) =>
  cartridgeType.substring(0, 2).toUpperCase();

/**
 * SCANNERS (старый UI):
 *  - Reagent Scanner (toggle)
 *  - Halogen Counter (toggle)
 *  - Gas Scanner (toggle)
 *
 * ВАЖНО: это НЕ отдельные программы, а просто кнопки ON/OFF (mock).
 */
class HomeApp extends Component<{ ctx: PdaProgramContext }> {
  private reagentOn = false;
  private halogenOn = false;
  private gasOn = false;

  private toggle = (k: 'reagent' | 'halogen' | 'gas') => {
    if (k === 'reagent') this.reagentOn = !this.reagentOn;
    if (k === 'halogen') this.halogenOn = !this.halogenOn;
    if (k === 'gas') this.gasOn = !this.gasOn;
    this.forceUpdate();
  };

  render() {
    const { ctx } = this.props;
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

          {/* Старые scanner toggles: только ON/OFF, без “вглубь” */}
          <div style={{ marginTop: '10px' }}>
            <div className="PDAScreen__h" style={{ marginTop: '6px' }}>SCANNERS</div>

            <div className="PDAProgram__panel">
              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Reagent Scanner</div>
                <div className="PDAProgram__v">{this.reagentOn ? 'ON' : 'OFF'}</div>
              </div>
              <Button
                content={this.reagentOn ? 'Disable Reagent Scanner' : 'Enable Reagent Scanner'}
                icon="flask"
                onClick={() => this.toggle('reagent')}
              />

              <div style={{ height: '8px' }} />

              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Halogen Counter</div>
                <div className="PDAProgram__v">{this.halogenOn ? 'ON' : 'OFF'}</div>
              </div>
              <Button
                content={this.halogenOn ? 'Disable Halogen Counter' : 'Enable Halogen Counter'}
                icon="radiation"
                onClick={() => this.toggle('halogen')}
              />

              <div style={{ height: '8px' }} />

              <div className="PDAProgram__row">
                <div className="PDAProgram__k">Gas Scanner</div>
                <div className="PDAProgram__v">{this.gasOn ? 'ON' : 'OFF'}</div>
              </div>
              <Button
                content={this.gasOn ? 'Disable Gas Scanner' : 'Enable Gas Scanner'}
                icon="wind"
                onClick={() => this.toggle('gas')}
              />

              <div className="PDAProgram__footerHint" style={{ marginTop: '8px' }}>
                UI-only toggles • no deep screen (matches old behavior)
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export const HomeProgram: PdaProgram = {
  id: 'home',
  title: 'HOME',
  icon: 'house',
  View: (ctx) => <HomeApp ctx={ctx} />,
};

function PDAAppTile(props: { tile: AppTile; ctx: PdaProgramContext }) {
  const { tile, ctx } = props;

  const visible = tile.canShow ? tile.canShow(ctx) : true;
  if (!visible) return null;

  const disabled = !ctx.hasCartridge || !ctx.isOn;
  const canRun = !disabled;

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
