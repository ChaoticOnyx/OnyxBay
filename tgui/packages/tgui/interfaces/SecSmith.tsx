import { useBackend, useLocalState } from "../backend";
import { Window } from "../layouts";
import {
  Button,
  Box,
  Section,
  Stack,
  Input,
  Modal,
  LabeledList,
  Divider,
  NoticeBox,
  LabeledControls,
} from "../components";

interface TaserVariant {
  name: string;
  type: string;
}

interface InputData {
  taserInstalled: boolean;
  model: string;
  owner: string;
  charge: string;
  rateOfFire: number;
  ammo: number;
  info: string;
  taserVariants: TaserVariant[];
}

export const SecSmith = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [ownerInputOpen, setOwnerInputOpen] = useLocalState(
    context,
    "ownerInput",
    false
  );

  const [assembleMenuOpen, setAssembleMenuOpen] = useLocalState(
    context,
    "assembleMenu",
    false
  );

  const [newOwner, setNewOwner] = useLocalState(context, "name", "");

  return (
    <Window width={400} height={320}>
      <Window.Content>
        <Section title="Security equipment assembling system">
          Property of NanoTransen
        </Section>
        {!data.taserInstalled ? (
          <NoticeBox>No equipment found!</NoticeBox>
        ) : (
          <Stack fill vertical>
            <Stack fill>
              <Stack.Item grow>
                <Section>
                  <Stack vertical>
                    <Button onClick={() => setOwnerInputOpen(true)} fluid>
                      Set Owner
                    </Button>
                    <Button onClick={() => act("reset_owner")} fluid>
                      Reset Owner
                    </Button>
                    <Button onClick={() => setAssembleMenuOpen(true)} fluid>
                      Reassemble
                    </Button>
                    <Button onClick={() => act("eject_taser")} fluid>
                      Eject
                    </Button>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section title="Equipment found:">
                  <LabeledList>
                    <LabeledList.Item label="Model">
                      <Box textColor="label">{data.model}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Assigned user">
                      <Box textColor="label">
                        {data.owner ? data.owner : "N/A"}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Charge">
                      <Box textColor="label">{data.charge}%</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Rate of fire">
                      <Box textColor="label">{data.rateOfFire} RPM</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Ammunition">
                      <Box textColor="label">{data.ammo} shots</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Info">
                      <Box textColor="label">{data.info}</Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack>
        )}
      </Window.Content>
      {ownerInputOpen && (
        <Modal>
          <Section title="Set Owner">
            <LabeledList>
              <LabeledList.Item label="Input name">
                <Input
                  fluid
                  onChange={(_, value: string) => setNewOwner(value)}
                ></Input>
              </LabeledList.Item>
            </LabeledList>
            <Divider hidden />
            <Divider hidden />
            <Stack justify="space-between" align="center">
              <Stack.Item width="100%">
                <Button
                  fluid
                  color="good"
                  icon="check"
                  content="Confirm"
                  onClick={() => {
                    act("set_owner", { ownerName: newOwner });
                    setOwnerInputOpen(false);
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  color="bad"
                  icon="ban"
                  content="Cancel"
                  onClick={() => setOwnerInputOpen(false)}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Modal>
      )}
      {assembleMenuOpen && (
        <Modal m={1}>
          <Section
            title="Reassemble"
            buttons={
              <Button
                icon="ban"
                color="red"
                onClick={() => setAssembleMenuOpen(false)}
              />
            }
          >
            <LabeledControls>
              {data.taserVariants.map((variant) => (
                <LabeledControls.Item>
                  <Button
                    content={variant.name}
                    onClick={() => {
                      act("select_model", { newModelType: variant.type });
                      setAssembleMenuOpen(false);
                    }}
                  />
                </LabeledControls.Item>
              ))}
            </LabeledControls>
          </Section>
        </Modal>
      )}
    </Window>
  );
};
