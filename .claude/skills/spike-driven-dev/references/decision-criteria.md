# When to Create a Spike Ticket

## Always Create a Spike When

- ✅ Using a new architecture pattern for the first time
- ✅ Integrating with unfamiliar APIs or frameworks
- ✅ Making assumptions about data structures (e.g., will this JSON decode properly?)
- ✅ Building something you've never built before
- ✅ The failure cost is high (would require complete redesign)
- ✅ You feel uncertain about technical feasibility
- ✅ Multiple approaches seem equally valid
- ✅ The main ticket has >10 subtasks
- ✅ You're about to say "we'll figure it out as we go"

## Never Skip a Spike When

- ✅ Testing unfamiliar model designs (e.g., SwiftData with nested Codable structs)
- ✅ Validating JSON structure from external sources
- ✅ Testing platform configuration patterns (macOS + iOS compatibility)
- ✅ Verifying query performance assumptions
- ✅ Integrating with third-party libraries for the first time

## The Cost-Benefit Analysis

### Scenario: Skip the Spike

**Week 1**: Build models and views based on assumptions
**Week 2**: Discover architecture doesn't work, requires redesign
**Week 3**: Rebuild everything with new approach
**Week 4**: Still debugging edge cases

**Total**: 4+ weeks, high stress, fragile code

### Scenario: Start with Spike

**Day 1**: TDD spike discovers issues in 4-6 hours, adjust design
**Days 2-5**: Build full feature using proven pattern

**Total**: 5 days, low stress, high confidence

**The spike saves 2+ weeks and eliminates architectural risk.**

## Red Flags That Demand a Spike

1. **"This should work..."** - Assumptions about technical feasibility
2. **"We'll deal with that when we get there"** - Deferred architecture decisions
3. **"It's probably fine"** - Unvalidated data structure assumptions
4. **"How hard could it be?"** - Unfamiliar territory
5. **"Just start coding"** - No validation plan

## Questions to Ask

Before starting any complex feature:

1. **Have I built this exact thing before?** → No = Spike needed
2. **Am I making assumptions about the data/API?** → Yes = Spike needed
3. **Could this fail in a way that breaks everything?** → Yes = Spike needed
4. **Would failure require redesigning multiple components?** → Yes = Spike needed
5. **Is there a pattern I can test in isolation first?** → Yes = Spike opportunity
