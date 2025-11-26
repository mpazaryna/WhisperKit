# How to Use the Spike-Driven Development Skill

## Quick Start

This skill guides Claude through spike-driven development methodology - building minimal proofs-of-concept before full implementation.

### When to Invoke This Skill

Ask Claude to use spike-driven development when:

```
"Help me create a spike ticket for testing the SwiftData model with real JSON"
"I need to validate this API integration approach before building the full feature"
"Let's create a spike to test if this architecture pattern will work"
```

Claude will automatically use this skill when you:
- Start new features with unfamiliar patterns
- Test architecture assumptions
- Integrate unfamiliar APIs or data sources
- Need to validate technical feasibility

## What This Skill Does

The spike-driven-dev skill helps you:

1. **Identify when you need a spike** - Decision criteria and risk analysis
2. **Define spike scope** - Keep it minimal, time-boxed, and test-driven
3. **Execute with TDD** - Write tests first, implement minimal code, validate with real data
4. **Evaluate outcomes** - Document findings and apply learnings
5. **Apply to main feature** - Replicate the proven pattern with confidence

## Usage Examples

### Example 1: New SwiftData Model

```
User: I need to build a complex SwiftData model with nested Codable types

Claude: Let's create a spike ticket to validate this approach first.

Step 1: Define minimal scope
- ONE model with basic nesting
- Write tests for encoding/decoding
- Test with real JSON data
- Time-box: 4 hours

Step 2: TDD Flow
1. Write tests first (fail)
2. Implement minimum code (pass)
3. Test with production JSON
4. Document the pattern

Step 3: Apply learnings to full feature
[Provides validated pattern for all models]
```

### Example 2: API Integration

```
User: I'm integrating with an external API I haven't used before

Claude: This is a perfect case for a spike. Let's validate the integration pattern with ONE endpoint first.

Spike Scope:
- ONE API endpoint with authentication
- Test error handling
- Verify response parsing
- Platform compatibility check
- Time-box: 6 hours

[Guides through TDD process with real API calls]
```

### Example 3: Architecture Decision

```
User: Should I use Coordinator pattern or SwiftUI navigation for this app?

Claude: Let's create a spike to test both approaches with ONE view.

Spike A: Coordinator Pattern
- Build ONE coordinator
- ONE view transition
- Test state management

Spike B: SwiftUI Navigation
- ONE NavigationStack
- ONE navigation path
- Test state preservation

[Provides comparison and recommendation based on spike results]
```

## Reference Files

The skill includes detailed reference documentation:

- **decision-criteria.md** - When to create spike tickets, risk analysis, decision trees
- **spike-patterns.md** - Good vs bad spike characteristics, detailed TDD flow patterns
- **examples.md** - Real-world examples from actual projects

Claude will automatically load these references as needed during the spike workflow.

## Best Practices

### Do's ✅

- Time-box spikes to 4-8 hours maximum
- Write tests FIRST, always
- Use real, production-like data
- Test on all target platforms
- Document findings thoroughly
- Keep scope to ONE component

### Don'ts ❌

- Don't skip spikes for unfamiliar territory
- Don't use only mock data
- Don't let scope creep beyond one component
- Don't fear throwing away spike code
- Don't skip documentation of findings
- Don't start without clear success criteria

## Expected Output

When you use this skill, Claude will provide:

1. **Spike ticket definition**
   - Clear scope and time-box
   - Success criteria checklist
   - TDD test outline

2. **Guided implementation**
   - Test-first development flow
   - Minimal code to validate approach
   - Real data validation steps

3. **Outcome evaluation**
   - What worked / what didn't
   - Documented pattern for replication
   - Updated estimates for main ticket

4. **Replication guidance**
   - How to apply the pattern
   - What to watch out for
   - Time savings from validated approach

## Integration with Your Workflow

### With Project Management

```
Main Ticket: "Build exercise library with 50 exercises"
↓
Spike Ticket: "Validate Exercise model with ONE exercise + real data" (6 hours)
↓
Main Ticket: Proceed with confidence using validated pattern
```

### With TDD Workflow

The skill enforces Test-Driven Development:
1. Write failing tests
2. Implement minimum code
3. Tests pass
4. Validate with real data
5. Document pattern

### With Agile Development

- Spikes reduce risk before sprint commitment
- Validated patterns increase velocity
- Better estimates from proven approaches
- Faster delivery of main features

## Tips for Maximum Value

1. **Always time-box** - Spikes prove feasibility, not perfection
2. **Real data immediately** - Don't waste time on mocks
3. **Platform test early** - macOS + iOS validation catches issues
4. **Document ruthlessly** - The pattern must be replicable
5. **One component only** - Resist the urge to build more

## Common Questions

**Q: How long should a spike take?**
A: 4-8 hours maximum. If longer, scope is too large.

**Q: Can I use the spike code in production?**
A: Sometimes yes, but spikes are proofs, not production code. Be willing to throw away and rebuild properly.

**Q: What if the spike fails?**
A: That's a success! Better to discover issues in 6 hours than 6 days. Create a new spike with a different approach.

**Q: Do I always need tests?**
A: Yes. Tests are the validation mechanism. No tests = no proof.

**Q: Can I skip the spike if I'm confident?**
A: Only if you've built the exact thing before with the exact same patterns. When in doubt, spike it out.

## Related Skills

- **code-reviewer** - Use after spike to validate quality
- **commit-helper** - Generate good commit messages for spike work
- **learn-project** - Understand new project before spiking

---

Generated by Claude Code Skills Factory
