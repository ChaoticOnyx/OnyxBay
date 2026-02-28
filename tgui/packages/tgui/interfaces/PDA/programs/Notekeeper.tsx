import { Component } from 'inferno';
import { Icon, Button, TextArea } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

type NoteEntry = {
  index?: number | string;
  title?: string;
  preview?: string;
};

class NotekeeperApp extends Component<{ ctx: PdaProgramContext }> {
  private draft = '';
  private draftIndex = -1;

  private normalizeBackendNote() {
    const noteRaw = String(this.props.ctx.data?.note_raw || '');
    if (noteRaw) {
      return noteRaw;
    }
    return String(this.props.ctx.data?.note || '').replace(/<br>/gi, '\n');
  }

  private syncDraftIfNeeded() {
    const activeNoteIndex = Number(this.props.ctx.data?.active_note_index || 1);
    if (this.draftIndex !== activeNoteIndex) {
      this.draft = this.normalizeBackendNote();
      this.draftIndex = activeNoteIndex;
    }
  }

  private setDraft = (value: string) => {
    this.draft = value;
    this.forceUpdate();
  };

  private saveDraft = () => {
    this.props.ctx.act('choice', {
      choice: 'Save Note',
      note: this.draft,
    });
  };

  render() {
    const { ctx } = this.props;
    const notes: NoteEntry[] = ctx.data?.notes || [];
    const activeNoteIndex = Number(ctx.data?.active_note_index || 1);
    this.syncDraftIfNeeded();

    return (
      <div className="PDAProgram PDAProgram--generic">
        <div className="PDAProgram__header">
          <div className="PDAProgram__title">
            <Icon name="file-lines" /> NOTEKEEPER
          </div>
          <div className="PDAProgram__sub">Multi-note storage</div>
        </div>

        <div className="PDAProgram__panel">
          <div className="PDAProgram__row">
            <div className="PDAProgram__k">Saved Notes</div>
            <div className="PDAProgram__v">
              {notes.length} total / active #{activeNoteIndex}
            </div>
          </div>

          <div className="PDAProgram__buttonGrid" style={{ marginTop: 10 }}>
            <Button
              icon="plus"
              content="New Note"
              onClick={() => ctx.act('choice', { choice: 'New Note' })}
            />
            <Button
              icon="trash"
              content="Delete Note"
              onClick={() => ctx.act('choice', { choice: 'Delete Note' })}
            />
            <Button
              icon="tag"
              content="Rename Note"
              onClick={() => ctx.act('choice', { choice: 'Rename Note' })}
            />
            <Button
              icon="save"
              content="Save Note"
              onClick={this.saveDraft}
            />
          </div>

          <div className="PDAProgram__list" style={{ marginTop: 12 }}>
            {notes.map((entry) => (
              <button
                key={entry.index}
                className={activeNoteIndex === Number(entry.index) ? 'PDAProgram__listButton is-active' : 'PDAProgram__listButton'}
                onClick={() => ctx.act('choice', { choice: 'Select Note', index: entry.index })}
              >
                <div className="PDAProgram__listTitle">{entry.title}</div>
                <div className="PDAProgram__listPreview">{entry.preview || '(empty)'}</div>
              </button>
            ))}
          </div>

          <div className="PDAProgram__readableBox" style={{ marginTop: 10 }}>
            <div className="PDAProgram__k" style={{ marginBottom: 6 }}>Active Note</div>
            <TextArea
              value={this.draft}
              onInput={(_, value) => this.setDraft(String(value))}
              fluid
              height="140px"
              onKeyDown={(event: KeyboardEvent) => {
                // @ts-ignore
                if (event.ctrlKey && event.key === 'Enter') {
                  this.saveDraft();
                }
              }}
            />
          </div>
        </div>
      </div>
    );
  }
}

export const NotekeeperProgram: PdaProgram = {
  id: PDA_MODE.NOTEKEEPER,
  title: 'Notekeeper',
  icon: 'file-lines',
  View: (ctx) => <NotekeeperApp ctx={ctx} />,
};
