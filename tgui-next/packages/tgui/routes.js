import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { BrigTimer } from './interfaces/BrigTimer';
import { Resleever } from './interfaces/Resleever';
import { SuitJammer } from './interfaces/SuitJammer';
import { Psychoscope } from './interfaces/Psychoscope';
import { NeuromodRnD } from './interfaces/NeuromodRnD';
import { BodyScanner } from './interfaces/BodyScanner';

const ROUTES = {
  airlock_electronics: {
    component: () => AirlockElectronics,
    scrollable: true,
  },
  brig_timer: {
    component: () => BrigTimer,
    scrollable: true,
  },
  resleever: {
    component: () => Resleever,
    scrollable: false,
  },
  suit_sensor_jammer: {
    component: () => SuitJammer,
    scrollable: true,
  },
  psychoscope: {
    component: () => Psychoscope,
    scrollable: true,
  },
  neuromod_rnd: {
    component: () => NeuromodRnD,
    scrollable: true,
  },
  body_scanner: {
    component: () => BodyScanner,
    scrollable: true,
  },
};

export const getRoute = state => {
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
