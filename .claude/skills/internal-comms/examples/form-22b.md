---
name: form-22b-report
description: Generate condensed executive summaries (Form 22-B) by reading and distilling Form 22-A reports. Use when your partner needs the TL;DR version - just the wins, the numbers, and the bottom line. Takes 30 seconds to read instead of 3 minutes.
---

# Form 22-B: Executive Digest

## Instructions

You are being asked to generate a Form 22-B report - an ultra-condensed version of Form 22-A designed for busy partners who need just the headline, the impact, and the bottom line.

Form 22-B is NOT generated from raw data. Instead, it reads the existing Form 22-A report and distills the most recent week into 4-6 lines that can be read in 30 seconds or less.

**Target audience:** Your business partner who:
- Wants to stay informed but doesn't have time for details
- Needs the "what happened" not the "how it works"
- Prefers headlines over explanations
- Will ask questions if they need more info

**Philosophy:** If they're not reading 22-A, give them something they WILL read.

## What 22-B Is

- ✅ **Ultra-condensed summary** - One paragraph, 4-6 lines max
- ✅ **Headline-focused** - Lead with the big win or milestone
- ✅ **Numbers-driven** - Quantify impact when possible
- ✅ **Bottom-line clear** - End with "what this means"

## What 22-B Is NOT

- ❌ Not a detailed feature breakdown (that's 22-A)
- ❌ Not generated from scratch (reads 22-A as source)
- ❌ Not technical (even more business-focused than 22-A)
- ❌ Not long-form (rigid 4-6 line limit)

## Workflow

### 1. Read the Source
```bash
# Read the most recent Form 22-A
cat FORM-22-A.md | head -n 50
```

### 2. Extract Key Elements

From the most recent week in 22-A, identify:

**Phase Progress:**
- Current phase and completion percentage
- Change from previous week (⬆️ indicator)
- Major milestone (if phase complete)

**Shipped Features:**
- Count of features shipped (e.g., "3 features")
- High-level category names (avoid specifics)
- Major capability unlocked

**Impact:**
- Key quantitative metrics (%, time saved, cost reduction)
- Business capabilities enabled
- User-facing improvements

**Velocity/Momentum:**
- Issues closed this week
- Sprint/phase completion status
- Notable achievements (test coverage, record weeks)

### 3. Condense Using Template

Apply the strict 4-6 line format:

```markdown
## Week of [Start Date] - [End Date], [Year]

**[BIG HEADLINE]** - [Phase status or major milestone]

**Shipped:** [Feature summary in 10 words or less]
**Impact:** [Key numbers and business value in one line]
**Velocity:** [Progress metric or momentum indicator]

**Bottom Line:** [One sentence - what this means for the business]
```

### 4. Update Documentation

Prepend to FORM-22-B.md, keeping last 8-10 weeks visible

## Formatting Rules

### Line 1: The Headline (Required)
Bold text with emoji, captures the week's theme:

**Examples:**
- `**🎊 PHASE 2 COMPLETE** - Clinical Intelligence shipped`
- `**🚀 Production Ready** - Core system delivered`
- `**📊 Record Week** - 11 features shipped`
- `**⚡ Major Milestone** - First practice deployment`

**Pattern:**
- Emoji that fits the mood (🎊 celebration, 🚀 launch, 📊 metrics, ⚡ speed)
- Bold text for major achievement
- Em-dash separator
- Brief context (5 words max)

### Line 2-5: The Facts (Required, 3-4 lines)
Use bold prefixes for quick scanning:

**Shipped:** Comma-separated feature names or category summary
- ✅ "Template system, AI engine, clinical dashboard"
- ✅ "Patient tracking and progress analytics"
- ❌ Avoid details about how features work

**Impact:** One line of quantified business value
- ✅ "60% cost reduction, 11 analysis types ready"
- ✅ "Eliminates 15-30 minutes per visit"
- ❌ Avoid vague statements like "improves workflow"

**Velocity:** Progress indicator or notable metric
- ✅ "11 issues closed (record week). TestFlight prep starting"
- ✅ "Phase 55% → 100% in one week"
- ❌ Avoid technical metrics like "code coverage"

### Line 6: The Bottom Line (Required)
One sentence that answers "So what?"

**Examples:**
- `**Bottom Line:** Both core phases complete. Production-ready system.`
- `**Bottom Line:** Halfway to launch with momentum accelerating.`
- `**Bottom Line:** First practice can start using the system next week.`

**Pattern:**
- Bold "Bottom Line:" prefix
- 1-2 short sentences max
- Future-focused or status-oriented
- Actionable implication when possible

## Translation Guide

### From 22-A to 22-B

**22-A format (detailed):**
```markdown
**Template Architecture Overhaul** 🏗️
- Doctors can now edit AI prompts without touching code
- Clean separation: markdown files for content, Swift for logic
- 28 clinical templates migrated to new system
- **Impact:** Practice managers can customize how AI writes notes
```

**22-B format (condensed):**
```markdown
**Shipped:** Template system, AI engine, clinical dashboard
```

**Translation rules:**
1. Feature names only (no bullets, no details)
2. Group related features (e.g., "Patient tracking suite")
3. Use categories when multiple features ship (e.g., "Core infrastructure")
4. Maximum 10 words for entire "Shipped" line

### Impact Condensation

**22-A format:**
```markdown
**Impact:** Practice managers can customize how AI writes notes. 
Update templates in minutes, not hours. No developer needed.
```

**22-B format:**
```markdown
**Impact:** Doctors customize AI without code. 60% cost reduction.
```

**Translation rules:**
1. Lead with numbers (percentages, time, cost)
2. One capability, one metric (pick the strongest)
3. Remove explanations (assume smart audience)
4. Maximum 15 words

### Velocity Condensation

**22-A format:**
```markdown
### 🎯 Development Velocity
- **11 issues closed this week** (highest weekly total yet)
- **100% test coverage** on new IntelligenceKit (59 tests passing)
- **Preparing for TestFlight** - QA validation starting next week
```

**22-B format:**
```markdown
**Velocity:** 11 issues closed (record week). TestFlight prep starting.
```

**Translation rules:**
1. Lead with issue count or completion percentage
2. Add context in parentheses if notable
3. Mention next milestone if imminent
4. Skip technical details (test counts, coverage)

## Examples

### Example 1: Phase Completion

**From 22-A:**
```markdown
## Week of October 14-20, 2025

**Phase 2 Progress:** 100% complete (6/6 features) ⬆️ from 33.3%

### 🎊 PHASE 2 COMPLETE - CLINICAL INTELLIGENCE SHIPPED!

**Template Architecture Overhaul** 🏗️
- Doctors can now edit AI prompts without touching code
- Clean separation: markdown files for content, Swift for logic
- 28 clinical templates migrated to new system
- **Impact:** Practice managers can customize how AI writes notes. 
  Update templates in minutes, not hours. No developer needed.

**IntelligenceKit Foundation** 🧠
- AI now knows which patient data each analysis needs
- Reduces AI processing costs by 60% (only sends relevant data)
- Fixed bug: patient names now appear in all reports
- 59 automated tests ensure quality
- **Impact:** Faster analysis, lower costs, more accurate clinical insights.

**Clinical Intelligence Dashboard** 📊
- Renamed from "View Trends" → clearer purpose
- 11 different analysis types for patient care
- Clean visual interface for selecting analyses
- **Impact:** Doctors immediately understand what each tool does.

### 📈 What This Means
- **Phase 2 is COMPLETE** - All clinical intelligence features delivered
- AI-powered analysis ready for real-world clinical use
- Architecture supports future enhancements
- System is more efficient, more accurate, and easier to maintain

### 🎯 Development Velocity
- **11 issues closed this week** (highest weekly total yet)
- **100% test coverage** on new IntelligenceKit (59 tests passing)
- **Preparing for TestFlight** - QA validation starting next week
```

**To 22-B:**
```markdown
## Week of October 14-20, 2025

**🎊 PHASE 2 COMPLETE** - Clinical Intelligence shipped

**Shipped:** Template editing system, AI analysis engine, clinical dashboard
**Impact:** Doctors customize AI without code. 60% cost reduction. 11 analysis types ready.
**Velocity:** 11 issues closed (record week). 100% test coverage. TestFlight prep starting.

**Bottom Line:** Both core phases done. Production-ready system.
```

### Example 2: Steady Progress

**From 22-A:**
```markdown
## Week of October 7-10, 2025

**Phase 1 Progress:** 55.6% complete (5/9 features) ⬆️ from 12.5%

### ✅ What We Shipped This Week

**SOAP Note Addendum System** ✨
- Doctors can now add notes to existing patient records
- Maintains legal compliance (original records stay locked)
- Full audit trail: who added what, when
- Export includes all additions for legal documentation
- **Impact:** Post-treatment observations without creating new SOAP note. 
  Saves 3-5 minutes per follow-up note.

**Patient Progress Tracking** 📊
- Track patient improvement across multiple visits
- 7 different analysis types: pain levels, movement range, flare-up patterns
- Auto-generates progress reports for patients
- Creates referral letters for specialists
- **Impact:** See if treatment is working at a glance. Adjust plans based on trends.

### 📈 What This Means
- **55% done with core features** - over halfway to production launch
- Can now manage patient records from creation → tracking → analysis → documentation
- EHR-compliant system ready for real-world use
- Only 4 features left until we can deploy to first practice
```

**To 22-B:**
```markdown
## Week of October 7-10, 2025

**📊 Major Progress** - Core features 55% complete

**Shipped:** Patient addendum system, progress tracking with 7 analysis types
**Impact:** Saves 3-5 minutes per follow-up. Treatment trends visible at a glance.
**Velocity:** Phase jumped from 12.5% to 55.6%. 4 features left until launch.

**Bottom Line:** Over halfway to production. First practice deployment in sight.
```

### Example 3: Foundation Work

**From 22-A:**
```markdown
## Week of September 30 - October 6, 2025

**Phase 1 Progress:** 33.3% complete (3/9 features)

### ✅ What We Shipped

**One-Tap Follow-Up Generator** 📋
- Convert SOAP notes into follow-up visit templates
- Generate patient-friendly summaries for phone calls
- Create referral letters automatically
- Extract billing summaries
- **Impact:** 15-30 minutes saved per visit with one-tap document generation

**ContentKit Infrastructure** 🏗️
- Built template library system for rapid feature development
- Enables adding new AI-powered features quickly
- **Impact:** Foundation for all future intelligent features

### 📈 What This Means
- Core infrastructure complete - can now build features rapidly
- First major productivity feature shipped (follow-up generator)
- 1/3 of Phase 1 complete
```

**To 22-B:**
```markdown
## Week of September 30 - October 6, 2025

**🏗️ Foundation Complete** - Core infrastructure and first major feature

**Shipped:** One-tap follow-up generator, ContentKit template system
**Impact:** 15-30 minutes saved per visit. Rapid feature development enabled.
**Velocity:** Phase 1 at 33%. Infrastructure ready for acceleration.

**Bottom Line:** Platform ready to build on. Productivity features ramping up.
```

## Special Cases

### Multiple Weeks Without Updates
If no 22-A entry exists for current week, use most recent entry:

```markdown
## Week of [Current Week Dates]

**📝 No Updates This Week** - Continuing previous work

**Status:** Phase [X] at [Y]% complete ([Z] features remaining)
**Focus:** [Brief description from last 22-A entry]

**Bottom Line:** [Expected completion or next milestone]
```

### Phase Transitions
When starting a new phase:

```markdown
## Week of [Dates]

**🚀 NEW PHASE** - Phase [X] kickoff

**Completed:** Phase [X-1] delivered with [Y] features
**Starting:** Phase [X] - [brief phase description]
**Goal:** [Key capability or milestone this phase]

**Bottom Line:** [Previous phase] complete. Now building [new focus area].
```

### Launch Weeks
When shipping to users:

```markdown
## Week of [Dates]

**🎉 LAUNCHED** - Live with first practice

**Deployed:** [System/feature name] to [customer name]
**Includes:** [X] features, [Y] capabilities
**Next:** [Feedback period, next deployment, etc.]

**Bottom Line:** Real users, real data. Validation phase begins.
```

## Output

When generating a Form 22-B report:

1. Read FORM-22-A.md
2. Extract most recent week
3. Apply condensation rules
4. Format in 4-6 line structure
5. Save to FORM-22-B.md (prepending to existing content)
6. Provide brief confirmation:

```
Generated Form 22-B for Week of [dates]

TL;DR:
- [Headline achievement]
- [Key number or metric]
- [Bottom line]

Added to: FORM-22-B.md
```

## Quality Checklist

Before saving, verify:

- ✅ **Total length:** 4-6 lines (not counting date header)
- ✅ **Headline:** Bold, emoji, captures the win
- ✅ **Shipped line:** Feature names only, no details, <10 words
- ✅ **Impact line:** Has numbers, <15 words
- ✅ **Velocity line:** Progress metric included
- ✅ **Bottom line:** Future-focused, actionable
- ✅ **Readability:** Takes 30 seconds or less to read
- ✅ **No jargon:** Business language only
- ✅ **Consistent format:** Matches previous 22-B entries

## Tips for Success

### Keep It Ruthlessly Short
- If you're explaining, you're losing
- Numbers > words
- Feature names > feature descriptions
- "What" > "How"

### Lead With Wins
- Celebrate completions (🎊, 🎉)
- Emphasize progress (📊, ⚡)
- Show momentum (🚀, ⬆️)

### Make It Scannable
- Bold prefixes for every line
- Parallel structure week-over-week
- Consistent emoji usage
- White space matters

### Remember the Audience
Your partner wants to know:
1. Are we making progress? (Velocity)
2. What can we do now? (Shipped)
3. What's the business value? (Impact)
4. What does this mean? (Bottom Line)

Answer those four questions in 30 seconds.

## Maintenance

### Weekly Cadence
Generate 22-B immediately after 22-A is complete:
1. Run Form 22-A generation
2. Run Form 22-B condensation
3. Send 22-B to partner (22-A available if needed)

### Archival
Keep last 8-10 weeks in FORM-22-B.md for trend visibility

### Evolution
If partner still doesn't read 22-B, consider:
- Form 22-C: One-line ticker format
- Slack/email summary instead of markdown
- Weekly verbal check-in with 22-B as reference

## Related Documentation

- **Source Reports:** FORM-22-A.md (detailed weekly reports)
- **Project Status:** `docs/plans/dev-plan.md` (technical roadmap)
- **For Devs:** 22-A is for you. 22-B is for business partners.

---

**Remember:** Form 22-B exists because Form 22-A wasn't getting read. If 22-B doesn't get read either, don't add more detail - go shorter. Communication is about what they absorb, not what you write.

**Last Updated:** October 17, 2025
