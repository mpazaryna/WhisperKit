---
description: Run diagnostics for common issues
tags: [debug, troubleshooting, diagnostics]
---

# Diagnose PAB Issues

Run common diagnostic commands to troubleshoot PAB app issues.

## Check MLX Model Cache

```bash
echo "=== MLX Model Cache ===" && ls -lh ~/Library/Containers/paz.pab/Data/Library/Caches/MLXModels/ 2>/dev/null || echo "Cache directory not found (models not loaded yet)"
```

**Expected:** Should see 3 model files (ICD-10, CPT, Vertebral) with `.safetensors` or `.npz` extensions and matching `_metadata.json` files.

## Check MLX Training Logs

```bash
echo "=== Recent MLX Training Logs ===" && ls -lt ../mlx/logs/ | head -10
```

**Expected:** Recent training logs if models were recently updated.

## Verify Xcode Project Structure

```bash
cd pab && find . -name "*.swift" -path "*/Core/Services/MLX/*" -type f
```

**Expected:** Should find MLX processor files:
- `ICD10MLXProcessor.swift`
- `CPTCodeMLXProcessor.swift`
- `VertebralLevelMLXProcessor.swift`

## Check for AttributeGraph Errors

```bash
echo "Build and check console for 'AttributeGraph' warnings..."
echo "Common patterns to look for:"
echo "  - 'AttributeGraph: cycle detected'"
echo "  - 'publishing changes from within view updates'"
echo "  - NSSplitView constraint conflicts"
```

**Action:** Build app and monitor Console.app filtering for "PAB" or "AttributeGraph"

## Check ContentKit Template Bundle

```bash
cd pab && find . -name "*.md" -path "*/ContentKit/Templates/Prompts/*" | wc -l
```

**Expected:** Should see 28 markdown template files.

## Common Fixes

### Clear MLX Model Cache
```bash
rm -rf ~/Library/Containers/paz.pab/Data/Library/Caches/MLXModels/
```
Then restart app to re-download models.

### Reset Build Folder
```bash
cd pab && rm -rf build/ && xcodebuild clean -project pab.xcodeproj -scheme pab
```

### Check Git Status
```bash
git status
```

### View Recent Commits
```bash
git log --oneline -10
```

## Related Documentation

- **AttributeGraph issues:** `docs/architecture/core-swiftui-config.md`
- **MLX debugging:** `../mlx/.claude/README.md`
- **Native app architecture:** `pab/CLAUDE.md`

**Related Commands:**
- `/test` - Run test suite
- `/mlx-test` - Test MLX processors specifically
- `/build` - Try a fresh build
