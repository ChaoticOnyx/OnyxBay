import { Icon, Button } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const NotekeeperApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const note = String(ctx.data?.note || '');
  const notes = ctx.data?.notes || [];
  const activeNoteIndex = Number(ctx.data?.active_note_index || 1);

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
            icon="pencil"
            content="Edit Notes"
            onClick={() => ctx.act('choice', { choice: 'Edit' })}
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

        <div className="PDAProgram__readableBox" style={{ marginTop: 10, whiteSpace: 'pre-wrap' }}>
          {note || '(empty)'}
        </div>
      </div>
    </div>
  );
};

export const NotekeeperProgram: PdaProgram = {
  id: PDA_MODE.NOTEKEEPER,
  title: 'Notekeeper',
  icon: 'file-lines',
  View: (ctx) => <NotekeeperApp ctx={ctx} />,
};
