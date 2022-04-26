/* eslint-disable camelcase */

import { useBackend } from "../backend";
import { Divider } from "../components/Divider";
import { NoticeBox } from "../components/NoticeBox";
import { Section } from "../components/Section";
import { Table } from "../components/Table";
import { Window } from "../layouts/Window";
import { Flex } from "../components/Flex";
import { LabeledList } from "../components/LabeledList";
import { ProgressBar } from "../components/ProgressBar";
import { Button } from "../components/Button";

type Organ = {
  name: string;
  status: string[];
  damage: string[];
};

type MedicalData = {
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
  body_temperature_c: number;
  body_temperature_f: number;
  brute_severity: string;
  burn_severity: string;
  tox_severity: string;
  oxy_severity: string;
  rad_severity: string;
  clone_severity: string;
  external_organs: Organ[];
  internal_organs: Organ[];
};

type InputData = {
  medical_data: MedicalData;
};

function Scan(props: MedicalData, context: any) {
  const { act } = useBackend<InputData>(context);

  return (
    <Flex direction="row">
      <Flex.Item shrink={1} basis={"40%"}>
        <Section title={"Scan Results"}>
          <LabeledList>
            <LabeledList.Item label="Name">{props.object}</LabeledList.Item>

            <LabeledList.Item label="Date">{props.scan_date}</LabeledList.Item>

            <LabeledList.Item label="Actions">
              <Button
                icon="tshirt"
                onClick={() => act("remove_clothes")}
                content="Remove Clothes"
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Common">
          <LabeledList>
            <LabeledList.Item label="Pulse">
              {`${props.pulse} BPM`}
            </LabeledList.Item>

            <LabeledList.Item label="Body Temperature">
              {props.body_temperature_c} °C ({props.body_temperature_f} °F)
            </LabeledList.Item>

            <LabeledList.Item label="Brain Activity">
              {props.brain_activity >= 0 ? (
                <ProgressBar
                  value={props.brain_activity}
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
          </LabeledList>
        </Section>

        <Section title="Blood">
          <LabeledList>
            <LabeledList.Item label="Blood Type">
              {props.blood_type ? props.blood_type : "Unknown"}
            </LabeledList.Item>

            <LabeledList.Item label="Blood Pressure">
              {props.blood_pressure}
            </LabeledList.Item>

            <LabeledList.Item label="Blood Volume">
              <ProgressBar
                value={props.blood_volume / 100}
                // eslint-disable-next-line max-len
                content={
                  props.blood_volume_abs +
                  "/" +
                  props.blood_volume_max +
                  "u (" +
                  props.blood_volume +
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
                value={props.blood_oxygenation / 100}
                ranges={{
                  good: [0.8, 1.0],
                  average: [0.5, 0.8],
                  bad: [0.0, 0.5],
                }}
              />
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

            {props.external_organs.map((organ, i) => {
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

            {props.internal_organs.map((organ, i) => {
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
}

export function OperatingTable(props: any, context: any) {
  const { data } = useBackend<InputData>(context);

  return (
    <Window theme="operating" width={800} height={710}>
      <Window.Content scrollable>
        {data.medical_data ? (
          Scan(data.medical_data, context)
        ) : (
          <NoticeBox>Operating Table is empty.</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
}
