/* eslint-disable camelcase */
import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Button, Section, ProgressBar, LabeledList } from "../components";

interface Method {
  name: string;
  cost: number;
  ref: string;
}

interface InputData {
  active: number;
  current_charge: number;
  max_charge: number;
  range: number;
  max_range: number;
  methods: Method[];
  current_method: string;
  current_cost: number;
  total_cost: string;
}

export const SuitSensorJammer = (props, context) => {
  const { act, data } = useBackend<InputData>(context);
  const charge = data.current_charge / data.max_charge;
  const methods = data.methods || [];

  return (
    <Window width={350} height={506}>
      <Window.Content fitted>
        <Section
          title="Status"
          buttons={
            <Button
              content="Toggle Jammer"
              icon="wifi"
              selected={data.active}
              onClick={() =>
                act(data.active ? "disable_jammer" : "enable_jammer")
              }
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="State">
              {data.active ? "Active" : "Disabled"}
            </LabeledList.Item>
            <LabeledList.Item label="Charge">
              <ProgressBar
                ranges={{
                  good: [0.6, 1.0],
                  average: [0.4, 0.6],
                  bad: [0.0, 0.4],
                }}
                value={String(charge)}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Energy Consumption">
              ~{data.total_cost}W
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Settings">
          <LabeledList>
            <LabeledList.Item label="Range">
              {data.range}{" "}
              <Button
                disabled={data.range <= 0 ? "1" : null}
                icon="minus"
                onClick={() => act("decrease_range")}
              />
              <Button
                disabled={data.range >= data.max_range ? "1" : null}
                icon="plus"
                onClick={() => act("increase_range")}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Methods">
          {methods.map((method) => {
            return (
              <>
                <Button
                  content={method.name}
                  disabled={data.current_method === method.ref ? "1" : null}
                  onClick={() => act("select_method", { method: method.ref })}
                />
                <br />
              </>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
