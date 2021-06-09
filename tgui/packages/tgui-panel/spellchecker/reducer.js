import { logger } from "../../tgui/logging";
import { toggleSpellChecker, updateSpellCheckerSettings } from "./actions";

export const initialState = {
  enabled: false,
  visible: false,
  blacklist: '',
};

export const spellCheckerReducer = (state = initialState, action) => {
  const { type, payload } = action;

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
