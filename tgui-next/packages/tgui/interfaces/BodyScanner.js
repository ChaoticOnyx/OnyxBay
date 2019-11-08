import { Fragment } from "inferno";
import { NoticeBox, Section, Tabs, ProgressBar, Button, Table } from '../components';
import { LabeledList } from "../components/LabeledList";
import { act } from "../byond";
import { createLogger } from "../logging";

const logger = createLogger('BodyScanner');

export const BodyScanner = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      {data.connected
        ? <Section title={'Scan Results'}>
          <LabeledList>

            <LabeledList.Item label="Name">
              {data.medical_data.object}
            </LabeledList.Item>

            <LabeledList.Item label="Date">
              {data.medical_data.scan_date}
            </LabeledList.Item>

            <LabeledList.Item label="Actions">
              <Button onClick={() => act(ref, 'print', null)} content="Print Scan" />
            </LabeledList.Item>

          </LabeledList>

          <Section title="Warnings" level={2}>
            {data.medical_data.warnings.length
              ? data.medical_data.warnings.map(warning => {
                return (
                  <Fragment>
                    <NoticeBox>
                      {warning}
                    </NoticeBox>
                  </Fragment>
                ); })
              : "Nothing"
            }
          </Section>

          <Tabs>

            <Tabs.Tab icon="notes-medical" label="Medical Status">
              <Section title="Common" level={2}>
                <LabeledList>

                  <LabeledList.Item label="Pulse">
                    {data.medical_data.pulse >= 0
                      ? data.medical_data.pulse + " BPM"
                      : "Nonstandard biology"
                    }
                  </LabeledList.Item>

                  <LabeledList.Item label="Body Temperature">
                    {data.medical_data.body_temperature_c} ℃ ({data.medical_data.body_temperature_f} ℉)
                  </LabeledList.Item>

                  <LabeledList.Item label="Brain Activity">
                    {data.medical_data.brain_activity >= 0
                      ? <ProgressBar value={data.medical_data.brain_activity}
                        ranges={{
                          good: [0.8, 1.0],
                          average: [0.5, 0.8],
                          bad: [0.0, 0.5],
                        }} />
                      : "Nonstandard biology"
                    }
                  </LabeledList.Item>

                  <LabeledList.Item label="Immunity">
                    <ProgressBar value={data.medical_data.immunity}
                      ranges={{
                        good: [0.8, 1.0],
                        average: [0.5, 0.8],
                        bad: [0.0, 0.5],
                      }} />
                  </LabeledList.Item>

                </LabeledList>
              </Section>

              <Section title="Blood" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Blood Type">
                    {data.medical_data.blood_type
                      ? data.medical_data.blood_type
                      : 'Unknown'
                    }
                  </LabeledList.Item>

                  <LabeledList.Item label="Blood Pressure">
                    {data.medical_data.blood_pressure}
                  </LabeledList.Item>

                  <LabeledList.Item label="Blood Volume">
                    <ProgressBar value={data.medical_data.blood_volume / 100}
                      ranges={{
                        good: [0.8, 1.0],
                        average: [0.5, 0.8],
                        bad: [0.0, 0.5],
                      }} />
                  </LabeledList.Item>

                  <LabeledList.Item label="Blood Oxygenation">
                    <ProgressBar value={data.medical_data.blood_oxygenation / 100}
                      ranges={{
                        good: [0.8, 1.0],
                        average: [0.5, 0.8],
                        bad: [0.0, 0.5],
                      }} />
                  </LabeledList.Item>

                </LabeledList>
              </Section>

              <Section title="Defects" level={2}>
                <LabeledList>
                  <LabeledList.Item label="Physical Trauma"
                    color={data.medical_data.brute_severity === 'None'
                      ? 'good'
                      : (data.medical_data.brute_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.brute_severity}
                  </LabeledList.Item>

                  <LabeledList.Item label="Burn Severity"
                    color={data.medical_data.burn_severity === 'None'
                      ? 'good'
                      : (data.medical_data.burn_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.burn_severity}
                  </LabeledList.Item>

                  <LabeledList.Item label="Systematic Organ Failure"
                    color={data.medical_data.tox_severity === 'None'
                      ? 'good'
                      : (data.medical_data.tox_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.tox_severity}
                  </LabeledList.Item>

                  <LabeledList.Item label="Oxygen Deprivation"
                    color={data.medical_data.oxy_severity === 'None'
                      ? 'good'
                      : (data.medical_data.oxy_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.oxy_severity}
                  </LabeledList.Item>

                  <LabeledList.Item label="Radiation Level"
                    color={data.medical_data.rad_severity === 'None'
                      ? 'good'
                      : (data.medical_data.rad_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.rad_severity}
                  </LabeledList.Item>

                  <LabeledList.Item label="Genetic Tissue Damage"
                    color={data.medical_data.clone_severity === 'None'
                      ? 'good'
                      : (data.medical_data.clone_severity === 'Severe' ? 'bad' : 'average')} >
                    {data.medical_data.clone_severity}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Tabs.Tab>

            <Tabs.Tab icon="columns" label="Organs Status">
              <Section title="External Organs" level={2}>
                <Table>
                  <Table.Row>
                    <Table.Cell bold>
                      Organ
                    </Table.Cell>
                    <Table.Cell bold>
                      Damage
                    </Table.Cell>
                    <Table.Cell bold>
                      Status
                    </Table.Cell>
                  </Table.Row>

                  {data.medical_data.external_organs.map(organ => {
                    return (
                      <Table.Row>
                        <Table.Cell>
                          {organ.name}
                        </Table.Cell>
                        <Table.Cell color={organ.damage[0] === 'None' ? 'good' : 'bad'}>
                          {organ.damage.map(organ_damage => {
                            return (
                              organ_damage + '\n'
                            );
                          })}
                        </Table.Cell>
                        <Table.Cell color={organ.status[0] === '' ? 'good' : 'bad'}>
                          {organ.status.map(organ_status => {
                            return (
                              organ_status === ''
                                ? 'Good'
                                : organ_status
                            );
                          })}
                        </Table.Cell>
                      </Table.Row>
                    );
                  })}
                </Table>
              </Section>
              <Section title="Internal Organs" level={2}>
                <Table>
                  <Table.Row>
                    <Table.Cell bold>
                      Organ
                    </Table.Cell>
                    <Table.Cell bold>
                      Damage
                    </Table.Cell>
                    <Table.Cell bold>
                      Status
                    </Table.Cell>
                  </Table.Row>

                  {data.medical_data.internal_organs.map(organ => {
                    return (
                      <Table.Row>
                        <Table.Cell>
                          {organ.name}
                        </Table.Cell>
                        <Table.Cell color={organ.damage[0] === 'None' ? 'good' : 'bad'}>
                          {organ.damage.map(organ_damage => {
                            return (
                              organ_damage + '\n'
                            );
                          })}
                        </Table.Cell>
                        <Table.Cell color={organ.status[0] === '' ? 'good' : 'bad'}>
                          {organ.status.map(organ_status => {
                            return (
                              organ_status === ''
                                ? 'Good'
                                : organ_status
                            );
                          })}
                        </Table.Cell>
                      </Table.Row>
                    );
                  })}
                </Table>
              </Section>
            </Tabs.Tab>

          </Tabs>
        </Section>

        : <NoticeBox>
        Error: No Body Scanner connected.
        </NoticeBox>
      }
    </Fragment>
  );
};
