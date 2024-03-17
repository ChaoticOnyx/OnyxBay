import { BooleanLike } from "common/react";

import { useBackend } from "../backend";
import { Box, Stack } from "../components";
import { Window } from "../layouts";

import { LockKeypad } from "./common/LockKeypad";

export interface LockData {
  input_code: string;
  locked: BooleanLike;
  lock_code: BooleanLike;
  emagged: BooleanLike;
  lock_setshort: BooleanLike;
}

export const LockedSafe = (props: any, context: any) => {
  const { act, data } = useBackend<LockData>(context);
  const { input_code, locked, lock_code, emagged, lock_setshort } = data;
  return (
    <Window width={300} height={400}>
      <Window.Content>
        <LockMenu></LockMenu>
      </Window.Content>
    </Window>
  );
};

export const LockMenu = (props: any, context: any) => {
  const { act, data } = useBackend<LockData>(context);
  const { input_code, locked, lock_code, emagged, lock_setshort } = data;

  return (
    <Box m="6px">
      <Box mb="6px" className="NuclearBomb__displayBox">
        {input_code}
      </Box>
      <Box className="NuclearBomb__displayBox">
        {!lock_code && !emagged && !lock_setshort ? "No password set." : ""}
        {emagged && !lock_setshort ? "SYSTEM ERROR 1701" : ""}
        {lock_setshort ? "SYSTEM ERROR 6040" : ""}
        {!!lock_code && !emagged && !lock_setshort
          ? locked
            ? "Locked"
            : "Unlocked"
          : ""}
      </Box>
      <Stack ml="42px" mt="12px">
        <Stack.Item>
          <LockKeypad />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
