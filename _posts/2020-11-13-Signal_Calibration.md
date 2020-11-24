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


$$
\begin{pmatrix}
I'\\
Q'
\end{pmatrix} =
M
\begin{pmatrix}
I\\
Q
\end{pmatrix}
$$

$$
\begin{pmatrix}
I\\
Q
\end{pmatrix} \equiv 

\begin{pmatrix}
\cos X\\
\sin X
\end{pmatrix} \equiv e^{iX}
$$

$$
e^{iX} + (a+ib) e^{-iX} =
\begin{pmatrix}
(1+a)\cos X + b \sin X\\
 b \cos X + (1-a)\sin X
\end{pmatrix}
= 
\begin{pmatrix}
A_1 \cos(X+\phi_1)\\
A_2 \sin(X+\phi_2)
\end{pmatrix}
$$

```python
compen_1 = 1 + compen.conjugate()
amp_1 = np.abs(compen_1)
phi_1 = np.angle(compen_1)

compen_2 = 1 - compen.conjugate()
amp_2 = np.abs(compen_2)
phi_2 = np.angle(compen_2)
```





## Zero

In spectrum analyzer, a peak of leakage at local frequency from microwave source can be observed, even if the base signal has not been sent. 

To suppress such leakage, we should add DC offset compensation `[I_off,Q_off]` according to related parameters. The parameters mainly include carrier frequency `f_c`,  sideband (or base) frequency `f_sb`, sideband amplitude `amp_sb`. A rough calibration can consider only local frequency involved. 



## Sideband

An ideal IQ mixer
$$
RF = I \cos \Omega t + Q \sin \Omega t
$$
can be considered as a mapping of the input signals I, Q onto the LO frame given by a new set of grid axes (X,Y)
$$
RF = I \hat{x} + Q\hat{y} = \cos X \hat{x} + \sin X \hat{y}
$$
Since
$$
\begin{pmatrix}
\cos (X+\delta) \\
\sin (X-\delta)  \\
\end{pmatrix} 
=
\begin{pmatrix}
\cos \delta & -\sin \delta   \\
-\sin \delta &  \cos \delta  \\
\end{pmatrix}
\begin{pmatrix}
\cos X \\
\sin X  \\
\end{pmatrix} 
$$

A realistic model to correct the non-orthogonality and amplitude imbalance can be
$$
\cos X \hat{x} + \sin X \hat{y} \to (1+\epsilon) \cos(X+\delta) \hat{x} + (1-\epsilon) \sin(X-\delta) \hat{y}
$$

$$
(I,Q)^T \to M (I,Q)^T
$$

$$
M = 
\begin{pmatrix}
(1+\epsilon) \cos \delta & -(1+\epsilon)\sin  \delta   \\
-(1-\epsilon)\sin \delta &  (1-\epsilon)\cos \delta   \\
\end{pmatrix}
$$

$$
(I,Q)^T \to \cos \delta  \left[(I,Q)^T  -\epsilon (I, -Q)^T - \tan\delta (Q, I)^T \right]
$$

$$
I + iQ = A e^ {i X}
$$

Then,
$$
I' + iQ' =  \cos \delta  A e^ {i X} - \epsilon\cos \delta  Ae^ {-i X} - i\sin \delta Ae^ {-i X}
$$

$$
I' + iQ' =\cos \delta  A e^ {i X} - \left[\epsilon\cos \delta  + i \sin \delta \right] Ae^ {-i X}
$$

which contributes a mirror sideband frequency. 



### Rough calibration

To correct the sideband leakage, we need the above parameters $\epsilon, \delta$ to describe non-orthogonality and amplitude imbalance. In a rough calibration, we need to calibrate it in varied carrier frequency `f_c` and sideband frequency `f_sb`, estimated by the peak at mirror sideband frequency at spectrum analyzer. 

### but the signal also varied

The filters in the lines, backscattering in the devices, and the conditions in fridge should be considered, which stop us to scanning all of the parameters and save it for the future correction.  

Moreover, due to the above factors, the varied response in signal is more critical rather than the leakage at carrier or mirror frequency for a complicated waveforms, which implies us to use the pulses with simple envelope, that has small width at frequency domain. 

### estimated by the final performance

A better way is to implement the calibration and correction according to the final performance in the low temperature of fridge, after the various parameters including carrier frequency, sideband frequency, sideband amplitude are fixed. The calibration efficiency will be increased due to the error function now estimated by the final performance, and various fixed parameters decrease the repetitions of measurements. 





## flux correction




```python
Xt (array): ideal input signal
Yt (array): real measured signal

X_fft = np.fft.fft(Xt)
Y_fft = np.fft.fft(Yt)

def ansatz(f,paras):
	return 1+np.sum(xxxx)

# fs frequency points

# calibrate
# find paras that fit_error smallest
fit_error = np.abs(
	ansatz(fs,paras) * X_fft - Y_fft
	)
paras_opt = optimize(fit_error)	

# correction 
# simply X_corr = X / ansatz 
X_fft_corr = X_fft/ansatz(fs,paras_opt)

Xt_corr = np.fft.ifft(X_fft_corr)
```





Ansatz
$$
H(f) = 1+\sum \frac{ i A_i f}{
(i 2\pi f + \gamma_i)
}
$$

$$
Y(f)\vert_{corrected} = X (f)   \vert_{in} / H(f)
$$




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





