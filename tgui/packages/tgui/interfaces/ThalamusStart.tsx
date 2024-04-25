import { GameIcon } from "../components/GameIcon";
import { useBackend, useLocalState } from "../backend";
import { Button, Section, Dimmer, Stack } from "../components";
import { Window } from "../layouts";

interface InputData {}

export const ThalamusStart = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return <Stack></Stack>;
};
