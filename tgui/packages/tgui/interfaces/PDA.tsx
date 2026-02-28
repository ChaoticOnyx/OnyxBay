import { Icon } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

import { PDA_MODE } from './PDA/programIds';
import { getProgram } from './PDA/programs/registry';
import { pdaThemeStore } from './PDA/themeStore';
import type { CartridgeType, PdaProgramContext, PdaProgramId, SkinType } from './PDA/types';
import { cx } from './PDA/types';

type PdaData = {
  mode?: string;
  cart_loaded?: number;
  fon?: number;
  stationTime?: string;
  skinType?: string;
  cartridge?: {
    icon_state?: string;
  };
  [key: string]: any;
};

const KNOWN_MODES = new Set(Object.values(PDA_MODE));
const SKIN_ORDER: SkinType[] = ['pda', 'pda-s', 'pda-m', 'pda-tox', 'pda-e', 'pda-c'];

const PROGRAM_CHOICE: Partial<Record<PdaProgramId, string>> = {
  [PDA_MODE.HOME]: '0',
  [PDA_MODE.NOTEKEEPER]: '1',
  [PDA_MODE.MESSENGER]: '2',
  [PDA_MODE.ATMOS_SCAN]: '3',
  [PDA_MODE.NEWS_FEED]: '6',
  [PDA_MODE.CREW_MANIFEST]: '41',
  [PDA_MODE.SIGNALER]: '40',
  [PDA_MODE.STATUS_DISPLAY]: '42',
  [PDA_MODE.POWER_MONITOR]: '43',
  [PDA_MODE.MEDICAL_RECORDS]: '44',
  [PDA_MODE.SECURITY_RECORDS]: '45',
  [PDA_MODE.SECURITY_BOT]: '46',
  [PDA_MODE.SUPPLY_RECORDS]: '47',
  [PDA_MODE.MULE_CONTROL]: '48',
  [PDA_MODE.JANITOR_LOCATOR]: '49',
};

const PROGRAM_ACTION: Partial<Record<PdaProgramId, string>> = {
  [PDA_MODE.DOOR_REMOTE]: 'Toggle Door',
  [PDA_MODE.HONK_SYNTH]: 'Honk',
  [PDA_MODE.REAGENT_SCANNER]: 'Reagent Scan',
  [PDA_MODE.HALOGEN_COUNTER]: 'Halogen Counter',
  [PDA_MODE.GAS_SCANNER]: 'Gas Scan',
};

const normalizeMode = (mode: string | undefined): PdaProgramId => {
  if (mode && KNOWN_MODES.has(mode)) {
    return mode as PdaProgramId;
  }
  return PDA_MODE.HOME;
};

const resolveCartridgeVisualType = (iconState: string): 'general' | 'admin' | 'medical' | 'engineering' => {
  if (!iconState) {
    return 'general';
  }
  if (iconState.includes('hos') || iconState.includes('-h') || iconState.includes('-c') || iconState.includes('syn')) {
    return 'admin';
  }
  if (iconState.includes('-m') || iconState.includes('chem') || iconState.includes('cmo')) {
    return 'medical';
  }
  if (iconState.includes('-e') || iconState.includes('ce') || iconState.includes('-a') || iconState.includes('tox') || iconState.includes('rd')) {
    return 'engineering';
  }
  return 'general';
};

export const PDA = (props: any, context: any) => {
  const { act, data } = useBackend<PdaData>(context);

  const [isOn, setIsOn] = useLocalState(context, 'power', true);
  const [showConfig, setShowConfig] = useLocalState(context, 'show_config', false);
  const [skin, setSkin] = useLocalState<SkinType>(context, 'skin', String(data.skinType || 'pda'));

  const backendMode = normalizeMode(data.mode);
  const activeProgramId = (showConfig ? PDA_MODE.CONFIG : backendMode) as PdaProgramId;
  const hasCartridge = !!data.cart_loaded;
  const flashlightOn = !!data.fon;
  const cartridgeIconState = String(data?.cartridge?.icon_state || '');

  const doChoice = (choice: string, payload?: Record<string, any>) =>
    act('choice', { choice, ...(payload || {}) });

  const setActiveProgram = (id: PdaProgramId) => {
    if (id === PDA_MODE.CONFIG) {
      setShowConfig(true);
      return;
    }

    setShowConfig(false);

    const actionChoice = PROGRAM_ACTION[id];
    if (actionChoice) {
      doChoice(actionChoice);
      return;
    }

    const modeChoice = PROGRAM_CHOICE[id];
    if (modeChoice) {
      doChoice(modeChoice);
    }
  };

  const setTab = (tab: 'HOME' | 'CFG') => {
    if (tab === 'CFG') {
      setShowConfig(true);
      return;
    }

    setShowConfig(false);
    if (backendMode !== PDA_MODE.HOME) {
      doChoice('0');
    }
  };

  const cycleSkin = () => {
    const idx = SKIN_ORDER.indexOf(skin);
    const next = SKIN_ORDER[(idx + 1 + SKIN_ORDER.length) % SKIN_ORDER.length];
    setSkin(next);
  };

  const ctx: PdaProgramContext = {
    isOn,
    hasCartridge,
    cartridgeType: cartridgeIconState as CartridgeType,
    flashlightOn,
    timeText: String(data.stationTime || ''),
    activeProgramId,
    setActiveProgram,
    data,
    act,
  };

  return (
    <Window width={840} height={520} theme="neutral">
      <Window.Content className="PDA__window" fitted>
        <div
          className="PDA"
          data-skin={skin}
          data-power={isOn ? 'on' : 'off'}
          data-cartridge={hasCartridge ? 'inserted' : 'ejected'}
          data-flashlight={flashlightOn ? 'on' : 'off'}
          data-screen-theme={pdaThemeStore.get()}
        >
          <div className="PDA__stage">
            <div className="PDA__device">
              <div className="PDA__texture" />

              <div className="PDA__center">
                <div className="PDA__headerRow">
                  <div className="PDA__headerLeft">
                    <div className="PDA__badge">NT-PDA v4.3</div>
                    <div className="PDA__title">PERSONAL DATA ASSISTANT</div>
                  </div>

                  <div className="PDA__headerRight">
                    <div
                      className={cx('PDA__sdSlot', !hasCartridge && 'is-ejected')}
                      title={hasCartridge ? 'Cartridge inserted' : 'No cartridge'}
                    >
                      <div className="PDA__sdCutout" />
                      <div className="PDA__sdTrack PDA__sdTrack--l" />
                      <div className="PDA__sdTrack PDA__sdTrack--r" />

                      <div className={cx('PDA__sdCartridge', !hasCartridge && 'is-ejected')}>
                        <PDACartridge iconState={cartridgeIconState} ejected={!hasCartridge} />
                      </div>
                    </div>

                    <div className="PDA__statusPills">
                      <div className={cx('PDA__pill', isOn ? 'is-on' : 'is-off')} />
                      <div className={cx('PDA__pill', hasCartridge ? 'is-warn' : 'is-off')} />
                    </div>
                  </div>
                </div>

                <div className="PDA__bezel">
                  <div className="PDA__screenFrame">
                    <PDAScreen
                      ctx={ctx}
                      activeTab={showConfig ? 'CFG' : 'HOME'}
                      onTab={setTab}
                    />
                  </div>
                  <div className="PDA__reflection" />
                </div>

                <div className="PDA__footerMark">
                  FIELD UNIT • MODEL {(data.skinType || skin || '').toUpperCase()} • TGUI COMPLIANT
                </div>
              </div>

              <div className="PDA__right">
                <PDAButton
                  label="PWR"
                  onClick={() => setIsOn(!isOn)}
                  ledColor={isOn ? 'green' : 'none'}
                  icon={
                    <Icon
                      name="power-off"
                      className={cx('PDA__btnIcon', isOn && 'PDA__btnIcon--greenGlow')}
                    />
                  }
                />

                <PDAButton
                  label="LIGHT"
                  onClick={() => doChoice('Light')}
                  isPressed={flashlightOn}
                  ledColor={flashlightOn ? 'blue' : 'none'}
                  icon={
                    <Icon
                      name="bolt"
                      className={cx('PDA__btnIcon', flashlightOn && 'PDA__btnIcon--amberGlow')}
                    />
                  }
                />

                <div className="PDA__divider" />

                <PDAButton
                  label="COMMS"
                  onClick={() => setActiveProgram(PDA_MODE.MESSENGER)}
                  icon={<Icon name="comment" className="PDA__btnIcon" />}
                />

                <PDAButton
                  label="EJECT"
                  onClick={() => doChoice('Eject')}
                  disabled={!hasCartridge}
                  icon={<Icon name="eject" className="PDA__btnIcon" />}
                />

                <div className="PDA__divider" />

                <PDAButton
                  label="SKIN"
                  onClick={cycleSkin}
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
};

type PDAButtonProps = {
  label?: string;
  icon?: any;
  variant?: 'normal' | 'wide';
  ledColor?: 'green' | 'red' | 'blue' | 'none';
  isPressed?: boolean;
  disabled?: boolean;
  onClick?: () => void;
};

const PDAButton = (props: PDAButtonProps) => {
  const {
    label,
    icon,
    variant = 'normal',
    ledColor = 'none',
    isPressed = false,
    disabled,
    onClick,
  } = props;

  return (
    <div className="PDAButton">
      <div className={cx('PDAButton__shell', variant === 'wide' && 'PDAButton__shell--wide')}>
        <div className="PDAButton__well" />
        <div className={cx('PDAButton__housing', isPressed && 'is-pressed', disabled && 'is-disabled')}>
          <div className="PDAButton__texture" />
          <div className="PDAButton__sheen" />

          <button
            className={cx('PDAButton__btn', variant === 'wide' && 'PDAButton__btn--wide')}
            disabled={disabled}
            onClick={onClick}
          >
            {icon && <div className={cx('PDAButton__icon', isPressed && 'is-pressed')}>{icon}</div>}
            {variant === 'wide' && label && <span className="PDAButton__wideLabel">{label}</span>}
          </button>

          {ledColor !== 'none' && (
            <div className={cx('PDAButton__led', `PDAButton__led--${ledColor}`, isPressed && 'is-lit')} />
          )}
        </div>
      </div>

      {variant !== 'wide' && label && <div className="PDAButton__label">{label}</div>}
    </div>
  );
};

const PDACartridge = (props: { iconState: string; ejected?: boolean }) => {
  const { iconState, ejected } = props;
  const visualType = resolveCartridgeVisualType(iconState);

  const label =
    visualType === 'admin'
      ? 'COMMAND AUTH'
      : visualType === 'medical'
        ? 'MED ACCESS'
        : visualType === 'engineering'
          ? 'ENGI ACCESS'
          : 'DATA CARD';

  const iconName =
    visualType === 'admin'
      ? 'lock'
      : visualType === 'medical'
        ? 'triangle-exclamation'
        : visualType === 'engineering'
          ? 'key'
          : 'database';

  return (
    <div className={cx('PDACart', `PDACart--${visualType}`, ejected && 'is-ejected')}>
      <div className="PDACart__corner" />
      <div className="PDACart__topLine" />

      <div className={cx('PDACart__label', `PDACart__label--${visualType}`)}>
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
};

const PDAScreen = (props: {
  ctx: PdaProgramContext;
  activeTab: 'HOME' | 'CFG';
  onTab: (tab: 'HOME' | 'CFG') => void;
}) => {
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
};
