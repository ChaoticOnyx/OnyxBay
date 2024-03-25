import { useBackend } from "../backend";
import { Button, NoticeBox, Section, Stack } from "../components";
import { Window } from "../layouts";

interface GunData {
  gunName: string;
  gunDesc: string;
}

interface Data {
  title: string;
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
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox success>
              It can be locked and unlocked by swiping your ID card across the
              lock.
            </NoticeBox>
            <NoticeBox>
              Be careful! Once you chose your weapon and unlock the gun case,
              you won't be able to change it.
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item>
                <Section fill>
                  <Stack vertical>
                    {data.possibleGuns.map((gun) => (
                      <Stack.Item>
                        <Button
                          textAlign="center"
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
              <Stack.Item grow>
                <Section title={data.chosenGun ? data.chosenGun : "N/A"}>
                  <Stack.Item>{data.chosenGunDesc}</Stack.Item>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
