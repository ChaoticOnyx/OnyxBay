/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { connectionLost, connectionRestored, roundRestarted } from './actions';
import { selectGame } from './selectors';
import { CONNECTION_LOST_AFTER } from './constants';

const withTimestamp = action => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = store => {
  setInterval(() => {
    const state = store.getState();
    if (!state) {
      return;
    }
    const game = selectGame(state);
  }, 1000);
  return next => action => {
    const { type, payload, meta } = action;
    if (type === roundRestarted.type) {
      return next(withTimestamp(action));
    }
    return next(action);
  };
};
