---
layout: post
title: "多比特读取的数据处理"
date: 2019-09-18
description: "多比特多能级IQ状态判别等"
tag: SQC-Exp
---



### 1. IQ 判别

这里我们讨论多比特实验中如何**对比特状态进行判别**，也就是对输出的IQ信息进行分类。先从简单的例子出发，然后推广到一般情况。

#### 单比特多能级

我们预先对于单比特不同的能级n进行多次测量取平均，得到不同能级 $\vert\psi_n\rangle = \vert 0\rangle,\vert 1\rangle \cdots \vert N-1\rangle$ 所对应的参考点 $x_n = (I_n,Q_n)$ 。

对于新测量到的未知量子态，解模获取的原始数据为IQ平面某一点 $x = (I,Q)$， 如果 $\vert x-x_a\vert = \mathrm{Min}(\vert x-x_n \vert)$  我们则判断它所处的量子态为 $\vert\psi_a\rangle$ 。据此我们可以定义如下函数

```python
def get_meas(data0,q,Nq = level):
    #data[0][x]   qubits[x]   x == 0,1,2,3
    
    Is = np.asarray(data0[0]) #array
    Qs = np.asarray(data0[1])    
    sigs = Is + 1j*Qs
	# input IQ array
    # return, e.g., array [0,2,0,1...] correspond to Qstate
    
    total = len(Is)
    distance = np.zeros((total,Nq))
    for i in np.arange(Nq):
        center_i = q['center|'+str(i)+'>'][0] + 1j*q['center|'+str(i)+'>'][1]
        distance_i = np.abs(sigs - center_i)
        distance[:,i]=  distance_i

    tunnels = np.zeros((total,))
    for i in np.arange(total):
        distancei = distance[i]
        tunneli = np.int(np.where(distancei == np.min(distancei))[0])
        tunnels[i] = tunneli 
    return tunnels
```

其中数据格式需根据实际所用进行修改，np为numpy包。

最终的目的为：已知参考IQ，对于多次测量下的一串新的IQ点，返回对应格式的数字，代表单比特对应的能级。



#### 多比特多能级

物理里，一般用张量积tensor写N比特的状态；在代码里，我们可以看成是一串长度为N的数字，若比特有M个能级，则数字的进制为M**进制**（通常qubit是2，如果叫qutrit就是3，更高的都叫qudit）。按照进制的转换方法，我们可以将N比特的状态表示成一个数字。因此我们创建数组binary_count，其中每一个元素都是一个数字，数字为M进制，长度为比特数。

然后利用循环，对每个态计数，最后求出重复实验所测量到每个态的概率，即布局数（population）。

```python
qNum = len(qubits)
# The length of raw data is counts_num
binary_count = np.zeros((counts_num),dtype = float)

for i in np.arange(qNum):
    ## define qNum - 1-i for the writing order : q1,q2,q3...
    binary_count += get_meas(data[0][i],qubits[qNum - 1-i]) * (level**i)
        
res_store = np.zeros((level**qNum))
for i in np.arange(level**qNum):
    res_store[i] = np.sum(binary_count == i) 

prob = res_store/counts_num
```

以下为实际代码示例

```python
def tunnelingNlevelQ_peach(qubits, data,level = 3,qNum = 1):
    ## generated to N qubit and multi level 20190618 -- ZiyuTao
    qNum = len(qubits) # redundancy for our data structure
    counts_num = len(np.asarray(data[0][0][0]))
    binary_count = np.zeros((counts_num),dtype = float)

    def get_meas(data0,q,Nq = level):
        #data[0][x]   qubits[x]   x == 0,1,2,3
        # if measure 1 then return 1
        Is = np.asarray(data0[0])
        Qs = np.asarray(data0[1])    
        sigs = Is + 1j*Qs
        
        total = len(Is)
        distance = np.zeros((total,Nq))
        for i in np.arange(Nq):
            center_i = q['center|'+str(i)+'>'][0] + 1j*q['center|'+str(i)+'>'][1]
            distance_i = np.abs(sigs - center_i)
            distance[:,i]=  distance_i
        
        tunnels = np.zeros((total,))
        for i in np.arange(total):
            distancei = distance[i]
            tunneli = np.int(np.where(distancei == np.min(distancei))[0])
            tunnels[i] = tunneli 
        return tunnels

    for i in np.arange(qNum):
        binary_count += get_meas(data[0][i],qubits[i]) * (level**i)
        

    res_store = np.zeros((level**qNum))
    for i in np.arange(level**qNum):
        res_store[i] = np.sum(binary_count == i) 
        
    prob = res_store/counts_num
    return prob
```



### 2. 量子态层析

量子态层析(quantum state tomography)，一般简称tomo。对于N个量子比特，我们需要 $3^N$ 个操作 $\{I,X_{\pi/2},Y_{\pi/2}\}^{\otimes N}$ ，其中算符有时也写成 $I,X/2,Y/2$。而每个操作都同时对N个比特 $(q_1,q_2,q_3 \cdots)$ 作用，也就是包含N个微波脉冲（不同的DAC，或者同一个DAC对不同频率混频）。因此我们可以简洁的把它们写成两重循环。

```python
for tomo_idx in range(3**N):
    for q_idx in range(N):
        q_tomo = qlist[N-1-q_idx]
        gate_idx = (tomo_idx//(3**(q_idx+1)))%(3**(q_idx)
        q_tomo.add_gate(gates[gate_idx])
```

#### Math Tips 

上面相当于把tomo_idx这个变量当成一个**三进制数**，其位数表示作用的比特，每一位上的数字表示需要进行的门操作。比如 "0212" 代表操作 $I \otimes Y/2 \otimes X/2 \otimes Y/2$。

#### Others: 

- 因为我喜欢把比特从左往右排 $q_1,q_2,\cdots$，但是循环对应的进制是从右往左数，所以我们用

```
q_tomo = qlist[N-1-q_idx]
```

- 然后还需注意的一点是：量子操作的顺序与物理公式书写顺序是相反的，比如 $XYZ$ 操作对应的量子操作的时序是 $Z,Y,X$。

- 一个量子门可以由二元组（two-tuple）表示，即 ($\theta$,$\phi$)，我们可以在程序中定义tomo所需的三个门

```python
thetas = [0,np.pi/2,np.pi/2]
phis = [0,0,np.pi/2]
## gates = [I,X/2,Y/2]
gates = [get_gate(thetas[i],phis[i]) for i in range(3)]
```

- 对于多能级的tomo，一般用的各有不同，需要根据所用的门来在循环里进行增改。





