<div align="center">

# 🛰️ OD Console - ORBIT DETERMINATION Pipeline of Space Navigators

### Interactive orbit determination — batch **and** sequential, in one HTML file

**60 real range / range-rate observables · 7 estimators · 8 guided stages · no build step**

[![Live demo](https://img.shields.io/badge/▶_Live_demo-GitHub_Pages-45D6C4?style=for-the-badge)](https://2248220hub.github.io/Orbit_Determination_Simulator/)
[![Math reference](https://img.shields.io/badge/📐_Math_reference-MATH.md-7AA2F7?style=for-the-badge)](MATH.md)
[![License](https://img.shields.io/badge/License-MIT-FFB454?style=for-the-badge)](LICENSE)

`single file` · `zero dependencies to build` · `runs offline` · `phone → 4K`

</div>

---

## What this is

A spacecraft flies a planar two-body orbit around the Earth. You cannot see it. One
ground station measures **range** `ρ` and **range-rate** `ρ̇` sixty times over 590
seconds, each reading corrupted by noise. Your job is to recover the epoch state
`X₀ = [x, y, ẋ, ẏ]` — and to say honestly how uncertain you are.

OD Console walks you through that in eight stages, on real data, in real units
(km, km/s, s, `μ = 398 600.4418 km³/s²`), with a live 3D Earth and full telemetry.
Every estimator is really implemented — no canned answers, no hidden lookup tables.

**It will also let you get it wrong.** Pick a bad first guess or an over-confident
prior and the filter diverges, stalls, or converges confidently to the wrong state —
and the verdict banner tells you which, in red. That is the point.

---

## ⚡ Quick start

### 1 · Open it

**Online** → [**2248220hub.github.io/Orbit_Determination_Simulator**](https://2248220hub.github.io/Orbit_Determination_Simulator/)

**Offline** → download `OD_Simulator_V2.html`, double-click. That's the whole install.

> The 3D Earth pulls Three.js from a CDN on first load. Without internet it falls
> back to a procedural 2D globe and everything else works unchanged.

### 2 · Your first run — about 60 seconds

| | Stage | Do this |
|---|---|---|
| 1 | **Problem** | Leave **Both (ρ + ρ̇)** and **Benchmark radar** selected → **Run tracking pass ▸** |
| 2 | **Guess** | Pick **Gauss / Lambert**, then **Rough guess** → **Set reference orbit ▸** |
| 3 | **STM** | **Propagate Φ ▸** — watch the 4×4 matrix fill the telemetry strip |
| 4 | **O−C** | **Compute pre-fit residuals ▸** — the smooth wave *is* your state error |
| 5 | **H = H̃Φ** | **Accumulate Λ and N ▸** |
| 6 | **Solve** | **Solve Λx̂₀ = N ▸** |
| 7 | **Iterate** | **Auto-run ▸▸** — the correction shrinks ~quadratically |
| 8 | **Results** | Read the verdict, the covariance, and the three-mode comparison |

Every stage puts **Continue →** right next to its action button, so you never scroll
to advance.

### 3 · Then break it on purpose

| Try | Where | What you'll see |
|---|---|---|
| **Lost** first guess + **Range** only | Stage 2 | ⚠ **DIVERGED** — `‖x̂₀‖` grows `1.6e3 → 7.4e3` km, wRMS hits `10⁵` |
| Same **Lost** guess + **Both** | pill toggle, stages 4–7 | ✓ converges in 8 iterations — *the second channel saved it* |
| **Tight** a priori + **Poor** guess | Stage 4+ | ⚠ **BIASED** — converges beautifully to an answer **3700 σ** wrong |
| **Kalman** (not Extended) | Stage 4+ | ⚠ one linear pass can never absorb a nonlinear gap |
| **Coloured** noise, whitening off | Stage 1 | wRMS drops to **0.74** — the filter flatters itself |

> The **DIVERGED** cases are loud. The **BIASED** ones are the dangerous ones: the
> loop converges, the residual plot looks fine, the covariance ellipse is tight — and
> the answer is thousands of sigma off. That is the failure mode that loses spacecraft.

---

## 🗺️ What you're looking at

```
┌───────────────────────┬──────────────────────────────────────────────┐
│  STAGE PANEL          │  3D Earth · orbits · ground station          │
│  · observable toggle  │  ┌────────────┐  Δ true−reference zoom inset │
│  · estimator + prior  │  │ legend     │  auto-scales 250 km → µm     │
│  · formula cards      │  └────────────┘         ◀ OBSERVABLES  (tab) │
│  · action + Continue  │  telemetry ticker · ground track  ◀ ELEMENTS │
├───────────────────────┼───────────────────┬──────────────────────────┤
│                       │  residual plots   │  telemetry readout       │
└───────────────────────┴───────────────────┴──────────────────────────┘
```

| Element | What it gives you |
|---|---|
| 🎚️ **Observable toggle** | Range · Range-Rate · Both — live, at any stage, without losing progress |
| 🔎 **Δ zoom inset** | The full view can't show a gap shrinking from 250 km to centimetres. This pane auto-scales to whatever is left and updates every frame. |
| 📋 **OBSERVABLES drawer** | All 60 points with live pre-fit O−C, plus the benchmark methodology notes |
| 📐 **ELEMENTS drawer** | True vs estimated state vector and Keplerian elements, side by side |
| 📉 **Residual plots** | Split-canvas in Both mode: ρ cyan above, ρ̇ crimson below, each with its own axis, ±σ corridor and wRMS |
| ⚠️ **Verdict banner** | CONVERGED / SUSPECT / BIASED / STALLED / DIVERGED, with the reason |
| 📟 **Telemetry ticker** | Colour-coded engine log — every accumulation, inversion and warning |

---

## 🎯 The benchmark

| | |
|---|---|
| `μ` | 398 600.4418 km³ s⁻² |
| `R_E` | 6378.137 km |
| Station | (5800.000, 2650.000) km, fixed |
| `X_TRUE(t₀)` | [7000.000, 0.000, 0.000, 7.54605] km, km s⁻¹ |
| Orbit | `a` = 6999.994 km · `e` ≈ 8.7 × 10⁻⁷ · `T` = 5828.5 s |
| Arc | 60 samples · Δt = 10 s · t = 0 … 590 s (**10.1 %** of one revolution) |
| Noise | `σ_ρ` = 10 m · `σ_ρ̇` = 0.1 m s⁻¹ |

The 60 observables are **embedded in the file** as `BENCH_OBS`, so every run is
byte-for-byte reproducible. Across the pass `ρ` falls 2909 → 623 km and climbs back;
`ρ̇` sweeps −6.87 → +6.53 km s⁻¹.

<details>
<summary><b>Why a simulated single-pass dataset, not real SLR / DORIS telemetry?</b></summary>

<br>

**Simulated Tracking Benchmark Method.** To keep the simulator numerically clean,
verified, and free from multi-day tracking gaps or frame conversion ambiguities, this
scenario uses a single-pass ground station tracking dataset across 60 uniform time
steps (Δt = 10 s, T = 590 s), as standard in astrodynamics benchmarks
(Vallado; Tapley, Schutz & Born).

**Raw sensor telemetry (SLR, radar, DORIS, GNSS RINEX)** would additionally require
modelling high-degree gravity (J₂), atmospheric drag, solar radiation pressure (SRP),
Earth rotation (ω⊕ × r), and strict ITRF → ECI coordinate transformations — none of
which is what this tool is teaching. Archives: NASA CDDIS Portal · ILRS Global Data
Centers.

Both notes are reproduced inside the app's OBSERVABLES drawer.

</details>

---

## 📊 Results at a glance

Batch WLS, weak prior, benchmark radar, rough first guess — same 60 epochs, only the
observable set changes:

| Mode | `m` | wRMS | ‖Δr‖ | ‖Δv‖ | σₓ | κ(Λ) |
|---|---|---|---|---|---|---|
| Range (ρ) | 60 | 0.96 | 32.6 m | 86 mm/s | 50 m | 1.5 × 10⁸ |
| Range-Rate (ρ̇) | 60 | 1.01 | 42.2 m | 116 mm/s | 56 m | 9.3 × 10⁷ |
| **Both (ρ + ρ̇)** | 120 | **1.00** | **21.1 m** | **60 mm/s** | **26 m** | **5.7 × 10⁷** |

Adding the second channel **halves σₓ**, drops the condition number, and pushes the
radius of convergence out by 4× — with no extra tracking.

**Radius of convergence**, measured:

| Epoch gap | Range | Rate | Both |
|---|---|---|---|
| 250 km | ✓ | ✓ | ✓ |
| 500 km | ✓ | ⚠ DIVERGED | ✓ |
| 1250 km | ⚠ DIVERGED | ⚠ DIVERGED | ✓ |
| 2000 km | ⚠ DIVERGED | ⚠ DIVERGED | ⚠ DIVERGED |

The ordering **rate < range < both** falls straight out of the partials — range-rate's
position information carries a `1/ρ` factor, so it loses the linear régime first.

📐 **Full derivations, all six results matrices, and the numerical verification are in
[`MATH.md`](MATH.md).**

---

## 🧮 The seven estimators

| Filter | Weight `W` | Prior | Solution |
|---|---|---|---|
| **LS** | `I` | — | `x̂ = (HᵀH)⁻¹Hᵀy` |
| **WLS** | `diag(1/σ²)` | — | `x̂ = (HᵀWH)⁻¹HᵀWy` |
| **WLS + a priori** | `diag(1/σ²)` | `P̄₀` | `x̂ = (HᵀWH + P̄₀⁻¹)⁻¹(HᵀWy + P̄₀⁻¹x̄₀)` |
| **MVE** | `R⁻¹` | — | `x̂ = (HᵀR⁻¹H)⁻¹HᵀR⁻¹y` |
| **MVE + a priori** | `R⁻¹` | `P̄₀` | `x̂ = (HᵀR⁻¹H + P̄₀⁻¹)⁻¹(HᵀR⁻¹y + P̄₀⁻¹x̄₀)` |
| **Kalman** | per-epoch | `P̄₀` | `K = P̄H̃ᵀ(H̃P̄H̃ᵀ + R)⁻¹`, one linear pass |
| **Extended Kalman** | per-epoch | `P̄₀` | Kalman + re-linearise `X*₀ ← X̂₀` each pass |

Batch accumulation, with the a priori entering as pseudo-observations:

```
Λ = Σᵢ Hᵢᵀ W Hᵢ + P̄₀⁻¹          N = Σᵢ Hᵢᵀ W yᵢ + P̄₀⁻¹ x̄₀

x̂₀ = Λ⁻¹ N        P₀ = Λ⁻¹
```

Sequential filters do a `p×p` measurement update per epoch (1×1 for one channel, 2×2
for both) and map the result back to the epoch with `x̂₀ = Φ(t₆₀,t₀)⁻¹ x̂₆₀`, so the two
families are directly comparable — **and they agree to 5.9 × 10⁻⁵** once the EKF has
re-linearised.

<details>
<summary><b>Observation partials — the whole story in two rows</b></summary>

<br>

```
H_ρ  = [ û_x , û_y , 0 , 0 ]                          û = (r − r_sta)/ρ

H_ρ̇  = [ (ẋ−ẋ_s − ρ̇ û_x)/ρ , (ẏ−ẏ_s − ρ̇ û_y)/ρ , û_x , û_y ]
```

| | position block | velocity block |
|---|---|---|
| `H_ρ` | `û` — full strength | **structurally zero** |
| `H_ρ̇` | attenuated by `1/ρ` | `û` — full strength |

Range measures position along the line of sight and is *blind to velocity* at first
order — velocity is recovered only through `Φ`. Range-rate measures velocity along the
line of sight *directly*, but its position information is weaker by a factor `≈ ρ`.
Together they fill in each other's null spaces, which is exactly why `κ(Λ)` drops.

</details>

---

## ⚙️ Options

| Sensor | `σ_ρ` | `σ_ρ̇` | Data |
|---|---|---|---|
| Benchmark radar | 10 m | 0.1 m/s | replays the embedded array |
| Precision radar | 2 m | 0.02 m/s | re-synthesized |
| Noisy radar | 50 m | 0.5 m/s | re-synthesized |

| First guess | Offset | Outcome (WLS, benchmark radar) |
|---|---|---|
| Good | 2.5 km · 1.8 m/s | all modes ✓ 4 it |
| Rough | 31 km · 23 m/s | all modes ✓ 5 it |
| Poor | 250 km · 192 m/s | all modes ✓ 6 it |
| **Lost ⚠** | **1250 km** · 960 m/s | Range ⚠ · Rate ⚠ · **Both ✓ 8 it** |

| A priori `P̄₀` | σ (pos / vel) | Effect at the Poor guess |
|---|---|---|
| Weak | 100 km / 1 km s⁻¹ | invisible → pure WLS |
| Nominal | 1 km / 1 m s⁻¹ | ⚠ BIASED, 15–28 σ |
| Tight | 20 m / 0.05 m s⁻¹ | ⚠ BIASED, 3700–7000 σ |
| Custom | log sliders | your own σ and `x̄₀` offset |

Plus: white or AR(1) coloured noise (`ρ = 0.85`), with optional Cholesky whitening
`W = R⁻¹` over the full stacked `m × m` system.

---

## 🚀 Publish your own copy

`push.bat` does the whole thing on Windows — copy to `index.html`, init, commit,
remote, push, and switch Pages on if the GitHub CLI is available:

```bat
push.bat
```

It asks for your GitHub username and repository name (defaults:
`2248220hub` / `Orbit_Determination_Simulator`) and prints your live URL when it's
done. Non-interactive form:

```bat
push.bat https://github.com/<user>/<repo>.git "commit message"
```

<details>
<summary><b>Manual route, or non-Windows</b></summary>

<br>

```bash
cp OD_Simulator_V2.html index.html
git init && git branch -M main
git add index.html OD_Simulator_V2.html README.md MATH.md LICENSE push.bat
git commit -m "Publish OD Console V2"
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```

Then **Settings → Pages → Source: Deploy from a branch → main / (root) → Save**.
Live at `https://<user>.github.io/<repo>/` about a minute later.

Create the repository **empty** first (no README, no .gitignore, no licence) or the
first push will be rejected as a non-fast-forward.

</details>

| | |
|---|---|
| **Licence** | [MIT](LICENSE) — all code hand-written, no vendored libraries |
| **External requests** | Google Fonts (Source Serif 4, JetBrains Mono) + Three.js r128 CDN |
| **Offline** | Fully functional; 3D Earth → procedural 2D globe, fonts → system stacks |
| **Backend** | None. Also works on Netlify, Cloudflare Pages, Vercel, or `python -m http.server` |
| **Privacy** | No analytics, no cookies, no storage |

---

## 📱 Screen support

Fluid layout, not fixed breakpoints. Verified with **no horizontal overflow on any of
the 8 stages** at:

| Target | Width | Layout |
|---|---|---|
| Phone | 390 px | single column · full-width drawers · stacked plot + telemetry |
| Tablet | 768 px | single column · ground track hidden · Δ inset repositioned |
| Laptop | 1280–1440 px | two columns · all panes visible |
| Desktop | 1920 px | two columns · reading column capped at 620 px |
| Ultra-wide | 2000 px + | reading column widens to 760 px, base font scales up |

Wide content scrolls inside its own container, touch targets are ≥ 38 px on
pointer-less devices, and `prefers-reduced-motion` disables every transition.

---

## 📁 Repository contents

| File | |
|---|---|
| **`OD_Simulator_V2.html`** | The entire simulator — engine, UI, 3D scene, data |
| `index.html` | Copy of the above, served by GitHub Pages (made by `push.bat`) |
| **`README.md`** | This page |
| **[`MATH.md`](MATH.md)** | Complete mathematical reference — every equation, every numerical method, six verified results matrices |
| `push.bat` | One-click publisher |
| `LICENSE` | MIT |

---

## 🔧 Under the hood

- Planar two-body dynamics in real units; RK4 at a 1 s step over the coupled
  **20-dimensional** state + STM system, so `Φ` is always consistent with the
  trajectory it linearises about.
- All linear algebra hand-rolled — **no math libraries**: Gaussian elimination with
  partial pivoting, column-wise inversion, Cholesky whitening, generic `p×q` products
  for the 1×1 / 2×2 measurement updates, power-iteration condition number.
- Deterministic PRNG (mulberry32, seed 42) — every run reproduces exactly.
- Stage-8 comparison and the divergence lab run on a **private state object** restored
  in a `finally` block, so studying a configuration never disturbs your live journey.
- Typography: Source Serif 4 for all prose and controls; JetBrains Mono only where
  column alignment carries meaning.

---

<div align="center">

📐 **Want the derivations?** → [**MATH.md**](MATH.md)

*Educational simulator — not for operational navigation.*

</div>
