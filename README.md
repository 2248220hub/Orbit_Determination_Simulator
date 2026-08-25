<div align="center">

<h1>🛰️ OD Console</h1>

<h3>ORBIT DETERMINATION — Pipeline of Space Navigators</h3>

<p><i>Interactive orbit determination — batch <b>and</b> sequential, in one HTML file</i><br>
<b>60 real range / range-rate observables · 7 estimators · 8 guided stages · no build step</b></p>

[![Live demo](https://img.shields.io/badge/▶_Live_demo-GitHub_Pages-45D6C4?style=for-the-badge)](https://2248220hub.github.io/Orbit_Determination_Simulator/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Vinoth_Emberumal-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/YOUR-LINKEDIN-ID/)
[![License](https://img.shields.io/badge/License-MIT-FFB454?style=for-the-badge)](LICENSE)

<sub><b>single file</b> · <b>zero build dependencies</b> · <b>runs offline &amp; online</b> · <b>phone → 4K</b><br>
<code>orbit determination</code> · <code>astrodynamics</code> · <code>state estimation</code> · <code>batch &amp; sequential filters</code> ·
<code>a priori covariance</code> · <code>residuals</code> · <code>Kalman filter</code> · <code>space navigation</code></sub>

</div>

---

## 📖 Abstract

**Orbit determination** is the inverse problem at the heart of space navigation: the
state of a spacecraft is never observed directly, only through sparse, noisy and
nonlinear functions of it. **OD Console** is a self-contained interactive laboratory in
which *astronomy navigators* reconstruct an unknown epoch state
$X_0 = [x,\ y,\ \dot x,\ \dot y]^{\mathsf T}$ from a single ground-station tracking
pass. The **mathematical models** are those of classical space physics: the planar
restricted two-body **equations of motion**,
$\ddot{\mathbf r} = -\mu\,\mathbf r / r^{3}$ with
$\mu = 398\,600.4418\ \mathrm{km^3 s^{-2}}$, integrated in real physical units together
with their variational equations, and a nonlinear measurement model relating the state
to **range** $\rho$ and **range-rate** $\dot\rho$. The **observables** are a benchmark
dataset of 60 uniformly spaced measurements ($\Delta t = 10\ \mathrm{s}$,
$t = 0 \ldots 590\ \mathrm{s}$, an arc spanning 10.1 % of one revolution) from a fixed
station, corrupted by Gaussian noise at $\sigma_\rho = 10\ \mathrm{m}$ and
$\sigma_{\dot\rho} = 0.1\ \mathrm{m\,s^{-1}}$; the array is embedded verbatim, so every
run is bit-for-bit reproducible.

The **method** follows classical statistical orbit determination. A reference
trajectory $X^{\ast}(t)$ is propagated with its state-transition matrix
$\Phi(t,t_0)$ as one coupled 20-dimensional system; pre-fit **residuals**
$y_i = Y_i - G(X^{\ast}_i)$ are formed, the observation partials are mapped to the
epoch as $H_i = \tilde H_i\,\Phi(t_i,t_0)$, and the normal equations are accumulated and
solved before the reference is re-linearised. Seven estimators — least squares,
weighted least squares, minimum-variance, their **a priori** variants, and the Kalman
and Extended Kalman filters — let **batch and sequential filters** be compared on
identical data, with the a priori covariance $\bar P_0$ entering the information matrix
exactly like additional pseudo-observations. The **outcomes** are quantitative and
reproducible: combining both observables halves the position uncertainty
($\sigma_x$ 50 m → 26 m), lowers the condition number $\kappa(\Lambda)$ from
$1.5\times10^{8}$ to $5.7\times10^{7}$ — breaking the geometric dilution of precision —
and extends the radius of convergence fourfold. Equally instructive are the documented
failures: over-confident priors that converge smoothly to answers thousands of sigma
wrong, and mis-specified noise models that flatter the filter into reporting a weighted
RMS below unity.

> **References** — Prof. **Luciano Iess**, *Space Missions and Systems*, Sapienza
> Università di Roma · B. D. **Tapley**, B. E. Schutz, G. H. Born,
> *Statistical Orbit Determination*, Elsevier, 2004 · D. A. **Vallado**,
> *Fundamentals of Astrodynamics and Applications*.

---

## ⚙️ Simulator Core

<details>
<summary><b>🧭 &nbsp;1 · Guided eight-stage estimation journey</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Complete pipeline: problem setup → first guess → STM → residuals → normal equations → solve → iterate → results |
| 🧮 **Mathematics** | Each stage exposes its governing relation, evaluated on the live data — `Yᵢ = G(Xᵢ,tᵢ) + εᵢ` through `P₀ = Λ⁻¹` |
| 🎛️ **Controls** | **Continue →** sits beside every action button; stage chips jump back to any completed stage |
| 📊 **Readout** | Prose, formula cards and telemetry stay synchronised with the current selection |
| ✅ **Why it matters** | The pipeline is walked, not summarised — every intermediate quantity is inspectable |

</details>

<details>
<summary><b>📡 &nbsp;2 · Three selectable observable sets</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Range `ρ`, Range-Rate `ρ̇`, or Both — switchable at any stage without resetting progress |
| 🧮 **Mathematics** | Selection resizes the block `p`, and with it `H̃ᵢ`, `Hᵢ`, `W`, `R` and `m` everywhere downstream |
| 🎛️ **Controls** | Pill toggle carried by stages 4–7; `m = 60` for one channel, `m = 120` for two |
| 📊 **Readout** | Residual plots, normal equations and telemetry recompute at the *current* reference |
| ✅ **Why it matters** | Both channels are always recorded, so only derived quantities rebuild — never the data |

</details>

<details>
<summary><b>🧮 &nbsp;3 · Seven estimators — batch and sequential, with a priori</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | LS · WLS · WLS + a priori · MVE · MVE + a priori · Kalman · Extended Kalman on one shared engine |
| 🧮 **Mathematics** | Weighting spans `W = I`, `W = diag(1/σ²)` and the full `W = R⁻¹`; a priori adds `Λ ← Λ + P̄₀⁻¹` |
| 🎛️ **Controls** | Batch / Sequential tabs, estimator pills, and four a priori presets plus custom log sliders |
| 📊 **Readout** | Sequential filters run a `p×p` update per epoch, mapped back by `x̂₀ = Φ(t₆₀,t₀)⁻¹ x̂₆₀` |
| ✅ **Why it matters** | Converged EKF reproduces the batch solution to `5.9 × 10⁻⁵` relative — the equivalence is demonstrated, not asserted |

</details>

<details>
<summary><b>🌍 &nbsp;4 · Real-units two-body engine and variational equations</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Physical units throughout — km, km/s, s — with `μ = 398 600.4418 km³s⁻²`, no canonical scaling |
| 🧮 **Mathematics** | State and STM integrated as one coupled **20-dimensional** RK4 system at a 1 s step |
| 🎛️ **Controls** | 2D / 3D orbit view, manual Φ scrub slider, live Keplerian element panel |
| 📊 **Readout** | Gravity gradient satisfies `a₃₁ + a₄₂ = μ/r³` to 11 significant figures; `Φ(t₀,t₀) = I₄` exactly |
| ✅ **Why it matters** | All linear algebra hand-rolled — pivoted elimination, Cholesky, power iteration — with **no math libraries** |

</details>

<details>
<summary><b>📉 &nbsp;5 · Residual diagnostics and split-canvas plotting</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Pre-fit residuals expose the systematic signature; post-fit residuals should collapse to pure noise |
| 🧮 **Mathematics** | `y = Y − G(X*)` per channel, with `wRMS = √( Σⱼ (yⱼ/σⱼ)² / m )` |
| 🎛️ **Controls** | In *Both* mode the canvas splits into two stacked panes — ρ cyan above, ρ̇ crimson below |
| 📊 **Readout** | Per-channel wRMS and lag-1 autocorrelation `ρ̂`, each with its own `±σ` corridor |
| ✅ **Why it matters** | km and km/s never share an axis, so it is always clear which observable carries the leftover structure |

</details>

<details>
<summary><b>🧊 &nbsp;6 · Covariance and information analysis</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Full uncertainty report accompanies every estimate, not just the state |
| 🧮 **Mathematics** | `P₀ = Λ⁻¹` with 1σ per component, six correlation coefficients, trace and `log₁₀ det P` |
| 🎛️ **Controls** | Prior-versus-posterior covariance ellipse drawn at the epoch — dashed prior, solid posterior |
| 📊 **Readout** | Condition number `κ(Λ) = λmax(Λ)·λmax(Λ⁻¹)` by power iteration; consistency flagged beyond 3σ |
| ✅ **Why it matters** | Adding a second observable fills the weakly observed eigen-directions of `Λ` — GDOP made visible |

</details>

<details>
<summary><b>⚠️ &nbsp;7 · Failure taxonomy and divergence laboratory</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | Every run graded **CONVERGED · SUSPECT · BIASED · STALLED · DIVERGED**, with the reason stated |
| 🧮 **Mathematics** | Divergence declared past `5 × 10³ km`, or when the correction grows ×1.5 for three consecutive passes |
| 🎛️ **Controls** | A built-in lab runs five verified failure modes off-screen and loads any of them into the live journey |
| 📊 **Readout** | Iteration log with `‖x̂₀‖`, wRMS, shrink factor and `‖K‖` for the sequential filters |
| ✅ **Why it matters** | Separates loud numerical blow-ups from the dangerous silent ones — a tight covariance around a wrong state |

</details>

<details>
<summary><b>🔎 &nbsp;8 · Δ true−reference zoom inset</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | A dedicated pane magnifies the gap between the true and reference arcs, live during convergence |
| 🧮 **Mathematics** | Log-eased auto-scaling follows the separation from 1250 km down to micrometres |
| 🎛️ **Controls** | Always visible from the moment the tracking pass is recorded, through to the final estimate |
| 📊 **Readout** | Round-number scale bar plus live `max Δ` and `epoch Δ` in adaptive units |
| ✅ **Why it matters** | The only view that can show 1250 km and 21 m in the same run |

</details>

<details>
<summary><b>📋 &nbsp;9 · Observables drawer and data provenance</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | All 60 recorded points in a scrollable table: time, `ρ`, `ρ̇` and live pre-fit O−C per channel |
| 🧮 **Mathematics** | Deterministic mulberry32 stream (seed 42) through Box–Muller — every variant exactly reproducible |
| 🎛️ **Controls** | Channels excluded by the active mode display `—`, so the working set is never ambiguous |
| 📊 **Readout** | The dataset methodology note is carried in-app, not buried in documentation |
| ✅ **Why it matters** | States plainly what raw SLR / radar / DORIS / GNSS telemetry would additionally require |

</details>

<details>
<summary><b>🎛️ &nbsp;10 · Tactical display and coherent interface</b></summary>

<br>

|  |  |
|---|---|
| ⚙️ **Operation** | 3D textured Earth with a 2D/3D toggle and a procedural fallback when offline |
| 🧮 **Mathematics** | Ground-track minimap from the analytic sub-satellite point; live UTC / GPS / Julian-date clocks |
| 🎛️ **Controls** | Changing sensor, noise model, estimator, prior or observable set live-updates every derived quantity |
| 📊 **Readout** | Colour-coded telemetry ticker logs every accumulation, inversion and warning |
| ✅ **Why it matters** | Fluid layout verified with no horizontal overflow from 390 px phones to 2000 px+ displays |

</details>

---

## ⚡ Quick start

**1 · Open it**

🌐 **Online** → [2248220hub.github.io/Orbit_Determination_Simulator](https://2248220hub.github.io/Orbit_Determination_Simulator/)

💾 **Offline** → download `OD_Simulator_V2.html` and double-click. That is the whole install.

> The 3D Earth pulls Three.js from a CDN on first load. Without internet it falls back
> to a procedural 2D globe and everything else works unchanged.

**2 · First run, about 60 seconds** — accept the defaults (**Both** + **Benchmark radar**),
then walk the eight stages below, pressing each action button followed by **Continue →**.

---

## 🧭 The estimation loop (8 stages)

| # | Stage | What happens | Key relation |
|---|-------|--------------|--------------|
| 1 | **Problem** | Pick sensor quality + noise model; run a tracking pass | $Y_i = G(X_i,t_i) + \varepsilon_i$ |
| 2 | **Guess** | Choose a first reference $X^{\ast}_0$ (Lambert / Newton) | $x = X - X^{\ast}$ |
| 3 | **STM** | Propagate the state-transition matrix $\Phi(t,t_0)$ | $\dot\Phi = A\,\Phi,\quad \Phi(t_0,t_0)=I$ |
| 4 | **O−C** | Compute pre-fit residuals (observed − computed) | $y_i = Y_i - G(X^{\ast}_i)$ |
| 5 | **H = H̃Φ** | Map every observation back to the epoch | $H_i = \tilde H_i\,\Phi(t_i,t_0)$ |
| 6 | **Solve** | Form and invert the normal equations | $\hat x_0 = \Lambda^{-1} N$ |
| 7 | **Iterate** | Update reference, re-linearise, repeat | $X^{\ast}_0 \leftarrow X^{\ast}_0 + \hat x_0$ |
| 8 | **Results** | Estimate, covariance, consistency report | $P_0 = \Lambda^{-1}$ |

---

## 🧮 Estimators

| Filter | Weight $W$ | Prior | Solution |
|--------|-----------|-------|----------|
| **LS** | $I$ | — | $\hat x = (H^{\mathsf T}H)^{-1}H^{\mathsf T}y$ |
| **WLS** | $1/\sigma^{2}$ | — | $\hat x = (H^{\mathsf T}WH)^{-1}H^{\mathsf T}Wy$ |
| **WLS + a priori** | $1/\sigma^{2}$ | $\bar P_0$ | $\hat x = (H^{\mathsf T}WH+\bar P^{-1})^{-1}(H^{\mathsf T}Wy+\bar P^{-1}\bar x)$ |
| **MVE** | $R^{-1}$ | — | $\hat x = (H^{\mathsf T}R^{-1}H)^{-1}H^{\mathsf T}R^{-1}y$ |
| **MVE + a priori** | $R^{-1}$ | $\bar P_0$ | $\hat x = (H^{\mathsf T}R^{-1}H+\bar P^{-1})^{-1}(H^{\mathsf T}R^{-1}y+\bar P^{-1}\bar x)$ |
| **Kalman (KF)** | per-obs | $\bar P_0$ | $K = \bar P\tilde H^{\mathsf T}(\tilde H\bar P\tilde H^{\mathsf T}+R)^{-1}$ |
| **Extended KF** | per-obs | $\bar P_0$ | KF + relinearise, re-propagate each pass |

The batch update, with the a priori entering exactly like extra measurements:

$$\Lambda = \sum_i H_i^{\mathsf T} W H_i + \bar P_0^{-1}
\qquad\qquad
N = \sum_i H_i^{\mathsf T} W y_i + \bar P_0^{-1}\bar x_0$$

$$\hat x_0 = \Lambda^{-1} N \qquad\qquad P_0 = \Lambda^{-1}$$

The sequential update, one epoch at a time:

$$K = \bar P\,\tilde H^{\mathsf T}\left(\tilde H\,\bar P\,\tilde H^{\mathsf T} + R\right)^{-1}
\qquad
\hat x = \bar x + K\left(y - \tilde H\bar x\right)
\qquad
P = \left(I - K\tilde H\right)\bar P$$

> ⚖️ **Batch vs sequential** — the batch update uses all historical data at once
> ($\Lambda$ = information matrix, $N$ = accumulated information vector). KF and EKF
> process one observation at a time through the Kalman gain $K$. The two agree once the
> EKF has re-linearised.

---

## 🛰️ The benchmark scenario

| Quantity | Value |
|---|---|
| Gravitational parameter $\mu$ | $398\,600.4418\ \mathrm{km^3 s^{-2}}$ |
| Earth radius $R_E$ | $6378.137\ \mathrm{km}$ |
| Ground station | $(5800.000,\ 2650.000)\ \mathrm{km}$, fixed |
| True epoch state $X_{\mathrm{TRUE}}(t_0)$ | $[7000.000,\ 0.000,\ 0.000,\ 7.54605]$ km, km/s |
| Derived orbit | $a = 6999.994\ \mathrm{km}$, $e \approx 8.7\times10^{-7}$, $T = 5828.5\ \mathrm{s}$ |
| Tracking arc | 60 samples, $\Delta t = 10\ \mathrm{s}$, $t = 0 \ldots 590\ \mathrm{s}$ |
| Noise | $\sigma_\rho = 10\ \mathrm{m}$, $\sigma_{\dot\rho} = 0.1\ \mathrm{m\,s^{-1}}$ |

<details>
<summary><b>📊 &nbsp;The 60 embedded observables — <code>BENCH_OBS</code></b></summary>

<br>

Generated from $X_{\mathrm{TRUE}}$ by the same two-body propagator and corrupted with
white Gaussian noise. Embedded verbatim in the HTML, so every run is bit-for-bit
reproducible. Across the pass $\rho$ falls from 2909 km through a 623 km closest
approach and climbs back, while $\dot\rho$ sweeps $-6.87 \to +6.53\ \mathrm{km\,s^{-1}}$.

| # | t (s) | ρ (km) | ρ̇ (km/s) | # | t (s) | ρ (km) | ρ̇ (km/s) |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 01 | 0 | 2909.028080 | −6.8741331 | 31 | 300 | 939.021590 | −5.3794071 |
| 02 | 10 | 2840.278254 | −6.8740677 | 32 | 310 | 886.509696 | −5.1160262 |
| 03 | 20 | 2771.556076 | −6.8728383 | 33 | 320 | 836.890990 | −4.8019922 |
| 04 | 30 | 2702.837782 | −6.8712427 | 34 | 330 | 790.664880 | −4.4283969 |
| 05 | 40 | 2634.136726 | −6.8685114 | 35 | 340 | 748.549031 | −3.9863112 |
| 06 | 50 | 2565.485997 | −6.8641394 | 36 | 350 | 711.204451 | −3.4675250 |
| 07 | 60 | 2496.877502 | −6.8590969 | 37 | 360 | 679.442334 | −2.8668934 |
| 08 | 70 | 2428.312968 | −6.8526581 | 38 | 370 | 654.122046 | −2.1853478 |
| 09 | 80 | 2359.816226 | −6.8451359 | 39 | 380 | 635.978776 | −1.4323760 |
| 10 | 90 | 2291.431455 | −6.8357742 | 40 | 390 | 625.651030 | −0.6269869 |
| 11 | 100 | 2223.093630 | −6.8247339 | 41 | 400 | 623.532983 | +0.2027870 |
| 12 | 110 | 2154.924860 | −6.8117389 | 42 | 410 | 629.699715 | +1.0247657 |
| 13 | 120 | 2086.871222 | −6.7968759 | 43 | 420 | 643.895986 | +1.8073909 |
| 14 | 130 | 2018.989707 | −6.7793302 | 44 | 430 | 665.634713 | +2.5273599 |
| 15 | 140 | 1951.294008 | −6.7592770 | 45 | 440 | 694.196012 | +3.1701505 |
| 16 | 150 | 1883.837734 | −6.7363513 | 46 | 450 | 728.750196 | +3.7304229 |
| 17 | 160 | 1816.592378 | −6.7097195 | 47 | 460 | 768.529264 | +4.2110354 |
| 18 | 170 | 1749.635796 | −6.6791725 | 48 | 470 | 812.732391 | +4.6187017 |
| 19 | 180 | 1683.020262 | −6.6440124 | 49 | 480 | 860.694084 | +4.9620442 |
| 20 | 190 | 1616.778742 | −6.6041198 | 50 | 490 | 911.784417 | +5.2502882 |
| 21 | 200 | 1550.943206 | −6.5577513 | 51 | 500 | 965.532696 | +5.4922707 |
| 22 | 210 | 1485.623546 | −6.5044030 | 52 | 510 | 1021.499950 | +5.6958047 |
| 23 | 220 | 1420.896161 | −6.4428584 | 53 | 520 | 1079.339779 | +5.8672165 |
| 24 | 230 | 1356.828888 | −6.3713271 | 54 | 530 | 1138.771103 | +6.0121980 |
| 25 | 240 | 1293.513817 | −6.2884608 | 55 | 540 | 1199.542554 | +6.1354942 |
| 26 | 250 | 1231.101742 | −6.1913536 | 56 | 550 | 1261.414531 | +6.2404654 |
| 27 | 260 | 1169.733367 | −6.0780683 | 57 | 560 | 1324.275161 | +6.3305165 |
| 28 | 270 | 1109.594592 | −5.9445296 | 58 | 570 | 1387.961983 | +6.4074411 |
| 29 | 280 | 1050.931781 | −5.7871723 | 59 | 580 | 1452.393196 | +6.4738329 |
| 30 | 290 | 993.966907 | −5.6008921 | 60 | 590 | 1517.414280 | +6.5312373 |

</details>

<details>
<summary><b>🧪 &nbsp;Data synthesis methodology</b></summary>

<br>

**Why a simulated single-pass dataset.** To keep the simulator numerically clean,
verified, and free from multi-day tracking gaps or frame-conversion ambiguities, the
scenario uses a single-pass ground-station tracking dataset across 60 uniform time
steps ($\Delta t = 10\ \mathrm{s}$, $T = 590\ \mathrm{s}$), as standard in
astrodynamics benchmarks (Vallado; Tapley, Schutz & Born).

**What raw telemetry would demand.** Processing direct network measurements — SLR,
radar, DORIS, GNSS RINEX — additionally requires modelling high-degree gravity
($J_2$), atmospheric drag, solar radiation pressure, Earth rotation
($\omega_\oplus \times \mathbf{r}$), and strict ITRF → ECI transformations.
Archives: NASA CDDIS Portal · ILRS Global Data Centers.

**Generation.** Truth is propagated by RK4 at a 1 s step; noise is drawn from a
deterministic mulberry32 stream (seed 42) through a Box–Muller transform, so the
benchmark array is exactly reproducible and the other sensor grades are re-synthesised
from the same seed.

| Sensor | σ_ρ | σ_ρ̇ | Data |
|---|---|---|---|
| **Benchmark radar** | 10 m | 0.1 m/s | replays the embedded array |
| **Precision radar** | 2 m | 0.02 m/s | re-synthesised |
| **Noisy radar** | 50 m | 0.5 m/s | re-synthesised |

Plus white **or** AR(1) **coloured noise** ($\rho = 0.85$), with optional Cholesky
whitening $W = R^{-1}$ over the full stacked $m \times m$ system:

$$R_{(i,c)(j,c)} = \sigma_c^{2}\,\rho^{\lvert i-j\rvert},
\qquad
R_{(i,c)(j,c')} = 0 \quad (c \neq c')$$

</details>

---

## 🎯 First guess and a priori

Two deterministic point-solution methods seed the reference trajectory:

| Method | Principle | Yields |
|---|---|---|
| **Gauss / Lambert** | Two positions and the time between them fix the connecting orbit; solve the time-of-flight equation and recover the epoch velocity from the Lagrange `f, g` coefficients | `X*₀ = [r₁, v₁]` |
| **Newton–Raphson** | Iterate a trial epoch state against the cost gradient, `X₀ⁿ⁺¹ = X₀ⁿ − [∂J/∂X₀]⁻¹ J(X₀ⁿ)`, until `‖ΔX₀‖ < ε` | refined `X*₀` |

| First guess | Offset | Outcome (WLS, benchmark radar) |
|---|---|---|
| **Good** | 2.5 km · 1.8 m/s | all modes ✓ 4 it |
| **Rough** | 31 km · 23 m/s | all modes ✓ 5 it |
| **Poor** | 250 km · 192 m/s | all modes ✓ 6 it |
| **Lost ⚠** | 1250 km · 960 m/s | Range ⚠ · Rate ⚠ · **Both ✓ 8 it** |

| A priori P̄₀ | σ (pos / vel) | Effect at the Poor guess |
|---|---|---|
| **Weak** | 100 km / 1 km s⁻¹ | invisible → pure WLS |
| **Nominal** | 1 km / 1 m s⁻¹ | ⚠ BIASED, 15–28 σ |
| **Tight** | 20 m / 0.05 m s⁻¹ | ⚠ BIASED, 3700–7000 σ |
| **Custom** | log sliders | your own σ and x̄₀ offset |

---

## 📊 Plots and results

| View | Shows | Significance |
|---|---|---|
| 🌍 **2D / 3D orbit display** | True, reference and estimated orbits over a textured Earth | The reference visibly snaps onto truth as the loop converges |
| 📈 **Observed data plot** | ρ and/or ρ̇ against time | The raw measurement geometry — closest approach and the ρ̇ sign change |
| 🌊 **Pre-fit residuals** | `y = Y − G(X*)`, connected | A smooth oscillation *is* the state error projected through the geometry |
| ✅ **Post-fit residuals** | The same, as scatter | Should collapse to unstructured noise; the title states wRMS honestly |
| 🪟 **Split-canvas panes** | ρ cyan above, ρ̇ crimson below | Separate axes because km and km/s do not share a scale |
| 📏 **±σ corridor** | Per-channel noise band | Residuals outside it mean unmodelled signal, not measurement error |
| 🔻 **‖x̂₀‖ per iteration** | Log-scale correction magnitude | Newton-like quadratic shrink; a flat or rising trace is failure |
| ⭕ **Covariance ellipse** | Prior dashed vs posterior solid at the epoch | Visualises how much information the data actually added |
| 🔎 **Δ true−reference inset** | Magnified gap between the arcs | The only view that can show 1250 km and 21 m in the same run |
| 🗺️ **Ground-track minimap** | Sub-satellite trace | Places the tracking arc on the rotating Earth |
| 📟 **Telemetry readout** | 1σ, correlations, κ(Λ), trace and log-determinant | The uncertainty report navigation cares about as much as the state |
| 📋 **Observables drawer** | 60 rows with live O−C | Ties every plotted point back to a number you can read |
| 🔬 **Mode comparison matrix** | Active filter across all three observable sets | Isolates the effect of the observable choice alone |
| 📜 **Iteration log** | ‖x̂₀‖, wRMS, shrink factor, ‖K‖ | The convergence history in numbers |
| ⚠️ **Verdict banner** | CONVERGED / SUSPECT / BIASED / STALLED / DIVERGED | One honest grade for the whole run |

### Mode performance — measured

Batch WLS, weak prior, benchmark radar, rough first guess. Same 60 epochs; only the
observable set changes.

| Mode | m | wRMS | ‖Δr‖ | ‖Δv‖ | σₓ | κ(Λ) |
|---|---|---|---|---|---|---|
| Range (ρ) | 60 | 0.96 | 32.6 m | 86 mm/s | 50 m | 1.5 × 10⁸ |
| Range-Rate (ρ̇) | 60 | 1.01 | 42.2 m | 116 mm/s | 56 m | 9.3 × 10⁷ |
| **Both (ρ + ρ̇)** | **120** | **1.00** | **21.1 m** | **60 mm/s** | **26 m** | **5.7 × 10⁷** |

### Radius of convergence — measured

| Epoch gap | Range | Rate | Both |
|---|---|---|---|
| 250 km | ✓ | ✓ | ✓ |
| 500 km | ✓ | ⚠ DIVERGED | ✓ |
| 1250 km | ⚠ DIVERGED | ⚠ DIVERGED | ✓ |
| 2000 km | ⚠ DIVERGED | ⚠ DIVERGED | ⚠ DIVERGED |

The ordering **rate < range < both** follows directly from the partials: range-rate's
position information carries a $1/\rho$ factor, so it leaves the linear régime first.

---

## 🚨 Then break it on purpose

| Try | Where | What you'll see |
|---|---|---|
| **Lost** first guess + **Range** only | Stage 2 | ⚠ **DIVERGED** — ‖x̂₀‖ grows 1.6e3 → 7.4e3 km, wRMS hits 10⁵ |
| Same **Lost** guess + **Both** | pill toggle, stages 4–7 | ✓ converges in 8 iterations — *the second channel saved it* |
| **Tight** a priori + **Poor** guess | Stage 4+ | ⚠ **BIASED** — converges beautifully to an answer 3700 σ wrong |
| **Kalman** (not Extended) | Stage 4+ | ⚠ one linear pass can never absorb a nonlinear gap |
| **Coloured** noise, whitening off | Stage 1 | wRMS drops to **0.74** — the filter flatters itself |

### The three outcomes

| Verdict | Condition | What it means |
|---|---|---|
| ✅ **CONVERGED** | Correction below ε, truth within 3σ, wRMS ≈ 1 | The state is trustworthy and the covariance covers the real error |
| 🟠 **BIASED** | The loop settled, but truth lies outside the reported 3σ | **Confidently wrong.** Residuals look plausible, the ellipse is tight, the answer is thousands of σ off |
| 🔴 **DIVERGED** | ‖x̂₀‖ past 5 × 10³ km, or growing ×1.5 for three passes | The linearisation about `X*₀` is invalid; each pass makes the reference worse |

> The **DIVERGED** cases are loud and unmistakable. The **BIASED** ones are the
> dangerous ones: the loop converges, the residual plot looks fine, the covariance
> ellipse is tight — and the answer is thousands of sigma off. That is the failure
> mode that loses spacecraft, and it is exactly what the verdict banner exists to catch.

---

## 📁 Repository contents

| File |  |
|---|---|
| **`OD_Simulator_V2.html`** | The entire simulator — engine, UI, 3D scene, embedded data |
| `index.html` | Copy served by GitHub Pages, created by `push.bat` |
| `README.md` | This page |
| `push.bat` | One-click publisher to GitHub Pages |
| `LICENSE` | MIT |

---

<div align="center">

<sub>Educational simulator — not for operational navigation.</sub>

<b>Vinoth Emberumal</b><br>
<sub>MSc Space &amp; Astronautical Engineering · Sapienza Università di Roma</sub>

[![LinkedIn](https://img.shields.io/badge/Connect_on_LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/YOUR-LINKEDIN-ID/)

</div>
