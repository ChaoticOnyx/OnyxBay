import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { BrigTimer } from './interfaces/BrigTimer';
import { Resleever } from './interfaces/Resleever';

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
