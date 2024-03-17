import { useBackend } from "../backend";
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  LabeledControls,
  Box,
} from "../components";
import { Window } from "../layouts";
import { LockData, LockMenu } from "./LockedSafe";

interface GunData {
  gunName: string;
  gunDesc: string;
}

interface Data extends LockData {
  chosenGun: string;
  chosenGunDesc: string;
  gunSpawned: boolean;
  possibleGuns: GunData[];
}

export const DetectiveGuncase = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<Data>(context);

  return (
    <Window width={430} height={490} theme={getTheme("neutral")}>
      <Window.Content>
        <Section title="The detective's gun case">
          Be careful! Once you chose your weapon and unlock the gun case, you
          won't be able to change it.
        </Section>
        <Stack fill vertical>
          <Stack fill>
            <Stack.Item grow>
              <Section minHeight="81.5%" width={window.innerWidth - 300 + "px"}>
                <Stack vertical>
                  {data.possibleGuns.map((gun, i) => (
                    <Stack.Item>
                      <Button
                        fluid
                        tooltip={gun.gunDesc}
                        onClick={() =>
                          act("chooseGun", { gunName: gun.gunName })
                        }
                        color={
                          data.chosenGun === gun.gunName ? "good" : "default"
                        }
                        disabled={data.gunSpawned}
                      >
                        {gun.gunName}
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow={10}>
              <Section>
                <LockMenu />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};
