# Styling: PrimeNG + TailwindCSS

## 1. PrimeNG Mandatory Replacement Table

Never use native HTML elements when a PrimeNG equivalent exists.

| Native HTML | PrimeNG Component | Notes |
|---|---|---|
| `<button>` | `<p-button>` | Use `severity`, `outlined`, `text`, `raised` variants |
| `<input type="text">` | `<inputText>` | Directive applied to `<input>` |
| `<input type="number">` | `<p-inputNumber>` | |
| `<input type="password">` | `<p-password>` | |
| `<input type="checkbox">` | `<p-checkbox>` | |
| `<input type="radio">` | `<p-radioButton>` | |
| `<select>` | `<p-select>` | Previously `p-dropdown` |
| `<select multiple>` | `<p-multiSelect>` | |
| `<textarea>` | `<p-textarea>` | |
| `<table>` | `<p-table>` | |
| `<input type="date">` | `<p-datePicker>` | Previously `p-calendar` |
| `<progress>` | `<p-progressBar>` | |
| `<dialog>` | `<p-dialog>` / `<p-dynamicDialog>` | |
| `<details>` | `<p-accordion>` | |
| Tabs UI | `<p-tabs>` | |
| Notifications | `<p-toast>` | Use `MessageService` |
| Inline message | `<p-message>` | |
| Badges | `<p-badge>` / `<p-tag>` | |
| Avatars | `<p-avatar>` | |
| Loading spinner | `<p-progressSpinner>` | |
| Skeleton loading | `<p-skeleton>` | |

---

## 2. Applying Classes to PrimeNG Components

Use the `class` attribute — **never `styleClass`**.

```html
<!-- Bad -->
<p-button styleClass="w-full mt-4" label="Save" />

<!-- Good -->
<p-button class="w-full mt-4" label="Save" />
```

Apply Tailwind layout classes directly on the component element. PrimeNG v17+ forwards `class` to the root element.

```html
<p-select
  class="w-full"
  [options]="options()"
  [(ngModel)]="selected"
  placeholder="Choose option"
/>

<p-button
  class="w-full"
  label="Submit"
  [loading]="loading()"
  severity="primary"
/>
```

---

## 3. TailwindCSS Usage Rules

### Use Tailwind for all layout and typography

```html
<div class="flex flex-col gap-4 p-6 rounded-xl bg-white shadow-sm">
  <h2 class="text-xl font-semibold text-slate-900">Profile</h2>
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <!-- fields -->
  </div>
</div>
```

### Spacing scale — be consistent

Use the Tailwind spacing scale consistently. Prefer:
- `gap-2`, `gap-4`, `gap-6`, `gap-8` for component spacing
- `p-4`, `p-6` for card/section padding
- `mb-1`, `mb-2` for label-to-input gaps

### Typography

```html
<h1 class="text-3xl font-bold text-slate-900">Page Title</h1>
<h2 class="text-xl font-semibold text-slate-800">Section</h2>
<p class="text-sm text-slate-600 leading-relaxed">Body text</p>
<span class="text-xs text-slate-400">Helper text</span>
```

### Never write custom SCSS unless absolutely required

Custom styles are a last resort. Before writing any SCSS:
1. Try Tailwind utility classes first.
2. Try PrimeNG PassThrough API.
3. Only then write minimal component SCSS.

### No `::ng-deep`

`::ng-deep` is deprecated and will be removed. Use the PassThrough API instead (see section 5).

---

## 4. Color Palette Rules

Use only Tailwind's built-in palette. Never use arbitrary values like `text-[#1a1a1a]` or `bg-[rgb(30,30,30)]`.

**Recommended palette for common UI patterns:**

| Use | Tailwind Class |
|---|---|
| Primary text | `text-slate-900` |
| Secondary text | `text-slate-600` |
| Muted / helper text | `text-slate-400` |
| Page background | `bg-slate-50` |
| Card background | `bg-white` |
| Border | `border-slate-200` |
| Divider | `divide-slate-100` |
| Focus ring | `ring-primary-500` |
| Error text | `text-red-600` |
| Success text | `text-green-600` |
| Warning text | `text-amber-600` |

For brand colors, extend the Tailwind theme in `tailwind.config.js` — do not use arbitrary values.

---

## 5. PrimeNG PassThrough API — Deep Customization

Use the `pt` prop (PassThrough) to style internal PrimeNG elements without `::ng-deep`.

```html
<p-table
  [value]="users()"
  [pt]="{
    root: { class: 'rounded-xl overflow-hidden border border-slate-200' },
    header: { class: 'bg-slate-50 px-4 py-3' },
    thead: { class: 'text-slate-600 text-sm' },
    tbody: { class: 'divide-y divide-slate-100' },
    bodyRow: { class: 'hover:bg-slate-50 transition-colors' }
  }"
>
```

```html
<p-select
  [options]="options()"
  [pt]="{
    root: { class: 'w-full' },
    listContainer: { class: 'max-h-60' },
    option: { class: 'text-sm py-2 px-3' }
  }"
/>
```

### Global PassThrough configuration (app-wide)

Configure once in `app.config.ts` to avoid repeating `pt` on every component:

```typescript
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeng/themes/aura';

export const appConfig: ApplicationConfig = {
  providers: [
    providePrimeNG({
      theme: { preset: Aura },
      pt: {
        button: {
          root: { class: 'font-medium' },
        },
        inputtext: {
          root: { class: 'w-full' },
        },
      },
    }),
  ],
};
```

---

## 6. Responsive Design

Use Tailwind's responsive prefixes for breakpoint-based layouts:

```html
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
  @for (card of cards(); track card.id) {
    <app-card [data]="card" />
  }
</div>
```

Common breakpoints:
- `sm:` — 640px+ (small tablets)
- `md:` — 768px+ (tablets)
- `lg:` — 1024px+ (desktops)
- `xl:` — 1280px+ (wide screens)

---

## 7. Dark Mode

Configure dark mode via Tailwind's `class` strategy. Use `dark:` prefixes:

```html
<div class="bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100">
  <p class="text-slate-600 dark:text-slate-400">Secondary content</p>
</div>
```

Toggle dark mode via a signal in a theme service:

```typescript
@Injectable({ providedIn: 'root' })
export class ThemeService {
  private _dark = signal(false);
  readonly isDark = this._dark.asReadonly();

  constructor() {
    effect(() => {
      document.documentElement.classList.toggle('dark', this._dark());
    });
  }

  toggle() {
    this._dark.update(v => !v);
  }
}
```

---

## 8. Form Layout Patterns

Standard field layout using Tailwind + PrimeNG:

```html
<div class="flex flex-col gap-1">
  <label for="email" class="text-sm font-medium text-slate-700">
    Email <span class="text-red-500" aria-hidden="true">*</span>
  </label>
  <inputText
    id="email"
    formControlName="email"
    class="w-full"
    aria-required="true"
    [attr.aria-invalid]="emailInvalid()"
  />
  @if (emailInvalid()) {
    <p class="text-xs text-red-600 mt-0.5" role="alert">
      Please enter a valid email address.
    </p>
  }
</div>
```

With `p-floatlabel` (floating label):

```html
<p-floatlabel class="w-full">
  <inputText id="name" formControlName="name" class="w-full" />
  <label for="name">Full Name</label>
</p-floatlabel>
```

---

## 9. Anti-Patterns Checklist

Before shipping any UI code, verify none of these are present:

- [ ] No `styleClass` attribute on PrimeNG components — use `class`.
- [ ] No `[ngClass]` — use `[class]` or `[class.name]`.
- [ ] No `[ngStyle]` — use `[style]` or `[style.prop]`.
- [ ] No `::ng-deep` — use PassThrough API.
- [ ] No custom SCSS that can be replaced by Tailwind utilities.
- [ ] No arbitrary color values — use Tailwind palette only.
- [ ] No native `<button>`, `<input>`, `<select>`, `<table>` when PrimeNG equivalent exists.
- [ ] No hardcoded pixel values in templates — use Tailwind scale.
