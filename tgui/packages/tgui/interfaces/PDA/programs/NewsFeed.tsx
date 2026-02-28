import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';

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
        <div className="PDAProgram__buttonGrid">
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
          <div className="PDAProgram__sectionTitle">Channel Directory</div>
          {channels.length === 0 && <i>No active channels found...</i>}
          {channels.map((channel, idx) => (
            <div key={`${channel.name}-${idx}`} className={cx('PDAProgram__newsChannel', channel.censored && 'is-censored')}>
              <div className="PDAProgram__newsChannelInfo">
                <div className="PDAProgram__newsChannelTitle">{channel.name}</div>
                <div className="PDAProgram__newsChannelMeta">{channel.censored ? 'D-Notice applied' : 'Open station feed'}</div>
              </div>
              <Button
                icon="right-to-bracket"
                content="Open"
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

          <div className="PDAProgram__newsHeadCard">
            <div className="PDAProgram__newsHeadTitle">{feed.channel}</div>
            <div className="PDAProgram__newsHeadMeta">
              Created by: {feed.author} - Views: {feed.views}
            </div>
          </div>

          {feed.censored ? (
            <div className="pda-bad">
              This channel has been marked with a D-Notice.
            </div>
          ) : (
            <>
              {(feed.messages || []).length === 0 && <i>No feed messages found in channel...</i>}
              {(feed.messages || []).map((message, idx) => (
                <div key={idx} className="PDAProgram__newsMessage">
                  <div className="PDAProgram__newsMessageBody" dangerouslySetInnerHTML={{ __html: message.body }} />
                  <div className="PDAProgram__newsMessageMeta">
                    {message.message_type} by {message.author} - {message.time_stamp}
                  </div>
                  {message.has_image && (
                    <div className="PDAProgram__newsMessageImage">Image attached: {message.caption || 'Untitled image'}</div>
                  )}
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
