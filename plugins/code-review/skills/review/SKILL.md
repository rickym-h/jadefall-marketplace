---
description: Review code and architecture for quality principles
---

Review the selected code or recent changes for adherence to software engineering principles:

## Code Quality Principles

**DRY (Don't Repeat Yourself)**
- Identify duplicated code, logic, or patterns
- Suggest abstractions or refactoring opportunities
- Check for repeated string literals, magic numbers, or configuration

**KISS (Keep It Simple, Stupid)**
- Flag overly complex solutions
- Identify unnecessary abstractions or indirection
- Suggest simpler approaches where complexity isn't justified
- Look for over-engineered patterns

**YAGNI (You Aren't Gonna Need It)**
- Identify speculative features or unused code
- Flag premature optimizations
- Find unnecessary configurability or extensibility
- Spot features built for hypothetical future requirements

**SOLID Principles**

*Single Responsibility Principle*
- Each class/module should have one reason to change
- Flag classes doing too many unrelated things

*Open/Closed Principle*
- Code should be open for extension, closed for modification
- Check if new features require modifying existing code

*Liskov Substitution Principle*
- Subtypes should be substitutable for base types
- Flag inheritance hierarchies that violate contracts

*Interface Segregation Principle*
- Clients shouldn't depend on interfaces they don't use
- Flag large, monolithic interfaces

*Dependency Inversion Principle*
- Depend on abstractions, not concretions
- Check for high coupling to concrete implementations

## Additional Checks

- **Architecture Quality**: Overall structure and organization
- **Maintainability**: How easy it will be to modify and extend
- **Readability**: Code clarity and documentation needs
- **Potential Issues**: Edge cases, error handling, security concerns

Provide specific, actionable feedback with code examples where helpful. Prioritize the most impactful issues.
