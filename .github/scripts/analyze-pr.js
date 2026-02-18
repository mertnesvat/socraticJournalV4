// PR Analyzer - Comprehensive PR quality analysis for Swift/TypeScript projects
// Evaluates complexity, error-proneness, and architecture compliance

module.exports = async ({ github, context, core }) => {
  const prNumber = context.payload.pull_request.number;
  const owner = context.repo.owner;
  const repo = context.repo.repo;

  // Fetch PR diff and file list
  const { data: files } = await github.rest.pulls.listFiles({
    owner,
    repo,
    pull_number: prNumber,
    per_page: 100,
  });

  const { data: pr } = await github.rest.pulls.get({
    owner,
    repo,
    pull_number: prNumber,
  });

  const totalAdditions = pr.additions;
  const totalDeletions = pr.deletions;
  const totalChangedFiles = pr.changed_files;

  // ── Analysis Results ────────────────────────────────────────────────
  const issues = [];
  let complexityDeductions = 0;
  let errorPronenessDeductions = 0;

  // ── Per-file analysis ───────────────────────────────────────────────
  const swiftFiles = [];
  const tsFiles = [];
  const testFiles = [];
  const sourceFiles = [];

  for (const file of files) {
    if (file.status === "removed") continue;

    const ext = file.filename.split(".").pop();
    const isTest =
      file.filename.includes("Tests/") ||
      file.filename.includes(".test.") ||
      file.filename.includes("Test.swift") ||
      file.filename.includes("Tests.swift");

    if (isTest) testFiles.push(file);
    else sourceFiles.push(file);

    if (ext === "swift") swiftFiles.push(file);
    if (ext === "ts" || ext === "js") tsFiles.push(file);

    const patch = file.patch || "";
    const addedLines = patch
      .split("\n")
      .filter((l) => l.startsWith("+") && !l.startsWith("+++"));

    // ── Swift-specific checks ───────────────────────────────────────
    if (ext === "swift") {
      analyzeSwift(file, addedLines, issues);
    }

    // ── TypeScript-specific checks ──────────────────────────────────
    if (ext === "ts" || ext === "js") {
      analyzeTypeScript(file, addedLines, issues);
    }

    // ── General checks (all file types) ─────────────────────────────
    analyzeGeneral(file, addedLines, issues);
  }

  // ── Architecture compliance ─────────────────────────────────────────
  analyzeArchitecture(files, issues);

  // ── Test coverage signal ────────────────────────────────────────────
  const newSourceFiles = sourceFiles.filter((f) => f.status === "added");
  const newTestFiles = testFiles.filter((f) => f.status === "added");
  if (newSourceFiles.length > 0 && newTestFiles.length === 0) {
    issues.push({
      category: "test-coverage",
      severity: "warning",
      message: `${newSourceFiles.length} new source file(s) added without any new test files`,
      file: "—",
    });
  }

  // ── Calculate scores ────────────────────────────────────────────────
  const scores = calculateScores(
    issues,
    totalAdditions,
    totalDeletions,
    totalChangedFiles,
    files
  );

  // ── Build and post comment ──────────────────────────────────────────
  const comment = buildComment(
    scores,
    issues,
    totalAdditions,
    totalDeletions,
    totalChangedFiles,
    files,
    testFiles,
    sourceFiles,
    pr
  );

  // Find and update existing comment, or create new one
  const { data: existingComments } = await github.rest.issues.listComments({
    owner,
    repo,
    issue_number: prNumber,
  });

  const botComment = existingComments.find(
    (c) =>
      c.user.type === "Bot" && c.body.includes("<!-- pr-analyzer-comment -->")
  );

  if (botComment) {
    await github.rest.issues.updateComment({
      owner,
      repo,
      comment_id: botComment.id,
      body: comment,
    });
  } else {
    await github.rest.issues.createComment({
      owner,
      repo,
      issue_number: prNumber,
      body: comment,
    });
  }

  core.info(`PR Analysis complete. Overall score: ${scores.overall}/100`);
};

// ── Swift Analysis ──────────────────────────────────────────────────────
function analyzeSwift(file, addedLines, issues) {
  let forceUnwrapCount = 0;
  let forceCastCount = 0;
  let forceTryCount = 0;
  let implicitUnwrapCount = 0;
  let retainCycleRisk = 0;
  let largeFunctionLines = 0;
  let currentFunctionLines = 0;
  let inFunction = false;
  let nestingDepth = 0;
  let maxNesting = 0;

  for (const line of addedLines) {
    const code = line.substring(1).trim();

    // Skip comments and strings
    if (code.startsWith("//") || code.startsWith("*") || code.startsWith("/*"))
      continue;

    // Force unwraps (exclude IBOutlets, protocol declarations, and implicitly unwrapped optionals in declarations)
    const forceUnwrapMatches = code.match(
      /(?<!\?\s*)(?<!\/\/)(?<!:\s*)(?<!->)\b\w+!/g
    );
    if (forceUnwrapMatches) {
      // More precise: look for pattern like variable! or expression!
      const preciseForceUnwraps = code.match(
        /\w+\s*!\s*(?:\.|\)|\]|,|\s|$)/g
      );
      if (preciseForceUnwraps && !code.includes("@IBOutlet") && !code.includes("!= ") && !code.includes("!==")) {
        forceUnwrapCount += preciseForceUnwraps.length;
      }
    }

    // Force casts
    if (/\bas!\s/.test(code)) {
      forceCastCount++;
    }

    // Force try
    if (/\btry!\s/.test(code)) {
      forceTryCount++;
    }

    // Implicitly unwrapped optionals in declarations
    if (/:\s*\w+\s*!/.test(code) && (code.includes("var ") || code.includes("let "))) {
      if (!code.includes("@IBOutlet")) {
        implicitUnwrapCount++;
      }
    }

    // Retain cycle risk: closures without [weak self] or [unowned self]
    if (/\{\s*(\[(?!weak|unowned)|\()/.test(code) && code.includes("self.")) {
      retainCycleRisk++;
    }
    if (
      code.includes("self.") &&
      !code.includes("[weak self]") &&
      !code.includes("[unowned self]") &&
      (code.includes("{ [") || code.includes("{ ("))
    ) {
      retainCycleRisk++;
    }

    // Track function length
    if (/\bfunc\s/.test(code)) {
      if (inFunction && currentFunctionLines > 50) {
        largeFunctionLines++;
      }
      inFunction = true;
      currentFunctionLines = 0;
    }
    if (inFunction) currentFunctionLines++;

    // Track nesting depth
    const opens = (code.match(/\{/g) || []).length;
    const closes = (code.match(/\}/g) || []).length;
    nestingDepth += opens - closes;
    if (nestingDepth > maxNesting) maxNesting = nestingDepth;
  }

  if (inFunction && currentFunctionLines > 50) {
    largeFunctionLines++;
  }

  if (forceUnwrapCount > 0)
    issues.push({
      category: "swift-safety",
      severity: forceUnwrapCount > 5 ? "error" : "warning",
      message: `${forceUnwrapCount} force unwrap(s) (\`!\`) detected`,
      file: file.filename,
    });
  if (forceCastCount > 0)
    issues.push({
      category: "swift-safety",
      severity: "warning",
      message: `${forceCastCount} force cast(s) (\`as!\`) detected`,
      file: file.filename,
    });
  if (forceTryCount > 0)
    issues.push({
      category: "swift-safety",
      severity: "warning",
      message: `${forceTryCount} force try (\`try!\`) detected`,
      file: file.filename,
    });
  if (implicitUnwrapCount > 0)
    issues.push({
      category: "swift-safety",
      severity: "info",
      message: `${implicitUnwrapCount} implicitly unwrapped optional(s) in declarations`,
      file: file.filename,
    });
  if (retainCycleRisk > 0)
    issues.push({
      category: "swift-memory",
      severity: "warning",
      message: `${retainCycleRisk} potential retain cycle risk(s) — closures referencing \`self\` without \`[weak self]\``,
      file: file.filename,
    });
  if (largeFunctionLines > 0)
    issues.push({
      category: "complexity",
      severity: "info",
      message: `${largeFunctionLines} function(s) exceeding 50 lines`,
      file: file.filename,
    });
  if (maxNesting > 4)
    issues.push({
      category: "complexity",
      severity: "warning",
      message: `Deep nesting detected (max depth: ${maxNesting})`,
      file: file.filename,
    });
}

// ── TypeScript Analysis ─────────────────────────────────────────────────
function analyzeTypeScript(file, addedLines, issues) {
  let anyTypeCount = 0;
  let consoleLogCount = 0;
  let missingErrorHandling = 0;
  let todoCount = 0;

  for (const line of addedLines) {
    const code = line.substring(1).trim();
    if (code.startsWith("//") || code.startsWith("*")) continue;

    // any type usage
    if (/:\s*any\b/.test(code) || /as\s+any\b/.test(code)) {
      anyTypeCount++;
    }

    // console.log in non-test files
    if (/\bconsole\.(log|debug|info)\b/.test(code)) {
      if (!file.filename.includes(".test.") && !file.filename.includes("spec.")) {
        consoleLogCount++;
      }
    }

    // Async functions without try-catch
    if (/\bawait\s/.test(code) && !code.includes("try") && !code.includes("catch")) {
      // This is a heuristic — await without nearby try/catch
      missingErrorHandling++;
    }

    if (/\b(TODO|FIXME|HACK|XXX)\b/.test(code)) {
      todoCount++;
    }
  }

  if (anyTypeCount > 0)
    issues.push({
      category: "ts-safety",
      severity: anyTypeCount > 3 ? "warning" : "info",
      message: `${anyTypeCount} \`any\` type usage(s) — reduces type safety`,
      file: file.filename,
    });
  if (consoleLogCount > 0)
    issues.push({
      category: "ts-quality",
      severity: "info",
      message: `${consoleLogCount} \`console.log/debug/info\` call(s) in production code`,
      file: file.filename,
    });
  if (todoCount > 0)
    issues.push({
      category: "quality",
      severity: "info",
      message: `${todoCount} TODO/FIXME/HACK comment(s) found`,
      file: file.filename,
    });
}

// ── General Analysis ────────────────────────────────────────────────────
function analyzeGeneral(file, addedLines, issues) {
  // Very large file changes
  if (file.additions > 300) {
    issues.push({
      category: "complexity",
      severity: "warning",
      message: `Large file change: ${file.additions} lines added — consider splitting`,
      file: file.filename,
    });
  }

  // Check for hardcoded secrets/keys patterns
  for (const line of addedLines) {
    const code = line.substring(1);
    if (
      /(?:api[_-]?key|secret|password|token)\s*[:=]\s*["'][^"']{8,}/i.test(code) &&
      !code.includes("example") &&
      !code.includes("test") &&
      !code.includes("mock") &&
      !code.includes("placeholder")
    ) {
      issues.push({
        category: "security",
        severity: "error",
        message: "Possible hardcoded secret or API key detected",
        file: file.filename,
      });
      break; // One warning per file is enough
    }
  }
}

// ── Architecture Analysis ───────────────────────────────────────────────
function analyzeArchitecture(files, issues) {
  for (const file of files) {
    if (file.status === "removed") continue;
    const patch = file.patch || "";

    // Domain layer should not import Data/Presentation
    if (file.filename.includes("/Domain/")) {
      if (
        patch.includes("import FirebaseFirestore") ||
        patch.includes("import SwiftUI") ||
        patch.includes("import UIKit")
      ) {
        issues.push({
          category: "architecture",
          severity: "error",
          message:
            "Domain layer imports framework-specific modules (should depend only on abstractions)",
          file: file.filename,
        });
      }
    }

    // Presentation layer should not directly import Data layer services
    if (file.filename.includes("/Presentation/")) {
      if (
        patch.includes("import FirebaseFirestore") ||
        patch.includes("import FirebaseAuth")
      ) {
        issues.push({
          category: "architecture",
          severity: "warning",
          message:
            "Presentation layer directly imports Firebase — should use Domain protocols",
          file: file.filename,
        });
      }
    }
  }
}

// ── Score Calculation ────────────────────────────────────────────────────
function calculateScores(issues, additions, deletions, changedFiles, files) {
  // Start from 100, deduct for issues
  let complexityScore = 100;
  let errorPronenessScore = 100;

  // ── Size-based complexity deductions ─────────────────────────────────
  // Large PRs are inherently more complex and risky
  const totalChanges = additions + deletions;
  if (totalChanges > 1000) complexityScore -= 15;
  else if (totalChanges > 500) complexityScore -= 10;
  else if (totalChanges > 200) complexityScore -= 5;

  if (changedFiles > 20) complexityScore -= 10;
  else if (changedFiles > 10) complexityScore -= 5;

  // ── Issue-based deductions ──────────────────────────────────────────
  for (const issue of issues) {
    switch (issue.severity) {
      case "error":
        if (
          issue.category === "security" ||
          issue.category === "architecture"
        ) {
          errorPronenessScore -= 15;
        } else {
          errorPronenessScore -= 10;
        }
        complexityScore -= 5;
        break;
      case "warning":
        if (issue.category.includes("safety") || issue.category.includes("memory")) {
          errorPronenessScore -= 5;
        } else {
          errorPronenessScore -= 3;
        }
        complexityScore -= 3;
        break;
      case "info":
        errorPronenessScore -= 1;
        complexityScore -= 1;
        break;
    }
  }

  // Bonus for having tests
  const hasTests = files.some(
    (f) =>
      f.filename.includes("Tests/") ||
      f.filename.includes(".test.") ||
      f.filename.includes("Test.swift")
  );
  if (hasTests) {
    errorPronenessScore = Math.min(100, errorPronenessScore + 5);
  }

  complexityScore = Math.max(0, Math.min(100, complexityScore));
  errorPronenessScore = Math.max(0, Math.min(100, errorPronenessScore));

  // Overall: weighted average (error-proneness matters more)
  const overall = Math.round(complexityScore * 0.4 + errorPronenessScore * 0.6);

  return {
    complexity: complexityScore,
    errorProneness: errorPronenessScore,
    overall,
  };
}

// ── Comment Builder ─────────────────────────────────────────────────────
function buildComment(
  scores,
  issues,
  additions,
  deletions,
  changedFiles,
  files,
  testFiles,
  sourceFiles,
  pr
) {
  const getScoreEmoji = (score) => {
    if (score >= 90) return "🟢";
    if (score >= 70) return "🟡";
    if (score >= 50) return "🟠";
    return "🔴";
  };

  const getGrade = (score) => {
    if (score >= 95) return "A+";
    if (score >= 90) return "A";
    if (score >= 85) return "A-";
    if (score >= 80) return "B+";
    if (score >= 75) return "B";
    if (score >= 70) return "B-";
    if (score >= 65) return "C+";
    if (score >= 60) return "C";
    if (score >= 55) return "C-";
    if (score >= 50) return "D";
    return "F";
  };

  const overallEmoji = getScoreEmoji(scores.overall);
  const overallGrade = getGrade(scores.overall);

  let comment = `<!-- pr-analyzer-comment -->\n`;
  comment += `## ${overallEmoji} PR Quality Analysis\n\n`;

  // Score table
  comment += `| Metric | Score | Grade |\n`;
  comment += `|--------|-------|-------|\n`;
  comment += `| ${getScoreEmoji(scores.overall)} **Overall Quality** | **${scores.overall}/100** | **${overallGrade}** |\n`;
  comment += `| ${getScoreEmoji(scores.complexity)} Complexity | ${scores.complexity}/100 | ${getGrade(scores.complexity)} |\n`;
  comment += `| ${getScoreEmoji(scores.errorProneness)} Error Proneness | ${scores.errorProneness}/100 | ${getGrade(scores.errorProneness)} |\n\n`;

  // PR stats
  comment += `### 📊 PR Statistics\n\n`;
  comment += `| Stat | Value |\n`;
  comment += `|------|-------|\n`;
  comment += `| Files Changed | ${changedFiles} |\n`;
  comment += `| Lines Added | +${additions} |\n`;
  comment += `| Lines Removed | -${deletions} |\n`;
  comment += `| Net Change | ${additions - deletions >= 0 ? "+" : ""}${additions - deletions} |\n`;

  const swiftCount = files.filter(
    (f) => f.filename.endsWith(".swift") && f.status !== "removed"
  ).length;
  const tsCount = files.filter(
    (f) =>
      (f.filename.endsWith(".ts") || f.filename.endsWith(".js")) &&
      f.status !== "removed"
  ).length;
  const testCount = testFiles.length;

  if (swiftCount > 0) comment += `| Swift Files | ${swiftCount} |\n`;
  if (tsCount > 0) comment += `| TypeScript/JS Files | ${tsCount} |\n`;
  comment += `| Test Files | ${testCount} |\n`;
  comment += `\n`;

  // Issues
  if (issues.length > 0) {
    comment += `### 🔍 Issues Found (${issues.length})\n\n`;

    const errorIssues = issues.filter((i) => i.severity === "error");
    const warningIssues = issues.filter((i) => i.severity === "warning");
    const infoIssues = issues.filter((i) => i.severity === "info");

    if (errorIssues.length > 0) {
      comment += `<details open>\n<summary>🔴 Errors (${errorIssues.length})</summary>\n\n`;
      comment += `| File | Issue |\n|------|-------|\n`;
      for (const issue of errorIssues) {
        comment += `| \`${truncatePath(issue.file)}\` | ${issue.message} |\n`;
      }
      comment += `\n</details>\n\n`;
    }

    if (warningIssues.length > 0) {
      comment += `<details${errorIssues.length === 0 ? " open" : ""}>\n<summary>🟡 Warnings (${warningIssues.length})</summary>\n\n`;
      comment += `| File | Issue |\n|------|-------|\n`;
      for (const issue of warningIssues) {
        comment += `| \`${truncatePath(issue.file)}\` | ${issue.message} |\n`;
      }
      comment += `\n</details>\n\n`;
    }

    if (infoIssues.length > 0) {
      comment += `<details>\n<summary>ℹ️ Info (${infoIssues.length})</summary>\n\n`;
      comment += `| File | Issue |\n|------|-------|\n`;
      for (const issue of infoIssues) {
        comment += `| \`${truncatePath(issue.file)}\` | ${issue.message} |\n`;
      }
      comment += `\n</details>\n\n`;
    }
  } else {
    comment += `### ✅ No Issues Found\n\nThis PR looks clean! No concerning patterns detected.\n\n`;
  }

  // Legend
  comment += `---\n`;
  comment += `<details>\n<summary>📖 Score Guide</summary>\n\n`;
  comment += `- **Complexity** measures PR size, nesting depth, function length, and structural complexity\n`;
  comment += `- **Error Proneness** measures risky patterns: force unwraps, force casts, missing error handling, architecture violations, and security concerns\n`;
  comment += `- **Overall Quality** is a weighted score (40% complexity + 60% error proneness)\n\n`;
  comment += `| Grade | Score Range | Meaning |\n`;
  comment += `|-------|-------------|----------|\n`;
  comment += `| 🟢 A+ to A- | 85-100 | Excellent — safe to merge |\n`;
  comment += `| 🟡 B+ to B- | 70-84 | Good — minor improvements possible |\n`;
  comment += `| 🟠 C+ to D | 50-69 | Fair — review carefully before merging |\n`;
  comment += `| 🔴 F | 0-49 | Poor — significant issues need attention |\n`;
  comment += `\n</details>\n`;

  return comment;
}

function truncatePath(filepath) {
  if (filepath.length <= 60) return filepath;
  const parts = filepath.split("/");
  if (parts.length <= 2) return filepath;
  return "…/" + parts.slice(-2).join("/");
}
