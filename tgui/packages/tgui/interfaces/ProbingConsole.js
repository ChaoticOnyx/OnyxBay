import { useBackend } from "../backend";
import { Button, LabeledList, NoticeBox, Section } from "../components";
import { Window } from "../layouts";

export const ProbingConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { open, feedback, occupant, OccupantName, OccupantStatus } = data;
  return (
    <Window width={330} height={207} theme="abductor">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Machine Report">
              {feedback}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Scanner"
          buttons={
            <Button
              icon={open ? "sign-out-alt" : "sign-in-alt"}
              content={open ? "Close" : "Open"}
              onClick={() => act("door")}
            />
          }
        >
          {(occupant && (
            <LabeledList>
              <LabeledList.Item label="Name">{OccupantName}</LabeledList.Item>
              <LabeledList.Item
                label="Status"
                color={
                  OccupantStatus === 3
                    ? "bad"
                    : OccupantStatus === 2
                    ? "average"
                    : "good"
                }
              >
                {OccupantStatus === 3
                  ? "Deceased"
                  : OccupantStatus === 2
                  ? "Unconscious"
                  : "Conscious"}
              </LabeledList.Item>
              <LabeledList.Item label="Experiments">
                <Button
                  icon="thermometer"
                  content="Probe"
                  onClick={() =>
                    act("experiment", {
                      experiment_type: 1,
                    })
                  }
                />
                <Button
                  icon="brain"
                  content="Dissect"
                  onClick={() =>
                    act("experiment", {
                      experiment_type: 2,
                    })
                  }
                />
                <Button
                  icon="search"
                  content="Analyze"
                  onClick={() =>
                    act("experiment", {
                      experiment_type: 3,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          )) || <NoticeBox>No Subject</NoticeBox>}
        </Section>
      </Window.Content>
    </Window>
  );
};
