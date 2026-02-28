import type { PdaProgram, PdaProgramContext, PdaProgramId } from '../types';
import { PDA_MODE } from '../programIds';

import { HomeProgram } from './Home';
import { ConfigProgram } from './Config';
import { MessengerProgram } from './Messenger';

import { NotekeeperProgram } from './Notekeeper';
import { CrewManifestProgram } from './CrewManifest';
import { NewsFeedProgram } from './NewsFeed';
import { AtmosScanProgram } from './AtmosScan';

import { SignalerProgram } from './Signaler';
import { StatusDisplayProgram } from './StatusDisplay';
import { PowerMonitorProgram } from './PowerMonitor';
import { SupplyRecordsProgram } from './SupplyRecords';
import { MuleControlProgram } from './MuleControl';
import { JanitorLocatorProgram } from './JanitorLocator';
import { HonkSynthProgram } from './HonkSynth';
import { DoorRemoteProgram } from './DoorRemote';
import { MedicalRecordsProgram } from './MedicalRecords';
import { SecurityRecordsProgram } from './SecurityRecords';
import { SecurityBotProgram } from './SecurityBot';
import { ReagentScannerProgram, HalogenCounterProgram, GasScannerProgram } from './Scanners';

export const PDA_PROGRAMS: PdaProgram[] = [
  HomeProgram,
  ConfigProgram,
  MessengerProgram,

  NotekeeperProgram,
  CrewManifestProgram,
  NewsFeedProgram,
  AtmosScanProgram,

  // old PDA cartridge utilities
  SignalerProgram,
  StatusDisplayProgram,
  PowerMonitorProgram,
  SupplyRecordsProgram,
  MuleControlProgram,
  JanitorLocatorProgram,
  HonkSynthProgram,
  DoorRemoteProgram,
  MedicalRecordsProgram,
  SecurityRecordsProgram,
  SecurityBotProgram,
  ReagentScannerProgram,
  HalogenCounterProgram,
  GasScannerProgram,
];
const byId = new Map<PdaProgramId, PdaProgram>(PDA_PROGRAMS.map(p => [p.id, p]));

const PROGRAM_ALIASES: Partial<Record<PdaProgramId, PdaProgramId>> = {
  [PDA_MODE.MESSENGER_CONVERSATION]: PDA_MODE.MESSENGER,
  [PDA_MODE.NEWS_FEED_CHANNEL]: PDA_MODE.NEWS_FEED,
  [PDA_MODE.POWER_MONITOR_READING]: PDA_MODE.POWER_MONITOR,
  [PDA_MODE.MEDICAL_RECORD]: PDA_MODE.MEDICAL_RECORDS,
  [PDA_MODE.SECURITY_RECORD]: PDA_MODE.SECURITY_RECORDS,
};

export const getProgram = (id: PdaProgramId): PdaProgram => {
  const resolvedId = PROGRAM_ALIASES[id] || id;
  const p = byId.get(resolvedId);
  return p || HomeProgram;
};

export const canRunProgram = (id: PdaProgramId, ctx: PdaProgramContext): boolean => {
  const p = getProgram(id);
  return p.canRun ? p.canRun(ctx) : true;
};
