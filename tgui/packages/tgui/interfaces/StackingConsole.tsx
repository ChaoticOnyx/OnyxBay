import { useBackend } from '../backend';
import { Button, Stack, NoticeBox, Section, NumberInput, LabeledList } from '../components';
import { Window } from '../layouts';

type Content = {
  type: string;
  name: string;
  amount: number;
};

type InputData = {
  machine_state: boolean;
  stacking_amount: number;
  contents: Content[];
};

export const StackingConsole = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window title="Stacking console" width={320} height={340}>
      <Window.Content scrollable>
      <Stack fill vertical>
        <Stack.Item>
          <Section>
            <Stack>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item
                    label="Stacking Amount"
                    buttons={(
                      <Button
                      icon="power-off"
                      color={data.machine_state ? 'green' : 'red'}
                      tooltip="Toggle stacking machine"
                      onClick={() => act('toggle_machine')}
                      />
                    )}>
                    <NumberInput
                    align = "right"
                    minValue={1}
                    maxValue={50}
                    unit="units"
                    value={data.stacking_amount}
                    onChange={(e: any, value: number) => act("adjust_stacking_amount", { stack_amount: value })}
                    />
                  </LabeledList.Item>
                </LabeledList>
                </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
        <Stack.Item>
        <Section title="Stored Materials">
          {!data.contents.length ? (
            <NoticeBox>No stored materials</NoticeBox>
          ) : (
            <LabeledList>
              {data.contents.map((content) => (
                <LabeledList.Item
                  key={content.type}
                  label={content.name}
                  buttons={
                    <Button
                      icon="eject"
                      content="Release"
                      onClick={() =>
                        act('release', {
                          type: content.type,
                        })
                      }
                    />
                  }
                >
                  {content.amount || 'Unknown'}
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
        </Stack.Item>
      </Stack>
    </Window.Content>
  </Window>
  );
};
