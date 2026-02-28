import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const NewsFeedApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const mode = String(ctx.data?.mode || '');
  const channels = ctx.data?.feedChannels || [];
  const feed = ctx.data?.feed;
  const hasReception = !!ctx.data?.reception;

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="radio" /> INSTANEWS ED 2.0.9
        </div>
        <div className="PDAProgram__sub">Station feed network</div>
      </div>

      <div className="PDAProgram__panel">
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          <Button
            icon={ctx.data?.news_silent ? 'volume-xmark' : 'volume-high'}
            content={ctx.data?.news_silent ? 'Ringer: Off' : 'Ringer: On'}
            onClick={() => ctx.act('choice', { choice: 'Toggle News' })}
          />
          <Button icon="music" content="Set news tone" onClick={() => ctx.act('choice', { choice: 'Newstone' })} />
        </div>

        {!hasReception && (
          <div className="pda-bad" style={{ marginTop: 8 }}>
            No reception with newscaster network.
          </div>
        )}
      </div>

      {mode === PDA_MODE.NEWS_FEED && (
        <div className="PDAProgram__panel">
          {channels.length === 0 && <i>No active channels found...</i>}
          {channels.map((channel, idx) => (
            <div key={`${channel.name}-${idx}`} style={{ marginBottom: 6 }}>
              <Button
                icon="circle-arrow-right"
                content={channel.name}
                color={channel.censored ? 'bad' : undefined}
                onClick={() => ctx.act('choice', { choice: 'Select Feed', name: channel.name, feed: channel.feed })}
              />
            </div>
          ))}
        </div>
      )}

      {mode === PDA_MODE.NEWS_FEED_CHANNEL && feed && (
        <div className="PDAProgram__panel">
          <div style={{ marginBottom: 8 }}>
            <Button icon="arrow-left" content="Return to Channels" onClick={() => ctx.act('choice', { choice: 'Return' })} />
          </div>
          <div style={{ fontWeight: 900 }}>{feed.channel}</div>
          <div style={{ opacity: 0.7, marginBottom: 8 }}>
            Created by: {feed.author} • Views: {feed.views}
          </div>

          {feed.censored ? (
            <div className="pda-bad">
              This channel has been marked with a D-Notice.
            </div>
          ) : (
            <>
              {(feed.messages || []).length === 0 && <i>No feed messages found in channel...</i>}
              {(feed.messages || []).map((message, idx) => (
                <div key={idx} style={{ marginBottom: 10 }}>
                  <div>- {message.body}</div>
                  <div style={{ opacity: 0.65 }}>
                    [{message.message_type} by {message.author} - {message.time_stamp}]
                  </div>
                </div>
              ))}
            </>
          )}
        </div>
      )}
    </div>
  );
};

export const NewsFeedProgram: PdaProgram = {
  id: PDA_MODE.NEWS_FEED,
  title: 'News',
  icon: 'radio',
  View: (ctx) => <NewsFeedApp ctx={ctx} />,
};
