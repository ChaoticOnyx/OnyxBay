import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';

type FeedMessage = {
  index: number;
  body: string;
  author: string;
  time_stamp: string;
  message_type: 'Report' | 'Alert' | 'Notice';
  has_image?: boolean;
  caption?: string;
};

type FeedChannel = {
  id: string;
  name: string;
  censored?: boolean;
  author: string;
  views: number;
  messages: FeedMessage[];
};

const FEEDS: FeedChannel[] = [
  {
    id: 'station',
    name: 'NSS Exodus Bulletin',
    author: 'NT Automated',
    views: 1832,
    messages: [
      { index: 0, body: 'Shift start: maintain station integrity and follow SOP.', author: 'NT Automated', time_stamp: '00:03', message_type: 'Notice' },
      { index: 1, body: 'Reminder: report contraband to Security.', author: 'NT Automated', time_stamp: '00:11', message_type: 'Notice' },
    ],
  },
  {
    id: 'eng',
    name: 'Engineering Wire',
    author: 'CE Office',
    views: 742,
    messages: [
      { index: 0, body: 'Power fluctuations detected near Substation 2.', author: "M. O'Brien", time_stamp: '00:27', message_type: 'Alert' },
      { index: 1, body: 'APC audit scheduled. Do not hotwire.', author: "M. O'Brien", time_stamp: '00:41', message_type: 'Report' },
    ],
  },
  {
    id: 'dn',
    name: 'D-Notice Channel',
    censored: true,
    author: '—',
    views: 0,
    messages: [],
  },
];

class NewsFeedApp extends Component<{ ctx: PdaProgramContext }> {
  private reception = true;

  private ringerOn = true;
  private tone = 'news_tone_1';

  private selectedId: string | null = null;

  private showTone = false;
  private toneDraft = '';

  private busy = false;
  private error: string | null = null;

  componentDidMount() {
    if (!this.selectedId) this.selectedId = FEEDS[0].id;
  }

  private toggleRinger = () => {
    this.ringerOn = !this.ringerOn;
    this.forceUpdate();
  };

  private openTone = () => {
    this.showTone = true;
    this.toneDraft = this.tone;
    this.forceUpdate();
  };

  private closeTone = () => {
    this.showTone = false;
    this.toneDraft = '';
    this.forceUpdate();
  };

  private applyTone = () => {
    const v = (this.toneDraft || '').trim();
    if (!v) return;
    this.tone = v;
    this.showTone = false;
    this.toneDraft = '';
    this.forceUpdate();
  };

  private selectFeed = (id: string) => {
    this.selectedId = id;
    this.forceUpdate();
  };

  private refresh = () => {
    if (this.busy) return;
    this.busy = true;
    this.error = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const noReception = Math.random() < 0.15;
      this.reception = !noReception;

      const fail = Math.random() < 0.08;
      this.error = fail ? 'Newscaster network error.' : null;

      this.busy = false;
      this.forceUpdate();
    }, 350);
  };

  render() {
    const current = this.selectedId ? FEEDS.find(f => f.id === this.selectedId) || null : null;

    return (
      <div className="PDAProgram PDAProgram--generic" style={{ height: '100%', minHeight: 0 }}>
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="radio" /> INSTANEWS ED 2.0.9
          </div>
          <div className="PDAProgram__sub">
            UI-only mock • {this.reception ? 'Reception OK' : 'No reception'}
          </div>
        </div>

        <div className="PDAProgram__panel">
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <Button
              icon={this.ringerOn ? 'volume-high' : 'volume-xmark'}
              content={this.ringerOn ? 'Ringer: On' : 'Ringer: Off'}
              onClick={this.toggleRinger}
            />
            <Button icon="music" content="Set news tone" onClick={this.openTone} />
            <Button icon="rotate" content={this.busy ? '…' : 'Refresh'} onClick={this.refresh} />
          </div>

          {!this.reception && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 8, color: '#f87171', opacity: 1 }}>
              No reception with newscaster network.
            </div>
          )}

          {this.error && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 6, color: '#f87171', opacity: 1 }}>
              {this.error}
            </div>
          )}
        </div>

        <div style={{ display: 'flex', gap: 10, minHeight: 0, height: '100%' }}>
          <div className="PDAProgram__panel" style={{ width: 240, flex: '0 0 auto', minHeight: 0, overflow: 'auto' }}>
            <div className="PDAProgram__row">
              <div className="PDAProgram__k">Channels</div>
              <div className="PDAProgram__v">{FEEDS.length}</div>
            </div>

            {FEEDS.map(ch => (
              <button
                key={ch.id}
                className={cx('PDAApp', this.selectedId === ch.id && 'is-active')}
                style={{ width: '100%', marginTop: 8, justifyContent: 'space-between' }}
                onClick={() => this.selectFeed(ch.id)}
                title={ch.name}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div className="PDAApp__icon">
                    <Icon name={ch.censored ? 'triangle-exclamation' : 'circle-arrow-right'} />
                  </div>
                  <div className="PDAApp__label" style={{ fontSize: 11 }}>
                    {ch.name}
                  </div>
                </div>

                {ch.censored && (
                  <span style={{ fontSize: 10, color: '#f87171', fontWeight: 900, letterSpacing: '0.10em' }}>
                    D-NOTICE
                  </span>
                )}
              </button>
            ))}
          </div>

          <div className="PDAProgram__panel" style={{ flex: '1 1 auto', minHeight: 0, overflow: 'auto' }}>
            {!current && (
              <div className="PDAProgram__footerHint">Select a channel.</div>
            )}

            {current && (
              <>
                <div style={{ display: 'flex', justifyContent: 'space-between', gap: 10 }}>
                  <div style={{ fontWeight: 900, color: '#aaffff', letterSpacing: '0.08em' }}>
                    {current.name}
                  </div>
                  <div style={{ fontSize: 10, opacity: 0.55, textTransform: 'uppercase', letterSpacing: '0.12em' }}>
                    Views: {current.views}
                  </div>
                </div>

                <div style={{ marginTop: 6, fontSize: 10, opacity: 0.55 }}>
                  Created by: <span style={{ color: '#aaffff', fontWeight: 800 }}>{current.author}</span>
                </div>

                <div style={{ marginTop: 10 }}>
                  {current.censored ? (
                    <div style={{ color: '#f87171' }}>
                      <div style={{ fontWeight: 900, letterSpacing: '0.12em' }}>ATTENTION</div>
                      <div style={{ marginTop: 6, fontSize: 12, opacity: 0.85 }}>
                        This channel has been marked with a D-Notice.
                        No further feed story additions are allowed while the D-Notice is in effect.
                      </div>
                    </div>
                  ) : (
                    <>
                      {current.messages.length === 0 ? (
                        <i style={{ opacity: 0.65 }}>No feed messages found in channel…</i>
                      ) : (
                        current.messages.map(m => (
                          <div key={m.index} style={{ marginBottom: 12 }}>
                            <div style={{ fontSize: 12, color: '#aaffff' }}>- {m.body}</div>

                            {m.has_image && (
                              <div style={{
                                marginTop: 6,
                                width: 180,
                                height: 100,
                                border: '1px solid rgba(79,255,153,0.18)',
                                background: 'rgba(0,0,0,0.25)',
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: 10,
                                opacity: 0.7,
                              }}>
                                [image mock]
                              </div>
                            )}

                            {m.caption && (
                              <div style={{ fontSize: 10, opacity: 0.65, marginTop: 4 }}>
                                {m.caption}
                              </div>
                            )}

                            <div style={{ fontSize: 10, opacity: 0.55, marginTop: 4 }}>
                              [{m.message_type} by <span style={{ color: '#aaffff', fontWeight: 800 }}>{m.author}</span> - {m.time_stamp}]
                            </div>
                          </div>
                        ))
                      )}
                    </>
                  )}
                </div>
              </>
            )}
          </div>
        </div>

        {this.showTone && (
          <div className="PdaMessengerModal" onClick={this.closeTone}>
            <div className="PdaMessengerModal__card" onClick={(e) => e.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="music" /> Set News Tone
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Tone id</div>
                  <Input
                    value={this.toneDraft}
                    placeholder="e.g. news_tone_1"
                    onInput={(_, v) => { this.toneDraft = String(v); this.forceUpdate(); }}
                    onKeyDown={(e: KeyboardEvent) => {
                      // @ts-ignore
                      if (e.key === 'Enter') this.applyTone();
                    }}
                  />
                  <div className="PdaMessengerModal__hint">
                    UI-only. Later: wire to backend.
                  </div>
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeTone} />
                <Button content="Apply" icon="check" onClick={this.applyTone} />
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }
}

export const NewsFeedProgram: PdaProgram = {
  id: 'news_feed',
  title: 'News',
  icon: 'radio',
  View: (ctx) => <NewsFeedApp ctx={ctx} />,
};
