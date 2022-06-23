import { createAction } from "../../common/redux";

export const loadSpellCheckerSettings = createAction(
  "spellCheckerSettings/load"
);
export const updateSpellCheckerSettings = createAction(
  "spellCheckerSettings/update"
);
export const toggleSpellChecker = createAction("spellChecker/toggle");
export const doSpellCheck = createAction("chat/spellcheck");
