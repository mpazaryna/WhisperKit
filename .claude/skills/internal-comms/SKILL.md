---
name: internal-comms
description: A set of resources to help me write all kinds of internal communications, using the formats that my company likes to use. Claude should use this skill whenever asked to write some sort of internal communications (devlog reports, leadership updates, 22A updates, 22B consended, company newsletters, FAQs, incident reports, project updates, etc.).
license: Complete terms in LICENSE.txt
---

## When to use this skill
To write internal communications, use this skill for:
- 22A full updates (Progress, Plans, Problems)
- 22B condensed (Progress, Plans, Problems)
- devlog updates
- Status reports
- Leadership updates
- Project updates
- Incident reports

## How to use this skill

To write any internal communication:

1. **Identify the communication type** from the request
2. **Load the appropriate guideline file** from the `examples/` directory:
    - `examples/form-22a.md` - For Progress/Plans/Problems team updates
    - `examples/devlog.md` - For devlogs
    - `examples/form-22b.md` - Baby version of the 22A
    - `examples/general-comms.md` - For anything else that doesn't explicitly match one of the above
3. **Follow the specific instructions** in that file for formatting, tone, and content gathering

If the communication type doesn't match any existing guideline, ask for clarification or more context about the desired format.

## Keywords
22A updates, 22B variant, devlogs, company newsletter, company comms, weekly update, faqs, common questions, updates, internal comms