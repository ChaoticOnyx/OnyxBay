import { Component } from 'inferno';
import { Icon, Button } from '../../../components';
import type { PdaProgram, PdaProgramContext } from '../types';

type BotMode = -1 | 0 | 1 | 2 | 3 | 4 | 5 | 6;

type Bot = {
  ref: string;
  name: string;
  location: string;
  mode: BotMode;
};

function modeToText(mode: BotMode): string {
  if (mode === -1) return 'Waiting for response...';
  if (mode === 0) return 'Ready';
  if (mode === 1) return 'Apprehending target';
  if (mode === 2 || mode === 3) return 'Arresting target';
  if (mode === 4) return 'Starting patrol';
  if (mode === 5) return 'On Patrol';
  return 'Responding to summons';
}

function randomBotMode(): BotMode {
  const options: BotMode[] = [0, 1, 2, 3, 4, 5, 6];
  return options[Math.floor(Math.random() * options.length)];
}

function randomLocation() {
  const areas = [
    'Brig',
    'Arrivals',
    'Bridge Hallway',
    'Engineering Hallway',
    'Cargo Bay',
    'Medbay Entrance',
  ];
  return areas[Math.floor(Math.random() * areas.length)];
}

class SecurityBotApp extends Component<{ ctx: PdaProgramContext }> {
  private bots: Bot[] = [
    { ref: 'beepsky-1', name: 'Officer Beepsky #1', location: 'Brig', mode: 5 },
    { ref: 'beepsky-2', name: 'Officer Beepsky #2', location: 'Arrivals', mode: 0 },
  ];

  private activeRef: string | null = null;
  private busy = false;
  private last: string | null = null;

  private get activeBot(): Bot | null {
    if (!this.activeRef) return null;
    return this.bots.find(b => b.ref === this.activeRef) || null;
  }

  private scanBots = () => {
    if (this.busy) return;
    this.busy = true;
    this.last = null;
    this.forceUpdate();

    window.setTimeout(() => {
      const foundNone = Math.random() < 0.12;
      if (foundNone) {
        this.bots = [];
        this.activeRef = null;
        this.last = 'Scan complete: no bots found.';
      } else {
        this.bots = [
          { ref: 'beepsky-1', name: 'Officer Beepsky #1', location: randomLocation(), mode: randomBotMode() },
          { ref: 'beepsky-2', name: 'Officer Beepsky #2', location: randomLocation(), mode: randomBotMode() },
          { ref: 'beepsky-3', name: 'Officer Beepsky #3', location: randomLocation(), mode: randomBotMode() },
        ];
        this.last = `Scan complete: ${this.bots.length} bot(s) reachable.`;
      }

      this.busy = false;
      this.forceUpdate();
    }, 350);
  };

  private selectBot = (ref: string) => {
    if (this.busy) return;
    this.activeRef = ref;

    const bot = this.activeBot;
    if (!bot) {
      this.forceUpdate();
      return;
    }

    bot.mode = -1;
    this.last = null;
    this.forceUpdate();

    window.setTimeout(() => {
      bot.mode = randomBotMode();
      bot.location = randomLocation();
      this.last = `Linked with ${bot.name}.`;
      this.forceUpdate();
    }, 220);
  };

  private runCmd = (command: 'stop' | 'go' | 'summon') => {
    const bot = this.activeBot;
    if (!bot) return;

    if (command === 'stop') {
      bot.mode = 0;
      this.last = `${bot.name}: patrol stopped.`;
    } else if (command === 'go') {
      bot.mode = 5;
      this.last = `${bot.name}: patrol started.`;
    } else {
      bot.mode = 6;
      bot.location = 'Your position';
      this.last = `${bot.name}: summon acknowledged.`;
    }

    this.forceUpdate();
  };

  private backToList = () => {
    this.activeRef = null;
    this.forceUpdate();
  };

  private renderBotList() {
    if (!this.bots.length) {
      return (
        <>
          <div style={{ color: '#f87171', fontWeight: 900 }}>No bots found.</div>
          <div style={{ marginTop: 10 }}>
            <Button icon="rotate" content={this.busy ? 'Scanning...' : 'Scan for Bots'} onClick={this.scanBots} />
          </div>
        </>
      );
    }

    return (
      <>
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Available bots</div>
          <div className="PDAProgram__v">{this.bots.length}</div>
        </div>

        <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 8 }}>
          {this.bots.map(bot => (
            <Button
              key={bot.ref}
              icon="circle-arrow-right"
              content={`${bot.name} (${bot.location})`}
              onClick={() => this.selectBot(bot.ref)}
            />
          ))}
        </div>

        <div style={{ marginTop: 10 }}>
          <Button icon="rotate" content={this.busy ? 'Scanning...' : 'Scan for Bots'} onClick={this.scanBots} />
        </div>
      </>
    );
  }

  private renderActiveBot(bot: Bot) {
    return (
      <>
        <div style={{ marginBottom: 8 }}>
          <Button icon="arrow-left" content="Return to Bot list" onClick={this.backToList} />
        </div>

        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Active Bot</div>
          <div className="PDAProgram__v">{bot.name}</div>
        </div>
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Location</div>
          <div className="PDAProgram__v">{bot.location}</div>
        </div>
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Mode</div>
          <div className="PDAProgram__v">{modeToText(bot.mode)}</div>
        </div>

        {bot.mode !== -1 && (
          <div style={{ marginTop: 12, display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <Button content="Stop Patrol" onClick={() => this.runCmd('stop')} />
            <Button content="Start Patrol" onClick={() => this.runCmd('go')} />
            <Button content="Summon Bot" onClick={() => this.runCmd('summon')} />
          </div>
        )}
      </>
    );
  }

  render() {
    const bot = this.activeBot;

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="gear" /> SECURITY BOT CONTROL
          </div>
          <div className="PDAProgram__sub">Legacy PDA mode 46 - UI-only mock</div>
        </div>

        <div className="PDAProgram__panel">
          {!bot ? this.renderBotList() : this.renderActiveBot(bot)}

          {this.last && (
            <div className="PDAProgram__footerHint" style={{ marginTop: 10, opacity: 0.8 }}>
              {this.last}
            </div>
          )}
        </div>
      </div>
    );
  }
}

export const SecurityBotProgram: PdaProgram = {
  id: 'security_bot',
  title: 'Security Bot',
  icon: 'gear',
  canRun: (ctx) => ctx.cartridgeType === 'admin',
  View: (ctx) => <SecurityBotApp ctx={ctx} />,
};
