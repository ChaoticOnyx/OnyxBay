/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { roundRestarted } from "./actions";

const withTimestamp = (action) => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = (store) => {
  return (next) => (action) => {
    const { type } = action;
    if (type === roundRestarted.type) {
      return next(withTimestamp(action));
    }
    return next(action);
  };
};
