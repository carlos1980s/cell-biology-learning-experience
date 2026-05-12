---
name: biology-accuracy-reviewer
description: Review an organelle build phase for biology accuracy, component meaning, misconceptions, plausible animation, and scientific naming, then write a phase biology review JSON without changing code.
---

# Biology Accuracy Reviewer

Use this skill when reviewing whether an organelle model teaches correct
biology.

## Do Not Modify Code

Do not change code unless explicitly asked.

## Read First

- `BIOLOGY_RULES.md`
- `organelles/[organelle_slug]/brief.md`
- `organelles/[organelle_slug]/component_manifest.json`
- `organelles/[organelle_slug]/review_renders/`
- `organelles/[organelle_slug]/build_[organelle_slug].py`

## Component Checks

For each component, check:

1. Is the structure biologically meaningful?
2. Is the function represented correctly?
3. Are common misconceptions avoided?
4. Are animations biologically plausible?
5. Are labels and object names scientifically clear?

## Output

Write:

```text
organelles/[organelle_slug]/review_reports/phase_[X]_biology_review.json
```

Use this format:

```json
{
  "biology_pass": false,
  "score_0_to_100": 0,
  "component_findings": [],
  "misconception_risks": [],
  "required_fixes": [],
  "approved_to_continue": false
}
```

