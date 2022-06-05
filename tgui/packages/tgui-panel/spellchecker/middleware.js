import { storage } from "../../common/storage";
import { MESSAGE_TYPE_INTERNAL } from "../chat/constants";
import {
  doSpellCheck,
  loadSpellCheckerSettings,
  updateSpellCheckerSettings,
} from "./actions";
import { YANDEX_BASE_URI } from "./constants";
import { selectSpellChecker } from "./selector";

const filterText = (text) => {
  text = text.toLowerCase();
  text = text.replace(/[^а-яА-ЯёЁ ]/g, " ");
  text = text.replace(/\s+/g, " ");

  return text;
};

const removeBlacklistedWords = (text, blacklist) => {
  const words = blacklist.split(",") || blacklist;
  let res = text;

  if (!blacklist) {
    return res;
  }

  for (const word of words) {
    const regex = "(?:\\s|^)(?:" + word.trim() + ")\\S*";
    res = res.replace(new RegExp(regex, "g"), "");
  }

  return res;
};

const yandexRequest = (text, callback) => {
  const xhr = new XMLHttpRequest();
  xhr.onreadystatechange = () => callback(xhr);
  xhr.open("GET", `${YANDEX_BASE_URI}${encodeURIComponent(text)}`, true);
  xhr.send();
};

const handleYandexResponse = (response) => {
  return response
    .filter((mistake) => mistake.s.length > 0)
    .map((mistake) => ({
      mistake: mistake.word,
      correct: mistake.s.join(","),
    }));
};

const makeSpellErrorMessage = (errors) => {
  let mistakes = [];

  for (const error of errors) {
    mistakes = mistakes.concat(
      `<span class='correct-word'>${error.correct}</span> - <span class='error-word'>${error.mistake}</span>`
    );
  }

  return `<span class="fas fa-spell-check"></span> <span class='spell-error'>Возможные орфографические ошибки: ${mistakes.join(
    ""
  )}</span>`;
};

export const spellCheckerMiddleware = (store) => {
  let initialized = false;

  return (next) => (action) => {
    const { type, payload } = action;

    if (!initialized) {
      initialized = true;
      storage.get("spellchecker-settings").then((settings) => {
        store.dispatch(loadSpellCheckerSettings(settings));
      });
    }

    // Pass action to get an updated state
    next(action);
    const settings = selectSpellChecker(store.getState());

    if (type === doSpellCheck.type && settings.enabled) {
      let filtered = filterText(payload);
      filtered = removeBlacklistedWords(filtered, settings.blacklist);
      yandexRequest(filtered, (response) => {
        if (
          response.readyState === XMLHttpRequest.DONE &&
          response.status === 200
        ) {
          const res = handleYandexResponse(JSON.parse(response.responseText));

          if (res.length === 0) {
            return;
          }

          store.dispatch({
            type: "chat/message",
            payload: {
              type: MESSAGE_TYPE_INTERNAL,
              html: makeSpellErrorMessage(res),
            },
          });
        }
      });
    }

    if (type === updateSpellCheckerSettings.type) {
      storage.set("spellchecker-settings", settings);
    }
  };
};
