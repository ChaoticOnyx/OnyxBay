import { Section, Tabs } from "../../../components";

export type Pane = "stats" | "control";

export const AirAlarmPaneSwitch = (props: {
  selected: Pane;
  onSelect: (p: Pane) => void;
  act: any;
}) => {
  const { selected, onSelect, act } = props;

  return (
    <Section className="AirAlarm__paneSwitch" fitted mt={1}>
      <Tabs fluid>
        <Tabs.Tab
          selected={selected === "stats"}
          onClick={() => {
            onSelect("stats");
            act("noop", {});
          }}
        >
          STATS
        </Tabs.Tab>
        <Tabs.Tab
          selected={selected === "control"}
          onClick={() => {
            onSelect("control");
            act("noop", {});
          }}
        >
          CONTROL
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};
