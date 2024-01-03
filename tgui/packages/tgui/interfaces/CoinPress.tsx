import { useBackend } from '../backend';
import { Window } from "../layouts";
import { Button, Section, Stack} from '../components';

type Material = {
  material: string;
  amount: number;
}

type InputData = {
  produced_coins: number;
  processing: boolean;
  chosen_material: string;
  inserted_materials: Material[];
}

export const CoinPress = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Coin Press" width={435} height={500}>
      <Window.Content fitted>
        <Section
          title="Materials"
          buttons={(data.processing ? (
            <Button
              content="Stop"
              onClick={() => act('stoppress')}
            />
          ) : (
            <Button
              content="Start"
              onClick={() => act('startpress')}
            />
          ))}>
          <Stack>
            {data.inserted_materials.map(material => {
              return (
                <Stack.Item
                  label = {material.material}
                  buttons={
                    <Button content="Select"
                      selected = {data.chosen_material === material.material}
                      onClick={() => act('changematerial', {
                        material_name: material.material,
                      })}
                    />
                  }>
                  {material.amount} cm³
                </Stack.Item>
              );
            })}
          </Stack>
        </Section>
        <Section>
          Pressed {data.produced_coins} coins this cycle.
        </Section>
    </Window.Content>
  </Window>
  );
};
