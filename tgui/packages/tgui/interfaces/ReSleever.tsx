import { useBackend } from "../backend";
import { Window } from "../layouts";
import { Button, LabeledList, Section, ProgressBar } from "../components";

interface InputData {
  name: string;
  lace?: string;
  isOccupiedEjectable: number;
  isLaceEjectable: number;
  active: number;
  remaining: number;
  timetosleeve: number;
  ready: number;
}

export const ReSleever = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const progress = data.remaining / data.timetosleeve;

  return (
    <Window width={400} height={300}>
      <Window.Content fitted>
        <Section
          title="Content"
          buttons={
            <>
              <Button
                icon="eject"
                content="Eject Occupant"
                disabled={data.isOccupiedEjectable ? null : "1"}
                onClick={() => act("eject")}
              />{" "}
              <Button
                icon="eject"
                content="Eject Lace"
                disabled={data.isLaceEjectable ? null : "1"}
                onClick={() => act("ejectlace")}
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Occupant">
              {data.name ? data.name : "Empty"}
            </LabeledList.Item>
            <LabeledList.Item label="Backup">
              {data.lace ? data.lace : "Empty"}
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section
          title="Procedure"
          buttons={
            <Button
              icon="play"
              content="Start Procedure"
              disabled={data.ready ? null : "0"}
              onClick={() => act("begin")}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              {(progress > 0 && "In Progress") ||
                (data.ready ? "Ready" : "Not Ready")}
            </LabeledList.Item>
            <LabeledList.Item label="Progress">
              <ProgressBar value={progress} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
