---
layout: post
title: "pyvisa decoding error"
description: "decoding error when get the data from devices via pyvisa"
date: 2020-10-22
tags: coding
---

# Case

To get the data array from devices, the encoding form should be stated. 

If you do not state the encoding form at all, pyvisa will has `UnicodeDecodeError` when query some devices for the data. 

# Code

For example, we want get the data trace from the spectrum analyzer

```python
## spec.query(*IDN?) == 'Rohde&Schwarz,FSL-18,102695/018,2.50\n'
spec.query(":TRAC? TRACE1")
```

This will cause  `UnicodeDecodeError`  if you have not state the encoding form at all.



In python3, we can use

```python
import pyvisa as visa
# pyvisa 1.11.1
# python 3.7.7

# you need state deviceIP, for example
deviceIP = 'TCPIP0::192.168.1.6::inst0::INSTR'
rm = visa.ResourceManager()
spec = rm.open_resource(deviceIP)


__QUERY__ = """\
:FORM INT,128
:FORM:BORD NORM
:TRAC? TRACE1""" 

resp = spec.query(__QUERY__)
#'1.00E+001,1.00E+001...'

data = np.array(eval(resp))
# numpy array
```



The commands `:FORM INT,128` and `:FORM:BORD NORM` state the returned data form, so that pyvisa can correctly decode it.

If it still has error, try this one

```python
__QUERY__ = """\
:FORM:BORD NORM
:TRAC? TRACE1""" 
```



In the common case, you only need to state the form once, but the safest way is always stating form before query data. 

