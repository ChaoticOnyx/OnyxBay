import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';

type ChatType = 'dm' | 'group';

type Chat = {
  id: string;
  type: ChatType;
  title: string;
  peerCkey?: string;
  members?: string[];
  unread: number;
  lastTs: number;
};

type Message = {
  id: string;
  chatId: string;
  ts: number;
  from: string;
  text: string;
};

type EmojiDef = {
  name: string;   // token :name:
  file: string;   // filename in assets dir
};

const EMOJI_RENDER_H = 32;

// ============================================================================
// GIF SUPPORT NOTE:
//   JUST RENAME IT TO PNG
// ============================================================================
const emojiCtx = require.context(
  '../../../assets/pda/emoji',
  false,
  /\.(png)$/i,
);

function emojiUrl(file: string): string {
  try {
    return emojiCtx('./' + file);
  } catch (_) {
    return '';
  }
}

const EMOJI_ALL: EmojiDef[] = [
  { name: '1997', file: '1997.png' },
  { name: 'ai', file: 'ai.png' },
  { name: 'ambrosia', file: 'ambrosia.png' },
  { name: 'arrrman', file: 'arrrman.png' },
  { name: 'bball', file: 'bball.png' },
  { name: 'bear', file: 'bear.png' },
  { name: 'beer', file: 'beer.png' },
  { name: 'blob', file: 'blob.png' },
  { name: 'bluban', file: 'bluban.png' },
  { name: 'bluetank', file: 'bluetank.png' },
  { name: 'brain', file: 'brain.png' },
  { name: 'burger', file: 'burger.png' },
  { name: 'burn', file: 'burn.png' },
  { name: 'c4', file: 'c4.png' },
  { name: 'camera', file: 'camera.png' },
  { name: 'candycorn', file: 'candycorn.png' },
  { name: 'capgun', file: 'capgun.png' },
  { name: 'capid', file: 'capid.png' },
  { name: 'cardborg', file: 'cardborg.png' },
  { name: 'carp', file: 'carp.png' },
  { name: 'cat', file: 'cat.png' },
  { name: 'chick', file: 'chick.png' },
  { name: 'chrono', file: 'chrono.png' },
  { name: 'clean', file: 'clean.png' },
  { name: 'clocky', file: 'clocky.png' },
  { name: 'coffee', file: 'coffee.png' },
  { name: 'cow', file: 'cow.png' },
  { name: 'cult', file: 'cult.png' },
  { name: 'cyka', file: 'cyka.png' },
  { name: 'd20', file: 'd20.png' },
  { name: 'd6', file: 'd6.png' },
  { name: 'disarm', file: 'disarm.png' },
  { name: 'disk', file: 'disk.png' },
  { name: 'donut', file: 'donut.png' },
  { name: 'donut2', file: 'donut2.png' },
  { name: 'dosh', file: 'dosh.png' },
  { name: 'down', file: 'down.png' },
  { name: 'drone', file: 'drone.png' },
  { name: 'eggplant', file: 'eggplant.png' },
  { name: 'engban', file: 'engban.png' },
  { name: 'engie', file: 'engie.png' },
  { name: 'evilcrab', file: 'evilcrab.png' },
  { name: 'face', file: 'face.png' },
  { name: 'faggot', file: 'faggot.png' },
  { name: 'fedora', file: 'fedora.png' },
  { name: 'flash', file: 'flash.png' },
  { name: 'flashbang', file: 'flashbang.png' },
  { name: 'flushed', file: 'flushed.png' },
  { name: 'forcesword', file: 'forcesword.png' },
  { name: 'frog', file: 'frog.png' },
  { name: 'gear', file: 'gear.png' },
  { name: 'gift', file: 'gift.png' },
  { name: 'goliath', file: 'goliath.png' },
  { name: 'goliathold', file: 'goliathold.png' },
  { name: 'grab', file: 'grab.png' },
  { name: 'happy', file: 'happy.png' },
  { name: 'harm', file: 'harm.png' },
  { name: 'head', file: 'head.png' },
  { name: 'heart', file: 'heart.png' },
  { name: 'help', file: 'help.png' },
  { name: 'hip', file: 'hip.png' },
  { name: 'honk', file: 'honk.png' },
  { name: 'honkman', file: 'honkman.png' },
  { name: 'hug', file: 'hug.png' },
  { name: 'hugbox', file: 'hugbox.png' },
  { name: 'ian', file: 'ian.png' },
  { name: 'id', file: 'id.png' },
  { name: 'igloves', file: 'igloves.png' },
  { name: 'jack', file: 'jack.png' },
  { name: 'jerry', file: 'jerry.png' },
  { name: 'joy', file: 'joy.png' },
  { name: 'kudzu', file: 'kudzu.png' },
  { name: 'liz', file: 'liz.png' },
  { name: 'lsd', file: 'lsd.png' },
  { name: 'mad', file: 'mad.png' },
  { name: 'medal', file: 'medal.png' },
  { name: 'medban', file: 'medban.png' },
  { name: 'medbot', file: 'medbot.png' },
  { name: 'monkey', file: 'monkey.png' },
  { name: 'narplush', file: 'narplush.png' },
  { name: 'neigh', file: 'neigh.png' },
  { name: 'newcop', file: 'newcop.png' },
  { name: 'ninja', file: 'ninja.png' },
  { name: 'nya', file: 'nya.png' },
  { name: 'onisoma', file: 'onisoma.png' },
  { name: 'owlman', file: 'owlman.png' },
  { name: 'paper', file: 'paper.png' },
  { name: 'paperman', file: 'paperman.png' },
  { name: 'paperwrote', file: 'paperwrote.png' },
  { name: 'peel', file: 'peel.png' },
  { name: 'pen', file: 'pen.png' },
  { name: 'pepper', file: 'pepper.png' },
  { name: 'pete', file: 'pete.png' },
  { name: 'pigman', file: 'pigman.png' },
  { name: 'plague', file: 'plague.png' },
  { name: 'plushake', file: 'plushake.png' },
  { name: 'plushbles', file: 'plushbles.png' },
  { name: 'plushizzard', file: 'plushizzard.png' },
  { name: 'plushop', file: 'plushop.png' },
  { name: 'plushvar', file: 'plushvar.png' },
  { name: 'poly', file: 'poly.png' },
  { name: 'popcorn', file: 'popcorn.png' },
  { name: 'queen', file: 'queen.png' },
  { name: 'rainhonk', file: 'rainhonk.png' },
  { name: 'reallyhappy', file: 'reallyhappy.png' },
  { name: 'redban', file: 'redban.png' },
  { name: 'revolver', file: 'revolver.png' },
  { name: 'riot', file: 'riot.png' },
  { name: 'rollie', file: 'rollie.png' },
  { name: 'rune', file: 'rune.png' },
  { name: 'sad', file: 'sad.png' },
  { name: 'salt', file: 'salt.png' },
  { name: 'sciban', file: 'sciban.png' },
  { name: 'secban', file: 'secban.png' },
  { name: 'shades', file: 'shades.png' },
  { name: 'silentman', file: 'silentman.png' },
  { name: 'singulo', file: 'singulo.png' },
  { name: 'skull', file: 'skull.png' },
  { name: 'slime', file: 'slime.gif' },
  { name: 'snail', file: 'snail.png' },
  { name: 'snek', file: 'snek.png' },
  { name: 'snya', file: 'snya.png' },
  { name: 'supban', file: 'supban.png' },
  { name: 'superhappy', file: 'superhappy.png' },
  { name: 'supermatter', file: 'supermatter.png' },
  { name: 'surprised', file: 'surprised.png' },
  { name: 'swarmer', file: 'swarmer.png' },
  { name: 'syndie', file: 'syndie.png' },
  { name: 'tada', file: 'tada.png' },
  { name: 'tea', file: 'tea.png' },
  { name: 'thelaw', file: 'thelaw.png' },
  { name: 'thenews', file: 'thenews.png' },
  { name: 'thinking', file: 'thinking.png' },
  { name: 'tile', file: 'tile.png' },
  { name: 'toolbox', file: 'toolbox.png' },
  { name: 'tophat', file: 'tophat.png' },
  { name: 'toysword', file: 'toysword.png' },
  { name: 'trophy', file: 'trophy.png' },
  { name: 'unepipe', file: 'unepipe.png' },
  { name: 'unknownman', file: 'unknownman.png' },
  { name: 'up', file: 'up.png' },
  { name: 'viva', file: 'viva.png' },
  { name: 'wetfloorsign', file: 'wetfloorsign.png' },
  { name: 'whiskey', file: 'whiskey.png' },
  { name: 'xeno', file: 'xeno.png' },
];

const EMOJI_BY_NAME: Record<string, EmojiDef> = EMOJI_ALL.reduce((acc, e) => {
  acc[e.name] = e;
  return acc;
}, {} as Record<string, EmojiDef>);

const makeId = () => `${Date.now()}-${Math.random().toString(16).slice(2)}`;

function formatTime(ts: number) {
  const d = new Date(ts);
  const hh = String(d.getHours()).padStart(2, '0');
  const mm = String(d.getMinutes()).padStart(2, '0');
  return `${hh}:${mm}`;
}

type EmojiPart =
  | string
  | { emoji: EmojiDef; raw: string };

/**
 * Supported:
 *  - :name:  (by EMOJI_BY_NAME)
 *  - :eNN:   (by EMOJI_ALL index)
 */
function parseEmojiParts(text: string): EmojiPart[] {
  if (!text) return [''];

  const out: EmojiPart[] = [];
  let i = 0;

  while (i < text.length) {
    const start = text.indexOf(':', i);
    if (start === -1) {
      out.push(text.slice(i));
      break;
    }
    if (start > i) out.push(text.slice(i, start));

    const end = text.indexOf(':', start + 1);
    if (end === -1) {
      out.push(text.slice(start));
      break;
    }

    const token = text.slice(start + 1, end).trim();
    let emoji: EmojiDef | null = null;

    if (token) {
      const m = token.match(/^e(\d{1,4})$/i);
      if (m) {
        const n = Number(m[1]);
        if (Number.isFinite(n) && n >= 0 && n < EMOJI_ALL.length) {
          emoji = EMOJI_ALL[n];
        }
      } else {
        const byName = EMOJI_BY_NAME[token];
        if (byName) emoji = byName;
      }
    }

    if (!emoji) {
      out.push(text.slice(start, end + 1));
    } else {
      out.push({ emoji, raw: text.slice(start, end + 1) });
    }

    i = end + 1;
  }

  return out;
}

function renderEmojiParts(parts: EmojiPart[]) {
  return parts.map((p, k) => {
    if (typeof p === 'string') return <span key={k}>{p}</span>;

    const src = emojiUrl(p.emoji.file);
    if (!src) {
      // если не нашли файл — оставим raw как текст, чтобы не “пропадало”
      return <span key={k}>{p.raw}</span>;
    }

    return (
      <img
        key={k}
        className="PDAEmoji"
        src={src}
        alt={p.raw}
        title={p.raw}
        style={{ height: `${EMOJI_RENDER_H}px`, width: 'auto' }}
      />
    );
  });
}

class MessengerApp extends Component<{ ctx: PdaProgramContext }> {
  private selfCkey = 'Lovla';
  private peerCkey = 'Zert0X-Bot';

  private chats: Chat[] = [];
  private messages: Message[] = [];
  private activeChatId: string | null = null;

  private draft = '';
  private filter = '';

  private showCreateGroup = false;
  private newGroupName = '';

  private showEmojiPicker = false;

  // ringtone UI (wire act() later)
  private ringtone = 'pda_beep_1';
  private showRingtone = false;
  private ringtoneDraft = '';

  componentDidMount() {
    if (this.chats.length !== 0) return;

    const dmId = 'dm-peer';
    this.chats.push({
      id: dmId,
      type: 'dm',
      title: this.peerCkey,
      peerCkey: this.peerCkey,
      unread: 0,
      lastTs: Date.now(),
    });

    this.messages.push({
      id: makeId(),
      chatId: dmId,
      ts: Date.now() - 1000 * 60 * 5,
      from: this.peerCkey,
      text: `Welcome to PDA Messenger, ${this.selfCkey}. Try :happy: or :e10:`,
    });

    this.activeChatId = dmId;
  }

  private getActiveChat(): Chat | null {
    if (!this.activeChatId) return null;
    return this.chats.find(c => c.id === this.activeChatId) || null;
  }

  private getChatMessages(chatId: string): Message[] {
    return this.messages
      .filter(m => m.chatId === chatId)
      .sort((a, b) => a.ts - b.ts);
  }

  private openChat = (chatId: string) => {
    this.activeChatId = chatId;
    const c = this.chats.find(x => x.id === chatId);
    if (c) c.unread = 0;
    this.forceUpdate();
  };

  private setDraft = (v: string) => {
    this.draft = v;
    this.forceUpdate();
  };

  private send = () => {
    const chat = this.getActiveChat();
    const text = (this.draft || '').trim();
    if (!chat || !text) return;

    const ts = Date.now();

    // my message
    this.messages.push({
      id: makeId(),
      chatId: chat.id,
      ts,
      from: this.selfCkey,
      text,
    });
    chat.lastTs = ts;

    // reply from the other side
    const replyTs = ts + 450;
    const replyFrom = chat.type === 'dm'
      ? (chat.peerCkey || this.peerCkey)
      : this.peerCkey;

    this.messages.push({
      id: makeId(),
      chatId: chat.id,
      ts: replyTs,
      from: replyFrom,
      text: this.makeAutoReply(text),
    });
    chat.lastTs = replyTs;

    this.draft = '';
    this.forceUpdate();
  };

  private makeAutoReply(text: string) {
    if (/^hi\b|^hello\b|привет/i.test(text)) return `Hello, ${this.selfCkey}. :happy:`;
    if (/ringtone|рингтон/i.test(text)) return `Current ringtone: ${this.ringtone} :tada:`;
    if (/эмодзи|emoji/i.test(text)) return `Try :tada: :joy: or :e0:.`;
    return `Received. :ok_hand:`;
  }

  private toggleEmojiPicker = () => {
    this.showEmojiPicker = !this.showEmojiPicker;
    this.forceUpdate();
  };

  private insertEmojiToken = (token: string) => {
    if (!this.draft) this.draft = token;
    else this.draft = `${this.draft} ${token}`;
    this.showEmojiPicker = false;
    this.forceUpdate();
  };

  private openCreateGroup = () => {
    this.showCreateGroup = true;
    this.newGroupName = '';
    this.forceUpdate();
  };

  private closeCreateGroup = () => {
    this.showCreateGroup = false;
    this.newGroupName = '';
    this.forceUpdate();
  };

  private createGroup = () => {
    const name = (this.newGroupName || '').trim();
    if (!name) return;

    const id = `grp-${makeId()}`;
    const ts = Date.now();

    this.chats.unshift({
      id,
      type: 'group',
      title: name,
      members: [this.selfCkey, this.peerCkey],
      unread: 0,
      lastTs: ts,
    });

    this.messages.push({
      id: makeId(),
      chatId: id,
      ts,
      from: this.peerCkey,
      text: `Group "${name}" created. :tada:`,
    });

    this.activeChatId = id;
    this.showCreateGroup = false;
    this.newGroupName = '';
    this.forceUpdate();
  };

  private setFilter = (v: string) => {
    this.filter = v;
    this.forceUpdate();
  };

  private openRingtone = () => {
    this.showRingtone = true;
    this.ringtoneDraft = this.ringtone;
    this.forceUpdate();
  };

  private closeRingtone = () => {
    this.showRingtone = false;
    this.ringtoneDraft = '';
    this.forceUpdate();
  };

  private applyRingtone = () => {
    const v = (this.ringtoneDraft || '').trim();
    if (!v) return;
    this.ringtone = v;
    this.showRingtone = false;
    this.ringtoneDraft = '';
    this.forceUpdate();
    // later: act('set_ringtone', { ringtone: v })
  };

  render() {
    const chat = this.getActiveChat();
    const visibleChats = this.chats
      .slice()
      .sort((a, b) => b.lastTs - a.lastTs)
      .filter(c => !this.filter || c.title.toLowerCase().includes(this.filter.toLowerCase()));

    return (
      <div className="PdaMessenger">
        <div className="PdaMessenger__sidebar">
          <div className="PdaMessenger__sideTop">
            <div className="PdaMessenger__sideTitle">
              <Icon name="comment" /> MESSENGER
            </div>

            <div className="PdaMessenger__sideActions">
              <Button
                icon="users"
                content="New Group"
                onClick={this.openCreateGroup}
                className="PdaMessenger__actionBtn"
              />
            </div>

            <div className="PdaMessenger__search">
              <Input
                value={this.filter}
                placeholder="Search…"
                onInput={(_, v) => this.setFilter(String(v))}
              />
            </div>
          </div>

          <div className="PdaMessenger__chatList">
            {visibleChats.map(c => (
              <div
                key={c.id}
                className={cx('PdaMessenger__chatRow', this.activeChatId === c.id && 'is-active')}
                onClick={() => this.openChat(c.id)}
              >
                <div className="PdaMessenger__avatar">
                  <Icon name={c.type === 'group' ? 'users' : 'user'} />
                </div>

                <div className="PdaMessenger__chatMeta">
                  <div className="PdaMessenger__chatTitle">{c.title}</div>
                  <div className="PdaMessenger__chatSub">
                    {c.type === 'group' ? 'Group' : 'Direct'}
                  </div>
                </div>

                <div className="PdaMessenger__chatRight">
                  <div className="PdaMessenger__chatTime">{formatTime(c.lastTs)}</div>
                  {c.unread > 0 && <div className="PdaMessenger__unread">{c.unread}</div>}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="PdaMessenger__main">
          <div className="PdaMessenger__topbar">
            <div className="PdaMessenger__topTitle">
              {chat ? chat.title : 'No chat'}
            </div>

            <div className="PdaMessenger__topHint">
              {chat?.type === 'group' ? 'Group chat' : 'Direct chat'} • {this.selfCkey} • Ringtone: {this.ringtone}
              <Button
                icon="music"
                tooltip="Change ringtone"
                onClick={this.openRingtone}
                className="PdaMessenger__ringtoneBtn"
              />
            </div>
          </div>

          <div className="PdaMessenger__messages">
            {!chat && <div className="PdaMessenger__empty">Select a chat.</div>}
            {chat && this.getChatMessages(chat.id).map(m => {
              const isMe = m.from === this.selfCkey;
              return (
                <div key={m.id} className={cx('PdaMessenger__msg', isMe && 'is-me')}>
                  <div className="PdaMessenger__bubble">
                    <div className="PdaMessenger__from">{m.from}</div>

                    <div className="PdaMessenger__text">
                      {renderEmojiParts(parseEmojiParts(m.text))}
                    </div>

                    <div className="PdaMessenger__meta">
                      <span className="PdaMessenger__time">{formatTime(m.ts)}</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="PdaMessenger__composer">
            <Button
              icon="face-smile"
              tooltip="Emoji"
              onClick={this.toggleEmojiPicker}
              className="PdaMessenger__emojiBtn"
            />

            <div className="PdaMessenger__inputWrap">
              <Input
                value={this.draft}
                placeholder="Message… (use :happy: or :e42:)"
                onInput={(_, v) => this.setDraft(String(v))}
                onKeyDown={(e: KeyboardEvent) => {
                  // @ts-ignore
                  if (e.key === 'Enter') this.send();
                }}
              />
            </div>

            <Button
              icon="paper-plane"
              content="Send"
              onClick={this.send}
              className="PdaMessenger__sendBtn"
            />

            {this.showEmojiPicker && (
              <EmojiPicker onPick={this.insertEmojiToken} />
            )}
          </div>
        </div>

        {this.showCreateGroup && (
          <div className="PdaMessengerModal" onClick={this.closeCreateGroup}>
            <div className="PdaMessengerModal__card" onClick={(e) => e.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="users" /> Create Group
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Group name</div>
                  <Input
                    value={this.newGroupName}
                    placeholder="e.g. Engineering"
                    onInput={(_, v) => { this.newGroupName = String(v); this.forceUpdate(); }}
                    onKeyDown={(e: KeyboardEvent) => {
                      // @ts-ignore
                      if (e.key === 'Enter') this.createGroup();
                    }}
                  />
                </div>

                <div className="PdaMessengerModal__hint">
                  Members UI will be wired later (backend). For now it’s {this.selfCkey} + {this.peerCkey}.
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeCreateGroup} />
                <Button content="Create" icon="check" onClick={this.createGroup} />
              </div>
            </div>
          </div>
        )}

        {this.showRingtone && (
          <div className="PdaMessengerModal" onClick={this.closeRingtone}>
            <div className="PdaMessengerModal__card" onClick={(e) => e.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="music" /> Change Ringtone
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Ringtone id</div>
                  <Input
                    value={this.ringtoneDraft}
                    placeholder="e.g. pda_beep_1"
                    onInput={(_, v) => { this.ringtoneDraft = String(v); this.forceUpdate(); }}
                    onKeyDown={(e: KeyboardEvent) => {
                      // @ts-ignore
                      if (e.key === 'Enter') this.applyRingtone();
                    }}
                  />
                  <div className="PdaMessengerModal__hint">
                    Later: wire to backend via act(). Сейчас — только UI.
                  </div>
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeRingtone} />
                <Button content="Apply" icon="check" onClick={this.applyRingtone} />
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }
}

class EmojiPicker extends Component<{ onPick: (token: string) => void }> {
  private mode: 'named' | 'all' = 'named';
  private filter = '';

  private setMode = (m: 'named' | 'all') => {
    this.mode = m;
    this.forceUpdate();
  };

  private setFilter = (v: string) => {
    this.filter = v;
    this.forceUpdate();
  };

  render() {
    const { onPick } = this.props;

    const list = EMOJI_ALL.filter(e =>
      !this.filter || e.name.toLowerCase().includes(this.filter.toLowerCase())
    );

    return (
      <div className="PdaEmojiPicker">
        <div className="PdaEmojiPicker__top">
          <div
            className={cx('PdaEmojiPicker__tab', this.mode === 'named' && 'is-active')}
            onClick={() => this.setMode('named')}
          >
            Named
          </div>
          <div
            className={cx('PdaEmojiPicker__tab', this.mode === 'all' && 'is-active')}
            onClick={() => this.setMode('all')}
          >
            All (:eNN:)
          </div>
        </div>

        <div className="PdaEmojiPicker__named">
          <Input
            value={this.filter}
            placeholder="Filter…"
            onInput={(_, v) => this.setFilter(String(v))}
          />
        </div>

        {this.mode === 'named' ? (
          <div className="PdaEmojiPicker__named">
            {list.map(e => (
              <button
                key={e.name}
                className="PdaEmojiPicker__namedItem"
                onClick={() => onPick(`:${e.name}:`)}
                title={`:${e.name}:`}
              >
                {emojiUrl(e.file)
                  ? (
                    <img
                      className="PDAEmoji"
                      src={emojiUrl(e.file)}
                      alt={e.name}
                      style={{ height: `${EMOJI_RENDER_H}px`, width: 'auto' }}
                    />
                  )
                  : (
                    <span className="PDAEmoji">{/* fallback */}</span>
                  )}
                <span className="PdaEmojiPicker__namedLabel">:{e.name}:</span>
              </button>
            ))}
          </div>
        ) : (
          <div className="PdaEmojiPicker__grid">
            {EMOJI_ALL.map((e, idx) => (
              <button
                key={idx}
                className="PdaEmojiPicker__cell"
                onClick={() => onPick(`:e${idx}:`)}
                title={`:e${idx}: (:${e.name}:)`}
              >
                {emojiUrl(e.file)
                  ? (
                    <img
                      className="PDAEmoji"
                      src={emojiUrl(e.file)}
                      alt={e.name}
                      style={{ height: `${EMOJI_RENDER_H}px`, width: 'auto' }}
                    />
                  )
                  : (
                    <span className="PDAEmoji">{/* fallback */}</span>
                  )}
              </button>
            ))}
          </div>
        )}
      </div>
    );
  }
}

export const MessengerProgram: PdaProgram = {
  id: 'messenger',
  title: 'Messenger',
  icon: 'comment',
  View: (ctx) => <MessengerApp ctx={ctx} />,
};
