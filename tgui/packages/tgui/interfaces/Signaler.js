import { clamp, toFixed } from "../../common/math";
import { useBackend } from "../backend";
import { Button, Section, NumberInput, Flex } from "../components";
import { Window } from "../layouts";

export const Signaler = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Window width={340} height={142}>
      <Window.Content>
        <SignalerContent>
          <Flex.Item>
            <Button
              fluid
              icon="arrow-up"
              content="Send Signal"
              textAlign="center"
              onClick={() => act("signal")}
            />
          </Flex.Item>
        </SignalerContent>
      </Window.Content>
    </Window>
  );
};

export const SignalerContent = (props, context) => {
  const { children } = props;
  const { act, data } = useBackend(context);
  const { code, frequency, maxFrequency, minFrequency } = data;

  return (
    <Section fill>
      <Flex height="100%" direction="column" justify="space-around">
        <Flex.Item>
          <Flex direction="row" justify="space-between">
            <Flex.Item color="label" width="19%" align="left">
              Frequency:
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="fast-backward"
                onClick={() =>
                  act("adjust", {
                    freq: clamp(frequency - 10, minFrequency, maxFrequency),
                  })
                }
              />
              <Button
                icon="backward"
                onClick={() =>
                  act("adjust", {
                    freq: clamp(frequency - 2, minFrequency, maxFrequency),
                  })
                }
              />
              <NumberInput
                animate
                width="80px"
                unit="kHz"
                step={3}
                stepPixelSize={6}
                minValue={minFrequency}
                maxValue={maxFrequency}
                value={frequency}
                format={(value) => toFixed(value / 10, 1)}
                onChange={(e, value) => act("adjust", { freq: value })}
              />
              <Button
                icon="forward"
                onClick={() =>
                  act("adjust", {
                    freq: clamp(frequency + 2, minFrequency, maxFrequency),
                  })
                }
              />
              <Button
                icon="fast-forward"
                onClick={() =>
                  act("adjust", {
                    freq: clamp(frequency + 10, minFrequency, maxFrequency),
                  })
                }
              />
            </Flex.Item>
            <Flex.Item align="rigth">
              <Button
                icon="sync"
                content="Reset"
                onClick={() => act("reset", { reset: "freq" })}
              />
            </Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item>
          <Flex direction="row" justify="space-between">
            <Flex.Item color="label" width="19%" align="left">
              Code:
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="fast-backward"
                onClick={() =>
                  act("adjust", { code: clamp(code - 10, 1, 100) })
                }
              />
              <Button
                icon="backward"
                onClick={() => act("adjust", { code: clamp(code - 1, 1, 100) })}
              />
              <NumberInput
                animate
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onDrag={(e, value) => act("adjust", { code: value })}
              />
              <Button
                icon="forward"
                onClick={() => act("adjust", { code: clamp(code + 1, 1, 100) })}
              />
              <Button
                icon="fast-forward"
                onClick={() =>
                  act("adjust", { code: clamp(code + 10, 1, 100) })
                }
              />
            </Flex.Item>
            <Flex.Item align="right">
              <Button
                icon="sync"
                content="Reset"
                onClick={() => act("reset", { reset: "code" })}
              />
            </Flex.Item>
          </Flex>
        </Flex.Item>
        {children}
      </Flex>
    </Section>
  );
};
