import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section, ProgressBar } from '../components';

export const Jukebox = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  const songs = data.tracks || [];

  return (
    <Fragment>
      <Section title="Control" buttons={(
        <Fragment>
          <Button
            icon="minus"
            onClick={() => act(ref, 'volume', { level: data.volume - 10 })} />
          <Button
            icon="plus"
            onClick={() => act(ref, 'volume', { level: data.volume + 10 })} />
        </Fragment>
      )}>
        <ProgressBar value={String(data.volume / 50)} content={'Volume: ' + data.volume} />
      </Section>
      <Section title="Tracks List" buttons={(
        <Fragment>
          <Button content="Play" icon="forward" onClick={() => act(ref, 'play', null)} />
          <Button content="Stop" icon="stop" onClick={() => act(ref, 'stop', null)} />
        </Fragment>
      )}>
        {songs.map(song => {
          return (
            <Fragment key={song}>
              <Button content={song} onClick={() => act(ref, 'change_track', {
                title: song,
              })} />
              <br />
            </Fragment>
          );
        })}
      </Section>
    </Fragment>
  );

};
