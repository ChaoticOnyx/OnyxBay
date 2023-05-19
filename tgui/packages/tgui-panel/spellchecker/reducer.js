import {
  loadSpellCheckerSettings,
  toggleSpellChecker,
  updateSpellCheckerSettings,
} from "./actions";

const initialState = {
  enabled: false,
  visible: false,
  blacklist:
    "бипски, дорм, еган, емаг, ионк, научк, синг, скрабер, термалы, хонк, центком, голодек, тазер, ксен, мусорк",
};

export const defaultBlacklist = initialState.blacklist;

export const spellCheckerReducer = (state = initialState, action) => {
  const { type, payload } = action;

  if (type === loadSpellCheckerSettings.type) {
    if (!payload) {
      return {
        ...initialState,
      };
    }

    payload.visible = false;

    return {
      ...state,
      ...payload,
    };
  }

  if (type === updateSpellCheckerSettings.type) {
    return {
      ...state,
      ...payload,
    };
  }

  if (type === toggleSpellChecker.type) {
    return {
      ...state,
      visible: !state.visible,
    };
  }

  return state;
};
