import { round } from "common/math";
import { useBackend, useLocalState } from "../backend";
import { Button, Divider, Icon, Modal, Section, Stack } from "../components";
import { Window } from "../layouts";
import { Event } from "./EventWindow";

type InputData = {
  events: Event[];
};

function EventTooltip(props: { event: Event }, context: any) {
  const event = props.event;
  const rawHtml = {
    __html: event.conditions_description,
  };

  return (
    <>
      <b>Id:</b> {event.id}
      <br />
      <b>MTTH:</b> {event.mtth}
      <Divider hidden />
      {event.description}
      <Divider />
      <span
        class="ConditionsDescription"
        dangerouslySetInnerHTML={rawHtml}
      ></span>
    </>
  );
}

function EventButton(props: { event: Event }, context: any) {
  const { act } = useBackend<InputData>(context);
  const event = props.event;

  return (
    <Stack align="center" mt="5px">
      <Stack.Item width="100%">
        <Button
          tooltip={<EventTooltip event={event} />}
          disabled={!event.fire_conditions}
          color={event.waiting_option ? "violet" : ""}
          onClick={() => {
            if (event.waiting_option) {
              act("choose", { event_id: event.id });
            }
          }}
          fluid
        >
          <Stack align="center">
            <Stack.Item>{round(event.chance * 100, 0)}%</Stack.Item>
            <Stack.Item width="100%">
              <b>{event.name}</b>{" "}
              {event.waiting_option ? "- choose an option" : ""}
            </Stack.Item>
            <Stack.Item>
              {event.fire_conditions ? (
                <Icon color="good" name="check"></Icon>
              ) : (
                <Icon color="bad" name="times"></Icon>
              )}
            </Stack.Item>
          </Stack>
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={!event.fire_conditions || event.waiting_option}
          icon="fire"
          tooltip="Force"
          onClick={() => act("force", { event_id: event.id })}
        ></Button>
      </Stack.Item>
    </Stack>
  );
}

export function EventsPanel(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);

  data.events.sort((a, b) => b.chance - a.chance);
  const waitingEvents = [];
  const events = [];

  for (const event of data.events) {
    if (event.waiting_option > 0) {
      waitingEvents.push(event);
    } else {
      events.push(event);
    }
  }

  return (
    <Window width={400} height={600}>
      <Window.Content scrollable>
        <Section title="Waiting">
          {waitingEvents.map((e) => {
            return <EventButton event={e} />;
          })}
        </Section>
        <Section title="Possible">
          {events.map((e) => {
            return <EventButton event={e} />;
          })}
        </Section>
      </Window.Content>
    </Window>
  );
}
