import { useBackend } from "../backend";
import { Button, NoticeBox, Section, Stack } from "../components";
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
  const { act, data } = useBackend<Data>(context);

  return (
    <Window width={430} height={470}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox>
              Be careful! Once you chose your weapon and unlock the gun case,
              you won't be able to change it.
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill vertical>
              <Stack fill>
                <Stack.Item grow>
                  <Section fill>
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
                              data.chosenGun === gun.gunName
                                ? "good"
                                : "default"
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
                <Stack.Item grow>
                  <Section fill>
                    <LockMenu />
                  </Section>
                </Stack.Item>
              </Stack>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
