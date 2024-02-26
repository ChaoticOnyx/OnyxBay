import { useBackend } from "../backend";
import { LabeledList, ProgressBar, Stack, NumberInput } from "../components";

export interface turretSettingsProps {
  gun: string;
  status: boolean;
  integrity: number;
  maxIntegrity: number;
  gunAmmo: number;
  gunMaxAmmo: number;
  storedAmmo: number;
  currentBearing: number;
  defaultBearing: number;
}

export const TurretSettings = (props: any, context: any) => {
  const { children } = props;
  const { act, data } = useBackend<turretSettingsProps>(context);
  const {
    gun,
    status,
    integrity,
    maxIntegrity,
    gunAmmo,
    gunMaxAmmo,
    storedAmmo,
    currentBearing,
    defaultBearing,
  } = data;

  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Installed gun">{gun}</LabeledList.Item>
        <LabeledList.Item label="Integrity">
          <ProgressBar
            value={integrity}
            minValue={0}
            maxValue={maxIntegrity}
            ranges={{
              bad: [-Infinity, 0.7],
              average: [0.7, 0.9],
              good: [0.9, Infinity],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Ammo">
          <ProgressBar
            value={gunAmmo}
            minValue={0}
            maxValue={gunMaxAmmo}
            ranges={{
              bad: [-Infinity, 0.7],
              average: [0.7, 0.9],
              good: [0.9, Infinity],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Default bearing">
          <NumberInput
            inline
            size={1}
            step={1}
            stepPixelSize={2}
            value={defaultBearing}
            minValue={0}
            maxValue={360}
            bipolar={true}
            onChange={(e: any, value: number) =>
              act("adjust_default_bearing", { new_bearing: value })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Current bearing">
          {currentBearing}
        </LabeledList.Item>
      </LabeledList>
      <LabeledList.Divider size={1} />
    </Stack.Item>
  );
};
