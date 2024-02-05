import { right } from "@popperjs/core";
import { useBackend } from "../backend";
import { Button, Section, Stack, Table, NumberInput } from "../components";
import { Window } from "../layouts";
import { toTitleCase } from "common/string";

type Material = {
  name: string;
  amount: number;
};

type InputData = {
  produced_coins: number;
  active: boolean;
  chosen_material: string;
  inserted_materials: Material[];
};

export const CoinPress = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Coin Press" width={169} height={275}>
      <Window.Content>
        <Stack fill vertical justify="space-between">
          <Stack.Item grow>
            <Section
              title="Materials"
              buttons={
                <Button
                  icon="power-off"
                  color={data.active ? "green" : "red"}
                  tooltip="Toggle industrial smelter"
                  onClick={() => act("toggle_machine")}
                />
              }
            >
              <MaterialsList />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>Pressed {data.produced_coins} coins this cycle.</Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

function MaterialsList(props: any, context: any) {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Stack vertical nowrap>
      {data.inserted_materials.map((material) => (
        <Stack.Item>
          <Stack fill>
            <Stack.Item grow>
              <Button
                fluid
                content={toTitleCase(material.name)}
                color={material.name === data.chosen_material ? "green" : null}
                onClick={() =>
                  act("change_material", { material_name: material.name })
                }
              />
            </Stack.Item>
            <Stack.Item align="right">
              <Button
                icon="eject"
                color={"red"}
                onClick={() =>
                  act("eject_material", { material_name: material.name })
                }
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
}
