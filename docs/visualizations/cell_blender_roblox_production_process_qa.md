# Cell Blender to Roblox Production Process Deck QA

Deck: `docs/visualizations/cell_blender_roblox_production_process.pptx`

## Mechanical Checks

- Slide count: 12
- PPTX package is non-empty
- Empty package files: 0
- Media files: 0; deck uses editable PowerPoint shapes and text
- Rendered contact sheet:
  `docs/visualizations/cell_blender_roblox_production_process_contact_sheet.png`

## Content Checks

- Includes full phase flow from Director ticket through next organelle ticket
- Includes validation points for brief, reference, Blender, review, export,
  package upload, Studio assembly, edit mode, play mode, and QA report
- Includes role touchpoints for Director, builder, reviewers, and integration
- Includes Roblox package behavior: package/model asset IDs, not child MeshIds
- Includes expected Studio structure with hidden raw packages and visible scoped
  model
- Includes MCP, legacy bridge, and Computer Use fallback path
- Includes failure policy and scale-up checklist

## Rubric Score

- Story: 5/5
- Specificity: 5/5
- Rhythm: 4/5
- Whitespace: 4/5
- Diagram clarity: 4/5
- Typography: 4/5
- Restraint: 5/5
- Precision: 5/5
- Coherence: 5/5

Total: 41/45

Remaining tradeoff: slide 3 intentionally compresses the entire 15-step flow
onto one slide. It is readable full-size and useful as an executive map, while
the later slides unpack the key gates.

