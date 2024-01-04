import { useBackend } from '../backend';
import {
  Button,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';

type Material = {
  name: string;
  ore_tag: string;
  amount: number;
}

type InputData = {
  produced_coins: number;
  active: boolean;
  chosen_material: string;
  inserted_materials: Material[];
}

export const CoinPress = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Coin Press" width={435} height={260}>
      <Window.Content>
      <Stack fill vertical justify="space-between">
        <Stack.Item grow>
          <Section
            title="Materials"
            buttons= {(
              <Button
                icon="power-off"
                color={data.active ? 'green' : 'red'}
                tooltip="Toggle industrial smelter"
                onClick={() => act('toggle_machine')}
              />
            )}>
            <MaterialsList />
          </Section>
        </Stack.Item>
        <Stack.Item>
          <Section>
            Pressed {data.produced_coins} coins this cycle.
          </Section>
        </Stack.Item>
      </Stack>
    </Window.Content>
  </Window>
  );
};

function MaterialsList (props: any, context: any) {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Table>
      {data.inserted_materials.map(material => (
        <Table.Row className="candystripe" collapsing>
        <Table.Cell>{material.name}</Table.Cell>
        <Table.Cell collapsing textAlign="left">
        <Button
            content="select"
            color={material.ore_tag === data.chosen_material ? 'green' : null}
            onClick={() => act('change_process', {material_name: material.ore_tag})}
          />
        </Table.Cell>
      </Table.Row>
      ))}
    </Table>
  );
}
