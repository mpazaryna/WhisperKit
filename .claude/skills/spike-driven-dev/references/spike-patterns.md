# Spike Ticket Patterns

## Good Spike Characteristics

✅ **Time-boxed**: 4-8 hours (single day maximum)
✅ **Scope-limited**: ONE file, ONE UI component, ONE feature
✅ **Test-driven**: Write tests FIRST, not after
✅ **Real data**: Use production-like data, not mocks
✅ **Platform-tested**: Verify on all target platforms (macOS + iOS)
✅ **Disposable**: OK to throw away if approach doesn't work
✅ **Proof-oriented**: Proves feasibility, not perfection

## Bad Spike Characteristics

❌ **Open-ended**: "Explore options" without clear success criteria
❌ **Too broad**: Multiple components or features
❌ **No tests**: Code-first without validation
❌ **Mock data only**: Doesn't catch real-world issues
❌ **Single platform**: Assumes it'll work everywhere
❌ **Production-bound**: Fear of throwing away the code
❌ **Perfectionist**: Trying to build production-ready code

## Spike Outcomes

### Outcome 1: Success (Most Common)
- Tests pass with real data
- Pattern proven viable
- Architecture validated
- **Action**: Close spike, proceed with main ticket using proven pattern

### Outcome 2: Partial Success
- Tests pass but pattern needs adjustment
- Approach works but inefficient
- Edge cases discovered
- **Action**: Document findings, adjust main ticket approach, create follow-up spike if needed

### Outcome 3: Failure (Rare but Valuable)
- Tests fail consistently
- Approach fundamentally flawed
- Technical limitation discovered
- **Action**: Research alternatives, create new spike with different approach

**All outcomes are wins** - better to fail fast on Day 1 than Day 5.

## The TDD Flow for Spikes

### Step 1: Write Tests FIRST (1 hour)
```
- Define success criteria in test form
- Test model creation
- Test JSON decoding with real data
- Test edge cases
- Run tests → ❌ FAIL (code doesn't exist yet)
```

### Step 2: Create Minimal Implementation (1-2 hours)
```
- Write minimum code to make tests pass
- Focus on architecture, not features
- Don't add extra functionality
- Run tests → ✅ PASS
```

### Step 3: Test with Real Data (1 hour)
```
- Load actual production/external data
- Test all edge cases found in real data
- Verify platform compatibility
- Document any data issues discovered
```

### Step 4: Refine and Document (1 hour)
```
- Refactor for clarity (tests still pass)
- Document any adjustments needed for main ticket
- Note any risks or edge cases
- Provide pattern for replication
```

## Spike Success Criteria Template

Use this checklist for every spike:

**Tests**:
- [ ] Model/component tests pass
- [ ] Real data loads without errors
- [ ] Platform compatibility verified (macOS + iOS)
- [ ] Edge cases handled

**What This Proves**:
- [ ] Architecture design is correct
- [ ] Data structure is valid
- [ ] Pattern works on target platforms
- [ ] Ready to build main feature

**Documentation**:
- [ ] Pattern documented for replication
- [ ] Edge cases noted
- [ ] Any adjustments needed documented
- [ ] Effort estimate validated/adjusted
