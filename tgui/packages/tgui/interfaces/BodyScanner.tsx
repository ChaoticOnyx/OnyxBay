/* eslint-disable camelcase */
import { useBackend } from "../backend";
import {
  NoticeBox,
  Section,
  ProgressBar,
  Button,
  Table,
  Flex,
  LabeledList,
  Divider,
} from "../components";
import { Window } from "../layouts";

interface Organ {
  name: string;
  status: string[];
  damage: string[];
}

interface MedicalData {
  object: string;
  scan_date: string;
  brain_activity: number;
  pulse: string;
  blood_volume: number;
  blood_volume_abs: number;
  blood_volume_max: number;
  blood_type: string;
  blood_pressure: string;
  blood_oxygenation: number;
  warnings: string[];
  body_temperature_c: number;
  body_temperature_f: number;
  brute_severity: string;
  burn_severity: string;
  tox_severity: string;
  oxy_severity: string;
  rad_severity: string;
  clone_severity: string;
  immunity: number;
  external_organs: Organ[];
  internal_organs: Organ[];
}

interface InputData {
  connected: string;
  medical_data: MedicalData;
}

export const BodyScanner = (props: any, context: any) => {
  return (
    <Window width={800} height={800}>
      <Window.Content scrollable>
        <ScanData />
      </Window.Content>
    </Window>
  );
};

const ScanData = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  if (!data.medical_data) {
    return <NoticeBox>Body Scanner is empty.</NoticeBox>;
  }

  if (!data.connected) {
    return <NoticeBox>Error: No Body Scanner connected.</NoticeBox>;
  }

  return (
    <Flex direction="row">
      <Flex.Item shrink={1} basis={"40%"}>
        <Section title={"Scan Results"}>
          <LabeledList>
            <LabeledList.Item label="Name">
              {data.medical_data.object}
            </LabeledList.Item>

            <LabeledList.Item label="Date">
              {data.medical_data.scan_date}
            </LabeledList.Item>

            <LabeledList.Item label="Actions">
              <Button
                icon="print"
                onClick={() => act("print")}
                content="Print Scan"
              />
              <Button
                icon="eject"
                onClick={() => act("eject")}
                content="Eject"
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Warnings">
          {data.medical_data.warnings.length
            ? data.medical_data.warnings.map((warning, i) => {
                return <NoticeBox key={i}>{warning}</NoticeBox>;
              })
            : "Nothing"}
        </Section>

        <Section title="Common">
          <LabeledList>
            <LabeledList.Item label="Pulse">
              {`${data.medical_data.pulse} BPM`}
            </LabeledList.Item>

            <LabeledList.Item label="Body Temperature">
              {data.medical_data.body_temperature_c} °C (
              {data.medical_data.body_temperature_f} °F)
            </LabeledList.Item>

            <LabeledList.Item label="Brain Activity">
              {data.medical_data.brain_activity >= 0 ? (
                <ProgressBar
                  value={data.medical_data.brain_activity}
                  ranges={{
                    good: [0.8, 1.0],
                    average: [0.5, 0.8],
                    bad: [0.0, 0.5],
                  }}
                />
              ) : (
                "Nonstandard biology"
              )}
            </LabeledList.Item>

            <LabeledList.Item label="Immunity">
              <ProgressBar
                value={data.medical_data.immunity}
                ranges={{
                  good: [0.8, 2.0],
                  average: [0.5, 0.8],
                  bad: [0.0, 0.5],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Blood">
          <LabeledList>
            <LabeledList.Item label="Blood Type">
              {data.medical_data.blood_type
                ? data.medical_data.blood_type
                : "Unknown"}
            </LabeledList.Item>

            <LabeledList.Item label="Blood Pressure">
              {data.medical_data.blood_pressure}
            </LabeledList.Item>

            <LabeledList.Item label="Blood Volume">
              <ProgressBar
                value={data.medical_data.blood_volume / 100}
                // eslint-disable-next-line max-len
                content={
                  data.medical_data.blood_volume_abs +
                  "/" +
                  data.medical_data.blood_volume_max +
                  "u (" +
                  data.medical_data.blood_volume +
                  "%)"
                }
                ranges={{
                  good: [0.8, 1.0],
                  average: [0.5, 0.8],
                  bad: [0.0, 0.5],
                }}
              />
            </LabeledList.Item>

            <LabeledList.Item label="Blood Oxygenation">
              <ProgressBar
                value={data.medical_data.blood_oxygenation / 100}
                ranges={{
                  good: [0.8, 1.0],
                  average: [0.5, 0.8],
                  bad: [0.0, 0.5],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Defects">
          <LabeledList>
            <LabeledList.Item
              label="Physical Trauma"
              color={
                data.medical_data.brute_severity === "None"
                  ? "good"
                  : data.medical_data.brute_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.brute_severity}
            </LabeledList.Item>

            <LabeledList.Item
              label="Burn Severity"
              color={
                data.medical_data.burn_severity === "None"
                  ? "good"
                  : data.medical_data.burn_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.burn_severity}
            </LabeledList.Item>

            <LabeledList.Item
              label="Systematic Organ Failure"
              color={
                data.medical_data.tox_severity === "None"
                  ? "good"
                  : data.medical_data.tox_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.tox_severity}
            </LabeledList.Item>

            <LabeledList.Item
              label="Oxygen Deprivation"
              color={
                data.medical_data.oxy_severity === "None"
                  ? "good"
                  : data.medical_data.oxy_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.oxy_severity}
            </LabeledList.Item>

            <LabeledList.Item
              label="Radiation Level"
              color={
                data.medical_data.rad_severity === "None"
                  ? "good"
                  : data.medical_data.rad_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.rad_severity}
            </LabeledList.Item>

            <LabeledList.Item
              label="Genetic Tissue Damage"
              color={
                data.medical_data.clone_severity === "None"
                  ? "good"
                  : data.medical_data.clone_severity === "Severe"
                  ? "bad"
                  : "average"
              }
            >
              {data.medical_data.clone_severity}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Flex.Item>
      <Divider vertical />
      <Flex.Item grow={1} basis={"60%"}>
        <Section title="External">
          <Table>
            <Table.Row>
              <Table.Cell bold>
                Organ
                <Divider />
              </Table.Cell>
              <Table.Cell bold>
                Damage
                <Divider />
              </Table.Cell>
              <Table.Cell bold>
                Status
                <Divider />
              </Table.Cell>
            </Table.Row>

            {data.medical_data.external_organs.map((organ, i) => {
              return (
                <Table.Row key={i}>
                  <Table.Cell>
                    {organ.name}
                    <Divider />
                  </Table.Cell>
                  <Table.Cell
                    color={organ.damage[0] === "None" ? "good" : "bad"}
                  >
                    {organ.damage.map((organ_damage) => {
                      return (
                        <>
                          {organ_damage + "\n"}
                          <Divider />
                        </>
                      );
                    })}
                  </Table.Cell>
                  <Table.Cell color={organ.status[0] === "" ? "good" : "bad"}>
                    {organ.status.map((organ_status) => {
                      return (
                        <>
                          {organ_status === "" ? "Good" : organ_status}
                          <Divider />
                        </>
                      );
                    })}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>

        <Section title="Internal">
          <Table>
            <Table.Row>
              <Table.Cell bold>
                Organ
                <Divider />
              </Table.Cell>
              <Table.Cell bold>
                Damage
                <Divider />
              </Table.Cell>
              <Table.Cell bold>
                Status
                <Divider />
              </Table.Cell>
            </Table.Row>

            {data.medical_data.internal_organs.map((organ, i) => {
              return (
                <Table.Row key={i}>
                  <Table.Cell>
                    {organ.name}
                    <Divider />
                  </Table.Cell>
                  <Table.Cell
                    color={organ.damage[0] === "None" ? "good" : "bad"}
                  >
                    {organ.damage.map((organ_damage) => {
                      return (
                        <>
                          {organ_damage + "\n"}
                          <Divider />
                        </>
                      );
                    })}
                  </Table.Cell>
                  <Table.Cell color={organ.status[0] === "" ? "good" : "bad"}>
                    {organ.status.map((organ_status) => {
                      return (
                        <>
                          {organ_status === "" ? "Good" : organ_status}
                          <Divider />
                        </>
                      );
                    })}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};
