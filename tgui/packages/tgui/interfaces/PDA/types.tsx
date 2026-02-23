export type SkinType =
  | 'standard'
  | 'security'
  | 'medical'
  | 'science'
  | 'engineering'
  | 'captain';

export type CartridgeType =
  | 'general'
  | 'admin'
  | 'medical'
  | 'engineering';

export type PdaProgramId =
  | 'home'
  | 'config'
  | 'notekeeper'
  | 'messenger'
  | 'crew_manifest'
  | 'news_feed'
  | 'atmos_scan'

  // cartridge utilities from old PDA
  | 'signaler'
  | 'status_display'
  | 'power_monitor'
  | 'supply_records'
  | 'mule_control'
  | 'janitor_locator'
  | 'honk_synth'
  | 'door_remote'
  | 'reagent_scanner'
  | 'halogen_counter'
  | 'gas_scanner'

export type PdaProgramContext = {
  // состояние оболочки (UI-only сейчас; в будущем — заменяется данными бекэнда точечно)
  isOn: boolean;
  hasCartridge: boolean;
  cartridgeType: CartridgeType;
  flashlightOn: boolean;
  timeText: string;

  // навигация
  activeProgramId: PdaProgramId;
  setActiveProgram: (id: PdaProgramId) => void;
};

export type PdaProgram = {
  id: PdaProgramId;
  title: string;
  icon?: string; // имя FontAwesome, как в исходнике через <Icon name="...">
  // можно расширять без ломки архитектуры
  badgeCount?: (ctx: PdaProgramContext) => number | null;
  canRun?: (ctx: PdaProgramContext) => boolean;
  onOpen?: (ctx: PdaProgramContext) => void;
  onClose?: (ctx: PdaProgramContext) => void;

  // View без хуков
  View: (props: PdaProgramContext) => any;
};

export const cx = (...parts: Array<string | false | null | undefined>) =>
  parts.filter(Boolean).join(' ');
