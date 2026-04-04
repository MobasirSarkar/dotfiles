# TypeScript Modeling Rules

This module defines Angular TypeScript structure for models, unions, constants, and UI configuration schemas.

Apply these rules whenever creating:

models/
constants/
dashboard metrics
table row schemas
status enums
filter configs
card config objects
SVG-safe UI bindings

---

# Models Directory Structure

Always place domain interfaces inside:

models/<domain>.models.ts

Example:

fms.models.ts
vehicle.models.ts
dashboard.models.ts

Each file must contain:

type unions
API DTO interfaces
UI ViewModel interfaces
config schema interfaces

Never mix service logic with models.

---

# Union Types Instead of Enums

Always prefer:

export type FuelingStatus =
  | 'need_review'
  | 'need_receipt'
  | 'mismatch'
  | 'flagged'
  | 'verified'
  | 'unverified';

Never use:

enum FuelingStatus {}

---

# API DTO Interfaces

DTO interfaces must:

match backend fields exactly
preserve nullable fields
avoid UI-only properties

Example:

export interface FuelingRecord {
  id: string;
  groupName: string;
  status: FuelingStatus;
}

---

# UI ViewModel Interfaces

ViewModels may extend DTO semantics with:

safeSvgIcon
surfaceClasses
valueClasses
computed display values

Example:

export interface FuelingMetric {
  title: string;
  value: number;
  iconBg: string;
  svgIcon: string;
  safeSvgIcon?: unknown;
}

---

# Constants Directory Structure

Always place constants inside:

constants/<domain>.constants.ts

Example:

fms.constants.ts
dashboard.constants.ts

---

# Typed Config Records

Status/config mappings must use:

Record<Union, ConfigShape>

Example:

export const FUELING_STATUS_CONFIG:
Record<FuelingStatus, StatusChipConfig>

Never use untyped object literals.

---

# Dashboard Card Config Schema

Metric cards must include:

iconBg
iconColor
surfaceClasses
valueClasses
svgIcon
safeSvgIcon

Example:

export interface StatCard {
  label: string;
  value: string;
  iconBg: string;
  svgIcon: string;
  safeSvgIcon?: unknown;
}

---

# SVG Safety Contract

All inline SVG strings must expose:

svgIcon: string
safeSvgIcon?: unknown

Sanitized version must be computed at runtime.

Never bind raw SVG directly.

---

# Filter Option Schemas

Filters must use:

export interface FilterOption {
  label: string;
  value: string;
}

Arrays must be:

as const

Example:

export const STATUS_FILTER_OPTIONS = [
  { label: 'Verified', value: 'verified' }
] as const;
