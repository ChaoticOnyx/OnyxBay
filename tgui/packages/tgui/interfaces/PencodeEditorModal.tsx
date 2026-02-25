import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, NoticeBox, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type Data = {
  title?: string;
  message?: string;
  init_value?: string;
  max_length?: number;
  max_fields?: number;

  value?: string;
  preview_html?: string;
  error_message?: string | null;
};

type State = {
  text: string;
  syntax: boolean;
  tab: 'edit' | 'preview';
};

const DEBOUNCE_MS = 1000;
const CHUNK_SIZE = 350000;
const CHUNK_THRESHOLD = 350000;

const makeChunkId = () => `${Date.now()}-${Math.random().toString(16).slice(2)}`;

type InsertMode = 'wrap' | 'insert' | 'lineprefix';

type TokenDef = {
  tooltip: string;
  mode: InsertMode;
  open?: string;
  close?: string;
  insert?: string;
  prefix?: string;
};

const countFields = (text: string) => {
  const m = text.match(/\[field\]/g);
  return m ? m.length : 0;
};

const escapeHtml = (s: string) =>
  s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');

const highlightPencodeToHtml = (text: string) => {
  const esc = escapeHtml(text);
  const withTokens = esc.replace(
    /\[(\/?)([a-zA-Z*]+)\]/g,
    (_m, slash: string, name: string) => {
      const cls =
        name === '*'
          ? 'PencodeEditorModal__tok PencodeEditorModal__tok--star'
          : slash
            ? 'PencodeEditorModal__tok PencodeEditorModal__tok--close'
            : 'PencodeEditorModal__tok PencodeEditorModal__tok--open';
      return `<span class="${cls}">[${slash}${name}]</span>`;
    },
  );
  return withTokens.replaceAll('\n', '<br/>');
};

export class PencodeEditorModal extends Component<any, State> {
  private textareaEl: HTMLTextAreaElement | null = null;
  private updateTimer: number | null = null;
  private highlightEl: HTMLDivElement | null = null;
  private highlightContentEl: HTMLDivElement | null = null;

  private lastUpdateText: string | null = null;
  private lastPreviewSyncText: string | null = null;

  constructor(props: any, context: any) {
    super(props, context);
    const { data } = useBackend<Data>(context);
    const init = (typeof data.value === 'string' ? data.value : (data.init_value || ''));
    this.state = {
      text: init,
      syntax: true,
      tab: 'edit',
    };
  }

  componentDidMount() {
    const { act } = useBackend<Data>(this.context);
    const text = this.state.text || '';
    this.sendUpdateIfChanged(act, text, this.state.tab === 'preview');
  }

  componentWillUnmount() {
    if (this.updateTimer !== null) {
      clearTimeout(this.updateTimer);
      this.updateTimer = null;
    }
  }

  private setTextareaRef = (el: HTMLTextAreaElement | null) => {
    this.textareaEl = el;
  };

  private setHighlightRef = (el: HTMLDivElement | null) => {
    this.highlightEl = el;
  };

  private setHighlightContentRef = (el: HTMLDivElement | null) => {
    this.highlightContentEl = el;
  };

  private syncScroll = () => {
    const ta = this.textareaEl;
    const hl = this.highlightEl;
    const hc = this.highlightContentEl;
    if (!ta || !hl || !hc) return;

    // Размеры скроллбаров textarea (если их нет — будет 0)
    const sbw = Math.max(0, (ta.offsetWidth || 0) - (ta.clientWidth || 0));
    const sbh = Math.max(0, (ta.offsetHeight || 0) - (ta.clientHeight || 0));

    // Уменьшаем overlay-область под размеры полос
    hl.style.setProperty('--pencode-sbw', `${sbw}px`);
    hl.style.setProperty('--pencode-sbh', `${sbh}px`);

    const x = ta.scrollLeft || 0;
    const y = ta.scrollTop || 0;
    hc.style.transform = `translate(${-x}px, ${-y}px)`;
  };

  private sendUpdateIfChanged(
    act: (a: string, p?: any) => void,
    text: string,
    markPreviewSync?: boolean
  ) {
    // общий анти-спам: одинаковое не отправляем
    if (this.lastUpdateText === text) {
      if (markPreviewSync) this.lastPreviewSyncText = text;
      return;
    }

    this.lastUpdateText = text;
    if (markPreviewSync) this.lastPreviewSyncText = text;

    act('update', {text});
  }

  private scheduleUpdate(act: (a: string, p?: any) => void, text: string, immediate?: boolean) {
    if (this.updateTimer !== null) {
      clearTimeout(this.updateTimer);
      this.updateTimer = null;
    }

    if (immediate) {
      this.sendUpdateIfChanged(act, text);
      return;
    }

    this.updateTimer = window.setTimeout(() => {
      this.sendUpdateIfChanged(act, text);
      this.updateTimer = null;
    }, DEBOUNCE_MS) as any;
  }

  private applyToken(token: TokenDef, maxLen: number, act: (a: string, p?: any) => void) {
    const ta = this.textareaEl;
    const value = this.state.text || '';

    const clamp = (s: string) => (maxLen > 0 && s.length > maxLen ? s.slice(0, maxLen) : s);

    const commit = (next: string, caretStart?: number, caretEnd?: number) => {
      const clamped = clamp(next);
      this.setState({ text: clamped }, () => {
        if (this.textareaEl) {
          this.textareaEl.focus();
          if (caretStart !== undefined && caretEnd !== undefined) {
            const cs = Math.min(caretStart, clamped.length);
            const ce = Math.min(caretEnd, clamped.length);
            try { this.textareaEl.setSelectionRange(cs, ce); } catch {}
          }
        }
        this.syncScroll();
        this.scheduleUpdate(act, clamped);
      });
    };

    if (!ta) {
      let next = value;
      if (token.mode === 'insert' && token.insert) next = value + token.insert;
      if (token.mode === 'wrap' && token.open && token.close) next = value + token.open + token.close;
      if (token.mode === 'lineprefix' && token.prefix) next = value + token.prefix;
      commit(next);
      return;
    }

    const selStart = ta.selectionStart ?? value.length;
    const selEnd = ta.selectionEnd ?? value.length;

    const before = value.slice(0, selStart);
    const selected = value.slice(selStart, selEnd);
    const after = value.slice(selEnd);

    let next = value;
    let nextCaretStart = selStart;
    let nextCaretEnd = selEnd;

    if (token.mode === 'insert' && token.insert) {
      next = before + token.insert + after;
      nextCaretStart = nextCaretEnd = selStart + token.insert.length;
      commit(next, nextCaretStart, nextCaretEnd);
      return;
    }

    if (token.mode === 'wrap' && token.open && token.close) {
      next = before + token.open + selected + token.close + after;
      if (selected.length > 0) {
        nextCaretStart = selStart + token.open.length;
        nextCaretEnd = selEnd + token.open.length;
      } else {
        nextCaretStart = nextCaretEnd = selStart + token.open.length;
      }
      commit(next, nextCaretStart, nextCaretEnd);
      return;
    }

    if (token.mode === 'lineprefix' && token.prefix) {
      const startLine = value.lastIndexOf('\n', selStart - 1) + 1;
      const endLine = value.indexOf('\n', selEnd);
      const end = endLine === -1 ? value.length : endLine;

      const block = value.slice(startLine, end);
      const prefixed = block
        .split('\n')
        .map((line) => (line.length ? token.prefix + line : line))
        .join('\n');

      next = value.slice(0, startLine) + prefixed + value.slice(end);

      const delta = prefixed.length - block.length;
      nextCaretStart = selStart + delta;
      nextCaretEnd = selEnd + delta;

      commit(next, nextCaretStart, nextCaretEnd);
      return;
    }
  }

  private setTab(act: (a: string, p?: any) => void, tab: 'edit' | 'preview') {
    this.setState({ tab }, () => {
      if (tab === 'preview') {
        const text = this.state.text || '';
        if (this.lastPreviewSyncText !== text) {
          this.sendUpdateIfChanged(act, text, true);
        }
      }
      this.syncScroll();
    });
  }

  render() {
    const { act, data } = useBackend<Data>(this.context);

    const title = data.title || 'Text Editor';
    const message = data.message || '';

    const maxLen = data.max_length ?? 0;
    const maxFields = data.max_fields ?? 50;

    const text = this.state.text || '';
    const len = text.length;
    const fields = countFields(text);

    const tooLong = maxLen > 0 && len > maxLen;
    const tooManyFields = fields > maxFields;
    const hasServerError = !!data.error_message;
    const canSubmit = !tooLong && !tooManyFields && !hasServerError;

    const onTextInput = (e: any) => {
      const next = String(e?.target?.value ?? '');
      const limited = maxLen > 0 ? next.slice(0, maxLen + 1) : next;
      this.setState({ text: limited }, () => this.syncScroll());
      this.scheduleUpdate(act, limited);
    };

    const tokBold: TokenDef = { tooltip: 'Bold: [b]...[/b]', mode: 'wrap', open: '[b]', close: '[/b]' };
    const tokItalic: TokenDef = { tooltip: 'Italic: [i]...[/i]', mode: 'wrap', open: '[i]', close: '[/i]' };
    const tokUnderline: TokenDef = { tooltip: 'Underline: [u]...[/u]', mode: 'wrap', open: '[u]', close: '[/u]' };

    const tokLeft: TokenDef = { tooltip: 'Align left: [left]...[/left]', mode: 'wrap', open: '[left]', close: '[/left]' };
    const tokCenter: TokenDef = { tooltip: 'Align center: [center]...[/center]', mode: 'wrap', open: '[center]', close: '[/center]' };
    const tokRight: TokenDef = { tooltip: 'Align right: [right]...[/right]', mode: 'wrap', open: '[right]', close: '[/right]' };

    const tokUl: TokenDef = { tooltip: 'Unordered list: [list]...[/list]', mode: 'wrap', open: '[list]\n', close: '\n[/list]' };
    const tokOl: TokenDef = { tooltip: 'Ordered list: [ord]...[/ord]', mode: 'wrap', open: '[ord]\n', close: '\n[/ord]' };
    const tokStar: TokenDef = { tooltip: 'List item marker: prefix selected lines with [*]', mode: 'lineprefix', prefix: '[*] ' };

    const tokBr: TokenDef = { tooltip: 'Line break: [br]', mode: 'insert', insert: '[br]' };
    const tokHr: TokenDef = { tooltip: 'Horizontal rule: [hr]', mode: 'insert', insert: '[hr]' };

    const tokField: TokenDef = { tooltip: 'Fillable field: [field]', mode: 'insert', insert: '[field]' };
    const tokSign: TokenDef = { tooltip: 'Signature: [sign]', mode: 'insert', insert: '[sign]' };
    const tokSignField: TokenDef = { tooltip: 'Signature field: [signfield]', mode: 'insert', insert: '[signfield]' };

    const tokTable: TokenDef = { tooltip: 'Table: [table]...[/table]', mode: 'wrap', open: '[table]\n[cell]', close: '\n[/table]' };
    const tokGrid: TokenDef = { tooltip: 'Grid: [grid]...[/grid]', mode: 'wrap', open: '[grid]\n[cell]', close: '\n[/grid]' };
    const tokRow: TokenDef = { tooltip: 'Row: [row]', mode: 'insert', insert: '[row]' };
    const tokCell: TokenDef = { tooltip: 'Cell: [cell]', mode: 'insert', insert: '[cell]' };

    const previewHtml = data.preview_html || '';
    const highlightHtml = highlightPencodeToHtml(text);

    return (
      <Window width={600} height={580} title={title}>
        <Window.Content scrollable={false} className="PencodeEditorModal">
          <Box className="PencodeEditorModal__layout">
            <Box className="PencodeEditorModal__topbar">
              <Stack align="center" wrap="wrap" className="PencodeEditorModal__topbarRow">
                <Tabs>
                  <Tabs.Tab selected={this.state.tab === 'edit'} onClick={() => this.setTab(act, 'edit')}>
                    Edit
                  </Tabs.Tab>
                  <Tabs.Tab selected={this.state.tab === 'preview'} onClick={() => this.setTab(act, 'preview')}>
                    Preview
                  </Tabs.Tab>
                </Tabs>

                <Box grow />

                <Box className={tooLong ? 'PencodeEditorModal__counter PencodeEditorModal__counter--bad' : 'PencodeEditorModal__counter'}>
                  Len {len}{maxLen ? `/${maxLen}` : ''}
                </Box>
                <Box className={tooManyFields ? 'PencodeEditorModal__counter PencodeEditorModal__counter--bad' : 'PencodeEditorModal__counter'}>
                  Fields {fields}/{maxFields}
                </Box>

                <Button
                  className="PencodeEditorModal__btn"
                  icon="highlighter"
                  selected={this.state.syntax}
                  tooltip="Toggle syntax highlighting"
                  onClick={() => this.setState({ syntax: !this.state.syntax }, () => this.syncScroll())}
                />

                <Button
                  className="PencodeEditorModal__btnWide"
                  icon="check"
                  content="Submit"
                  tooltip={canSubmit ? 'Submit text' : 'Cannot submit: limit exceeded'}
                  disabled={!canSubmit}
                  onClick={() => act('submit', {text})}
                />
                <Button
                  className="PencodeEditorModal__btnWide"
                  icon="times"
                  content="Cancel"
                  tooltip="Close without saving"
                  onClick={() => act('cancel')}
                />
              </Stack>

              {!!message && <Box className="PencodeEditorModal__message">{message}</Box>}
            </Box>

            <Box className="PencodeEditorModal__toolbar">
              <Stack wrap="wrap" align="center" className="PencodeEditorModal__toolbarRow">
                <Button className="PencodeEditorModal__btn" icon="bold" tooltip={tokBold.tooltip} onClick={() => this.applyToken(tokBold, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="italic" tooltip={tokItalic.tooltip} onClick={() => this.applyToken(tokItalic, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="underline" tooltip={tokUnderline.tooltip} onClick={() => this.applyToken(tokUnderline, maxLen, act)} />

                <Dropdown
                  className="PencodeEditorModal__dd PencodeEditorModal__ddSmall"
                  width="48px"
                  displayText="H"
                  options={['H1', 'H2', 'H3']}
                  tooltip="Headings: H1/H2/H3"
                  onSelected={(v) => {
                    const map: Record<string, TokenDef> = {
                      H1: { tooltip: 'Header 1: [h1]...[/h1]', mode: 'wrap', open: '[h1]', close: '[/h1]' },
                      H2: { tooltip: 'Header 2: [h2]...[/h2]', mode: 'wrap', open: '[h2]', close: '[/h2]' },
                      H3: { tooltip: 'Header 3: [h3]...[/h3]', mode: 'wrap', open: '[h3]', close: '[/h3]' },
                    };
                    const tok = map[v];
                    if (tok) this.applyToken(tok, maxLen, act);
                  }}
                />

                <Button className="PencodeEditorModal__btn" icon="align-left" tooltip={tokLeft.tooltip} onClick={() => this.applyToken(tokLeft, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="align-center" tooltip={tokCenter.tooltip} onClick={() => this.applyToken(tokCenter, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="align-right" tooltip={tokRight.tooltip} onClick={() => this.applyToken(tokRight, maxLen, act)} />

                <Button className="PencodeEditorModal__btn" icon="list-ul" tooltip={tokUl.tooltip} onClick={() => this.applyToken(tokUl, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="list-ol" tooltip={tokOl.tooltip} onClick={() => this.applyToken(tokOl, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" content="*" tooltip={tokStar.tooltip} onClick={() => this.applyToken(tokStar, maxLen, act)} />

                <Button className="PencodeEditorModal__btn" content="BR" tooltip={tokBr.tooltip} onClick={() => this.applyToken(tokBr, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="minus" tooltip={tokHr.tooltip} onClick={() => this.applyToken(tokHr, maxLen, act)} />

                <Button className="PencodeEditorModal__btn" icon="pen" tooltip={tokField.tooltip} onClick={() => this.applyToken(tokField, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" icon="signature" tooltip={tokSign.tooltip} onClick={() => this.applyToken(tokSign, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" content="SF" tooltip={tokSignField.tooltip} onClick={() => this.applyToken(tokSignField, maxLen, act)} />

                <Button className="PencodeEditorModal__btn" icon="table" tooltip={tokTable.tooltip} onClick={() => this.applyToken(tokTable, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" content="Grid" tooltip={tokGrid.tooltip} onClick={() => this.applyToken(tokGrid, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" content="Row" tooltip={tokRow.tooltip} onClick={() => this.applyToken(tokRow, maxLen, act)} />
                <Button className="PencodeEditorModal__btn" content="Cell" tooltip={tokCell.tooltip} onClick={() => this.applyToken(tokCell, maxLen, act)} />
              </Stack>
            </Box>

            {!!data.error_message && (
              <NoticeBox danger className="PencodeEditorModal__error">
                {data.error_message}
              </NoticeBox>
            )}

            <Box className="PencodeEditorModal__body">
              {this.state.tab === 'edit' ? (
                <Box className="PencodeEditorModal__editorWrap">
                  <div className={`PencodeEditorModal__highlight ${this.state.syntax ? '' : 'PencodeEditorModal__highlight--off'}`}
                    ref={this.setHighlightRef as any}>
                    <div
                      className="PencodeEditorModal__highlightContent"
                      ref={this.setHighlightContentRef as any}
                      // @ts-ignore
                      dangerouslySetInnerHTML={{ __html: highlightHtml }}
                    />
                  </div>

                  <textarea
                    className={`PencodeEditorModal__textarea ${this.state.syntax ? 'PencodeEditorModal__textarea--syntax' : ''}`}
                    ref={this.setTextareaRef as any}
                    value={text}
                    onInput={onTextInput}
                    onScroll={this.syncScroll}
                    spellCheck={false as any}
                  />
                </Box>
              ) : (
                <Box className="PencodeEditorModal__previewWrap">
                  <div
                    className="PencodeEditorModal__preview"
                    // @ts-ignore
                    dangerouslySetInnerHTML={{ __html: previewHtml }}
                  />
                </Box>
              )}
            </Box>
          </Box>
        </Window.Content>
      </Window>
    );
  }
}
