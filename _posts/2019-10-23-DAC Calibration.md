---
title: "DAC Calibration"
author: Ziyu Tao
description: "about paramp"
date: 2019-12-25
categories: [SQC, calibration]
tags: [calibration]
math: true
---



updating



- 仪器：

  DAC板子，

  Spectrum analyzer (spectrum_analyzer.py）

  Digital serial analyzer （tektronixDSA8300y.py）







需要连接微波源（给板子载波$f_c$）以及数字示波器，以同步（仪器反面）。



### Script以及操作

scripts: GHz_DAC_calibrate.py

其中import了server\ghzdac

#### pulse calibration

板子output连接频谱仪RF input，进行第一步操作。脚本自动迭代寻找最优质，使得目标波形以外的杂峰强度最小。

板子output连接示波器CH1端口，板子trigger连接右边另一端口Trigger direct input。然后得到波形。

其中，ghzdac\calibrate的参数horizontal_position可以调节使得波形在正中间，方便查看。

从波形中观察IQ同步性，若不好则反复进行bringup重启。日常实验中只用粗测的话可以直接用普通示波器接IQ查看。

#### zero calibration

#### sideband calibration

这两个只用接示波器，在脚本界面设置好参数后，即可运行。耗时较长。

sideband相当于在一段频率范围扫描，然后每个频率点中又由板子加sideband一段范围的不同响应。所以最终是多条线的数据图。

#### 

参考（Numeric Correction of the GHz DAC chain，Max Hofheinz）





### 2	Modeling DAC

对一个连续的含时信号 $f(t)$，DAC将在一定时间间隔对其采样（采样率的倒数）

$$
f_n = f(n\Delta)
$$


### 3	IQ mixer

IQ mixer的输出为

$$
g(t)=I \cos \left(2 \pi f_{\mathrm{c}} t\right)+Q \sin \left(2 \pi f_{\mathrm{c}} t\right)
$$

sideband mixing, 设置 $I = a \cos(2\pi f_{sb} t),Q=-a\sin(2\pi f_{sb} t)$，则有

$$
g(t) = a \cos(2\pi (f_c + f_{sb})t)
$$

其中DAC板子贡献IQ，微波源贡献$f_c$。这样能快速灵活的对波形进行控制，并且避免微波源的$f_c$导致比特激发。因为IQ的零点不一定校准的很好（zero calibration），所以一些本来应该关闭信号将被打开，即微波源在整个时间段泄露；如果没有sideband或者sideband很小，那么信号频率就等于载波频率，将导致比特被泄露信号影响。

Note: 所以实验时fc与比特频率不能太近，不然载波频率泄露会影响比特

实际的IQ mixer不是完美的，它的IQ大小不等，相位差不完全为$\pi/2$。因此需要我们额外去校准。



### 4	校准流程

校准程序的工作流程如下：

**zero calibration at a fixed carrier frequency** (typically 6 GHz).

The output of the microwave chain is plugged into the spectrum analyzer. The DAC A and B values are adjusted so that the output measured by the spectrum analyzer in a very narrow band around the carrier frequency becomes minimal (typically −50 dBm). 



**Impulse response**. The microwave source is kept at the same frequency. First the DAC outputs are kept at the zero value determined in the last step. The output signal is measured with the sampling scope to determine the DC baseline. Then one DAC A sample is set to a high value. The signal recorded by the sampling scope is the impulse response of the microwave chain with respect to channel A. The same is done for DAC B.

**Full zero calibration.** The zero calibration is now done for the whole carrier frequency range we want calibrate.

**Sideband calibration.** A sideband signal at frequency $\Delta f$ is output by the DACs. In the same way as for the zero calibration, the amplitude at $f-\Delta f$ ($f$ being the carrier frequency) is monitored with the spectrum analyzer. We now add an opposite sideband and adjust its complex amplitude so that the amplitude measured at $f-\Delta f$ becomes minimal. In this step the DAC outputs are already corrected for the zero offset and the impulse response (see below).



The zero calibration is split so that the impulse response can be measured at the beginning that way no cables have to be switched between the longest parts (full zero calibration and side band calibration) and they can be run over lunch or over night.



The calibrations can also be done individually this is useful because the pulse calibration is less critical and drifts less than the zero and sideband calibration. So you only need the spectrum analyzer most of the time. 



The spectrum analyzer is set to a very narrow band (typically 1 kHz) in order to reduce noise. Thus, the DAC board, the microwave source and the spectrum analyzer have to be phase locked or the spectrum analyzer will not measure off the peak. So be sure the spectrum analyzer and the microwave source are locked to the clock source!







