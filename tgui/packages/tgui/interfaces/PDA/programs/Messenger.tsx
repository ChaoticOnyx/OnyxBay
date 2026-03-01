import { Component } from 'inferno';
import { Icon, Button, Input } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';
import { cx } from '../types';

type PdaEntry = {
  Name?: string;
  Reference?: string;
  Job?: string;
  Detonate?: string | number;
  inconvo?: string | number;
};

type BackendMessage = {
  sent?: number | string;
  owner?: string;
  message?: string;
  timestamp?: string;
  target?: string;
};

type GroupChannelEntry = {
  id?: number | string;
  title?: string;
  members?: number | string;
  pda_members?: number | string;
  client_members?: number | string;
  is_member?: number | string;
  locked?: number | string;
};

type GroupChannelMember = {
  ref?: string;
  name?: string;
  kind?: string;
  role?: string;
  job?: string;
  is_admin?: number | string;
  is_operator?: number | string;
  is_self?: number | string;
};

type GroupChannelMessage = {
  timestamp?: string;
  username?: string;
  message?: string;
  status?: number | string;
};

type EmojiDef = {
  name: string;
  file: string;
};

const EMOJI_RENDER_H = 32;

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

type EmojiPart = string | { emoji: EmojiDef; raw: string };

function parseEmojiParts(text: string): EmojiPart[] {
  if (!text) {
    return [''];
  }

  const out: EmojiPart[] = [];
  let i = 0;

  while (i < text.length) {
    const start = text.indexOf(':', i);
    if (start === -1) {
      out.push(text.slice(i));
      break;
    }
    if (start > i) {
      out.push(text.slice(i, start));
    }

    const end = text.indexOf(':', start + 1);
    if (end === -1) {
      out.push(text.slice(start));
      break;
    }

    const token = text.slice(start + 1, end).trim();
    let emoji: EmojiDef | null = null;

    if (token) {
      const nIndex = token.match(/^e(\d{1,4})$/i);
      if (nIndex) {
        const n = Number(nIndex[1]);
        if (Number.isFinite(n) && n >= 0 && n < EMOJI_ALL.length) {
          emoji = EMOJI_ALL[n];
        }
      } else {
        emoji = EMOJI_BY_NAME[token] || null;
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
  return parts.map((part, index) => {
    if (typeof part === 'string') {
      return <span key={index}>{part}</span>;
    }

    const src = emojiUrl(part.emoji.file);
    if (!src) {
      return <span key={index}>{part.raw}</span>;
    }

    return (
      <img
        key={index}
        className="PDAEmoji"
        src={src}
        alt={part.raw}
        title={part.raw}
        style={{ height: `${EMOJI_RENDER_H}px`, width: 'auto' }}
      />
    );
  });
}

const toBool = (value: any) => {
  if (typeof value === 'string') {
    return value !== '0' && value.toLowerCase() !== 'false' && value !== '';
  }
  return !!value;
};

const toText = (value: any) => {
  if (value === null || value === undefined) {
    return '';
  }
  return String(value);
};

class MessengerApp extends Component<{ ctx: PdaProgramContext }> {
  private draft = '';
  private filter = '';
  private listTab: 'groups' | 'pms' = 'groups';
  private showEmojiPicker = false;
  private showRingtone = false;
  private showGroupCreate = false;
  private showGroupJoin = false;
  private showGroupMembers = false;
  private showGroupInvite = false;
  private ringtoneDraft = '';
  private groupTitleDraft = '';
  private groupPasswordDraft = '';
  private groupJoinId = '';
  private groupJoinTitle = '';
  private groupJoinPasswordDraft = '';
  private inviteSearch = '';
  private selectedTargetRef: string | null = null;
  private messagesViewport: HTMLDivElement | null = null;
  private lastMessageViewKey = '';

  componentDidMount() {
    this.lastMessageViewKey = this.getMessageViewKey();
    this.scrollMessagesToBottom();
  }

  componentDidUpdate() {
    const refs = this.allEntries.map((entry) => String(entry.Reference || ''));
    const currentConversation = this.activeConversation;
    if (
      this.selectedTargetRef
      && this.selectedTargetRef !== currentConversation
      && !refs.includes(this.selectedTargetRef)
    ) {
      this.selectedTargetRef = null;
      this.forceUpdate();
    }

    const nextViewKey = this.getMessageViewKey();
    if (nextViewKey !== this.lastMessageViewKey) {
      this.lastMessageViewKey = nextViewKey;
      this.scrollMessagesToBottom();
    }
  }

  private get mode() {
    return String(this.props.ctx.data?.mode || PDA_MODE.MESSENGER);
  }

  private get isConversationMode() {
    return this.mode === PDA_MODE.MESSENGER_CONVERSATION;
  }

  private get activeConversation() {
    return String(this.props.ctx.data?.active_conversation || '');
  }

  private get conversations(): PdaEntry[] {
    return this.props.ctx.data?.convopdas || [];
  }

  private get availablePdas(): PdaEntry[] {
    return this.props.ctx.data?.pdas || [];
  }

  private get allEntries(): PdaEntry[] {
    return [...this.conversations, ...this.availablePdas];
  }

  private get messages(): BackendMessage[] {
    return this.props.ctx.data?.messages || [];
  }

  private get groupChannels(): GroupChannelEntry[] {
    return this.props.ctx.data?.group_channels || [];
  }

  private get groupMessages(): GroupChannelMessage[] {
    return this.props.ctx.data?.group_messages || [];
  }

  private get groupMembers(): GroupChannelMember[] {
    return this.props.ctx.data?.group_members || [];
  }

  private get groupCandidates(): GroupChannelMember[] {
    return this.props.ctx.data?.group_candidates || [];
  }

  private get activeGroupId() {
    return toText(this.props.ctx.data?.group_active_id);
  }

  private get hasActiveGroup() {
    return this.activeGroupId !== '';
  }

  private get activeGroupTitle() {
    return String(this.props.ctx.data?.group_title || '');
  }

  private get groupChatAvailable() {
    return toBool(this.props.ctx.data?.group_chat_available);
  }

  private get isGroupAdmin() {
    return toBool(this.props.ctx.data?.group_is_admin);
  }

  private get isGroupMember() {
    return toBool(this.props.ctx.data?.group_is_member);
  }

  private get groupLocked() {
    return toBool(this.props.ctx.data?.group_locked);
  }

  private get messengerOn() {
    return !toBool(this.props.ctx.data?.toff);
  }

  private get ringerOn() {
    return !toBool(this.props.ctx.data?.message_silent);
  }

  private get ringtone() {
    return String(this.props.ctx.data?.ttone || 'beep');
  }

  private get access() {
    return this.props.ctx.data?.cartridge?.access || {};
  }

  private get selectedTarget() {
    if (this.hasActiveGroup) {
      return null;
    }
    const activeRef = this.activeConversation || this.selectedTargetRef || '';
    if (!activeRef) {
      return null;
    }
    return this.allEntries.find((entry) => String(entry.Reference || '') === activeRef) || null;
  }

  private get selectedTitle() {
    if (this.hasActiveGroup) {
      return this.activeGroupTitle || 'Group Chat';
    }
    if (this.isConversationMode) {
      const convoName = String(this.props.ctx.data?.convo_name || '');
      if (convoName) {
        return convoName;
      }
    }
    return this.selectedTarget?.Name || 'No chat';
  }

  private get charges() {
    return Number(this.props.ctx.data?.cartridge?.charges || 0);
  }

  private setDraft = (value: string) => {
    this.draft = value;
    this.forceUpdate();
  };

  private setFilter = (value: string) => {
    this.filter = value;
    this.forceUpdate();
  };

  private setListTab = (tab: 'groups' | 'pms') => {
    this.listTab = tab;
    this.forceUpdate();
  };

  private selectConversation = (ref: string) => {
    this.listTab = 'pms';
    this.selectedTargetRef = null;
    if (this.hasActiveGroup) {
      this.props.ctx.act('group_close');
    }
    this.showGroupMembers = false;
    this.showGroupInvite = false;
    this.props.ctx.act('select_conversation', { convo: ref });
  };

  private selectPeer = (ref: string) => {
    this.listTab = 'pms';
    if (this.isConversationMode) {
      this.props.ctx.act('return');
    }
    if (this.hasActiveGroup) {
      this.props.ctx.act('group_close');
    }
    this.showGroupMembers = false;
    this.showGroupInvite = false;
    this.selectedTargetRef = ref;
    this.forceUpdate();
  };

  private selectGroupRow = (group: GroupChannelEntry) => {
    const id = toText(group.id);
    if (!id) {
      return;
    }
    this.listTab = 'groups';
    this.selectedTargetRef = null;
    this.showGroupMembers = false;
    this.showGroupInvite = false;
    const isMember = toBool(group.is_member);
    const locked = toBool(group.locked);
    if (isMember) {
      this.props.ctx.act('group_open', { id });
      return;
    }
    if (locked) {
      this.openGroupJoin(id, String(group.title || 'Group Channel'));
      return;
    }
    this.props.ctx.act('group_preview', { id });
  };

  private openGroupJoin = (id: string, title: string) => {
    if (!id) {
      return;
    }
    this.showGroupJoin = true;
    this.groupJoinId = id;
    this.groupJoinTitle = title;
    this.groupJoinPasswordDraft = '';
    this.forceUpdate();
  };

  private closeGroupJoin = () => {
    this.showGroupJoin = false;
    this.groupJoinId = '';
    this.groupJoinTitle = '';
    this.groupJoinPasswordDraft = '';
    this.forceUpdate();
  };

  private submitGroupJoin = () => {
    if (!this.groupJoinId) {
      return;
    }
    this.props.ctx.act('group_join', {
      id: this.groupJoinId,
      password: this.groupJoinPasswordDraft,
    });
    this.closeGroupJoin();
  };

  private joinActiveGroup = () => {
    if (!this.activeGroupId || this.isGroupMember) {
      return;
    }
    if (this.groupLocked) {
      this.openGroupJoin(this.activeGroupId, this.activeGroupTitle || 'Group Channel');
      return;
    }
    this.props.ctx.act('group_join', {
      id: this.activeGroupId,
      password: '',
    });
  };

  private closeGroup = () => {
    this.props.ctx.act('group_close');
    this.showGroupMembers = false;
    this.showGroupInvite = false;
  };

  private leaveGroup = () => {
    this.props.ctx.act('group_leave');
  };

  private renameGroup = () => {
    this.props.ctx.act('group_rename');
  };

  private setGroupPassword = () => {
    this.props.ctx.act('group_set_password');
  };

  private deleteGroup = () => {
    this.props.ctx.act('group_delete');
  };

  private addGroupMember = (target: string) => {
    this.props.ctx.act('group_add_member', { target });
  };

  private removeGroupMember = (target: string) => {
    this.props.ctx.act('group_remove_member', { target });
  };

  private setGroupAdmin = (target: string, admin: boolean) => {
    this.props.ctx.act('group_set_admin', { target, admin: admin ? 1 : 0 });
  };

  private openGroupCreate = () => {
    this.listTab = 'groups';
    this.showGroupCreate = true;
    this.groupTitleDraft = '';
    this.groupPasswordDraft = '';
    this.forceUpdate();
  };

  private closeGroupCreate = () => {
    this.showGroupCreate = false;
    this.groupTitleDraft = '';
    this.groupPasswordDraft = '';
    this.forceUpdate();
  };

  private openGroupMembers = () => {
    if (!this.hasActiveGroup || !this.isGroupMember) {
      return;
    }
    this.showGroupMembers = true;
    this.forceUpdate();
  };

  private closeGroupMembers = () => {
    this.showGroupMembers = false;
    this.forceUpdate();
  };

  private openGroupInvite = () => {
    if (!this.isGroupAdmin) {
      return;
    }
    this.showGroupInvite = true;
    this.inviteSearch = '';
    this.forceUpdate();
  };

  private closeGroupInvite = () => {
    this.showGroupInvite = false;
    this.inviteSearch = '';
    this.forceUpdate();
  };

  private setInviteSearch = (value: string) => {
    this.inviteSearch = value;
    this.forceUpdate();
  };

  private createGroup = () => {
    const title = (this.groupTitleDraft || '').trim();
    if (!title) {
      return;
    }
    this.props.ctx.act('group_create', {
      title,
      password: (this.groupPasswordDraft || '').trim(),
    });
    this.showGroupCreate = false;
    this.groupTitleDraft = '';
    this.groupPasswordDraft = '';
    this.forceUpdate();
  };

  private getActiveTargetRef() {
    if (this.hasActiveGroup) {
      return '';
    }
    if (this.isConversationMode && this.activeConversation) {
      return this.activeConversation;
    }
    if (this.selectedTargetRef) {
      return this.selectedTargetRef;
    }
    return '';
  }

  private getJobLabel(entry: PdaEntry | null) {
    if (!entry) {
      return 'Unknown role';
    }
    const job = String(entry.Job || '').trim();
    return job || 'Unknown role';
  }

  private send = () => {
    if (!this.messengerOn) {
      return;
    }

    const message = (this.draft || '').trim();
    if (!message) {
      return;
    }

    if (this.hasActiveGroup) {
      if (!this.isGroupMember) {
        return;
      }
      this.props.ctx.act('group_message', {
        message,
      });
    } else {
      const target = this.getActiveTargetRef();
      if (!target) {
        return;
      }
      this.props.ctx.act('message', {
        target,
        message,
      });
    }
    this.draft = '';
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
    const ringtone = (this.ringtoneDraft || '').trim();
    if (!ringtone) {
      return;
    }
    this.props.ctx.act('ringtone', { ringtone });
    this.showRingtone = false;
    this.ringtoneDraft = '';
    this.forceUpdate();
  };

  private toggleMessenger = () => {
    this.props.ctx.act('toggle_messenger');
  };

  private toggleRinger = () => {
    this.props.ctx.act('toggle_ringer');
  };

  private clearAllConversations = () => {
    this.props.ctx.act('clear', { option: 'PMs' });
    this.selectedTargetRef = null;
    this.draft = '';
    this.forceUpdate();
  };

  private leaveAllGroups = () => {
    this.props.ctx.act('clear', { option: 'Groups' });
    this.showGroupMembers = false;
    this.showGroupInvite = false;
    this.forceUpdate();
  };

  private clearAllByTab = () => {
    if (this.listTab === 'groups') {
      this.leaveAllGroups();
      return;
    }
    this.clearAllConversations();
  };

  private clearCurrentConversation = () => {
    if (!this.isConversationMode || !this.activeConversation) {
      return;
    }
    this.props.ctx.act('clear', { option: 'Convo' });
    this.draft = '';
    this.forceUpdate();
  };

  private runTargetAction = (choice: string) => {
    const target = this.getActiveTargetRef();
    if (!target) {
      return;
    }
    this.props.ctx.act(choice, { target });
  };

  private toggleEmojiPicker = () => {
    this.showEmojiPicker = !this.showEmojiPicker;
    this.forceUpdate();
  };

  private insertEmojiToken = (token: string) => {
    this.draft = this.draft ? `${this.draft} ${token}` : token;
    this.showEmojiPicker = false;
    this.forceUpdate();
  };

  private getVisiblePmMessages() {
    if (!this.activeConversation) {
      return [];
    }
    return this.messages.filter((message) =>
      String(message.target || '') === this.activeConversation
    );
  }

  private getMessageViewKey() {
    if (this.hasActiveGroup) {
      return `group:${this.activeGroupId}:${this.groupMessages.length}`;
    }
    if (this.isConversationMode && this.activeConversation) {
      return `pm:${this.activeConversation}:${this.getVisiblePmMessages().length}`;
    }
    return 'none';
  }

  private scrollMessagesToBottom() {
    if (!this.messagesViewport) {
      return;
    }
    this.messagesViewport.scrollTop = this.messagesViewport.scrollHeight;
  }

  private renderChargeHint() {
    if (this.charges <= 0) {
      return null;
    }

    const labels: string[] = [];
    if (toBool(this.access.access_detonate_pda)) {
      labels.push('detonation charges');
    }
    if (toBool(this.access.access_clown) || toBool(this.access.access_mime)) {
      labels.push('viral files');
    }

    const label = labels.length ? labels.join(' / ') : 'charges';
    return (
      <div className="PDAProgram__footerHint" style={{ marginBottom: 6 }}>
        {this.charges} {label} left.
      </div>
    );
  }

  render() {
    const filter = (this.filter || '').toLowerCase();
    const groupChannels = this.groupChannels
      .filter((group) =>
        !filter || String(group.title || '').toLowerCase().includes(filter)
      )
      .slice()
      .sort((left, right) => {
        const leftJoined = toBool(left.is_member);
        const rightJoined = toBool(right.is_member);
        if (leftJoined !== rightJoined) {
          return leftJoined ? -1 : 1;
        }

        const leftTitle = String(left.title || '');
        const rightTitle = String(right.title || '');
        const titleOrder = leftTitle.localeCompare(rightTitle, undefined, { sensitivity: 'base' });
        if (titleOrder !== 0) {
          return titleOrder;
        }

        return toText(left.id).localeCompare(toText(right.id), undefined, { sensitivity: 'base' });
      });
    const conversations = this.conversations.filter((entry) =>
      !filter
      || String(entry.Name || '').toLowerCase().includes(filter)
      || String(entry.Job || '').toLowerCase().includes(filter)
    );
    const others = this.availablePdas.filter((entry) =>
      !filter
      || String(entry.Name || '').toLowerCase().includes(filter)
      || String(entry.Job || '').toLowerCase().includes(filter)
    );

    const activeRef = this.getActiveTargetRef();
    const groupActive = this.hasActiveGroup;
    const targetEntry = this.selectedTarget;
    const canDetonate = toBool(this.access.access_detonate_pda) && toBool(targetEntry?.Detonate);
    const canHonk = toBool(this.access.access_clown);
    const canSilence = toBool(this.access.access_mime);

    const visibleMessages = this.getVisiblePmMessages();
    const visibleGroupMessages = this.groupMessages;

    const showGroupJoinComposer = groupActive && !this.isGroupMember;
    const inputDisabled = !this.messengerOn || (!activeRef && !groupActive) || showGroupJoinComposer;
    const placeholder = !this.messengerOn
      ? 'Messenger is OFF'
      : showGroupJoinComposer
        ? 'Join group to send messages'
      : groupActive
        ? 'Group message... (use :happy: or :e42:)'
        : !activeRef
          ? 'Select a contact first'
          : 'Message... (use :happy: or :e42:)';
    const inviteFilter = this.inviteSearch.toLowerCase();
    const inviteCandidates = this.groupCandidates.filter((candidate) => {
      const name = String(candidate.name || '').toLowerCase();
      const role = String(candidate.job || '').toLowerCase();
      return !inviteFilter || name.includes(inviteFilter) || role.includes(inviteFilter);
    });
    const bulkDeleteTooltip = this.listTab === 'groups'
      ? 'Leave all groups'
      : 'Delete all PMs';

    return (
      <div className="PdaMessenger">
        <div className="PdaMessenger__sidebar">
          <div className="PdaMessenger__sideTop">
            <div className="PdaMessenger__sideTitle">
              <Icon name="comment" /> MESSENGER
            </div>

            <div className="PdaMessenger__sideActions">
              <Button
                icon="rotate"
                tooltip="Refresh"
                onClick={() => this.props.ctx.act('refresh')}
                className="PdaMessenger__actionBtn"
              />
              <Button
                icon="trash-can"
                tooltip={bulkDeleteTooltip}
                onClick={this.clearAllByTab}
                className="PdaMessenger__actionBtn"
              />
              <Button
                icon={this.messengerOn ? 'check' : 'xmark'}
                tooltip="Toggle messenger"
                onClick={this.toggleMessenger}
                className="PdaMessenger__actionBtn"
              />
              <Button
                icon={this.ringerOn ? 'volume-high' : 'volume-xmark'}
                tooltip="Toggle ringer"
                onClick={this.toggleRinger}
                className="PdaMessenger__actionBtn"
              />
              <Button
                icon="music"
                tooltip="Set ringtone"
                onClick={this.openRingtone}
                className="PdaMessenger__actionBtn"
              />
            </div>

            <div className="PdaMessenger__tabs">
              <button
                className={cx('PdaMessenger__tabBtn', this.listTab === 'groups' && 'is-active')}
                onClick={() => this.setListTab('groups')}
              >
                Groups
              </button>
              <button
                className={cx('PdaMessenger__tabBtn', this.listTab === 'pms' && 'is-active')}
                onClick={() => this.setListTab('pms')}
              >
                PMs
              </button>
            </div>

            <div className="PdaMessenger__search">
              <Input
                value={this.filter}
                placeholder="Search..."
                onInput={(_, value) => this.setFilter(String(value))}
              />
            </div>
          </div>

          <div className="PdaMessenger__chatList">
            {this.listTab === 'groups' && (
              <>
                {!this.groupChatAvailable && (
                  <div className="PDAProgram__footerHint">NTNet chat is currently unavailable.</div>
                )}
                {!!this.groupChatAvailable && (
                  <div style={{ padding: '0 10px 10px 10px' }}>
                    <Button icon="users" content="Create Group" onClick={this.openGroupCreate} fluid />
                  </div>
                )}
                {groupChannels.length === 0 && this.groupChatAvailable && (
                  <div className="PDAProgram__footerHint">No group channels.</div>
                )}
                {groupChannels.map((group, index) => {
                  const id = toText(group.id);
                  const title = String(group.title || 'Group Channel');
                  const locked = toBool(group.locked);
                  const isMember = toBool(group.is_member);
                  const users = Number(group.members || 0);
                  return (
                    <div
                      key={`${id || 'group'}-${index}`}
                      className={cx('PdaMessenger__chatRow', this.activeGroupId === id && 'is-active')}
                      onClick={() => this.selectGroupRow(group)}
                    >
                      <div className="PdaMessenger__avatar">
                        <Icon name={locked ? 'lock' : 'users'} />
                      </div>
                      <div className="PdaMessenger__chatMeta">
                        <div className="PdaMessenger__chatTitle">{title}</div>
                        <div className="PdaMessenger__chatSub">
                          {users} user{users === 1 ? '' : 's'}{isMember ? ' - Joined' : ''}
                        </div>
                      </div>
                    </div>
                  );
                })}
              </>
            )}

            {this.listTab === 'pms' && (
              <>
                <div className="PdaMessenger__listSection">
                  <Icon name="clock-rotate-left" /> Conversations
                </div>
                {conversations.length === 0 && (
                  <div className="PDAProgram__footerHint">No conversations.</div>
                )}
                {conversations.map((entry, index) => {
                  const ref = String(entry.Reference || '');
                  const isActive = this.isConversationMode && this.activeConversation === ref;
                  const job = this.getJobLabel(entry);
                  return (
                    <div
                      key={`${ref || 'convo'}-${index}`}
                      className={cx('PdaMessenger__chatRow', isActive && 'is-active')}
                      onClick={() => this.selectConversation(ref)}
                    >
                      <div className="PdaMessenger__avatar">
                        <Icon name="user" />
                      </div>
                      <div className="PdaMessenger__chatMeta">
                        <div className="PdaMessenger__chatTitle">{entry.Name || 'Unknown PDA'}</div>
                        <div className="PdaMessenger__chatSub">{job}</div>
                      </div>
                    </div>
                  );
                })}

                <div className="PdaMessenger__listSection">
                  <Icon name="users" /> Recipients
                </div>
                {others.length === 0 && (
                  <div className="PDAProgram__footerHint">No other PDAs located.</div>
                )}
                {others.map((entry, index) => {
                  const ref = String(entry.Reference || '');
                  const isActive = !this.isConversationMode && this.selectedTargetRef === ref;
                  const job = this.getJobLabel(entry);
                  return (
                    <div
                      key={`${ref || 'pda'}-${index}`}
                      className={cx('PdaMessenger__chatRow', isActive && 'is-active')}
                      onClick={() => this.selectPeer(ref)}
                    >
                      <div className="PdaMessenger__avatar">
                        <Icon name="user" />
                      </div>
                      <div className="PdaMessenger__chatMeta">
                        <div className="PdaMessenger__chatTitle">{entry.Name || 'Unknown PDA'}</div>
                        <div className="PdaMessenger__chatSub">{job}</div>
                      </div>
                    </div>
                  );
                })}
              </>
            )}
          </div>
        </div>

        <div className="PdaMessenger__main">
          <div className="PdaMessenger__topbar">
            <div className="PdaMessenger__topTitle">
              {this.selectedTitle}
            </div>

            <div className="PdaMessenger__topHint">
              {groupActive
                ? `Group ${this.isGroupMember ? 'joined' : 'preview'}${this.groupLocked ? ' - Private' : ' - Public'}`
                : this.messengerOn
                  ? 'Messenger online'
                  : 'MESSENGER OFF - no incoming or outgoing messages'}
            </div>

            <div className="PdaMessenger__topActions">
              {!groupActive && (
                <Button
                  icon="trash"
                  tooltip="Delete conversation"
                  onClick={this.clearCurrentConversation}
                  disabled={!this.isConversationMode || !this.activeConversation}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && (
                <Button
                  icon="xmark"
                  tooltip="Close group view"
                  onClick={this.closeGroup}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && !this.isGroupMember && (
                <Button
                  icon="right-to-bracket"
                  tooltip="Join group"
                  onClick={this.joinActiveGroup}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && this.isGroupMember && (
                <Button
                  icon="users"
                  tooltip="Group members"
                  onClick={this.openGroupMembers}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && this.isGroupMember && (
                <Button
                  icon="arrow-right"
                  tooltip="Leave group"
                  onClick={this.leaveGroup}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && this.isGroupMember && this.isGroupAdmin && (
                <Button
                  icon="tag"
                  tooltip="Rename group"
                  onClick={this.renameGroup}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && this.isGroupMember && this.isGroupAdmin && (
                <Button
                  icon="key"
                  tooltip="Set/remove group password"
                  onClick={this.setGroupPassword}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}

              {groupActive && this.isGroupMember && this.isGroupAdmin && (
                <Button
                  icon="trash-can"
                  tooltip="Delete group"
                  onClick={this.deleteGroup}
                  className="PdaMessenger__ringtoneBtn"
                />
              )}
            </div>
          </div>

          {!this.messengerOn && (
            <div className="PdaMessenger__offBanner">
              <Icon name="triangle-exclamation" />
              Messenger is OFF. Turn it on to send and receive messages.
            </div>
          )}

          <div
            className="PdaMessenger__messages"
            ref={(node) => {
              this.messagesViewport = (node as HTMLDivElement) || null;
            }}
          >
            {this.renderChargeHint()}

            {!groupActive && (canDetonate || canHonk || canSilence) && !!activeRef && (
              <div style={{ display: 'flex', gap: 6, marginBottom: 10, flexWrap: 'wrap' }}>
                {canDetonate && (
                  <Button
                    icon="radiation"
                    content="Detonate"
                    color="bad"
                    onClick={() => this.runTargetAction('detonate')}
                  />
                )}
                {canHonk && (
                  <Button
                    icon="star"
                    content="Send Honk Virus"
                    onClick={() => this.runTargetAction('send_honk')}
                  />
                )}
                {canSilence && (
                  <Button
                    icon="circle-arrow-right"
                    content="Send Silence Virus"
                    onClick={() => this.runTargetAction('send_silence')}
                  />
                )}
              </div>
            )}

            {showGroupJoinComposer && (
              <div className="PdaMessenger__joinHint">
                <div className="PDAProgram__footerHint">
                  You are viewing this group as a guest. Join to send messages.
                </div>
                <Button icon="right-to-bracket" content="Join Group" onClick={this.joinActiveGroup} />
              </div>
            )}

            {!groupActive && !this.isConversationMode && (
              <div className="PdaMessenger__empty">
                Select a conversation or choose a PDA and send a message.
              </div>
            )}

            {groupActive && visibleGroupMessages.length === 0 && (
              <div className="PdaMessenger__empty">No messages in this group yet.</div>
            )}

            {!groupActive && this.isConversationMode && visibleMessages.length === 0 && (
              <div className="PdaMessenger__empty">No messages in this conversation.</div>
            )}

            {groupActive && visibleGroupMessages.map((message, index) => {
              const isStatus = Number(message.status || 0) === 1;
              const senderName = String(message.username || 'Unknown');
              const fromMe = senderName === String(this.props.ctx.data?.owner || '');
              const text = String(message.message || '');
              return (
                <div key={`group-${index}`} className={cx('PdaMessenger__msg', fromMe && !isStatus && 'is-me')}>
                  <div className={cx('PdaMessenger__bubble', isStatus && 'is-status')}>
                    <div className="PdaMessenger__from">{isStatus ? 'System' : senderName}</div>
                    <div className="PdaMessenger__text">
                      {renderEmojiParts(parseEmojiParts(text))}
                    </div>
                    <div className="PdaMessenger__meta">
                      <span className="PdaMessenger__time">{message.timestamp || ''}</span>
                    </div>
                  </div>
                </div>
              );
            })}

            {!groupActive && this.isConversationMode && visibleMessages.map((message, index) => {
              const fromMe = Number(message.sent || 0) === 1;
              const text = String(message.message || '');
              return (
                <div key={index} className={cx('PdaMessenger__msg', fromMe && 'is-me')}>
                  <div className="PdaMessenger__bubble">
                    <div className="PdaMessenger__from">{fromMe ? 'You' : (message.owner || 'Them')}</div>
                    <div className="PdaMessenger__text">
                      {renderEmojiParts(parseEmojiParts(text))}
                    </div>
                    <div className="PdaMessenger__meta">
                      <span className="PdaMessenger__time">{message.timestamp || ''}</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {!showGroupJoinComposer && (
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
                  placeholder={placeholder}
                  onInput={(_, value) => this.setDraft(String(value))}
                  disabled={inputDisabled}
                  onKeyDown={(event: KeyboardEvent) => {
                    // @ts-ignore
                    if (event.key === 'Enter') {
                      this.send();
                    }
                  }}
                />
              </div>

              <Button
                icon="paper-plane"
                content="Send"
                onClick={this.send}
                disabled={inputDisabled}
                className="PdaMessenger__sendBtn"
              />

              {this.showEmojiPicker && (
                <EmojiPicker onPick={this.insertEmojiToken} />
              )}
            </div>
          )}
        </div>

        {this.showRingtone && (
          <div className="PdaMessengerModal" onClick={this.closeRingtone}>
            <div className="PdaMessengerModal__card" onClick={(event) => event.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="music" /> Change Ringtone
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Ringtone id</div>
                  <Input
                    value={this.ringtoneDraft}
                    placeholder="e.g. pda_beep_1"
                    onInput={(_, value) => {
                      this.ringtoneDraft = String(value);
                      this.forceUpdate();
                    }}
                    onKeyDown={(event: KeyboardEvent) => {
                      // @ts-ignore
                      if (event.key === 'Enter') {
                        this.applyRingtone();
                      }
                    }}
                  />
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeRingtone} />
                <Button content="Apply" icon="check" onClick={this.applyRingtone} />
              </div>
            </div>
          </div>
        )}

        {this.showGroupCreate && (
          <div className="PdaMessengerModal" onClick={this.closeGroupCreate}>
            <div className="PdaMessengerModal__card" onClick={(event) => event.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="users" /> Create Group Channel
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Group Name</div>
                  <Input
                    value={this.groupTitleDraft}
                    placeholder="e.g. Med Duty"
                    onInput={(_, value) => {
                      this.groupTitleDraft = String(value);
                      this.forceUpdate();
                    }}
                  />
                </div>
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Password (optional)</div>
                  <Input
                    type="password"
                    value={this.groupPasswordDraft}
                    placeholder="Leave blank for open channel"
                    onInput={(_, value) => {
                      this.groupPasswordDraft = String(value);
                      this.forceUpdate();
                    }}
                  />
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeGroupCreate} />
                <Button content="Create" icon="check" onClick={this.createGroup} />
              </div>
            </div>
          </div>
        )}

        {this.showGroupJoin && (
          <div className="PdaMessengerModal" onClick={this.closeGroupJoin}>
            <div className="PdaMessengerModal__card" onClick={(event) => event.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="key" /> Join Group Channel
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Channel</div>
                  <div className="PDAProgram__footerHint">{this.groupJoinTitle || 'Unknown channel'}</div>
                </div>
                <div className="PdaMessengerModal__field">
                  <div className="PdaMessengerModal__label">Password</div>
                  <Input
                    type="password"
                    value={this.groupJoinPasswordDraft}
                    placeholder="Enter channel password"
                    onInput={(_, value) => {
                      this.groupJoinPasswordDraft = String(value);
                      this.forceUpdate();
                    }}
                    onKeyDown={(event: KeyboardEvent) => {
                      // @ts-ignore
                      if (event.key === 'Enter') {
                        this.submitGroupJoin();
                      }
                    }}
                  />
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Cancel" onClick={this.closeGroupJoin} />
                <Button content="Join" icon="right-to-bracket" onClick={this.submitGroupJoin} />
              </div>
            </div>
          </div>
        )}

        {this.showGroupMembers && groupActive && this.isGroupMember && (
          <div className="PdaMessengerModal" onClick={this.closeGroupMembers}>
            <div className="PdaMessengerModal__card" onClick={(event) => event.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="users" /> Group Members
              </div>

              <div className="PdaMessengerModal__body">
                <div className="PdaMessenger__groupMembers">
                  {this.groupMembers.map((member, index) => {
                    const memberRef = String(member.ref || '');
                    const isSelf = toBool(member.is_self);
                    const isAdmin = toBool(member.is_admin);
                    const isOperator = toBool(member.is_operator);
                    const memberKind = String(member.kind || 'pda');
                    const memberRole = String(member.role || member.job || 'Member');
                    return (
                      <div key={`${memberRef || 'member'}-${index}`} className="PdaMessenger__groupMember">
                        <div className="PdaMessenger__groupMemberName">
                          {member.name || 'Unknown PDA'} {isOperator ? '[OP]' : isAdmin ? '[ADMIN]' : ''}
                          <div className="PdaMessenger__groupMemberRole">{memberRole}</div>
                        </div>
                        {this.isGroupAdmin && memberKind === 'pda' && !isSelf && (
                          <div className="PdaMessenger__groupMemberActions">
                            <Button
                              icon={isAdmin ? 'user-minus' : 'user-plus'}
                              tooltip={isAdmin ? 'Revoke admin' : 'Make admin'}
                              onClick={() => this.setGroupAdmin(memberRef, !isAdmin)}
                              className="PdaMessenger__ringtoneBtn"
                            />
                            <Button
                              icon="times"
                              tooltip="Remove from group"
                              onClick={() => this.removeGroupMember(memberRef)}
                              className="PdaMessenger__ringtoneBtn"
                            />
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                {this.isGroupAdmin && (
                  <Button icon="user-plus" content="Add to the group" onClick={this.openGroupInvite} />
                )}
                <Button content="Close" onClick={this.closeGroupMembers} />
              </div>
            </div>
          </div>
        )}

        {this.showGroupInvite && groupActive && this.isGroupMember && this.isGroupAdmin && (
          <div className="PdaMessengerModal" onClick={this.closeGroupInvite}>
            <div className="PdaMessengerModal__card" onClick={(event) => event.stopPropagation()}>
              <div className="PdaMessengerModal__title">
                <Icon name="user-plus" /> Add to the group
              </div>

              <div className="PdaMessengerModal__body">
                <Input
                  value={this.inviteSearch}
                  placeholder="Search by name or role..."
                  onInput={(_, value) => this.setInviteSearch(String(value))}
                />
                <div className="PdaMessenger__inviteList">
                  {inviteCandidates.length === 0 && (
                    <div className="PDAProgram__footerHint">No matching PDAs found.</div>
                  )}
                  {inviteCandidates.map((candidate, index) => {
                    const ref = String(candidate.ref || '');
                    const role = String(candidate.job || 'Unknown role');
                    return (
                      <div key={`${ref || 'invite'}-${index}`} className="PdaMessenger__inviteRow">
                        <div className="PdaMessenger__inviteName">
                          {candidate.name || 'Unknown PDA'}
                          <div className="PdaMessenger__inviteRole">{role}</div>
                        </div>
                        <Button icon="plus" content="Add to the group" onClick={() => this.addGroupMember(ref)} />
                      </div>
                    );
                  })}
                </div>
              </div>

              <div className="PdaMessengerModal__actions">
                <Button content="Close" onClick={this.closeGroupInvite} />
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

  private setMode = (mode: 'named' | 'all') => {
    this.mode = mode;
    this.forceUpdate();
  };

  private setFilter = (value: string) => {
    this.filter = value;
    this.forceUpdate();
  };

  render() {
    const { onPick } = this.props;
    const filter = (this.filter || '').toLowerCase();
    const list = EMOJI_ALL.filter((emoji) =>
      !filter || emoji.name.toLowerCase().includes(filter)
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
            placeholder="Filter..."
            onInput={(_, value) => this.setFilter(String(value))}
          />
        </div>
        {this.mode === 'named' ? (
          <div className="PdaEmojiPicker__named">
            {list.map((emoji, index) => {
              const token = `:${emoji.name}:`;
              const src = emojiUrl(emoji.file);
              return (
                <button
                  key={`${emoji.name}-${index}`}
                  className="PdaEmojiPicker__namedItem"
                  onClick={() => onPick(token)}
                  title={`${token} (${emoji.file})`}
                >
                  {src
                    ? (
                      <img
                        src={src}
                        alt={token}
                        style={{ width: 24, height: 24, objectFit: 'contain' }}
                      />
                    )
                    : <span>{emoji.name}</span>}
                  <span className="PdaEmojiPicker__namedLabel">{token}</span>
                </button>
              );
            })}
          </div>
        ) : (
          <div className="PdaEmojiPicker__grid">
            {list.map((emoji, index) => {
              const globalIndex = EMOJI_ALL.indexOf(emoji);
              const token = `:e${globalIndex}:`;
              const src = emojiUrl(emoji.file);
              return (
                <button
                  key={`${emoji.name}-${index}`}
                  className="PdaEmojiPicker__cell"
                  onClick={() => onPick(token)}
                  title={`${token} (${emoji.file})`}
                >
                  {src
                    ? (
                      <img
                        src={src}
                        alt={token}
                        style={{ width: 18, height: 18, objectFit: 'contain' }}
                      />
                    )
                    : <span>{globalIndex}</span>}
                </button>
              );
            })}
          </div>
        )}
      </div>
    );
  }
}

export const MessengerProgram: PdaProgram = {
  id: PDA_MODE.MESSENGER,
  title: 'Messenger',
  icon: 'comment',
  View: (ctx) => <MessengerApp ctx={ctx} />,
};
