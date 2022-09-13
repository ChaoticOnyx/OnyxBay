import {
  Box,
  Button,
  Divider,
  Flex,
  Icon,
  Modal,
  Section,
  Stack,
} from "../components";
import { Window } from "../layouts";
import { useBackend } from "../backend";
import { round } from "common/math";

export type Option = {
  id: string;
  name: string;
  description: string;
  event_id?: string;
  weight: number;
};

export type Event = {
  id: string;
  name: string;
  description: string;
  mtth: number;
  chance: number;
  waiting_option: number;
  fire_conditions: boolean;
  options: Option[];
  conditions_description: string;
  disabled: boolean;
};

type InputData = {
  event: Event;
};

function OptionTooltip(props: { option: Option }, context: any) {
  const option = props.option;

  return (
    <>
      <b>Id:</b> {option.id}
      <br />
      <b>Event Id:</b> {option.event_id || "null"}
      <br />
      <b>Weight:</b> {round(option.weight, 0)}
      <Divider hidden />
      {option.description}
    </>
  );
}

export function EventWindow(props: any, context: any) {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const event = data.event;
  const prefered = [...event.options].sort((a, b) => b.weight - a.weight)[0];

  return (
    <Window width={500} height={300} title={event.name}>
      <Window.Content>
        <Flex height="100%" direction="column">
          <Flex.Item grow={true}>
            <Section height="100%">{event.description}</Section>
          </Flex.Item>
          <Flex.Item>
            <Divider />
          </Flex.Item>

          <Flex.Item shrink={true}>
            {event.options.map((o) => {
              return (
                <Button
                  onClick={() => {
                    act("choose", {
                      option_id: o.id,
                      event_id: event.id,
                    });
                  }}
                  tooltip={<OptionTooltip option={o} />}
                  textAlign="center"
                  color={o.id === prefered.id ? "pink" : ""}
                  fluid
                >
                  {o.name}{" "}
                  {o.id === prefered.id ? <em>(prefered by AI)</em> : ""}
                </Button>
              );
            })}

            <Button
              textAlign="center"
              tooltip="Ignore it"
              onClick={() => {
                act("close");
              }}
              fluid
            >
              Ok
            </Button>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
}
