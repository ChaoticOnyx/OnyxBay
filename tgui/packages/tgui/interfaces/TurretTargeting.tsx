import { useBackend } from "../backend";
import { Button, Section, Stack } from "../components";

export interface turretTargetProps {
  lethalMode: boolean;
  checkSynth: boolean;
  checkWeapon: boolean;
  checkRecords: boolean;
  checkArrests: boolean;
  checkAccess: boolean;
  checkAnomalies: boolean;
}

export const TurretTargeting = (props, context) => {
  const { children } = props;
  const { act, data } = useBackend<turretTargetProps>(context);
  const {
    lethalMode,
    checkSynth,
    checkWeapon,
    checkRecords,
    checkArrests,
    checkAccess,
    checkAnomalies,
  } = data;

  return (
    <Section>
      <Stack.Item>
        <Stack>
          <Stack.Item align="right">
            <Button
              fluid
              content={"Lethal Mode"}
              icon={lethalMode ? "circle-check" : "circle"}
              color={lethalMode ? "red" : "green"}
              onClick={() => act("lethal_mode", {})}
            />
            <Button
              fluid
              content={"Neutralize ALL Non-Synthetics"}
              icon={checkSynth ? "circle-check" : "circle"}
              color={checkSynth ? "red" : "green"}
              onClick={() => act("check_synth", {})}
            />
            <Button
              fluid
              content={"Check Weapon Authorization"}
              icon={checkWeapon ? "circle-check" : "circle"}
              color={checkWeapon ? "red" : "green"}
              onClick={() => act("check_weapon", {})}
            />
            <Button
              fluid
              content={"Check Security Records"}
              icon={checkRecords ? "circle-check" : "circle"}
              color={checkRecords ? "red" : "green"}
              onClick={() => act("check_records", {})}
            />
            <Button
              fluid
              content={"Check Arrest Status"}
              icon={checkArrests ? "circle-check" : "circle"}
              color={checkArrests ? "red" : "green"}
              onClick={() => act("check_arrest", {})}
            />
            <Button
              fluid
              content={"Check Access Authorization"}
              icon={checkAccess ? "circle-check" : "circle"}
              color={checkAccess ? "red" : "green"}
              onClick={() => act("check_access", {})}
            />
            <Button
              fluid
              content={"Check misc. Lifeforms"}
              icon={checkAnomalies ? "circle-check" : "circle"}
              color={checkAnomalies ? "red" : "green"}
              onClick={() => act("check_anomalies", {})}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Section>
  );
};
