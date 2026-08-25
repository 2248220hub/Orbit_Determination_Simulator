<div align="center">

<h1>🛰️ OD Console</h1>

<h3>ORBIT DETERMINATION — Pipeline of Space Navigators</h3>

<p><i>Interactive orbit determination — batch <b>and</b> sequential, in one HTML file</i><br>
<b>60 real range / range-rate observables · 7 estimators · 8 guided stages · no build step</b></p>

[![Live demo](https://img.shields.io/badge/▶_Live_demo-GitHub_Pages-45D6C4?style=for-the-badge)](https://2248220hub.github.io/Orbit_Determination_Simulator/)
[![Math reference](https://img.shields.io/badge/📐_Math_reference-MATH.md-7AA2F7?style=for-the-badge)](MATH.md)
[![Demo reel](https://img.shields.io/badge/🎬_60s_demo_reel-demo/-FF6B7A?style=for-the-badge)](demo/)
[![License](https://img.shields.io/badge/License-MIT-FFB454?style=for-the-badge)](LICENSE)

<sub><b>single file</b> · <b>zero build dependencies</b> · <b>runs offline &amp; online</b> · <b>phone → 4K</b><br>
<code>orbit determination</code> · <code>astrodynamics</code> · <code>state estimation</code> · <code>Kalman filter</code> ·
<code>least squares</code> · <code>covariance analysis</code> · <code>space navigation</code></sub>

</div>

---

## 📖 Abstract

**Orbit determination** is the inverse problem at the heart of space navigation: a
spacecraft state is never observed directly, only through sparse, noisy, nonlinear
functions of it. **OD Console** is a self-contained interactive laboratory in which
*astronomy navigators* reconstruct an unknown epoch state
$X_0=[x,\ y,\ \dot x,\ \dot y]^{\mathsf T}$ from a single ground-station tracking pass.
The spacecraft obeys the planar restricted two-body **equations of motion**,
$\ddot{\mathbf r}=-\mu\,\mathbf r/r^{3}$ with
$\mu = 398\,600.4418\ \mathrm{km^3 s^{-2}}$, integrated in real physical units
alongside its variational equations. Every quantity on screen — orbit, residual,
gain, covariance — is produced by the estimator actually running, not by a scripted
animation.

The **observables** are a benchmark dataset of 60 uniformly spaced measurements
($\Delta t = 10\ \mathrm{s}$, $t = 0 \ldots 590\ \mathrm{s}$, an arc spanning
10.1 % of one revolution) of **range** $\rho$ and **range-rate** $\dot\rho$ from a
fixed station at $(5800.000,\ 2650.000)\ \mathrm{km}$, corrupted by white Gaussian
noise at $\sigma_\rho = 10\ \mathrm{m}$ and
$\sigma_{\dot\rho} = 0.1\ \mathrm{m\,s^{-1}}$. Across the pass the geometry is
strongly observable: $\rho$ falls from 2909 km through a 623 km closest approach and
climbs back, while $\dot\rho$ sweeps $-6.87 \to +6.53\ \mathrm{km\,s^{-1}}$. The array
is embedded verbatim in the file, so every run is bit-for-bit reproducible; a
deterministic generator can re-synthesise the same pass at other sensor grades or
under an AR(1) coloured-noise model.

The **method** follows classical statistical orbit determination. A reference
trajectory $X^{*}(t)$ is propagated together with the state-transition matrix
$\Phi(t,t_0)$ as one coupled 20-dimensional system; observation partials
$\tilde H = [\partial G/\partial X]^{*}$ are mapped to the epoch as
$H_i = \tilde H_i\,\Phi(t_i,t_0)$; the normal equations are accumulated and solved,
and the reference is re-linearised until the correction vanishes. Seven estimators —
LS, WLS, WLS + a priori, MVE, MVE + a priori, Kalman and Extended Kalman — share the
same engine, letting **batch** and **sequential** philosophies be compared on identical
data. The **scientific outcomes** are quantitative and reproducible: combining both
observables halves the position uncertainty ($\sigma_x$ 50 m → 26 m), lowers the
condition number $\kappa(\Lambda)$ from $1.5\times10^{8}$ to $5.7\times10^{7}$ —
breaking the geometric dilution of precision — and extends the radius of convergence
fourfold, from 500 km (rate-only) to 2000 km (combined). Equally instructive are the
documented failures: over-confident priors that converge smoothly to answers
thousands of sigma wrong, and mis-specified noise models that flatter the filter into
reporting wRMS &lt; 1.

> **References** — Prof. **Luciano Iess**, *Space Missions and Systems* (Sapienza
> Università di Roma) · B. D. **Tapley**, B. E. Schutz, G. H. Born,
> *Statistical Orbit Determination*, Elsevier, 2004 · D. A. **Vallado**,
> *Fundamentals of Astrodynamics and Applications*.

---

## ✨ Features

<details>
<summary><b>🧭 &nbsp;1 · Guided 8-stage estimation journey</b></summary>

<br>

🧭 Complete pipeline from problem setup → first guess → STM → residuals → normal equations → solve → iterate → results.
🔁 Each stage exposes its own governing relation as a formula card, evaluated on the live data.
⏭️ **Continue →** sits beside every action button, so no stage requires scrolling to advance.
🔢 Stage chips let you jump back to any completed stage without losing the run.
📖 Prose, mathematics and telemetry stay synchronised with whatever you have selected.

</details>

<details>
<summary><b>📡 &nbsp;2 · Three selectable observable sets</b></summary>

<br>

📡 **Range** $\rho$, **Range-Rate** $\dot\rho$, or **Both** — switchable at any stage without resetting progress.
📐 Selection resizes the measurement block $p$ and therefore $\tilde H_i$, $H_i$, $W$, $R$ and $m$ everywhere downstream.
🧮 $m = 60$ scalar measurements for one channel, $m = 120$ for two.
♻️ Both channels are always recorded, so only derived quantities rebuild — never the data.
📊 Residual plots, normal equations and telemetry recompute at the *current* reference.

</details>

<details>
<summary><b>🧮 &nbsp;3 · Seven estimators, batch and sequential</b></summary>

<br>

🧮 LS · WLS · WLS + a priori · MVE · MVE + a priori · Kalman · Extended Kalman on one shared engine.
⚖️ Weighting spans $W = I$, $W = \mathrm{diag}(1/\sigma^2)$ and the full $W = R^{-1}$.
🎯 A priori enters as pseudo-observations: $\Lambda \mathrel{+}= \bar P_0^{-1}$, $N \mathrel{+}= \bar P_0^{-1}\bar x_0$.
🔗 Sequential filters run a $p\times p$ update per epoch and map back with $\hat x_0 = \Phi(t_{60},t_0)^{-1}\hat x_{60}$.
✅ Converged EKF reproduces the batch solution to $5.9\times10^{-5}$ relative.

</details>

<details>
<summary><b>🌍 &nbsp;4 · Real-units two-body engine with variational equations</b></summary>

<br>

🌍 Physical units throughout — km, km/s, s — with $\mu = 398\,600.4418\ \mathrm{km^3 s^{-2}}$, no canonical scaling.
🛰️ State and STM integrated as one coupled **20-dimensional** RK4 system at a 1 s step.
📉 Gravity gradient $A = [\partial F/\partial X]^{*}$ satisfies $a_{31}+a_{42} = \mu/r^{3}$ to 11 significant figures.
🧭 Keplerian elements derived live from the planar state; $\Phi(t_0,t_0)=I_4$ exactly.
➗ All linear algebra hand-rolled — pivoted elimination, Cholesky, power iteration — with **no math libraries**.

</details>

<details>
<summary><b>📉 &nbsp;5 · Split-canvas residual diagnostics</b></summary>

<br>

📉 Range residuals in **cyan** (km), range-rate residuals in **crimson** (km/s), never mixed onto one axis.
🪟 In *Both* mode the plot canvas splits into two stacked panes, each with its own scale and $\pm\sigma$ corridor.
📏 Per-channel wRMS reported separately, so you can see which observable still carries structure.
🔬 Lag-1 autocorrelation $\hat\rho$ shown whenever a coloured-noise model is active.
🌊 Pre-fit residuals expose the systematic signature; post-fit should collapse to pure noise.

</details>

<details>
<summary><b>🧊 &nbsp;6 · Covariance and information analysis</b></summary>

<br>

🧊 $P_0 = \Lambda^{-1}$ with 1σ per component, all six correlation coefficients, trace and $\log_{10}|P|$.
🔢 Condition number $\kappa(\Lambda) = \lambda_{\max}(\Lambda)\cdot\lambda_{\max}(\Lambda^{-1})$ by power iteration.
📐 Prior-versus-posterior covariance ellipse drawn at the epoch — dashed prior, solid posterior.
✔️ Consistency check reports $|\Delta|/\sigma$ per state and flags anything beyond 3σ.
📡 GDOP interpretation: adding a second observable fills the weakly observed eigen-directions of $\Lambda$.

</details>

<details>
<summary><b>⚠️ &nbsp;7 · Failure taxonomy and the divergence lab</b></summary>

<br>

⚠️ Every run is graded **CONVERGED · SUSPECT · BIASED · STALLED · DIVERGED**, with the reason stated.
🔬 A built-in lab runs five verified failure modes off-screen and lets you load any of them into the live journey.
📈 A growth detector flags a correction that grows ×1.5 for three passes, before it reaches the hard limit.
🎭 Distinguishes loud numerical blow-ups from the dangerous silent ones — a tight covariance around a wrong state.
🧪 All failure cases are measured at render time, never hard-coded.

</details>

<details>
<summary><b>🔎 &nbsp;8 · Δ true−reference zoom inset</b></summary>

<br>

🔎 A dedicated pane magnifies the gap between the true and reference arcs, live during convergence.
🔭 Log-eased auto-scaling follows the separation from 1250 km down to micrometres.
📌 Per-epoch whiskers connect matching samples so the shape of the error is visible, not just its size.
📏 Round-number scale bar plus live `max Δ` and `epoch Δ` readouts in adaptive units.
🎨 The reference arc turns from amber to blue at the moment the solution is accepted.

</details>

<details>
<summary><b>📋 &nbsp;9 · Observables drawer and benchmark provenance</b></summary>

<br>

📋 All 60 recorded points in a scrollable table: time, $\rho$, $\dot\rho$ and live pre-fit O−C per channel.
🚫 Channels excluded by the active mode are shown as `—`, so the working set is never ambiguous.
📜 The dataset methodology note is carried in-app, not buried in documentation.
🛰️ States plainly what raw SLR / radar / DORIS / GNSS telemetry would additionally require.
🔁 Deterministic PRNG (seed 42) makes every synthesised variant exactly reproducible.

</details>

<details>
<summary><b>🎛️ &nbsp;10 · Tactical display and coherent interface</b></summary>

<br>

🎛️ 3D textured Earth (Three.js) with a 2D/3D toggle, procedural fallback when offline.
🗺️ Ground-track minimap, colour-coded telemetry ticker, and live UTC / GPS / Julian-date clocks.
🔊 WebAudio click feedback and a convergence chime, silenced during off-screen study runs.
🔄 Changing sensor, noise model, estimator, prior or observable set live-updates every derived quantity.
📱 Fluid layout verified with no horizontal overflow from 390 px phones to 2000 px+ displays.

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
| 2 | **Guess** | Choose a first reference $X^{*}_0$ (Lambert / Newton) | $x = X - X^{*}$ |
| 3 | **STM** | Propagate the state-transition matrix $\Phi(t,t_0)$ | $\dot\Phi = A\,\Phi,\quad \Phi(t_0,t_0)=I$ |
| 4 | **O−C** | Compute pre-fit residuals (observed − computed) | $y_i = Y_i - G(X^{*}_i)$ |
| 5 | **H = H̃Φ** | Map every observation back to the epoch | $H_i = \tilde H_i\,\Phi(t_i,t_0)$ |
| 6 | **Solve** | Form and invert the normal equations | $\hat x_0 = \Lambda^{-1} N$ |
| 7 | **Iterate** | Update reference, re-linearise, repeat | $X^{*}_0 \leftarrow X^{*}_0 + \hat x_0$ |
| 8 | **Results** | Estimate, covariance, consistency report | $P_0 = \Lambda^{-1}$ |

---

## 🧮 Estimators

| Filter | Weight $W$ | Prior | Solution |
|--------|-----------|-------|----------|
| **LS** | $I$ | — | $\hat x = (H^{\mathsf T}H)^{-1}H^{\mathsf T}y,\quad P=(H^{\mathsf T}H)^{-1}\sigma^{2}$ |
| **WLS** | $1/\sigma^{2}$ | — | $\hat x = (H^{\mathsf T}WH)^{-1}H^{\mathsf T}Wy$ |
| **WLS + a priori** | $1/\sigma^{2}$ | $\bar P_0$ | $\hat x = (H^{\mathsf T}WH+\bar P^{-1})^{-1}(H^{\mathsf T}Wy+\bar P^{-1}\bar x)$ |
| **MVE** | $R^{-1}$ | — | $\hat x = (H^{\mathsf T}R^{-1}H)^{-1}H^{\mathsf T}R^{-1}y$ |
| **MVE + a priori** | $R^{-1}$ | $\bar P_0$ | $\hat x = (H^{\mathsf T}R^{-1}H+\bar P^{-1})^{-1}(H^{\mathsf T}R^{-1}y+\bar P^{-1}\bar x)$ |
| **Kalman (KF)** | per-obs | $\bar P_0$ | $K = \bar P\tilde H^{\mathsf T}(\tilde H\bar P\tilde H^{\mathsf T}+R)^{-1},\quad \hat x = \bar x + K(y-\tilde H\bar x)$ |
| **Extended KF** | per-obs | $\bar P_0$ | KF + relinearise: $X^{*}_0 \leftarrow \hat X_0$, re-propagate each pass |

Batch accumulation, with the a priori entering exactly like extra measurements:

$$\Lambda = \sum_i H_i^{\mathsf T} W H_i + \bar P_0^{-1}
\qquad
N = \sum_i H_i^{\mathsf T} W y_i + \bar P_0^{-1}\bar x_0
\qquad
\hat x_0 = \Lambda^{-1} N,\quad P_0 = \Lambda^{-1}$$

> ⚖️ **Batch vs sequential** — the batch update $\hat x_0 = \Lambda^{-1}N$ uses all
> historical data at once ($\Lambda$ = information matrix, $N$ = accumulated
> information vector $H^{\mathsf T}Wy$). KF/EKF process one observation at a time via
> the Kalman gain $K$. The two agree once the EKF has re-linearised.

---

## 🛰️ The benchmark scenario

| Quantity | Value |
|---|---|
| Gravitational parameter $\mu$ | $398\,600.4418\ \mathrm{km^3 s^{-2}}$ |
| Earth radius $R_E$ | $6378.137\ \mathrm{km}$ |
| Ground station | $(5800.000,\ 2650.000)\ \mathrm{km}$, fixed, $\dot{\mathbf r}_{sta}=0$ |
| True epoch state $X_{\text{TRUE}}(t_0)$ | $[7000.000,\ 0.000,\ 0.000,\ 7.54605]$ km, km/s |
| Derived orbit | $a = 6999.994\ \mathrm{km}$ · $e \approx 8.7\times10^{-7}$ · $T = 5828.5\ \mathrm{s}$ |
| Tracking arc | 60 samples · $\Delta t = 10\ \mathrm{s}$ · $t = 0\ldots590\ \mathrm{s}$ (**10.1 %** of one revolution) |
| Noise | $\sigma_\rho = 10\ \mathrm{m}$ · $\sigma_{\dot\rho} = 0.1\ \mathrm{m\,s^{-1}}$ |

<details>
<summary><b>📊 &nbsp;The 60 embedded observables — <code>BENCH_OBS</code></b></summary>

<br>

Generated from $X_{\text{TRUE}}$ by the same two-body propagator and corrupted with
white Gaussian noise at $(\sigma_\rho,\ \sigma_{\dot\rho})$. Embedded verbatim in the
HTML, so every run is bit-for-bit reproducible.


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
($\boldsymbol\omega_\oplus \times \mathbf r$), and strict ITRF → ECI transformations.
Archives: NASA CDDIS Portal · ILRS Global Data Centers.

**Generation.** Truth is propagated by RK4 at a 1 s step; noise is drawn from a
deterministic mulberry32 stream (seed 42) through a Box–Muller transform, so the
"Benchmark radar" array is exactly reproducible and the other sensor grades are
re-synthesised from the same seed.

| Sensor | $\sigma_\rho$ | $\sigma_{\dot\rho}$ | Data |
|---|---|---|---|
| **Benchmark radar** | 10 m | 0.1 m/s | replays the embedded array |
| **Precision radar** | 2 m | 0.02 m/s | re-synthesised |
| **Noisy radar** | 50 m | 0.5 m/s | re-synthesised |

Plus white **or** AR(1) **coloured noise** ($\rho = 0.85$), with optional Cholesky
whitening $W = R^{-1}$ over the full stacked $m \times m$ system:

$$R_{(i,c)(j,c)} = \sigma_c^{2}\,\rho^{|i-j|}, \qquad R_{(i,c)(j,c')} = 0 \ \ (c \neq c')$$

</details>

---

## 🎯 First guess and a priori

Two deterministic point-solution methods seed the reference trajectory:

| Method | Principle | Yields |
|---|---|---|
| **Gauss / Lambert** | Two positions and the time between them fix the connecting orbit; solve the time-of-flight equation, recover $v_1$ from the Lagrange $f,g$ coefficients | $X^{*}_0 = [\mathbf r_1,\ \mathbf v_1]$ |
| **Newton–Raphson** | Iterate a trial epoch state against the cost gradient, $X_0^{n+1} = X_0^{n} - [\partial J/\partial X_0]^{-1}J(X_0^{n})$, until $\lVert \Delta X_0\rVert < \varepsilon$ | refined $X^{*}_0$ |

| First guess | Offset | Outcome (WLS, benchmark radar) |
|---|---|---|
| **Good** | 2.5 km · 1.8 m/s | all modes ✓ 4 it |
| **Rough** | 31 km · 23 m/s | all modes ✓ 5 it |
| **Poor** | 250 km · 192 m/s | all modes ✓ 6 it |
| **Lost ⚠** | 1250 km · 960 m/s | Range ⚠ · Rate ⚠ · **Both ✓ 8 it** |

| A priori $\bar P_0$ | $\sigma$ (pos / vel) | Effect at the Poor guess |
|---|---|---|
| **Weak** | 100 km / 1 km s⁻¹ | invisible → pure WLS |
| **Nominal** | 1 km / 1 m s⁻¹ | ⚠ BIASED, 15–28 σ |
| **Tight** | 20 m / 0.05 m s⁻¹ | ⚠ BIASED, 3700–7000 σ |
| **Custom** | log sliders | your own $\sigma$ and $\bar x_0$ offset |

---

## 📊 Plots, views and what they tell you

| View | Shows | Significance |
|---|---|---|
| 🌍 **2D / 3D orbit display** | True, reference and estimated orbits over a textured Earth | The reference visibly snaps onto truth as the loop converges |
| 📈 **Observed data plot** | $\rho$ and/or $\dot\rho$ against time | The raw measurement geometry — closest approach and the $\dot\rho$ sign change |
| 🌊 **Pre-fit residuals** | $y_i = Y_i - G(X^{*}_i)$, connected | A smooth oscillation *is* the state error projected through the geometry |
| ✅ **Post-fit residuals** | Same, as scatter | Should collapse to unstructured noise; the title states wRMS honestly |
| 🪟 **Split-canvas panes** | ρ cyan above, ρ̇ crimson below | Separate axes because km and km/s do not share a scale |
| 📏 **±σ corridor** | Per-channel noise band | Residuals outside it mean unmodelled signal, not measurement error |
| 🔻 **‖x̂₀‖ per iteration** | Log-scale correction magnitude | Newton-like quadratic shrink; a flat or rising trace is failure |
| ⭕ **Covariance ellipse** | Prior (dashed) vs posterior (solid) at the epoch | Visualises how much information the data actually added |
| 🔎 **Δ true−reference inset** | Magnified gap between arcs | The only view that can show 1250 km and 21 m in the same run |
| 🗺️ **Ground-track minimap** | Sub-satellite trace | Places the tracking arc on the rotating Earth |
| 📟 **Telemetry readout** | 1σ, correlations, κ(Λ), tr P, log₁₀\|P\| | The uncertainty report navigation cares about as much as the state |
| 📋 **Observables drawer** | 60 rows with live O−C | Ties every plotted point back to a number you can read |
| 🔬 **Mode comparison matrix** | Active filter across all three observable sets | Isolates the effect of the observable choice alone |
| 📜 **Iteration log** | ‖x̂₀‖, wRMS, shrink factor, ‖K‖ | The convergence history in numbers |
| ⚠️ **Verdict banner** | CONVERGED / SUSPECT / BIASED / STALLED / DIVERGED | One honest grade for the whole run |

### Mode performance — measured

Batch WLS, weak prior, benchmark radar, rough first guess. Same 60 epochs; only the
observable set changes.

| Mode | $m$ | wRMS | $\lVert\Delta r\rVert$ | $\lVert\Delta v\rVert$ | $\sigma_x$ | $\kappa(\Lambda)$ |
|---|---|---|---|---|---|---|
| Range (ρ) | 60 | 0.96 | 32.6 m | 86 mm/s | 50 m | $1.5\times10^{8}$ |
| Range-Rate (ρ̇) | 60 | 1.01 | 42.2 m | 116 mm/s | 56 m | $9.3\times10^{7}$ |
| **Both (ρ + ρ̇)** | **120** | **1.00** | **21.1 m** | **60 mm/s** | **26 m** | **$5.7\times10^{7}$** |

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
| ✅ **CONVERGED** | $\lVert\hat x_0\rVert < \varepsilon$, $\max\lvert\Delta\rvert/\sigma \le 3$, $0.7 \le$ wRMS $\le 1.3$ | The state is trustworthy and the covariance covers the real error |
| 🟠 **BIASED** | Loop settled, but truth lies outside the reported 3σ | **Confidently wrong.** Residuals look plausible, the ellipse is tight, the answer is thousands of σ off |
| 🔴 **DIVERGED** | $\lVert\hat x_0\rVert$ past $5\times10^{3}$ km, or growing ×1.5 for three passes | The linearisation about $X^{*}_0$ is invalid; each pass makes the reference worse |

> The **DIVERGED** cases are loud and unmistakable. The **BIASED** ones are the
> dangerous ones: the loop converges, the residual plot looks fine, the covariance
> ellipse is tight — and the answer is thousands of sigma off. That is the failure
> mode that loses spacecraft, and it is exactly what the verdict banner exists to catch.

---

## 📁 Repository contents

| File | |
|---|---|
| **`OD_Simulator_V2.html`** | The entire simulator — engine, UI, 3D scene, embedded data |
| `index.html` | Copy served by GitHub Pages (created by `push.bat`) |
| **[`MATH.md`](MATH.md)** | Complete mathematical reference — every equation, every numerical method, six verified results matrices |
| **[`demo/`](demo/)** | 60-second demo reel + ffmpeg recorder |
| `push.bat` | One-click publisher to GitHub Pages |
| `LICENSE` | MIT |

---

<div align="center">

📐 **Full derivations, all six results matrices, and the numerical verification are in [MATH.md](MATH.md)**

<sub>Educational simulator — not for operational navigation.</sub>

<sub><b>Author</b> · Vinoth Emberumal · MSc Space &amp; Astronautical Engineering, Sapienza Università di Roma</sub>

</div>
