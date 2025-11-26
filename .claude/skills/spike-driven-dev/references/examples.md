# Spike Ticket Examples

## Example 1: Exercise Library Integration

**Context**: Integrating 649 exercises across 24 rehabilitation protocols into app's Reference Library.

**Initial Plan (Issue #66)**: 
- 6-phase implementation
- Build all models, views, and navigation
- 4-5 day estimate

**Spike Decision**:
Created Issue #67 - TDD Spike to validate ONE exercise detail view first.

**Why Spike Was Needed**:
- ✅ First time using SwiftData with nested Codable structs
- ✅ Untested JSON structure from external source (Google Docs conversion)
- ✅ New platform configuration pattern
- ✅ 649 exercises depend on getting the first one right

**Spike Scope (4-6 hours)**:
1. Create Exercise model with nested instruction steps
2. Test JSON decoding with real exercise file
3. Build ONE detail view
4. Test platform config pattern
5. Verify on macOS + iOS

**What It Proved**:
- ✅ SwiftData can handle nested Codable with `Data` encoding
- ✅ JSON structure is valid and decodes correctly
- ✅ Local config pattern works for this use case
- ✅ Ready to build remaining 648 exercises using same pattern

**Time Saved**: 2+ days by catching architecture issues early

---

## Example 2: AttributeGraph Crisis (Historical)

**Context**: Building NavigationSplitView with shared configuration patterns.

**What Happened**:
- Built multiple views using shared config pattern
- Discovered AttributeGraph cycles after async operations
- Complete UI freezes
- Had to refactor everything

**What Should Have Happened**:
- Spike ticket: Test config pattern in ONE NavigationSplitView first
- Discover issue in 2 hours
- Switch to local config pattern
- Build remaining views with correct pattern

**Lesson**: Architecture patterns should always be spiked before scaling.

---

## Example 3: MLX Sigmoid/Softmax Bug (Historical)

**Context**: Building MLX processor pipeline for predictions.

**What Happened**:
- Built entire MLX processor pipeline
- Used softmax instead of sigmoid
- Zero predictions because softmax normalized to sum=1
- Critical bug rendered all models non-functional

**What Should Have Happened**:
- Spike ticket: Test ONE classifier with real data
- Make prediction, check output
- Discover math is wrong immediately
- Fix before building pipeline

**Lesson**: Mathematical assumptions should be validated with real data in isolation.

---

## Example 4: API Integration Spike

**Context**: Integrating with unfamiliar third-party API.

**Spike Scope (6 hours)**:
1. Write test for API response parsing
2. Make ONE real API call
3. Parse response into model
4. Handle authentication
5. Test rate limiting behavior

**What It Proved**:
- ✅ API response structure matches documentation
- ✅ Authentication flow works
- ✅ Rate limiting requires exponential backoff
- ✅ Some optional fields are actually required

**Adjustments Made**:
- Added rate limiter class to main ticket
- Updated model to handle "optional" fields as required
- Documented authentication flow for team

---

## Example 5: Database Migration Spike

**Context**: Migrating from Core Data to SwiftData.

**Spike Scope (8 hours)**:
1. Create SwiftData model for ONE entity
2. Write migration logic
3. Test with production data snapshot
4. Verify queries work
5. Check relationships

**What It Discovered**:
- ❌ SwiftData doesn't support custom transformers
- ✅ Can use `@Transient` + computed properties instead
- ✅ Migration logic works but needs data validation step
- ✅ Query performance acceptable

**Decision**:
- Adjusted architecture to use computed properties
- Added validation step to migration
- Proceeded with remaining entities using proven pattern

---

## Anti-Pattern Examples

### Bad Spike 1: Too Broad
**Title**: "Explore SwiftUI animation options"
**Problem**: No clear success criteria, too many options
**Fix**: "Implement spring animation for ONE button, measure performance"

### Bad Spike 2: No Tests
**Title**: "Try building the login flow"
**Problem**: No validation, just exploration
**Fix**: "Write tests for authentication model, implement ONE endpoint"

### Bad Spike 3: Mock Data Only
**Title**: "Test JSON parsing with sample data"
**Problem**: Doesn't catch real-world issues
**Fix**: "Test JSON parsing with actual API response from staging environment"

### Bad Spike 4: Open-Ended
**Title**: "Research best practices for state management"
**Problem**: No concrete implementation or validation
**Fix**: "Implement @Observable pattern in ONE view, compare to @StateObject pattern"

---

## Template for Creating Spike Tickets

```markdown
## Issue #X: TDD Spike - [Feature Name]

**Context**: [Why this spike is needed]

**Scope** (4-8 hours):
- [ ] Write tests FIRST
- [ ] Implement minimal code
- [ ] Test with real data
- [ ] Verify on target platforms
- [ ] Document findings

**What This Will Prove**:
- [ ] Technical feasibility
- [ ] Data structure validity
- [ ] Architecture pattern viability
- [ ] Ready for main implementation

**Success Criteria**:
- [ ] All tests pass
- [ ] Real data loads correctly
- [ ] Pattern documented
- [ ] No architectural blockers

**Next Steps**:
- If successful → Proceed with Issue #Y (main feature)
- If issues found → Document, adjust approach, create follow-up spike if needed
```
