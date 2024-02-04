import { useBackend } from "../backend";
import {
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Stack,
  Table,
} from "../components";
import { Window } from "../layouts";
import { toTitleCase } from "common/string";

const METAL_PROCESS = {
  noAction: 0,
  processSmelt: 1,
  processCompress: 2,
  processAlloy: 3,
};

type User = {
  name: string;
  cash: number;
};

type Material = {
  name: string;
  current_action: number;
  ore_tag: string;
};

type InputData = {
  unclaimedPoints: number;
  user: User;
  materials: Material[];
  machine_state: boolean;
};

export const OreRedemptionMachine = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Ore Redemption Machine" width={435} height={400}>
      <Window.Content>
        <Stack fill vertical justify="space-between">
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item m={1}>
                  <Icon
                    name="id-card"
                    size={2}
                    color={data.user ? "green" : "red"}
                  />
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Name">
                      {data.user?.name || "No Name Detected"}
                    </LabeledList.Item>
                    <LabeledList.Item label="Balance">
                      {data.user?.cash || "No Balance Detected"}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Icon name="coins" color="gold" />
              <Box inline color="label" ml={1}>
                Unclaimed points:
              </Box>
              {data.unclaimedPoints}
              <Button
                ml={2}
                content="Claim"
                disabled={data.unclaimedPoints === 0}
                onClick={() => act("claim")}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              justify="space-between"
              title="Ore processing"
              buttons={
                <Button
                  icon="power-off"
                  color={data.machine_state ? "green" : "red"}
                  tooltip="Toggle industrial smelter"
                  onClick={() => act("toggle_machine")}
                />
              }
            >
              <MaterialsList />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

function MaterialsList(props: any, context: any) {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Table>
      {data.materials.map((material) => (
        <Table.Row className="candystripe" collapsing>
          <Table.Cell>{toTitleCase(material.name)}</Table.Cell>
          <Table.Cell collapsing textAlign="left">
            <Button
              content="no action"
              color={
                material.current_action === METAL_PROCESS.noAction
                  ? "green"
                  : null
              }
              onClick={() =>
                act("change_process", {
                  material_name: material.ore_tag,
                  material_process: METAL_PROCESS.noAction,
                })
              }
            />
            <Button
              content="smelt"
              color={
                material.current_action === METAL_PROCESS.processSmelt
                  ? "green"
                  : null
              }
              onClick={() =>
                act("change_process", {
                  material_name: material.ore_tag,
                  material_process: METAL_PROCESS.processSmelt,
                })
              }
            />
            <Button
              content="compress"
              color={
                material.current_action === METAL_PROCESS.processCompress
                  ? "green"
                  : null
              }
              onClick={() =>
                act("change_process", {
                  material_name: material.ore_tag,
                  material_process: METAL_PROCESS.processCompress,
                })
              }
            />
            <Button
              content="alloy"
              color={
                material.current_action === METAL_PROCESS.processAlloy
                  ? "green"
                  : null
              }
              onClick={() =>
                act("change_process", {
                  material_name: material.ore_tag,
                  material_process: METAL_PROCESS.processAlloy,
                })
              }
            />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
}
