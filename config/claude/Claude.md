# Global Development Guidelines for Claude

## Communication Principles

### Language Policy
- **Input**: Always interpret prompts and context in English first for better accuracy
- **Output**: Respond in Japanese unless explicitly requested otherwise
- **Reasoning**: Think and analyze in English, then translate the final response
- This approach ensures better understanding while maintaining Japanese UX

### Interaction Style
- Explain the reasoning behind changes
- Ask for clarification instead of making assumptions
- Prefer incremental confirmations for large changes

## Design Philosophy

### Unix Philosophy (Core Principles)
- **Do one thing well**: Single responsibility, focused modules
- **Composition over complexity**: Build tools that work together
- **Text-based data**: Prefer readable formats (JSON, YAML) for debuggability
- **Portability first**: Write maintainable code, optimize later
- **Prototype quickly**: Start simple, iterate based on real usage
- **Reuse, don't reinvent**: Leverage existing proven solutions

## Code Quality Standards

### Readability First
- Prioritize clarity over cleverness
- Use self-documenting code (meaningful names, clear structure)
- Avoid magic numbers and hard-coded values
- Comment complex logic, not obvious code

### Comments Philosophy
**DO write comments for:**
- **Why**: The reason behind a design decision
- **Intent**: The purpose or goal of the code
- **Trade-offs**: Why you chose approach A over B
- **Context**: Business rules, external constraints, or non-obvious requirements
- **Warnings**: Gotchas, performance implications, or future considerations

**DON'T write comments for:**
- What the code does (the code itself should be clear)
- Repeating variable/function names in natural language
- Obvious operations that are self-explanatory

**Examples:**
```python