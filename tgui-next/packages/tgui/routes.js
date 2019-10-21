import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { BrigTimer } from './interfaces/BrigTimer';
import { Resleever } from './interfaces/Resleever';
import { Jukebox } from './interfaces/Jukebox';
import { SuitJammer } from './interfaces/SuitJammer';

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
};

export const getRoute = state => {
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
