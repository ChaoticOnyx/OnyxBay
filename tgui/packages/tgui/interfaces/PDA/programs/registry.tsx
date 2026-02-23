import type { PdaProgram, PdaProgramContext, PdaProgramId } from '../types';

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
  ReagentScannerProgram,
  HalogenCounterProgram,
  GasScannerProgram,
];
const byId = new Map<PdaProgramId, PdaProgram>(PDA_PROGRAMS.map(p => [p.id, p]));

export const getProgram = (id: PdaProgramId): PdaProgram => {
  const p = byId.get(id);
  return p || HomeProgram;
};

export const canRunProgram = (id: PdaProgramId, ctx: PdaProgramContext): boolean => {
  const p = getProgram(id);
  return p.canRun ? p.canRun(ctx) : true;
};
