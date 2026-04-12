# Phase 4: Cart Comparison - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in CONTEXT.md — this log preserves the discussion.

**Date:** 2026-03-30
**Phase:** 04-cart-comparison
**Mode:** discuss
**Areas discussed:** Cart Navigation, Comparison Layout, Quantity Support, Add-to-Cart Feedback, Partial Match Behavior

## Areas Discussed

### Cart Navigation
| Question | Options Presented | User Choice |
|----------|------------------|-------------|
| How does user access cart? | Cart icon in AppBar (Recommended) / 6th tab in nav / FAB on Products page | Cart icon in AppBar |

**Decision:** Cart icon with badge in AppBar of ProductsPage and ProductDetailPage. Navigator.push to CartPage. 5-tab nav unchanged.

---

### Comparison Layout
| Question | Options Presented | User Choice |
|----------|------------------|-------------|
| Per-market result display | Card per market sorted by total (Recommended) / Simple flat list | Card per market, sorted by total |

**Decision:** One card per market, sorted cheapest-total first. Cards expandable to show matched/unmatched products. Cheapest highlighted.

---

### Quantity Support
| Question | Options Presented | User Choice |
|----------|------------------|-------------|
| Quantity per product? | No quantity — each product once (Recommended) / With quantity (N × each) | No quantity — each product once |

**Decision:** Cart is a set of unique products. Adding duplicate is a no-op. Simple `List<ProductItem>` state.

---

### Add-to-Cart Feedback
| Question | Options Presented | User Choice |
|----------|------------------|-------------|
| What happens after tapping 'Sepete Ekle'? | Snackbar + 'Sepete Git' action (Recommended) / Button toggles like favorites / Immediate nav to cart | Snackbar + 'Sepete Git' action |

**Decision:** Snackbar "Ürün sepete eklendi" with "Sepete Git" action button. User stays on ProductDetailPage.

---

### Partial Match / Unavailable Products Behavior
| Question | Options Presented | User Choice |
|----------|------------------|-------------|
| Markets with missing products | Show partial total + honest label (Recommended) / Sort by match rate first / Hide markets below threshold | Show partial total + honest label |

**Decision:** Always show partial total: "7/9 ürün | 131,20 ₺\*" with "2 ürün bu markette bulunamadı" note. No markets hidden.

---

## Corrections Made

None — all recommended options confirmed.

---

*Discussion: 2026-03-30*
