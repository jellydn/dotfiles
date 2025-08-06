#!/usr/bin/env node

// @ts-check

const fs = require("node:fs");

/**
 * Extract relevant PR comment information from GitHub API JSON files
 * and format it for AI consumption
 *
 * Supports both:
 * - Review comments (inline code review comments)
 * - Issue comments (general PR discussion comments)
 *
 * Filtering logic:
 * - Skip replies (comments with in_reply_to_id) - these are likely resolved comments
 * - Skip bot comments unless they contain actionable feedback
 * - Only include top-level comments that need attention
 */
function extractPrComments(reviewCommentsFile, issueCommentsFile, outputFile) {
  try {
    let allComments = [];

    // Load review comments (inline code review comments)
    if (fs.existsSync(reviewCommentsFile)) {
      const reviewData = fs.readFileSync(reviewCommentsFile, "utf8");
      const reviewComments = JSON.parse(reviewData);
      allComments = allComments.concat(
        reviewComments.map((comment) => ({
          ...comment,
          comment_type: "review",
        })),
      );
    }

    // Load issue comments (general PR discussion comments)
    if (fs.existsSync(issueCommentsFile)) {
      const issueData = fs.readFileSync(issueCommentsFile, "utf8");
      const issueComments = JSON.parse(issueData);
      allComments = allComments.concat(
        issueComments.map((comment) => ({
          ...comment,
          comment_type: "issue",
        })),
      );
    }

    const comments = allComments;

    // Create a set of comment IDs that have replies (likely resolved)
    const commentIdsWithReplies = new Set(
      comments
        .filter((comment) => comment.in_reply_to_id)
        .map((comment) => comment.in_reply_to_id),
    );

    // Filter and extract relevant comments
    const relevantComments = comments
      .filter((comment) => {
        // Skip replies (comments with in_reply_to_id)
        if (comment.in_reply_to_id) {
          return false;
        }

        // Skip comments that have replies (likely resolved)
        if (commentIdsWithReplies.has(comment.id)) {
          return false;
        }

        if (!comment.body || comment.body.trim() === "") {
          return false;
        }

        // Skip simple bot acknowledgment comments that don't contain actionable feedback
        const isBot =
          comment.user?.type === "Bot" ||
          comment.user?.login?.includes("[bot]");
        if (isBot) {
          const body = comment.body.toLowerCase();
          // Keep bot comments that contain actionable feedback (like CodeRabbit reviews)
          const hasActionableContent =
            body.includes("issue") ||
            body.includes("fix") ||
            body.includes("error") ||
            body.includes("suggestion") ||
            body.includes("improvement") ||
            body.includes("bug") ||
            (body.includes("review") &&
              (body.includes("feedback") || body.includes("found")));
          if (!hasActionableContent) {
            return false;
          }
        }

        return true;
      })
      .map((comment) => {
        const classification = classifyComment(comment);
        return {
          id: comment.id,
          body: comment.body,
          diff_hunk: comment.diff_hunk,
          commit_id: comment.commit_id,
          path: comment.path,
          user: comment.user?.login || "unknown",
          comment_type: comment.comment_type,
          html_url: comment.html_url,
          severity: classification.severity,
          categories: classification.categories,
        };
      });

    const ndjsonOutput = formatAsNdjson(relevantComments);

    fs.writeFileSync(outputFile, ndjsonOutput, "utf8");

    const todoFile = outputFile.replace(".ndjson", "-todo.md");
    const todoContent = createTodoFile(
      relevantComments,
      reviewCommentsFile || issueCommentsFile,
    );
    fs.writeFileSync(todoFile, todoContent, "utf8");

    // Generate summary statistics
    const summaryStats = generateSummaryStats(relevantComments);
    const summaryFile = outputFile.replace(".ndjson", "-summary.md");
    const summaryContent = createSummaryFile(
      summaryStats,
      relevantComments.length,
      comments.length,
    );
    fs.writeFileSync(summaryFile, summaryContent, "utf8");

    const resolvedCount = commentIdsWithReplies.size;
    console.log(
      `✅ Extracted ${relevantComments.length} unresolved comments from ${comments.length} total comments`,
    );
    console.log(
      `📝 Skipped ${resolvedCount} comments with replies (likely resolved)`,
    );
    console.log(
      `📊 Severity breakdown: Critical: ${summaryStats.severity.critical}, High: ${summaryStats.severity.high}, Medium: ${summaryStats.severity.medium}, Low: ${summaryStats.severity.low}`,
    );
    console.log(`📝 Output saved to: ${outputFile}`);
    console.log(`📝 Todo file created: ${todoFile}`);
    console.log(`📋 Summary file created: ${summaryFile}`);
  } catch (error) {
    console.error("❌ Error processing comments:", error.message);
    process.exit(1);
  }
}

/**
 * Classify comment severity and category based on content analysis
 */
function classifyComment(comment) {
  const body = comment.body.toLowerCase();

  // Severity classification (highest severity wins)
  let severity = "low";
  if (
    body.includes("security") ||
    body.includes("vulnerability") ||
    body.includes("critical") ||
    body.includes("exploit")
  ) {
    severity = "critical";
  } else if (
    body.includes("bug") ||
    body.includes("error") ||
    body.includes("breaking") ||
    body.includes("crash") ||
    body.includes("fail")
  ) {
    severity = "high";
  } else if (
    body.includes("performance") ||
    body.includes("improvement") ||
    body.includes("refactor") ||
    body.includes("optimize") ||
    body.includes("slow")
  ) {
    severity = "medium";
  }

  // Category classification (can have multiple categories)
  const categories = [];
  if (
    body.includes("security") ||
    body.includes("vulnerability") ||
    body.includes("auth") ||
    body.includes("permission")
  ) {
    categories.push("security");
  }
  if (
    body.includes("performance") ||
    body.includes("slow") ||
    body.includes("optimize") ||
    body.includes("memory") ||
    body.includes("speed")
  ) {
    categories.push("performance");
  }
  if (
    body.includes("complex") ||
    body.includes("refactor") ||
    body.includes("maintainability") ||
    body.includes("clean")
  ) {
    categories.push("maintainability");
  }
  if (
    body.includes("aria") ||
    body.includes("accessibility") ||
    body.includes("a11y") ||
    body.includes("screen reader")
  ) {
    categories.push("accessibility");
  }
  if (
    body.includes("test") ||
    body.includes("coverage") ||
    body.includes("spec") ||
    body.includes("unit test")
  ) {
    categories.push("testing");
  }
  if (
    body.includes("doc") ||
    body.includes("comment") ||
    body.includes("readme") ||
    body.includes("jsdoc")
  ) {
    categories.push("documentation");
  }
  if (
    body.includes("type") ||
    body.includes("typescript") ||
    body.includes("interface") ||
    body.includes("generic")
  ) {
    categories.push("typing");
  }
  if (
    body.includes("style") ||
    body.includes("format") ||
    body.includes("lint") ||
    body.includes("prettier")
  ) {
    categories.push("style");
  }

  // Default to code-quality if no specific categories found
  if (categories.length === 0) {
    categories.push("code-quality");
  }

  return { severity, categories };
}

/**
 * Format comments as NDJSON for grep-friendly AI consumption
 */
function formatAsNdjson(comments) {
  return comments
    .map((comment, index) => {
      const commentObj = {
        id: index + 1,
        github_id: comment.id,
        user: comment.user,
        comment_type: comment.comment_type,
        path: comment.path || "",
        commit_id: comment.commit_id || "",
        diff_hunk: comment.diff_hunk || "",
        html_url: comment.html_url || "",
        body: comment.body,
        severity: comment.severity,
        categories: comment.categories,
      };
      return JSON.stringify(commentObj);
    })
    .join("\n");
}

/**
 * Generate summary statistics for comments
 */
function generateSummaryStats(comments) {
  const stats = {
    severity: { critical: 0, high: 0, medium: 0, low: 0 },
    categories: {},
    total: comments.length,
  };

  comments.forEach((comment) => {
    // Count severity
    if (stats.severity[comment.severity] !== undefined) {
      stats.severity[comment.severity]++;
    }

    // Count categories
    comment.categories.forEach((category) => {
      stats.categories[category] = (stats.categories[category] || 0) + 1;
    });
  });

  return stats;
}

/**
 * Create enhanced summary file with categorized analysis
 */
function createSummaryFile(stats, relevantCount, totalCount) {
  const severityEmojis = {
    critical: "🔴",
    high: "🟠",
    medium: "🟡",
    low: "🟢",
  };

  const categoryEmojis = {
    security: "🔒",
    performance: "⚡",
    maintainability: "🔧",
    accessibility: "♿",
    testing: "🧪",
    documentation: "📚",
    typing: "🏷️",
    style: "🎨",
    "code-quality": "✨",
  };

  let content = `# Comment Analysis Summary\n\n`;

  // Impact Analysis
  content += `🎯 **Impact Analysis:**\n`;
  Object.entries(stats.severity).forEach(([severity, count]) => {
    if (count > 0) {
      content += `• ${severity.charAt(0).toUpperCase() + severity.slice(1)}: ${severityEmojis[severity]} ${count} issue${count !== 1 ? "s" : ""}\n`;
    }
  });

  content += `\n📊 **Total Comments:** ${relevantCount} actionable (${totalCount - relevantCount} resolved/skipped)\n\n`;

  // Category Breakdown
  content += `📋 **Category Breakdown:**\n`;
  Object.entries(stats.categories)
    .sort(([, a], [, b]) => b - a)
    .forEach(([category, count]) => {
      const emoji = categoryEmojis[category] || "📝";
      content += `• ${emoji} ${category.charAt(0).toUpperCase() + category.slice(1).replace("-", " ")}: ${count}\n`;
    });

  content += `\n---\n\n*Use this analysis to prioritize your fixes by severity and category.*`;

  return content;
}

/**
 * Create enhanced todo file with severity indicators
 */
function createTodoFile(comments, inputFile) {
  const prNumber = inputFile.match(/pr-(\d+)/)?.[1] || "XXXX";

  const severityEmojis = {
    critical: "🔴",
    high: "🟠",
    medium: "🟡",
    low: "🟢",
  };

  const todoItems = comments
    .sort((a, b) => {
      const severityOrder = { critical: 0, high: 1, medium: 2, low: 3 };
      return severityOrder[a.severity] - severityOrder[b.severity];
    })
    .map((comment, index) => {
      const shortBody = comment.body
        .split("\n")[0]
        .replace(/[*_`]/g, "")
        .substring(0, 60);
      const filePath =
        comment.path ||
        (comment.comment_type === "issue"
          ? "General PR Discussion"
          : "unknown");
      const commentId = index + 1;
      const commentType = comment.comment_type === "issue" ? "💬" : "📝";
      const severityIndicator = severityEmojis[comment.severity] || "🟢";
      const categories = comment.categories.slice(0, 2).join(", "); // Show first 2 categories

      return `- [ ] ${commentType} ${severityIndicator} **${comment.severity.toUpperCase()}** Comment #${commentId} - **${filePath}** - ${shortBody}${shortBody.length >= 60 ? "..." : ""} *(${categories})* - [View](${comment.html_url || "#"})`;
    })
    .join("\n");

  return `# PR #${prNumber} Review Comments - TODO List\n\n🎯 **Priority Order:** 🔴 Critical → 🟠 High → 🟡 Medium → 🟢 Low\n\n${todoItems}`;
}

// Command line usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.log(
      "Usage: node extract-pr-comments.js <review-comments-file> <issue-comments-file> [output-file]",
    );
    console.log(
      "Example: node .claude/extract-pr-comments.js pr-4972-review-comments-raw.json pr-4972-issue-comments-raw.json pr-4972-comments.ndjson",
    );
    console.log("");
    console.log(
      "Note: This script processes both review comments (inline code comments) and issue comments (general PR discussion).",
    );
    console.log(
      "It filters out comments with replies (likely resolved) and only shows top-level comments that need attention.",
    );
    process.exit(1);
  }

  const reviewCommentsFile = args[0];
  const issueCommentsFile = args[1];
  const outputFile =
    args[2] ||
    reviewCommentsFile
      .replace("-review-comments-raw.json", "-comments.ndjson")
      .replace(".claude/", "");

  extractPrComments(reviewCommentsFile, issueCommentsFile, outputFile);
}

module.exports = { extractPrComments };
