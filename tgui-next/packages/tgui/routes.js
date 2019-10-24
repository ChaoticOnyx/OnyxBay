import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { BrigTimer } from './interfaces/BrigTimer';
import { Resleever } from './interfaces/Resleever';
import { Jukebox } from './interfaces/Jukebox';
import { SuitJammer } from './interfaces/SuitJammer';
import { Psychoscope } from './interfaces/Psychoscope';
import { NeuromodRnD } from './interfaces/NeuromodRnD';

const ROUTES = {
  airlock_electronics: {
    component: () => AirlockElectronics,
    scrollable: true,
  },
  brig_timer: {
    component: () => BrigTimer,
    scrollable: false,
  },
  resleever: {
    component: () => Resleever,
    scrollable: false,
  },
  jukebox: {
    component: () => Jukebox,
    scrollable: true,
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
};

export const getRoute = state => {
  // Show a kitchen sink
  if (state.showKitchenSink) {
    return {
      component: () => KitchenSink,
      scrollable: true,
    };
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
