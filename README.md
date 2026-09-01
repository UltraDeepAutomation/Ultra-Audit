# Ultra-Audit

A Claude Code skill that audits a codebase for bugs the way a careful engineer would —
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

Personal (available in every project):

```bash
git clone https://github.com/UltraDeepAutomation/Ultra-Audit.git ~/.claude/skills/Ultra-Audit
```

Or per project:

```bash
git clone https://github.com/UltraDeepAutomation/Ultra-Audit.git .claude/skills/Ultra-Audit
```

A skill is identified by its directory name, so the skill is invoked as
`Ultra-Audit`. If your setup insists on lowercase skill names, clone into
`~/.claude/skills/ultra-audit` instead — nothing else changes.

Optional `/ultraaudit` slash command:

```bash
cp ~/.claude/skills/Ultra-Audit/commands/ultraaudit.md ~/.claude/commands/ultraaudit.md
```

## Use

Ask for it in plain language ("audit this project for bugs and fix them"), or run
`/ultraaudit`. Narrow the scope with an argument:

```bash
/ultraaudit packages/engine
```

The rules do not relax inside a narrowed scope — same three sweeps, same coverage
table, just a smaller area.

## Expect a long run

This is not a quick lint. On a real codebase it reads a lot of code, writes a detailed
report, and then makes a series of commits. Give it a clean working tree, or a branch.

## Files

- `SKILL.md` — the procedure. The only source of truth for it.
- `reference/report-template.md` — skeleton of the seven-section audit report.
- `commands/ultraaudit.md` — thin slash-command wrapper that invokes the skill.

## По-русски

Скилл делает полный аудит проекта на баги и нарушения SSOT, пишет подробный отчёт
`BUGSAUDIT-<дата>.md` и сразу чинит найденное — сам, без вопросов по ходу работы.
Вопросы только в финале, одним списком, и только те, что git не откатит.
Установка — команды выше; вызов — `/ultraaudit` или обычной просьбой сделать аудит.

## License

MIT
