import { useBackend } from "../backend";
import { Button, LabeledList, NumberInput, Section } from "../components";
import { Window } from "../layouts";
import { useLocalState } from "../backend";

function kelvinToCelsius(kelvin: number) {
  return kelvin - 273.15;
}

type InputData = {
  cell: boolean;
  charge: number;
  temperature: number;
  minTemperature: number;
  maxTemperature: number;
};

export const SpaceHeater = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const [useKelvin, setUseKelvin] = useLocalState<boolean>(
    context,
    "useKelvin",
    true
  );

  return (
    <Window width={250} height={140}>
      <Window.Content>
        <Section
          fill
          title={`Battery charge: ${data.charge}%`}
          buttons={
            <Button onClick={() => setUseKelvin(!useKelvin)}>
              Switch Units
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Set Temperature">
              <NumberInput
                fluid
                minValue={
                  useKelvin
                    ? data.minTemperature
                    : kelvinToCelsius(data.minTemperature)
                }
                maxValue={
                  useKelvin
                    ? data.maxTemperature
                    : kelvinToCelsius(data.maxTemperature)
                }
                unit={useKelvin ? "kelvin" : "celsius"}
                value={
                  useKelvin
                    ? data.temperature
                    : kelvinToCelsius(data.temperature)
                }
                onChange={(_, value: number) => {
                  act("changeTemperature", {
                    newTemp: value,
                    useKelvin: useKelvin,
                  });
                }}
              ></NumberInput>
            </LabeledList.Item>
            <LabeledList.Item label="Cell">
              <Button textAlign="center" fluid onClick={() => act("cell")}>
                {data.cell ? "Remove" : "Install"}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
