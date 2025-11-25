---
description: Run PAB test suite
tags: [test, xcode, qa]
---

# Run PAB Tests

Run all tests in the PAB test suite.

```bash
cd pab && xcodebuild test -project pab.xcodeproj -scheme pab
```

**What gets tested:**
- Unit tests in `pabTests/`
- UI tests in `pabUITests/`
- MLX integration tests

**Test-specific commands:**
- MLX tests only: `/mlx-test`
- Specific test class: Use `-only-testing:pabTests/ClassName`

**Interpreting Results:**
- ✅ `Test Suite 'All tests' passed` - All good
- ❌ Individual test failures will show file/line numbers
- Check console output for detailed failure messages

**Related:**
- `/mlx-test` - Run only MLX processor tests
- `/build` - Build without running tests
