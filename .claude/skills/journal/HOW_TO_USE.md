# How to Use the Journal Skill

Run the journal skill to capture your work session at natural breakpoints throughout the day.

## Example Invocations

**Example 1: After completing a feature**
```
Run the journal skill to capture this work session
```

**Example 2: At the end of a work block**
```
I just finished working on the authentication module. Run the journal skill.
```

**Example 3: After making a key decision**
```
We just decided on the database architecture. Help me journal this decision.
```

**Example 4: Mid-day checkpoint**
```
Let me capture what I've been working on this morning with the journal skill
```

## What Happens

The skill will:

1. **Auto-detect your environment**
   - Check if you're in a git repository
   - Look for recent commits (last 2 hours)
   - Or scan for recently modified files

2. **Show you what changed**
   - Git mode: Commits, changed files, stats
   - Filesystem mode: Modified files grouped by type
   - Manual mode: Ask you to describe changes

3. **Ask you questions** (interactive)
   - What would you title this session?
   - What problem were you solving?
   - What approach did you take?
   - What decisions did you make?
   - What was difficult or surprising?
   - What did you learn?
   - What's next?

4. **Generate journal entry**
   - Comprehensive markdown document
   - Saved to `docs/journal/YYYY-MM-DD-HHMM-slug.md`
   - Self-contained with all context

## What to Provide

**Required (you'll be prompted):**
- Title for this work session
- Summary (2-3 sentences)
- What problem you were solving
- What approach you took
- What you learned
- What's next

**Optional (you'll be prompted):**
- Key decisions made
- Alternatives considered
- Challenges or surprises
- Open questions

## What You'll Get

A comprehensive journal entry in `docs/journal/` with:

- **Executive Summary**: Quick overview
- **What Changed**: Automatic context from git or filesystem
- **The Problem**: What you were solving
- **Approach Taken**: How you solved it
- **Decisions Made**: Choices and rationale
- **Alternatives Considered**: Paths not taken
- **Challenges & Surprises**: What was hard
- **Lessons Learned**: Insights and takeaways
- **What's Next**: Immediate next steps
- **Open Questions**: Uncertainties to resolve

## Best Practices

1. **Capture frequently**: Run after 1-2 hours of focused work
2. **Multiple entries per day**: Create separate entries for different work streams
3. **Be specific**: Include concrete details, not generalizations
4. **Document alternatives**: Future you will want to know what you considered
5. **Note surprises**: Capture what was different than expected
6. **Self-contained**: Include all necessary context in the entry

## Works For

- **Developers**: Capture coding sessions with git integration
- **Business Analysts**: Document requirements sessions with file tracking
- **Technical Writers**: Track documentation work
- **Data Analysts**: Journal analysis sessions
- **Researchers**: Capture investigation and findings
- **Anyone doing knowledge work**: Universal application

## File Location

All journal entries are saved to:
```
docs/journal/YYYY-MM-DD-HHMM-descriptive-slug.md
```

Examples:
- `docs/journal/2025-11-20-1423-agent-composition-system.md`
- `docs/journal/2025-11-20-1610-storage-decision-analysis.md`
- `docs/journal/2025-11-21-0930-requirements-gathering-session.md`

This allows multiple atomic entries per day, each capturing a specific moment in your work.
