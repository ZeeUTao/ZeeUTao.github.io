---
layout: post
title: "Signal Calibration"
description: "DAC signal Calibration"
date: 2020-11-13
categories: [SQC, calibration]
tags: [calibration]
math: true
---



# Calibration



## Zero

Add offset compensation `[I_off,Q_off]` according to local frequency $f_c$. 

Zurich UI can be used to set the offset value. 





## Sideband

In frequency domain, before corrected $h(f)$

```python
signal_correct = signal + signal[::-1].conjugate() * _IQcompensation(carrierFreq, nfft)
```

`_IQcompensation` returns an array interpolated from the referenced data. 

## filter

hardware related, for example, gaussian filter



## Pulse shape

flux pulse calibration

If a calibration can be characterized by time constants, i.e., the step response function is

```python
if t<0:
    res = 0
else:
	res = 1 + sum(amps*exp(-rates*t))
    # amps, rates is array
```


then you don't need to load the response function explicitly, but can just give the time constants and amplitudes. 





# Algorithm

For zero and sideband calibration, we use

```python
def minPos(yl, y0, yr):
    """Calculates minimum of a parabola to 
    three equally spaced points. 
    The return value is in units of the spacing 
    relative to the center point.
    It is bounded by -1 and 1.
    Example: 
    f(x) =ax^2+bx+c, x_center = -b/(2a)
    yl,y0,yr = f(-1),f(0),f(1)
    0.5*(yl-yr)/(yl+yr-2.0*ym) = -b/(2a)
    """
    x_center = yl+yr-2.0*y0
    if x_center <= 0:
        return 0
    x_center = 0.5*(yl-yr)/x_center
    if x_center > 1:
        x_center = 1
    elif x_center < -1:
        x_center = -1
    else:
        return x_center
```





