import { useBackend } from "../backend";
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  LabeledControls,
} from "../components";
import { Window } from "../layouts";

interface GunData {
  gunName: string;
  gunDesc: string;
}

interface Data {
  chosenGun: string;
  chosenGunDesc: string;
  gunSpawned: boolean;
  possibleGuns: GunData[];
}

export const Guncase = (props: any, context: any) => {
  const { act, data } = useBackend<Data>(context);

  return (
    <Window width={300} height={345}>
      <Window.Content>
        <Section title="The security hardcase">
          <Stack fill vertical>
            <Stack.Item>
              It can be locked and unlocked by swiping your ID card across the
              lock.
            </Stack.Item>
            <Stack.Item>
              Be careful! Once you chose your weapon and unlock the gun case,
              you won't be able to change it.
            </Stack.Item>
          </Stack>
        </Section>
        <Stack>
          <Stack.Item>
            <Section minHeight="100%" width={window.innerWidth - 220 + "px"}>
              <Stack vertical>
                {data.possibleGuns.map((gun) => (
                  <Stack.Item>
                    <Button
                      fluid
                      tooltip={gun.gunDesc}
                      onClick={() => act("chooseGun", { gunName: gun.gunName })}
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
          <Stack ml="10px">
            <Stack.Item>
              <Section title="Chosen gun:">
                {data.chosenGun ? data.chosenGun : "N/A"}
                <Stack.Item>{data.chosenGunDesc}</Stack.Item>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};
