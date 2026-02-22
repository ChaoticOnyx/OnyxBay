import { Component } from 'inferno';
import { Icon } from '../components';
import { Window } from '../layouts';

import type { SkinType, CartridgeType, PdaProgramId, PdaProgramContext } from './PDA/types';
import { cx } from './PDA/types';
import { getProgram, canRunProgram } from './PDA/programs/registry';

const SKIN_ORDER: SkinType[] = ['standard', 'security', 'medical', 'science', 'engineering', 'captain'];
const CART_ORDER: CartridgeType[] = ['general', 'admin', 'medical', 'engineering'];

export class PDA extends Component<unknown> {
  // UI-only state (без State/setState)
  private isOn = true;
  private isEjected = false;
  private flashlightOn = false;
  private cartridgeType: CartridgeType = 'general';
  private skin: SkinType = 'standard';

  // навигация программ
  private activeProgramId: PdaProgramId = 'home';

  private nowTs = Date.now();
  private timer: number | null = null;

  componentDidMount() {
    this.timer = window.setInterval(() => {
      this.nowTs = Date.now();
      this.forceUpdate();
    }, 1000);
  }

  componentWillUnmount() {
    if (this.timer) window.clearInterval(this.timer);
    this.timer = null;
  }

  private cycleSkin = () => {
    const idx = SKIN_ORDER.indexOf(this.skin);
    this.skin = SKIN_ORDER[(idx + 1) % SKIN_ORDER.length];
    this.forceUpdate();
  };

  private togglePower = () => {
    this.isOn = !this.isOn;
    // при выключении — оставляем активную программу, но экран станет "off"
    this.forceUpdate();
  };

  private toggleFlashlight = () => {
    this.flashlightOn = !this.flashlightOn;
    this.forceUpdate();
  };

  private handleEject = () => {
    this.isEjected = true;
    // если текущая программа требует картридж — откатываемся на home визуально корректно
    this.ensureRunnableProgram();
    this.forceUpdate();
  };

  private handleInsert = () => {
    if (!this.isEjected) return;
    const idx = CART_ORDER.indexOf(this.cartridgeType);
    this.cartridgeType = CART_ORDER[(idx + 1) % CART_ORDER.length];
    this.isEjected = false;
    this.ensureRunnableProgram();
    this.forceUpdate();
  };

  private ensureRunnableProgram() {
    const ctx = this.buildProgramContext();
    if (!canRunProgram(this.activeProgramId, ctx)) {
      this.activeProgramId = 'home';
    }
  }

  private setActiveProgram = (id: PdaProgramId) => {
    if (id === this.activeProgramId) return;

    const prev = getProgram(this.activeProgramId);
    const next = getProgram(id);

    const ctxBefore = this.buildProgramContext();

    // запреты по canRun
    if (next.canRun && !next.canRun(ctxBefore)) {
      // UI-only: тихо игнорируем, не меняем визуал
      return;
    }

    if (prev.onClose) prev.onClose(ctxBefore);

    this.activeProgramId = id;

    const ctxAfter = this.buildProgramContext();
    if (next.onOpen) next.onOpen(ctxAfter);

    this.forceUpdate();
  };

  private setTab = (t: 'HOME' | 'CFG') => {
    // вкладки сохраняем как в исходнике
    this.setActiveProgram(t === 'HOME' ? 'home' : 'config');
  };

  private formatTimeHHMM(ts: number) {
    const d = new Date(ts);
    const hh = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    return `${hh}:${mm}`;
  }

  private buildProgramContext(): PdaProgramContext {
    return {
      isOn: this.isOn,
      hasCartridge: !this.isEjected,
      cartridgeType: this.cartridgeType,
      flashlightOn: this.flashlightOn,
      timeText: this.formatTimeHHMM(this.nowTs),

      activeProgramId: this.activeProgramId,
      setActiveProgram: this.setActiveProgram,
    };
  }

  render() {
    const ctx = this.buildProgramContext();

    return (
      <Window width={840} height={520} theme="neutral">
        <Window.Content className="PDA__window" fitted>
          <div
            className="PDA"
            data-skin={this.skin}
            data-power={this.isOn ? 'on' : 'off'}
            data-cartridge={this.isEjected ? 'ejected' : 'inserted'}
            data-flashlight={this.flashlightOn ? 'on' : 'off'}
          >
            <div className="PDA__stage">
              <div className="PDA__device">
                <div className="PDA__texture" />

                {/* Center */}
                <div className="PDA__center">
                  <div className="PDA__headerRow">
                    <div className="PDA__headerLeft">
                      <div className="PDA__badge">NT-PDA v4.3</div>
                      <div className="PDA__title">PERSONAL DATA ASSISTANT</div>
                    </div>

                    <div className="PDA__headerRight">
                      <div
                        className={cx('PDA__sdSlot', this.isEjected && 'is-ejected')}
                        onClick={this.isEjected ? this.handleInsert : undefined}
                        style={{ cursor: this.isEjected ? 'pointer' : 'default' }}
                        title={this.isEjected ? 'Insert cartridge' : 'Cartridge inserted'}
                      >
                        <div className="PDA__sdCutout" />
                        <div className="PDA__sdTrack PDA__sdTrack--l" />
                        <div className="PDA__sdTrack PDA__sdTrack--r" />

                        <div className={cx('PDA__sdCartridge', this.isEjected && 'is-ejected')}>
                          <PDACartridge type={this.cartridgeType} ejected={this.isEjected} />
                        </div>
                      </div>

                      <div className="PDA__statusPills">
                        <div className={cx('PDA__pill', this.isOn ? 'is-on' : 'is-off')} />
                        <div className={cx('PDA__pill', !this.isEjected ? 'is-warn' : 'is-off')} />
                      </div>
                    </div>
                  </div>

                  <div className="PDA__bezel">
                    <div className="PDA__screenFrame">
                      <PDAScreen
                        ctx={ctx}
                        activeTab={this.activeProgramId === 'config' ? 'CFG' : 'HOME'}
                        onTab={this.setTab}
                      />
                    </div>
                    <div className="PDA__reflection" />
                  </div>

                  <div className="PDA__footerMark">
                    FIELD UNIT • MODEL {String(this.skin).toUpperCase()} • TGUI COMPLIANT
                  </div>
                </div>

                {/* Right */}
                <div className="PDA__right">
                  <PDAButton
                    label="PWR"
                    onClick={this.togglePower}
                    ledColor={this.isOn ? 'green' : 'none'}
                    icon={
                      <Icon
                        name="power-off"
                        className={cx('PDA__btnIcon', this.isOn && 'PDA__btnIcon--greenGlow')}
                      />
                    }
                  />

                  <PDAButton
                    label="LIGHT"
                    onClick={this.toggleFlashlight}
                    isPressed={this.flashlightOn}
                    ledColor={this.flashlightOn ? 'blue' : 'none'}
                    icon={
                      <Icon
                        name="bolt"
                        className={cx('PDA__btnIcon', this.flashlightOn && 'PDA__btnIcon--amberGlow')}
                      />
                    }
                  />

                  <div className="PDA__divider" />

                  <PDAButton label="COMMS" icon={<Icon name="comment" className="PDA__btnIcon" />} />

                  <PDAButton
                    label="EJECT"
                    onClick={this.handleEject}
                    disabled={this.isEjected}
                    icon={<Icon name="eject" className="PDA__btnIcon" />}
                  />

                  <div className="PDA__divider" />

                  <PDAButton
                    label="SKIN"
                    onClick={this.cycleSkin}
                    icon={<Icon name="palette" className="PDA__btnIcon PDA__btnIcon--small" />}
                  />
                </div>
              </div>

              <div className="PDA__glow" />
            </div>
          </div>
        </Window.Content>
      </Window>
    );
  }
}

/* -------------------- */
/* Subcomponents        */
/* -------------------- */

type PDAButtonProps = {
  label?: string;
  icon?: any;
  variant?: 'normal' | 'wide';
  ledColor?: 'green' | 'red' | 'blue' | 'none';
  isPressed?: boolean;
  disabled?: boolean;
  onClick?: () => void;
};

class PDAButton extends Component<PDAButtonProps> {
  private active = false;

  private down = () => { this.active = true; this.forceUpdate(); };
  private up = () => { this.active = false; this.forceUpdate(); };
  private leave = () => { this.active = false; this.forceUpdate(); };

  render() {
    const { label, icon, variant = 'normal', ledColor = 'none', isPressed = false, disabled, onClick } = this.props;
    const pressed = this.active || isPressed;

    return (
      <div className="PDAButton">
        <div className={cx('PDAButton__shell', variant === 'wide' && 'PDAButton__shell--wide')}>
          <div className="PDAButton__well" />
          <div className={cx('PDAButton__housing', pressed && 'is-pressed', disabled && 'is-disabled')}>
            <div className="PDAButton__texture" />
            <div className="PDAButton__sheen" />

            <button
              className={cx('PDAButton__btn', variant === 'wide' && 'PDAButton__btn--wide')}
              disabled={disabled}
              onMouseDown={this.down}
              onMouseUp={this.up}
              onMouseLeave={this.leave}
              onClick={onClick}
            >
              {icon && <div className={cx('PDAButton__icon', pressed && 'is-pressed')}>{icon}</div>}
              {variant === 'wide' && label && <span className="PDAButton__wideLabel">{label}</span>}
            </button>

            {ledColor !== 'none' && (
              <div className={cx('PDAButton__led', `PDAButton__led--${ledColor}`, pressed && 'is-lit')} />
            )}
          </div>
        </div>

        {variant !== 'wide' && label && <div className="PDAButton__label">{label}</div>}
      </div>
    );
  }
}

function PDACartridge(props: { type: CartridgeType; ejected?: boolean }) {
  const { type, ejected } = props;

  const label =
    type === 'admin' ? 'COMMAND AUTH'
      : type === 'medical' ? 'MED ACCESS'
      : type === 'engineering' ? 'ENGI ACCESS'
      : 'DATA CARD';

  const iconName =
    type === 'admin' ? 'lock'
      : type === 'medical' ? 'triangle-exclamation'
      : type === 'engineering' ? 'key'
      : 'database';

  return (
    <div className={cx('PDACart', `PDACart--${type}`, ejected && 'is-ejected')}>
      <div className="PDACart__corner" />
      <div className="PDACart__topLine" />

      <div className={cx('PDACart__label', `PDACart__label--${type}`)}>
        <div className="PDACart__labelTop">Nanotrasen Data Module</div>

        <div className="PDACart__mid">
          <div className="PDACart__iconBadge">
            <Icon name={iconName} className="PDACart__icon" />
          </div>
          <div className="PDACart__labelMain">{label}</div>
        </div>

        <div className="PDACart__bars">
          <div className="PDACart__bar PDACart__bar--full" />
          <div className="PDACart__bar PDACart__bar--twoThird" />
        </div>
      </div>

      <div className="PDACart__switch" />
      <div className="PDACart__pins">
        {Array.from({ length: 9 }).map((_, i) => <div key={i} className="PDACart__pin" />)}
      </div>
      <div className="PDACart__bottomLine" />
    </div>
  );
}

function PDAScreen(props: {
  ctx: PdaProgramContext;
  activeTab: 'HOME' | 'CFG';
  onTab: (t: 'HOME' | 'CFG') => void;
}) {
  const { ctx, activeTab, onTab } = props;

  if (!ctx.isOn) {
    return (
      <div className="PDAScreenOff">
        <div className="PDAScreenOff__line" />
      </div>
    );
  }

  if (!ctx.hasCartridge) {
    return (
      <div className="PDAScreenNoCart">
        <div className="PDAScreen__scanlines PDAScreen__scanlines--error" />
        <Icon name="circle-xmark" className="PDAScreenNoCart__icon" />
        <div className="PDAScreenNoCart__title">NO CARTRIDGE DETECTED</div>
        <div className="PDAScreenNoCart__text">
          Please insert a compatible data cartridge to access system functions.
        </div>
        <div className="PDAScreenNoCart__code">SYSTEM HALTED // ERROR_CODE: 0x004F</div>
      </div>
    );
  }

  const program = getProgram(ctx.activeProgramId);
  const View = program.View;

  return (
    <div className="PDAScreen">
      <div className="PDAScreen__scanlines" />
      {ctx.flashlightOn && <div className="PDAScreen__flashlight" />}

      <div className="PDAScreen__tabs">
        <div className={cx('PDAScreen__tab', activeTab === 'HOME' && 'is-active')} onClick={() => onTab('HOME')}>
          HOME
        </div>
        <div className={cx('PDAScreen__tab', activeTab === 'CFG' && 'is-active')} onClick={() => onTab('CFG')}>
          CFG
        </div>

        <div className="PDAScreen__tabIcons">
          {ctx.flashlightOn && <Icon name="lightbulb" className="PDAScreen__tabIcon PDAScreen__tabIcon--flash" />}
          <Icon name="signal" className="PDAScreen__tabIcon" />
          <Icon name="battery-half" className="PDAScreen__tabIcon" />
        </div>
      </div>

      <div className="PDAScreen__body scrollbar-hide">
        <View {...ctx} />
      </div>

      <div className="PDAScreen__footer">
        <div className="PDAScreen__footerText">Encryption Active • Secure Link</div>
      </div>
    </div>
  );
}
