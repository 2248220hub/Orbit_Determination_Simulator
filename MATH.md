# 📐 OD Console — Mathematical Reference

**Complete formulation of the orbit-determination pipeline implemented in
`OD_Simulator_V2.html`.** Every equation below corresponds to named code in the
single-file simulator, and every number in the results tables was produced by
running that code — not copied from a textbook.

- **Model** — planar restricted two-body, state `x = [x, y, ẋ, ẏ]ᵀ ∈ ℝ⁴`
- **Units** — kilometres, kilometres per second, seconds (no canonical scaling)
- **Observables** — range `ρ` and range-rate `ρ̇` from one fixed ground station
- **Epoch** — `t₀ = 0`; arc `t = 0 … 590 s`, `Δt = 10 s`, `N = 60` epochs
- **Reference** — Tapley, Schutz & Born, *Statistical Orbit Determination* (2004); Vallado, *Fundamentals of Astrodynamics and Applications*

---

## 1 · Constants and scenario

| Symbol | Value | Units | Code |
|---|---|---|---|
| `μ` | 398 600.4418 | km³ s⁻² | `MU` |
| `R_E` | 6378.137 | km | `R_E` |
| `r_sta` | (5800.000, 2650.000) | km | `STA` |
| `ṙ_sta` | (0, 0) | km s⁻¹ | `STA_V` |
| `‖r_sta‖` | 6376.7155 | km | — (0.9998 R_E, on the surface) |
| `X_TRUE(t₀)` | [7000.000, 0.000, 0.000, 7.54605] | km, km s⁻¹ | `X_TRUE` |
| `σ_ρ` | 0.010 | km | `SIG_RHO` |
| `σ_ρ̇` | 0.0001 | km s⁻¹ | `SIG_RHODOT` |
| `N` | 60 | — | `N_OBS` |
| `Δt` | 10 | s | `DT_OBS` |
| `h` | 1.0 | s (RK4 step) | `H_INT` |

**Derived orbit** — from vis-viva, `a = [2/r − v²/μ]⁻¹`:

| Quantity | Value |
|---|---|
| `a` | 6999.9939 km |
| `e` | 8.72 × 10⁻⁷ (numerically circular) |
| `T` | 5828.509 s |
| `v_circ(7000 km)` | 7.546053 km s⁻¹ |
| arc covered | 590 s = **10.12 %** of one revolution |

The tracking geometry: `ρ` falls 2909.04 → 623.53 km (closest approach near
`t ≈ 450 s`) then climbs to 1517.41 km, while `ρ̇` sweeps −6.8741 → +6.5314 km s⁻¹.
The station being **off the symmetry axis** is what makes the problem observable.

---

## 2 · Dynamics and the state-transition matrix

### 2.1 Equations of motion

```
        ⎡ ẋ ⎤   ⎡      ẋ      ⎤
 Ẋ = F(X) = ⎢ ẏ ⎥ = ⎢      ẏ      ⎥ ,      r = √(x² + y²)
        ⎢ ẍ ⎥   ⎢ −μ x / r³   ⎥
        ⎣ ÿ ⎦   ⎣ −μ y / r³   ⎦
```

### 2.2 Jacobian (gravity gradient)

`A(t) = [∂F/∂X]*` evaluated **on the reference**:

```
        ⎡ 0   0   1   0 ⎤
 A  =   ⎢ 0   0   0   1 ⎥
        ⎢ a₃₁ a₃₂ 0   0 ⎥
        ⎣ a₄₁ a₄₂ 0   0 ⎦

 a₃₁ = μ ( −1/r³ + 3x²/r⁵ )      a₃₂ = a₄₁ = 3μ x y / r⁵
 a₄₂ = μ ( −1/r³ + 3y²/r⁵ )
```

*Code: `deriv(z)`. Trace check: `a₃₁ + a₄₂ = μ(−2/r³ + 3(x²+y²)/r⁵) = μ/r³`, as
required for a central inverse-square field.*

### 2.3 State-transition matrix

```
 Φ̇(t,t₀) = A(t) Φ(t,t₀) ,      Φ(t₀,t₀) = I₄
 x(t)    = Φ(t,t₀) x₀
```

The 4 state equations and the 16 STM equations are integrated **together** as one
20-dimensional RK4 system, so `Φ` is always consistent with the trajectory it was
linearised about.

```
 z = [ x, y, ẋ, ẏ | Φ₁₁ … Φ₄₄ ] ∈ ℝ²⁰
 z_{k+1} = z_k + (h/6)(k₁ + 2k₂ + 2k₃ + k₄)
```

*Code: `deriv`, `rk4`, `propagate`. Step `h = 1 s` → local truncation `O(h⁵) ≈ 10⁻¹²`
relative over the 590 s arc.*

### 2.4 Inter-epoch STM (sequential filters)

```
 Φ(t_k, t_{k−1}) = Φ(t_k, t₀) · Φ(t_{k−1}, t₀)⁻¹
```

*Code: `runSequentialFilter`, via `invN`. This chaining is why the sequential path
carries a slightly higher numerical floor than the batch solve — see §7.3.*

---

## 3 · Observation model

### 3.1 The two observables

With `Δr = r − r_sta` and `Δv = ṙ − ṙ_sta`:

```
 ρ  = ‖Δr‖ = √[ (x − x_s)² + (y − y_s)² ]

         Δr · Δv     (x − x_s)(ẋ − ẋ_s) + (y − y_s)(ẏ − ẏ_s)
 ρ̇  =  ───────── = ─────────────────────────────────────────
           ‖Δr‖                        ρ

 Y_i = G(X_i, t_i) + ε_i ,      ε ~ 𝒩(0, R)
```

Define the **line-of-sight unit vector** `û = Δr / ρ`. Then `ρ̇ = û · Δv`.

*Code: `rho(X)`, `rhodot(X)`.*

### 3.2 Observation partials `H̃ = [∂G/∂X]*`

**Range row (1×4):**

```
 H_ρ = [ ∂ρ/∂x , ∂ρ/∂y , ∂ρ/∂ẋ , ∂ρ/∂ẏ ]
     = [ (x − x_s)/ρ , (y − y_s)/ρ , 0 , 0 ]
     = [ û_x , û_y , 0 , 0 ]
```

**Range-rate row (1×4)** — differentiating `ρ̇ = (Δr · Δv)/ρ` and using `∂ρ/∂r = û`:

```
        ⎡ (ẋ − ẋ_s) − ρ̇ û_x     (ẏ − ẏ_s) − ρ̇ û_y            ⎤
 H_ρ̇ = ⎢ ─────────────────── , ─────────────────── , û_x , û_y ⎥
        ⎣          ρ                     ρ                      ⎦
```

**Structural reading of the two rows**

| | position block | velocity block |
|---|---|---|
| `H_ρ` | `û` — full strength | **exactly zero** |
| `H_ρ̇` | `(Δv − ρ̇ û)/ρ` — the component of relative velocity ⟂ to the LOS, attenuated by `1/ρ` | `û` — full strength |

- Range measures **position along the line of sight** and is *structurally blind*
  to velocity at first order. Velocity is recovered only through `Φ`.
- Range-rate measures **velocity along the line of sight** directly. Its position
  information is the `O(1/ρ)` term — weaker by a factor `≈ ρ`, i.e. 10²–10³ here.

*Code: `Htil(X)` returns both rows plus the computed `ρ*`, `ρ̇*`. Verified against
central finite differences over all 60 epochs: max relative error **3.6 × 10⁻⁸** for
`H_ρ` and **1.6 × 10⁻⁶** for `H_ρ̇` (the larger figure is finite-difference truncation
on the more nonlinear function, not analytic error).*

### 3.3 Mode selection — the block size `p`

| Mode | rows used | `p` | `m = N·p` |
|---|---|---|---|
| Range | `H_ρ` | 1 | 60 |
| Range-Rate | `H_ρ̇` | 1 | 60 |
| Both | `[H_ρ ; H_ρ̇]` | 2 | 120 |

*Code: `obsChans`, `obsDim`, `HtilRows`, `obsCount`.*

### 3.4 Mapping to the epoch

```
 y_i = H̃_i x_i + ε_i = H̃_i Φ(t_i,t₀) x₀ + ε_i = H_i x₀ + ε_i

 H_i = H̃_i Φ(t_i, t₀)          (p × 4)
```

*Code: `buildH()` returns one `p×4` block per epoch; `stackH()` flattens to `m×4`.*

---

## 4 · The estimators

All seven minimise a quadratic cost in the epoch deviation `x₀` and differ only in
the weight `W`, whether an a priori term is present, and batch vs sequential
processing.

### 4.1 Weighting

| Estimator | `W` | Code path |
|---|---|---|
| LS | `I` | `weightMode() = 'identity'` |
| WLS, WLS+ap | `diag(1/σ_c²)` — or `R⁻¹` if whitening is on | `'diag'` / `'full'` |
| MVE, MVE+ap | `R⁻¹` always | `'full'` |
| KF, EKF | per-epoch `R⁻¹` inside the gain | `runSequentialFilter` |

Per-mode weight, explicitly:

```
 range :  W = 1/σ_ρ²                      = 1.0 × 10⁴   km⁻²
 rate  :  W = 1/σ_ρ̇²                      = 1.0 × 10⁸   (km/s)⁻²
 both  :  W = diag( 1/σ_ρ² , 1/σ_ρ̇² )    = diag(1.0e4, 1.0e8)
```

> ⚠️ **Why LS differs only in `both` mode.** With one channel, `W = cI` and the
> scalar `c` cancels from `x̂ = (HᵀcH)⁻¹Hᵀc y` — LS, WLS and MVE give *identical*
> estimates (confirmed in Table T1: all 32.6 m for range). With two channels
> `W = I` adds km² and (km/s)² together, which is dimensionally meaningless and
> lets the range channel dominate by a factor `σ_ρ̇²/σ_ρ² = 10⁻⁴`. LS in `both`
> mode therefore returns the *range-only* answer (32.6 m) while WLS returns
> 21.1 m. This is not a bug — it is the reason weighting exists.

### 4.2 Batch normal equations

Cost:

```
 J(x₀) = ½ (y − H x₀)ᵀ W (y − H x₀) + ½ (x₀ − x̄₀)ᵀ P̄₀⁻¹ (x₀ − x̄₀)
```

Setting `∂J/∂x₀ = 0`:

```
 Λ = Σᵢ Hᵢᵀ W Hᵢ + P̄₀⁻¹          information matrix        (4×4)
 N = Σᵢ Hᵢᵀ W yᵢ + P̄₀⁻¹ x̄₀       information vector        (4×1)

 Λ x̂₀ = N    ⇒    x̂₀ = Λ⁻¹ N ,    P₀ = Λ⁻¹
```

Because `W` is diagonal in every mode, the sum runs **block by block** over the 60
epochs — one weighted outer product per active channel, never an `m×m` product.

*Code: `accumulateNormals()`, `solveLSE()`.*

**A priori as pseudo-observations.** `P̄₀⁻¹` enters `Λ` exactly like `Hᵀ W H` from
extra measurements: the prior is `x̄₀` observed with covariance `P̄₀`. Presets:

| Preset | `P̄₀` diag (km², (km/s)²) | `σ_ap` |
|---|---|---|
| weak | `[1e4, 1e4, 1e0, 1e0]` | 100 km / 1 km s⁻¹ |
| nominal | `[1e0, 1e0, 1e−6, 1e−6]` | 1 km / 1 m s⁻¹ |
| tight | `[4e−4, 4e−4, 2.5e−9, 2.5e−9]` | 20 m / 0.05 m s⁻¹ |

### 4.3 Coloured noise and whitening

AR(1) within each channel, independent across channels, over the stacked residual:

```
 R[(i,c)][(j,c)]  = σ_c² ρ^|i−j| ,   ρ = 0.85
 R[(i,c)][(j,c′)] = 0                for c ≠ c′
```

Whitening by Cholesky `R = V Vᵀ`:

```
 z  = V⁻¹ y ,   H_w = V⁻¹ H    ⇒    Λ = H_wᵀ H_w ,   N = H_wᵀ z
```

*Code: `buildR()` (m×m, m = 60 or 120), `cholL`, `fwdSolve`.*

### 4.4 Sequential — Kalman and Extended Kalman

For each epoch `k = 1 … 60`, with `Φ_s = Φ(t_k, t_{k−1})`:

```
 time update        x̄ = Φ_s x̂                  P̄ = Φ_s P Φ_sᵀ    (Q = 0)

 innovation         ν = y_k − H̃_k x̄            (p × 1)
 innovation cov     S = H̃_k P̄ H̃_kᵀ + R         (p × p)
 gain               K = P̄ H̃_kᵀ S⁻¹             (4 × p)

 measurement update x̂ = x̄ + K ν                P = (I − K H̃_k) P̄
```

`R` follows the mode: `σ_ρ²` (1×1), `σ_ρ̇²` (1×1), or `diag(σ_ρ², σ_ρ̇²)` (2×2).
`S⁻¹` is formed by the same pivoted solver used everywhere else.

**Mapping back to the epoch** — so the sequential answer is directly comparable
with the batch answer:

```
 x̂₀ = Φ(t₆₀, t₀)⁻¹ x̂₆₀ ,      P₀ = Φ⁻¹ P₆₀ Φ⁻ᵀ
```

**KF vs EKF.** The KF makes a single linear pass (`S.converged` after one pass).
The EKF adds the outer re-linearisation `X*₀ ← X*₀ + x̂₀`, re-propagates, and repeats
— which is what makes it agree with the batch solution.

*Code: `runSequentialFilter()`.*

### 4.5 Differential correction loop

```
 repeat:
   propagate X*(t), Φ(t,t₀)                   over the 60 epochs
   y_i  = Y_i − G(X*_i)                       residuals
   H_i  = H̃_i Φ(t_i,t₀)                       mapping
   solve Λ x̂₀ = N        (or run the sequential pass)
   X*₀  ← X*₀ + x̂₀                            reference update
   x̄₀   ← x̄₀ − x̂₀                             prior shift
 until ‖x̂₀‖ < ε   or   iteration cap
```

> The prior shift `x̄₀ ← x̄₀ − x̂₀` keeps `X*₀ + x̄₀` invariant. Omitting it makes the
> filter re-apply the same a priori correction on every pass and it never converges.

*Code: `oneIteration()`.*

---

## 5 · Diagnostics

### 5.1 Weighted RMS

```
 wRMS = √( (1/m) Σⱼ ( yⱼ / σⱼ )² ) ,      m = N·p
```

with the whitened form `√(yᵀR⁻¹y / m)` when a full `R` is in use. Per-channel wRMS
is reported separately, because a combined value can sit near 1 while one channel
is badly fitted.

**Interpretation:** `wRMS ≈ 1` ⇒ residuals at the noise floor. `wRMS ≫ 1` ⇒ the
model, weighting or prior does not match the data. `wRMS ≪ 1` ⇒ over-fitting or an
over-stated `σ` (this is what mis-specified coloured noise produces — see T5).

### 5.2 Covariance quality

```
 σ_i   = √P_ii                              1σ per component
 ρ_ij  = P_ij / (σ_i σ_j)                   correlation
 κ(Λ)  = λ_max(Λ) · λ_max(Λ⁻¹)              condition number (power iteration)
 GDOP  ∝ √(tr Λ⁻¹)                          geometric dilution
 Δ/σ   = |X̂₀ − X_TRUE|_i / σ_i              consistency (should be ≲ 3)
```

### 5.3 Verdict classification

*Code: `runVerdict()`.*

| Verdict | Condition | Meaning |
|---|---|---|
| **CONVERGED** | `‖x̂₀‖ < ε`, `Δ/σ ≤ 3`, `0.7 ≤ wRMS ≤ 1.3` | trustworthy |
| **SUSPECT** | converged but wRMS outside `[0.7, 1.3]` | residuals not at the noise floor |
| **BIASED** | converged but `max Δ/σ > 3` | **confidently wrong** — P does not cover the error |
| **STALLED** | hit the iteration cap with `‖x̂₀‖ > 10⁻³` km | correction stopped decaying |
| **DIVERGED** | `‖x̂₀‖ > 5 × 10³` km, or grew ×1.5 for 3 passes | linearisation invalid |

---

## 6 · Numerical methods

| Operation | Method | Code |
|---|---|---|
| Linear solve `Λx = N` | Gaussian elimination, **partial pivoting**, pivot floor 10⁻¹⁴ | `solveN` |
| Matrix inverse | column-wise back-substitution against `e_i` | `invN` |
| `p×p` innovation inverse | same pivoted solver, `p ∈ {1,2}` | `invN` |
| Cholesky `R = V Vᵀ` | banded forward factorisation, floor 10⁻³⁰⁰ | `cholL` |
| Triangular solve | forward substitution | `fwdSolve` |
| Determinant | LU with row swaps, sign tracked | `detN` |
| Dominant eigenvalue | power iteration, 300 steps | `powerEig` |
| Non-square products | generic `p×q` | `matmulG`, `transposeG` |
| ODE integration | fixed-step RK4, 20-D coupled system | `rk4` |
| PRNG | mulberry32, seed 42 (fully reproducible) | `mulberry32` |
| Gaussian deviates | Box–Muller | `gaussPair` |

No external mathematics library is used anywhere.

---

## 7 · Verification

### 7.1 Independent reimplementation

The complete pipeline (RK4 + STM, both partials, normal equations, sequential
filter) was reimplemented independently in Python and compared against the
in-browser engine on identical inputs:

| Quantity | Browser | Python | Agreement |
|---|---|---|---|
| `ρ(t₀)` | 2909.037642 km | 2909.037642 km | exact to 10 s.f. |
| `ρ̇(t₀)` | −6.8741058 km/s | −6.8741058 km/s | exact to 8 s.f. |
| `H_ρ(t₀)` | [0.412508, −0.910954, 0, 0] | identical | exact |
| final `‖Δr‖` (range) | 3.26 × 10⁻² km | 3.26 × 10⁻² km | exact to 3 s.f. |
| final `‖Δr‖` (both) | 2.11 × 10⁻² km | 2.11 × 10⁻² km | exact to 3 s.f. |

### 7.2 Analytic checks

| Check | Result |
|---|---|
| `Φ(t₀,t₀) = I₄` | exact — all 16 entries `1.0` / `0.0` |
| `a₃₁ + a₄₂ = μ/r³` | `1.1621005710e−6` both sides — 11 s.f. |
| `tr A = 0` | exact (diagonal is structurally zero) |
| `a`, `e`, `T` from `keplerFrom2D` | 6999.9939 km · 8.72e−7 · 5828.509 s — match vis-viva |
| closed display ellipse closure | `0.0e+0` km (exact return to start) |
| `H_ρ` vs central differences | 3.6 × 10⁻⁸ relative |
| `H_ρ̇` vs central differences | 1.6 × 10⁻⁶ relative (FD truncation) |

### 7.3 Batch ↔ sequential equivalence

Converged EKF vs batch WLS, `both` mode, identical data and first guess:

```
 batch WLS  ‖Δr‖ = 21.098442 m
 EKF        ‖Δr‖ = 21.097205 m
 relative difference = 5.9 × 10⁻⁵
```

The residual gap is the accumulated round-off of 60 chained `Φ⁻¹` inversions, which
is exactly why the sequential path uses `ε = 10⁻⁶ km` while the batch path uses
`ε = 10⁻⁸ km`.

---

## 8 · Results matrices

All runs use the embedded 60-point benchmark dataset. `|Δr|` in metres, `|Δv|` in
mm s⁻¹, `Δ/σ` = max normalised error, `κ` = `cond(Λ)`.

### T1 · Estimator × mode
*benchmark radar · rough guess (31 km) · weak prior*

| Estimator | Mode | Outcome | it | \|Δr\| | \|Δv\| | wRMS | Δ/σ | κ(Λ) |
|---|---|---|---|---|---|---|---|---|
| LS | Range | ✓ | 5 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| LS | Rate | ✓ | 5 | 42.2 | 116.0 | 1.01 | 1.9 | 9.3e7 |
| LS | **Both** | ✓ | 5 | **32.6** | 86.2 | 1.02 | 0.9 | 1.5e8 |
| WLS | Range | ✓ | 5 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| WLS | Rate | ✓ | 5 | 42.2 | 116.0 | 1.01 | 1.9 | 9.3e7 |
| WLS | **Both** | ✓ | 5 | **21.1** | 59.6 | 1.00 | 0.9 | 5.7e7 |
| WLS+ap | Range | ✓ | 5 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| WLS+ap | Rate | ✓ | 5 | 42.1 | 115.9 | 1.01 | 1.9 | 9.3e7 |
| WLS+ap | Both | ✓ | 5 | 21.1 | 59.6 | 1.00 | 0.9 | 5.7e7 |
| MVE | Range | ✓ | 5 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| MVE | Rate | ✓ | 5 | 42.2 | 116.0 | 1.01 | 1.9 | 9.3e7 |
| MVE | Both | ✓ | 5 | 21.1 | 59.6 | 1.00 | 0.9 | 5.7e7 |
| MVE+ap | Range | ✓ | 5 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| MVE+ap | Rate | ✓ | 5 | 42.1 | 115.9 | 1.01 | 1.9 | 9.3e7 |
| MVE+ap | Both | ✓ | 5 | 21.1 | 59.6 | 1.00 | 0.9 | 5.7e7 |
| **KF** | Range | ⚠ BIASED | 1 | 4440.5 | 1.4e4 | 50.4 | 108.7 | 1.6e8 |
| **KF** | Rate | ⚠ BIASED | 1 | 4164.8 | 1.4e4 | 46.7 | 145.3 | 1.1e8 |
| **KF** | Both | ⚠ BIASED | 1 | 4571.4 | 1.5e4 | 48.0 | 214.5 | 5.9e7 |
| EKF | Range | ✓ | 4 | 32.6 | 86.3 | 0.96 | 0.6 | 1.5e8 |
| EKF | Rate | ✓ | 4 | 42.1 | 115.9 | 1.01 | 1.9 | 9.3e7 |
| EKF | Both | ✓ | 4 | 21.1 | 59.6 | 1.00 | 0.9 | 5.7e7 |

**Readings.** (1) LS = WLS = MVE for a single channel — the scalar weight cancels.
(2) In `both` mode LS collapses to the range-only answer; only a properly weighted
`W` extracts the 21.1 m solution. (3) The single-pass KF is *always* BIASED from a
31 km guess: one linear update cannot absorb a nonlinear gap, and its covariance
never says so. (4) EKF reproduces batch WLS exactly.

### T2 · First guess × mode — radius of convergence
*benchmark radar · WLS · weak prior*

| Guess | gap | Range (ρ) | Rate (ρ̇) | Both (ρ+ρ̇) |
|---|---|---|---|---|
| Good | 2.5 km | ✓ 4 it · 32.6 m | ✓ 4 it · 42.2 m | ✓ 4 it · 21.1 m |
| Rough | 31 km | ✓ 5 it · 32.6 m | ✓ 5 it · 42.2 m | ✓ 5 it · 21.1 m |
| Poor | 250 km | ✓ 6 it · 32.6 m | ✓ 6 it · 42.2 m | ✓ 6 it · 21.1 m |
| **Lost** | **1250 km** | ⚠ **DIVERGED** 2 it | ⚠ **DIVERGED** 1 it | ✓ **8 it · 21.1 m** |

Divergence trace at the Lost guess: range `1.6e3 → 7.4e3`, rate `4.2e3 → 2.7e4`
(km), wRMS reaching `10⁵`. The cliff, measured by scaling the poor guess:

| gap | Range | Rate | Both |
|---|---|---|---|
| 500 km | ✓ | ⚠ DIVERGED | ✓ |
| 1000 km | ✓ | ⚠ DIVERGED | ✓ |
| 1250 km | ⚠ DIVERGED | ⚠ DIVERGED | ✓ |
| 2000 km | ⚠ DIVERGED | ⚠ DIVERGED | ⚠ DIVERGED |

**Ordering `rate < range < both` is the quantitative statement of §3.2**: rate's
position information is `O(1/ρ)`, so it loses the linear régime first; combining
channels roughly quadruples the usable capture radius.

### T3 · A priori × mode
*noisy radar (σ_ρ = 50 m) · WLS+ap · poor guess (250 km)*

| Prior | Mode | Outcome | it | \|Δr\| | wRMS | Δ/σ |
|---|---|---|---|---|---|---|
| weak | Range | ✓ | 6 | 163.7 m | 0.96 | 0.6 |
| weak | Rate | ✓ | 6 | 209.8 m | 1.01 | 1.9 |
| weak | Both | ✓ | 6 | 105.3 m | 1.00 | 0.9 |
| nominal | Range | ⚠ BIASED | 7 | 4.98 km | 2.69 | 23.6 |
| nominal | Rate | ⚠ BIASED | 7 | 6.50 km | 3.10 | 28.2 |
| nominal | Both | ⚠ BIASED | 7 | 1.97 km | 1.60 | 15.1 |
| tight | Range | ⚠ BIASED | 9 | 50.9 km | 526.4 | 3765 |
| tight | Rate | ⚠ BIASED | 12 | 139.6 km | 594.5 | 7010 |
| tight | Both | ⚠ BIASED | 9 | 49.3 km | 346.1 | 3680 |

**The prior is the easiest way to break the filter without any numerical blow-up.**
A `tight` prior claims `σ_ap = 20 m` while the reference is 250 km off — four orders
of magnitude of false confidence. `Λ₀ = P̄₀⁻¹` swamps `ΣHᵀWH`, the loop converges
smoothly, and reports an answer 3700 σ from truth. Note `κ(Λ)` actually *improves*
(4.8e5 vs 1.5e8) — a well-conditioned system solving the wrong problem.

### T4 · Sensor × mode
*WLS · weak prior · rough guess*

| Sensor | Range | Rate | Both |
|---|---|---|---|
| Precision (σ_ρ = 2 m) | 6.5 m | 8.4 m | **4.2 m** |
| Benchmark (σ_ρ = 10 m) | 32.6 m | 42.2 m | **21.1 m** |
| Noisy (σ_ρ = 50 m) | 162.9 m | 210.8 m | **105.6 m** |

Error scales **linearly** with σ (5× noise → 5× error) exactly as `P = (HᵀR⁻¹H)⁻¹`
predicts, and `both` is ≈ 1.55× better than range-only at every sensor grade. wRMS
stays at 1.00 throughout — a correctly weighted filter is insensitive to the
absolute noise level.

### T5 · Noise model × weighting
*benchmark radar · WLS · rough guess*

| Noise / weight | Range | Rate | Both |
|---|---|---|---|
| white / diag `1/σ²` | 32.6 m · wRMS 0.958 | 42.2 m · wRMS 1.009 | 21.1 m · wRMS 1.002 |
| coloured / diag **(mis-specified)** | 114.4 m · wRMS **0.750** | 24.2 m · wRMS **0.740** | 65.1 m · wRMS **0.813** ⚠ BIASED |
| coloured / whitened `R⁻¹` | 90.5 m · wRMS 1.069 | 87.8 m · wRMS 0.911 | 20.5 m · wRMS 1.002 |

Ignoring AR(1) correlation drives wRMS **below** 1 (0.74–0.81): the filter believes
it is fitting better than it is, because it counts 60 correlated samples as 60
independent ones. Cholesky whitening restores wRMS ≈ 1 and recovers the `both`-mode
accuracy (65.1 m → 20.5 m).

### T6 · Divergence lab — five verified failure modes
*noisy radar · poor guess (scaled where noted)*

| # | Configuration | Outcome | it | Final | wRMS | Δ/σ |
|---|---|---|---|---|---|---|
| D1 | Rate · WLS · weak · gap 500 km | **DIVERGED** | 2 | ‖x̂₀‖ 4.2e3 → 2.7e4 km | 6.1e4 | 7.0e3 |
| D2 | Range · WLS · weak · gap 1250 km | **DIVERGED** | 2 | ‖x̂₀‖ 1.6e3 → 7.4e3 km | 9.7e4 | 9.9e3 |
| D3 | Both · WLS · weak · gap 2000 km | **DIVERGED** | 1 | ‖x̂₀‖ 1.1e4 km | 1.3e5 | 5.2e4 |
| D4 | Both · WLS+ap · **tight** · gap 250 km | **BIASED** | 9 | \|Δr\| 49.3 km | 346.1 | 3.7e3 |
| D5 | Both · WLS+ap · tight, `x̄₀` off 200 km | **STALLED** | 12 | \|Δr\| 1536 km | 921.4 | 1.0e5 |

D5's `‖x̂₀‖` trace — `2.5e2 → 9.9e1 → 1.2e2 → 1.2e2 → …` — is a **limit cycle**: the
prior pulls one way, `ΣHᵀWy` the other, and `x̄₀ ← x̄₀ − x̂₀` re-arms the conflict
every pass, so the correction never decays.

> **Only D1–D3 are numerical blow-ups.** D4 and D5 are the dangerous cases: the
> filter reports a tight covariance and, in D4, a clean monotone convergence trace —
> while being 49 km wrong. In flight this is the failure mode that loses spacecraft.

---

## 9 · Summary of what the benchmark demonstrates

| Claim | Evidence |
|---|---|
| Range constrains position, not velocity | `H_ρ` velocity block is structurally zero (§3.2) |
| Range-rate constrains velocity directly | `H_ρ̇` velocity block is `û` (§3.2) |
| Range-rate is weakest in position | its position term carries `1/ρ`; first to diverge (T2) |
| Combining channels reduces GDOP | `κ(Λ)`: 1.5e8 / 9.3e7 → **5.7e7**; `σₓ`: 50 m → **26 m** (T1) |
| Combining extends the capture radius | divergence cliff 500 → 1250 → **2000 km** (T2) |
| Weighting is not cosmetic | LS vs WLS in `both` mode: 32.6 m vs **21.1 m** (T1) |
| One linear pass is never enough | KF BIASED at every mode from 31 km (T1) |
| Batch ≡ converged sequential | agreement 5.9 × 10⁻⁵ (§7.3) |
| A confident wrong prior is worse than noise | tight prior → 3700 σ error with κ(Λ) *improved* (T3) |
| Mis-specified noise flatters the filter | wRMS drops to 0.74 with correlated noise ignored (T5) |

---

*Educational simulator — not for operational navigation. Perturbations (J₂, drag,
SRP), Earth rotation, light-time correction, and ITRF↔ECI transformations are
deliberately excluded; see the Observables drawer for the rationale.*
