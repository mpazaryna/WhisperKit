# Journal Skill - Installation Guide

**Version**: 1.0.0

Interstitial journaling skill for capturing work sessions with automatic context detection.

## What This Skill Does

The journal skill helps you capture comprehensive journal entries at natural breakpoints in your work. It automatically detects whether you're working in a git repository or a regular filesystem, analyzes recent changes, and guides you through documenting the human insights that matter: why you made decisions, what you learned, and what's next.

Perfect for developers, business analysts, technical writers, researchers, and anyone doing knowledge work.

## Installation

### Quick Install

1. **Extract the skill folder**:
   ```bash
   unzip journal.zip
   ```

2. **Copy to your project** (option 1: project-specific):
   ```bash
   cp -r journal/ /path/to/your/project/.claude/skills/
   ```

3. **Or install globally** (option 2: available to all projects):
   ```bash
   cp -r journal/ ~/.claude/skills/
   ```

4. **Verify installation**:
   Open Claude Code and check that the "journal" skill is listed:
   ```
   /skills
   ```

### Manual Installation

If you prefer manual installation:

1. Create the skills directory if it doesn't exist:
   ```bash
   mkdir -p .claude/skills
   # or globally:
   mkdir -p ~/.claude/skills
   ```

2. Copy all files from the journal folder:
   ```
   journal/
   ├── SKILL.md
   ├── detect_context.py
   ├── git_analyzer.py
   ├── filesystem_analyzer.py
   ├── journal_generator.py
   ├── slugify.py
   ├── sample_input.json
   ├── expected_output.md
   └── HOW_TO_USE.md
   ```

## Python Modules

This skill includes 5 Python modules:

- **detect_context.py**: Environment detection (git vs filesystem)
- **git_analyzer.py**: Git commit and diff analysis
- **filesystem_analyzer.py**: Recent file modification tracking
- **journal_generator.py**: Interactive prompting and markdown generation
- **slugify.py**: Filename slug generation

## Requirements

- Python 3.7+ (for the skill modules)
- Git (optional, for git mode functionality)
- Filesystem access (for file modification detection)

## Usage

See [HOW_TO_USE.md](HOW_TO_USE.md) for detailed usage examples.

**Quick start**:
```
Run the journal skill to capture this work session
```

The skill will:
1. Auto-detect your environment (git or filesystem)
2. Show you what changed
3. Ask interactive questions
4. Generate comprehensive journal entry
5. Save to `docs/journal/YYYY-MM-DD-HHMM-slug.md`

## Features

✅ Auto-detects git repositories vs regular filesystems
✅ Analyzes recent commits, diffs, and file changes
✅ Interactive prompting for human insights
✅ Comprehensive markdown journal entries
✅ Atomic notes (multiple entries per day)
✅ Self-contained documentation (no external links)
✅ Works for any knowledge work domain

## Output Location

All journal entries are saved to:
```
docs/journal/YYYY-MM-DD-HHMM-descriptive-slug.md
```

Examples:
- `docs/journal/2025-11-20-1423-agent-composition-system.md`
- `docs/journal/2025-11-20-1610-storage-decision.md`

## Customization

You can customize the skill by modifying:

- **Time window**: Default is 2 hours. Modify in `detect_context.py` and `git_analyzer.py`
- **Questions**: Edit `get_prompt_questions()` in `journal_generator.py`
- **Template sections**: Modify `generate_journal_entry()` in `journal_generator.py`
- **Slug length**: Adjust `max_length` in `slugify.py`

## Troubleshooting

**Skill not appearing**:
- Verify installation path (`.claude/skills/journal/` or `~/.claude/skills/journal/`)
- Check that `SKILL.md` exists with correct YAML frontmatter
- Restart Claude Code

**Git commands not working**:
- Ensure git is installed and in PATH
- Skill gracefully falls back to filesystem mode if git unavailable

**No recent changes detected**:
- Skill looks back 2 hours by default
- Try running immediately after making changes
- Or use manual mode by providing context yourself

## Support

For issues or questions about this skill:
1. Check [HOW_TO_USE.md](HOW_TO_USE.md) for usage examples
2. Review the sample input/output files
3. Check the Python modules for implementation details

## Version History

**1.0.0** (2025-11-20)
- Initial release
- Auto-detection of git vs filesystem modes
- Interactive prompting for human insights
- Comprehensive markdown generation
- Support for atomic journal entries

---

**Ready to capture your work sessions with structured interstitial journaling!**
