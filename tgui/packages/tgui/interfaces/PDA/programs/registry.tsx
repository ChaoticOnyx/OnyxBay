import type { PdaProgram, PdaProgramContext, PdaProgramId } from '../types';

import { HomeProgram } from './Home';
import { ConfigProgram } from './Config';
import { NotekeeperProgram } from './Notekeeper';
import { MessengerProgram } from './Messenger';
import { CrewManifestProgram } from './CrewManifest';
import { NewsFeedProgram } from './NewsFeed';
import { AtmosScanProgram } from './AtmosScan';
import { StorageProgram } from './Storage';
import { HealthScanProgram } from './HealthScan';
import { EngineDiagProgram } from './EngineDiag';
import { SecurityProgram } from './Security';

export const PDA_PROGRAMS: PdaProgram[] = [
  HomeProgram,
  ConfigProgram,

  NotekeeperProgram,
  MessengerProgram,
  CrewManifestProgram,
  NewsFeedProgram,
  AtmosScanProgram,
  StorageProgram,

  HealthScanProgram,
  EngineDiagProgram,
  SecurityProgram,
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
