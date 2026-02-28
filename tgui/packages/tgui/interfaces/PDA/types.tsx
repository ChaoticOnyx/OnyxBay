import type { PdaProgramId as ProgramId } from './programIds';

export type PdaProgramId = ProgramId;

export type SkinType = string;
export type CartridgeType = string;

export type PdaProgramContext = {
  isOn: boolean;
  hasCartridge: boolean;
  cartridgeType: CartridgeType;
  flashlightOn: boolean;
  timeText: string;

  activeProgramId: ProgramId;
  setActiveProgram: (id: ProgramId) => void;

  data: Record<string, any>;
  act: (action: string, payload?: Record<string, any>) => void;
};

export type PdaProgram = {
  id: ProgramId;
  title: string;
  icon?: string;
  badgeCount?: (ctx: PdaProgramContext) => number | null;
  canRun?: (ctx: PdaProgramContext) => boolean;
  onOpen?: (ctx: PdaProgramContext) => void;
  onClose?: (ctx: PdaProgramContext) => void;
  View: (props: PdaProgramContext) => any;
};

export const cx = (...parts: Array<string | false | null | undefined>) =>
  parts.filter(Boolean).join(' ');
