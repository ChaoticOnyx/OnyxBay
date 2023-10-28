import { useBackend } from "../backend";
import { Button, LabeledList, NoticeBox, Section, Stack } from "../components"
import { Window } from "../layouts"

import { capitalize } from "common/string"

type Spawner = {
  spawner_ref: string;
  name: string;
  origin: string;
  directives: string;
  conditions: string;
  amount_left: number;
};

type InputData = {
  spawners: Spawner[];
};

function SpawnersList(props: Spawner[], context: any) {
  const { act } = useBackend<InputData>(context);

  return (
    <Stack vertical>
      {props.map(spawner => (
        <Stack.Item>
          <Section
          fill
          title={capitalize(spawner.name)}
          buttons={
            <Stack>
              <Stack.Item fontSize="14px" color="green">
                {spawner.amount_left} left
              </Stack.Item>
              <Stack.Item>
                <Button
                content="Jump"
                onClick={() => act('jump', {spawner_ref: spawner.spawner_ref})}
                />
                <Button
                content="Spawn"
                onClick={() => act('spawn', {spawner_ref: spawner.spawner_ref})}
                />
              </Stack.Item>
            </Stack>
          }>
          <LabeledList>
            <LabeledList.Item label="Origin">
              {spawner.origin || 'Unknown'}
            </LabeledList.Item>
            <LabeledList.Item label="Directives">
              {spawner.directives || 'None'}
            </LabeledList.Item>
            <LabeledList.Item color="bad" label="Conditions">
              {spawner.conditions || 'None'}
            </LabeledList.Item>
          </LabeledList>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
}

export function SpawnersMenu(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);
  return (
    <Window theme={getTheme("neutral")} width={700} height={525}>
      <Window.Content scrollable>
        {data.spawners.length ? (
          SpawnersList(data.spawners, context)
        ) : (
          <NoticeBox>No suitable for possess targets were found!</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
}
