import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, NumberInput } from '../components';
import { Window } from '../layouts';
import { clamp, toFixed } from "../../common/math";

type Content = {
  type: string;
  name: string;
  amount: number;
};

type InputData = {
  machine: boolean;
  stacking_amount: number;
  contents: Content[];
};

export const StackingConsole = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <Window width={320} height={340}>
      <Window.Content scrollable>
        {!data.machine ? (
          <NoticeBox>No connected stacking machine</NoticeBox>
        ) : (
          <StackingConsoleContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const StackingConsoleContent = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  return (
    <>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Stacking Amount">
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
      </Section>
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
    </>
  );
};
