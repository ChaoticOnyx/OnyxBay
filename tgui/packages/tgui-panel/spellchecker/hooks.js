import { useDispatch, useSelector } from "../../common/redux";
import { toggleSpellChecker, updateSpellCheckerSettings } from "./actions";
import { selectSpellChecker } from "./selector";

export const useSpellCheckerSettings = (context) => {
  const state = useSelector(context, selectSpellChecker);
  const dispatch = useDispatch(context);
  return {
    ...state,
    visible: state.visible,
    toggle: () => dispatch(toggleSpellChecker()),
    update: (obj) => dispatch(updateSpellCheckerSettings(obj)),
  };
};
