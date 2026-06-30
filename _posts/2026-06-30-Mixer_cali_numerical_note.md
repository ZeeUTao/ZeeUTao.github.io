---
layout: post
title: "IQ Mixer Calibration: Numerical Demo"
description: "The proof-of-principle demonstration for IQ Mixer Calibration"
date: 2026-06-30
categories: [SQC, calibration]
tags: [calibration]
math: true
---

# Mixer imbalance numerical demonstration

```
Disclaimer:​

This article is a personal research note and a record of my own understanding. It may contain simplifications, incomplete arguments, or unintentional mistakes. It is shared for interest and discussion only, not as a formal reference.
```




## note

For an ideal IQ Mixer, the generated RF signal is ($\omega_C$ is the carrier / signal source LO frequency)

$ RF = I(t) \cos ( \omega_{C} t) + Q(t) \sin ( \omega_{C} t) $

In physical world, the IQ Mixer has

$ RF = I''(t) \cos ( \omega_{C} t) + Q''(t) \sin ( \omega_{C} t) $

where we denote the IQ mismatch as

$ I'' = (1+\delta_A) I' \cos(\delta_\phi) + Q' \sin(\delta_\phi) $

$ Q'' = Q' $

which is one of the denotation as an example, and you may seek more supporting mathematical information for LLM-AI.

The LO leakage contributed by the DC-part can be considered as

$ I' = I + I_0 $

$ Q' = Q + Q_0 $

where $I_0, Q_0$ are constants。


In experiment, the spectrum analyzer was used to acquire `RF spectral data`, while the supplied I and Q values were adjusted to minimize leakage from the LO and image components.
The resulting parameters correspond to the required mixer correction parameters.

- RF spectral data:  `spectrum analyzer` -> `Computer` -> `Python scripts`

- I, Q Parameters:  `Python scripts` -> Change `Numpy array` -> Send `AWG`

Just point-by-point mapping from mathematical understanding to your own scripts

```python
# I' = I + I_offset
I_offset = 0.001 # for example
I_array_change_dc = I_array + I_offset

# fake_function
some_awg_sendTo_some_port(array=I_array_change_dc, *args, **kwargs)
```


## python demo

```python
import numpy as np
from matplotlib import pyplot as plt
import scipy
```

```python
def mixer_iq2rf(t, i, q, fc=5e9, dA=-0.0, dphi=0.0, i0=0.0, q0=-0.0):
    wc = 2*np.pi*fc
    # i2 = i + i0
    # q2 = q + q0
    i3 = (1+dA)*i*np.cos(dphi) + q*np.sin(dphi)  + i0
    q3 = q  + q0
    res = i3*np.cos(wc*t) + q3*np.sin(wc*t)
    return res

def get_fft_spectrum(t, rf_raw):
    N = len(rf_raw)
    fs = 1.0 / (t[1] - t[0])  # 采样率
    rf_fft = np.fft.rfft(rf_raw-np.mean(rf_raw),norm='ortho')
    freqs = np.fft.rfftfreq(N, d=1.0/fs)
    return freqs, np.abs(rf_fft)

def plot_spectrum(freqs, power_fft):
    fig = plt.figure(figsize=(5,2), dpi=150)
    plt.plot(freqs/1e9, power_fft)
    plt.ylim(-130,50)
    plt.grid(linestyle='dotted')
    plt.xlabel("freq (GHz)")
```


```python
f_sb = 200e6 # sideband
fc = 5e9

qpara = {"fc": fc, "f_sb": f_sb}
t = np.arange(0, 20_000, 0.05)*1e-9  # ns
i = np.sin(f_sb*2*np.pi*t)
q = np.cos(f_sb*2*np.pi*t)
```

## show plot


```python

rf_raw = mixer_iq2rf(t, i, q, dA=0.0, dphi=0.0, i0=0.0, q0=0.0)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft)
plt.xlim(4.7,5.3)
plt.title(r"Ideal $\delta_A, \delta_\phi, I_0, Q_0 =0$")
```


You will see a peak of leakage in the frequency of $f_c$, which is induced by the DC-part `i0, q0`, and usually called as zero (LO) leakage

```python
rf_raw = mixer_iq2rf(t, i, q, dA=0.0, dphi=0.0, i0=0.01, q0=-0.01)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft)
plt.xlim(4.7,5.3)
plt.title(r"Non-zero $I_0, Q_0$")
```

You will see a peak of leakage in the frequency of $f_c-f_{sb}$, which is induced by the mixer imbalance parameter `dA, dphi`, and usually called as mirror leakage

```python
rf_raw = mixer_iq2rf(t, i, q, dA=0.01, dphi=-0.02, i0=0.0, q0=0.0)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft)
plt.xlim(4.7,5.3)
plt.title(r"Non-zero $\delta_A, \delta_\phi$")
```

You will see a peak of leakage in both frequencies of $f_c$ and $f_c-f_{sb}$

```python
rf_raw = mixer_iq2rf(t, i, q, dA=1e-4, dphi=-2e-4, i0=5e-3, q0=-1e-3)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft)
plt.xlim(4.7,5.3)
plt.title(r"More physical case")
```

## correct demo

Assume artificial parameters​ to numerically emulate mixer imbalance and DC offset

```python
dA=1e-4
dphi=-2e-4
i0=5e-3
q0=-1e-3
rf_raw = mixer_iq2rf(t, i, q, dA=dA, dphi=dphi, i0=i0, q0=q0)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft = 10*np.log10(rf_fft)
plot_spectrum(freqs, power_fft)
plt.xlim(4.7,5.3)
plt.title(r"Before correct")
```

### Search paramters to correct LO leakage 


In a manner analogous to a real experiment, the correction parameters are numerically searched as the following demonstration

```python
def binary_search_2d(f, x_bounds, y_bounds, tol=1e-10, max_iter=100):
    """
    Two-dimensional alternating-direction binary search（2D）
    """
    xl, xu = x_bounds
    yl, yu = y_bounds

    for it in range(max_iter):
        # ---- x ----
        xm = 0.5 * (xl + xu)
        yc = 0.5 * (yl + yu)

        f_left  = f(xl, yc)
        f_right = f(xu, yc)

        if f_left < f_right:
            xu = xm
        else:
            xl = xm

        # ---- y ----
        ym = 0.5 * (yl + yu)
        xc = 0.5 * (xl + xu)

        f_down = f(xc, yl)
        f_up   = f(xc, yu)

        if f_down < f_up:
            yu = ym
        else:
            yl = ym

        # ---- Convergence criterion ----
        if (xu - xl) < tol and (yu - yl) < tol:
            break

    x_opt = 0.5 * (xl + xu)
    y_opt = 0.5 * (yl + yu)
    return x_opt, y_opt, f(x_opt, y_opt)
```


```python

def correct_zero(corr_i0, corr_q0):
    i2 = i-corr_i0
    q2 = q-corr_q0
    rf_raw = mixer_iq2rf(t, i2, q2, dA=dA, dphi=dphi, i0=i0, q0=q0)
    freqs, rf_fft = get_fft_spectrum(t, rf_raw)
    # power_fft2 = 10*np.log10(rf_fft)
    fc = qpara['fc']
    idxs = np.where(np.round(freqs/1e9,3)==fc/1e9)[0]
    p_max = np.max(rf_fft[idxs])
    print(f"corr_i0, corr_q0 = ({corr_i0, corr_q0})")
    return p_max
```


```python
res_opt = binary_search_2d(
    correct_zero,
    x_bounds=(-0.5, 0.5),
    y_bounds=(-0.5, 0.5),
    tol=1e-14,
)
```


```python
corr_i0, corr_q0 = res_opt[:2]

print(corr_i0, corr_q0)
i2 = i.copy()-corr_i0
q2 = q.copy()-corr_q0

rf_raw = mixer_iq2rf(t, i2, q2, dA=dA, dphi=dphi, i0=i0, q0=q0)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft2 = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft2)
plt.xlim(4.7,5.3)
plt.title(r"After correct LO")
```

### Search paramter to correct mirror leakage


```python
def correct_mirror(dA, dphi):
    i3 = (i-q*np.sin(dphi))/(np.cos(dphi)*(1+dA)) - corr_i0
    q3 = q.copy() - corr_q0
    rf_raw = mixer_iq2rf(t, i3, q3, dA=dA, dphi=dphi, i0=i0, q0=q0)
    freqs, rf_fft = get_fft_spectrum(t, rf_raw)
    # power_fft2 = 10*np.log10(rf_fft)
    f_mirror = qpara['fc'] - qpara['f_sb']
    idxs = np.where(np.round(freqs/1e9,3)==f_mirror/1e9)[0]
    p_max = np.max(rf_fft[idxs])
    print(f"dA, dphi = ({dA, dphi}), p_max = {p_max}")
    return p_max
```


```python
res_mirror = binary_search_2d(
    correct_mirror,
    x_bounds=(-0.5, 0.5),
    y_bounds=(-0.5, 0.5),
    tol=1e-14,
)
```


```python
corr_dA, corr_dphi = res_mirror[:2]
# dA=1e-4
# dphi=-2e-4
print(corr_dA, corr_dphi)
i3 = (i-q*np.sin(dphi))/(np.cos(dphi)*(1+dA)) - corr_i0
q3 = q.copy() - corr_q0

rf_raw = mixer_iq2rf(t, i3, q3, dA=dA, dphi=dphi, i0=i0, q0=q0)
freqs, rf_fft = get_fft_spectrum(t, rf_raw)
power_fft2 = 10*np.log10(rf_fft)

plot_spectrum(freqs, power_fft2)
plt.xlim(4.7,5.3)
plt.title(r"After correct LO and mirror")
```




