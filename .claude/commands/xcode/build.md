---
description: Build PAB app in Debug configuration
tags: [build, xcode, development]
---

# Build PAB (Debug)

Build the Practice Assistant for Bodywork app in Debug configuration.

```bash
cd pab && xcodebuild -project pab.xcodeproj -scheme pab -configuration Debug build
```

**Output:** Check for build errors and warnings. Successful builds will show:
```
** BUILD SUCCEEDED **
```

**Next Steps:**
- Run the app from Xcode
- Or use `/install` for a Release build that installs to Applications

**Related:**
- `/test` - Run test suites
- `/install` - Build and install Release version
