---
name: angular-best-practices
description: Angular v20+ expert code generation using signals, PrimeNG, TailwindCSS, and strict TypeScript modeling rules.
version: 1.0
---

# Angular Developer Skill

This skill enforces Angular architecture, template correctness, styling standards, dependency injection usage, and TypeScript modeling structure.

All referenced rule modules inside:

rules/*.md

are authoritative.

---

# Default Rule Modules

Always apply:

Read [components.md](rules/components.md)

Read [styling.md](rules/styling.md)

Read [typescript-modeling.md](rules/typescript-modeling.md)

These define baseline Angular structure, UI styling guarantees, and TypeScript schema discipline.

---

# Components

When working with Angular components, consult:

Component structure and metadata

Read [components.md](rules/components.md)

Template interaction boundaries

Read [templates.md](rules/templates.md)

Signal-based inputs and outputs

Read [signal-overview.md](rules/signal-overview.md)

Local reactive state

Read [state.md](rules/state.md)

---

# Templates

When working with templates, consult:

Control-flow syntax

Read [templates.md](rules/templates.md)

Derived UI state

Read [state.md](rules/state.md)

Styling bindings

Read [styling.md](rules/styling.md)

---

# Reactivity and Signals

When managing reactive state, consult:

Signal primitives

Read [signal-overview.md](rules/signal-overview.md)

Derived computation

Read [state.md](rules/state.md)

Effect lifecycle

Read [sideeffects.md](rules/sideeffects.md)

---

# Services

When implementing services or API access layers, consult:

Service architecture boundaries

Read [services.md](rules/services.md)

Dependency injection usage

Read [di.md](rules/di.md)

Provider configuration strategy

Read [providers.md](rules/providers.md)

---

# Dependency Injection

When working with Angular DI, consult:

inject() usage

Read [di.md](rules/di.md)

Hierarchical injector resolution

Read [di.md](rules/di.md)

Provider scope rules

Read [providers.md](rules/providers.md)

---

# Providers

When defining providers, consult:

Provider resolution order

Read [providers.md](rules/providers.md)

useClass / useFactory / useValue patterns

Read [providers.md](rules/providers.md)

Multi-provider composition

Read [providers.md](rules/providers.md)

---

# Styling

When implementing UI styling, consult:

Tailwind layout rules

Read [styling.md](rules/styling.md)

PrimeNG styling strategy

Read [styling.md](rules/styling.md)

Template class binding constraints

Read [templates.md](rules/templates.md)

---

# Side Effects

When working with reactive effects, consult:

effect() lifecycle

Read [sideeffects.md](rules/sideeffects.md)

Render-phase interaction rules

Read [sideeffects.md](rules/sideeffects.md)

Derived-state separation

Read [state.md](rules/state.md)
