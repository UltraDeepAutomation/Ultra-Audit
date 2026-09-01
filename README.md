# Ultra-Audit

![Ultra-Audit](assets/cover.png)

A coding-agent skill that audits a codebase for bugs the way a careful engineer would —
then fixes what it found, autonomously, in one uninterrupted run, with questions saved
for the very end.

Asking an agent to "find bugs and fix them" usually returns a padded list, a few
confident inventions, and no way to tell which is which. This skill is the same request
with the failure modes closed: no target number to pad toward, a defect checklist to
sweep, a confirmed-vs-hypothesis mark on every finding, an honest map of what was never
looked at, and a ban on the fixes that merely hide a bug.

> The skill body is written in Russian, because that is the language it was tuned in.
> It works on codebases in any language. An English translation is welcome as a PR.

## What it does

Three sweeps, all mandatory: the last 40 commits (workarounds, half-finished renames,
code added but never called), the module map, and — the one most audits skip — the
product's own features and the seams *between* them.

Then it writes `BUGSAUDIT-YYYY-MM-DD.md` in the project root and starts fixing, P0
first, without waiting for approval.

Design choices that matter:

- **No target number of bugs.** Asking for "100 bugs" makes a model invent the last
  thirty. Instead an area is closed only when both the findings *and* the places where
  there are provably none have been named.
- **Every finding is marked `подтверждено` (confirmed) or `гипотеза` (hypothesis)** —
  and the two are counted separately. A finding is confirmed only when the path from
  an entry point to the defect has been spelled out.
- **A coverage table is mandatory.** "Analyse the whole codebase" is not achievable on
  a large repo; an honest map of what was and wasn't examined is.
- **P0/P1/P2 are defined in the skill**, so "all P0 fixed" is checkable rather than
  self-assessed.
- **Twelve defect classes are enumerated** — contracts, races, error handling,
  resources, data/migrations, security, SSOT, engineering level, performance, tests,
  dead code, UX. Most extra findings come from here.
- **Fake fixes are banned by name:** weakening a test, swallowing an exception,
  adding a fallback instead of removing the cause, hand-editing a generated file.
- **Every fix carries a check** — a command that failed before and passes after — or
  says outright that it has none.
- **Full autonomy inside the repository**, including deleting files, adding
  dependencies and rewriting modules. The one exception is anything git cannot undo —
  live databases, deploys, publishing, force pushes, credentials: those are prepared
  in full, left unexecuted, and raised in the final summary.

## Install

### Claude Code

```bash
git clone https://github.com/UltraDeepAutomation/Ultra-Audit.git ~/.claude/skills/Ultra-Audit
```

That is the whole install — ask for an audit in plain language and the skill triggers.
A skill is identified by its directory name, so it is invoked as `Ultra-Audit`; if your
setup insists on lowercase names, clone into `~/.claude/skills/ultra-audit` instead.

For a `/ultraaudit` slash command as well:

```bash
cp ~/.claude/skills/Ultra-Audit/commands/ultraaudit.md ~/.claude/commands/ultraaudit.md
```

### Any other agent

The skill is one Markdown procedure, so it fits any coding agent that reads rules from
the repository. `install.sh` projects `SKILL.md` into the format your tool expects —
there is no second copy of the rules anywhere.

```bash
git clone https://github.com/UltraDeepAutomation/Ultra-Audit.git ~/.ultra-audit
cd /path/to/your/project && ~/.ultra-audit/install.sh cursor
```

| Agent | Command | What it writes |
| --- | --- | --- |
| Claude Code, this project only | `install.sh claude` | `.claude/skills/Ultra-Audit/` |
| Claude Code, every project | `install.sh claude-global` | `~/.claude/skills/Ultra-Audit/` |
| Cursor | `install.sh cursor` | `.cursor/rules/ultra-audit.mdc` — call it with `@ultra-audit` |
| Windsurf | `install.sh windsurf` | `.windsurf/rules/ultra-audit.md` |
| Cline, Roo Code | `install.sh cline` | `.clinerules/ultra-audit.md` |
| GitHub Copilot | `install.sh copilot` | `.github/prompts/ultra-audit.prompt.md` — call it with `/ultra-audit` |
| Codex CLI and anything else reading `AGENTS.md` | `install.sh agents` | appends a marked section to `AGENTS.md` |
| Gemini CLI | `install.sh gemini` | appends a marked section to `GEMINI.md` |
| ChatGPT, Claude.ai, any chat | `install.sh print` | prints the procedure to stdout — paste it in |

Every command takes an optional project directory as its second argument and defaults
to the current one. Appends are marked with an HTML comment, so re-running the
installer refuses to duplicate a section instead of quietly doubling it.

## Use

Ask for it in plain language ("audit this project for bugs and fix them"), or run the
slash command your tool installed. Narrow the scope with an argument:

```text
/ultraaudit packages/engine
```

The rules do not relax inside a narrowed scope — same three sweeps, same coverage
table, just a smaller area.

## Expect a long run

This is not a quick lint. On a real codebase it reads a lot of code, writes a detailed
report, and then makes a series of commits. Give it a clean working tree, or a branch.

## What is in the repo

- [`SKILL.md`](SKILL.md) — the procedure itself, and the only source of truth for it.
- [`install.sh`](install.sh) — projects `SKILL.md` into each agent's format.
- [`reference/report-template.md`](reference/report-template.md) — skeleton of the
  seven-section audit report.
- [`commands/ultraaudit.md`](commands/ultraaudit.md) — slash-command wrapper that
  invokes the skill and deliberately holds no second copy of the rules.

## По-русски

Скилл делает полный аудит проекта на баги и нарушения SSOT, пишет подробный отчёт
`BUGSAUDIT-<дата>.md` и сразу чинит найденное — сам, без вопросов по ходу работы.
Вопросы только в финале, одним списком, и только те, что git не откатит.

Работает не только в Claude Code: `install.sh` раскладывает ту же процедуру в формат
Cursor, Windsurf, Cline, Copilot, `AGENTS.md`, `GEMINI.md` — или печатает её в stdout,
чтобы вставить в любой чат. Правила лежат в одном месте, второй копии нет нигде.
Вызов — `/ultraaudit`, `@ultra-audit` или обычной просьбой сделать аудит.

## License

MIT
