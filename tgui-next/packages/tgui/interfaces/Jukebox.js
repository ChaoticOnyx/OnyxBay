import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, ProgressBar, LabeledList } from '../components';

export const Jukebox = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const songs = data.tracks || [];

  return (
    <Fragment>
      <Section title="Control">
        <LabeledList>
          <LabeledList.Item label="Current Track">
            {data.current_track}
          </LabeledList.Item>
          <LabeledList.Item label="Volume">
            <ProgressBar value={String(data.volume / 50)} />
          </LabeledList.Item>
          <LabeledList.Item label="Control">
            <Button
              icon="minus"
              onClick={() => act(ref, 'volume', { level: data.volume - 10 })}
              tooltip="Decrement volume by 10" />
            <Button
              icon="plus"
              onClick={() => act(ref, 'volume', { level: data.volume + 10 })}
              tooltip="Increment volume by 10" />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Tracks List" buttons={(
        <Fragment>
          <Button content="Eject" icon="eject" disabled={data.tape ? null : '1'} onClick={() => act(ref, 'eject', null)} />
          {data.playing
            ? <Button content="Stop" icon="stop" onClick={() => act(ref, 'stop', null)} />
            : <Button content="Play" icon="forward" onClick={() => act(ref, 'play', null)} />
          }
        </Fragment>
      )}>
        {songs.map(song => {
          return (
            <Fragment key={song}>
              <Button content={song} onClick={() => act(ref, 'change_track', {
                title: song,
              })}
              selected={data.current_track === song ? true : false} />
              <br />
            </Fragment>
          );
        })}
      </Section>
    </Fragment>
  );

};
