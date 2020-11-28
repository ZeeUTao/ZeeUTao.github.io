---
layout: post
title: "low frequency noise"
description: "low frequency noise in experiment"
date: 2020-11-28
categories: [SQC,calibration]
tags: [calibration,noise]
math: true
---





## power supply

The commercial *power supply* for the daily use has large switch noise in the level of Hz, which can be measured by the *spectrum analyzer* with DC coupling (important). 

> Warning: AC coupling spectrum analyzer removes any DC that may be present on the signal. If DC component is too large, then it could easily damage the input of the spectrum analyzer, and the repair could be expensive.

### suggest

> The low frequency noise of power supply may reduce the dephasing lifetime of qubit. 
>
> A special designed power supply or a commercial ones with low noise (e.g. keysight) is required.



