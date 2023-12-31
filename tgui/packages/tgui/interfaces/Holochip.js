import { clamp, toFixed } from "common/math";
import { useBackend } from "../backend";
import { Button, Section, NumberInput, Flex } from "../components";
import { Window } from "../layouts";
import { SignalerContent } from "./Signaler";

export const Holochip = (props, context) => {
  const { act, data } = useBackend(context)
  return (
    <Window width={340} height={142}>
      <Window.Content>
        <SignalerContent />
      </Window.Content>
    </Window>
  )
}
