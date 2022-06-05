import { useBackend } from "../backend";
import { Button, Stack, Section, NumberInput } from "../components";
import { Window } from "../layouts";

interface Flash {
  status: number;
}

interface InputData {
  timing: number;
  releasetime: number;
  timetoset: number;
  timeleft: number;
  flashes: Flash[];
}

export const BrigTimer = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const flashCharging: boolean =
    data.flashes.filter((flash, _) => !flash.status).length > 0;

  return (
    <Window width={300} height={140}>
      <Window.Content fitted>
        <Section
          title="Cell Timer"
          fill
          buttons={
            <>
              <Button
                icon="clock-o"
                content={data.timing ? "Stop" : "Start"}
                selected={data.timing}
                onClick={() => act(data.timing ? "stop" : "start")}
              />
              <Button
                icon="lightbulb-o"
                content={flashCharging ? "Recharging" : "Flash"}
                disabled={flashCharging}
                onClick={() => act("flash")}
              />
            </>
          }
        >
          <Stack vertical align={"center"}>
            <Stack.Item>
              <Button
                icon="fast-backward"
                onClick={() => act("time", { adjust: -(600 * 5) })}
              />
              <Button
                icon="backward"
                onClick={() => act("time", { adjust: -600 })}
              />{" "}
              <NumberInput
                minValue={0}
                maxValue={60}
                unit="Minutes"
                value={data.timetoset / 600}
                onChange={(e: any, value: number) =>
                  act("time", { adjust: -data.timetoset + value * 600 })
                }
              />{" "}
              <Button
                icon="forward"
                onClick={() => act("time", { adjust: 600 })}
              />
              <Button
                icon="fast-forward"
                onClick={() => act("time", { adjust: 600 * 5 })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="hourglass-start"
                content="Short"
                onClick={() => act("time", { preset: "short" })}
              />
              <Button
                icon="hourglass-start"
                content="Medium"
                onClick={() => act("time", { preset: "medium" })}
              />
              <Button
                icon="hourglass-start"
                content="Long"
                onClick={() => act("time", { preset: "long" })}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
