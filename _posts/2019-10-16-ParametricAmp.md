---
title: "Parametric amplifier measure"
author: Ziyu Tao
description: "about paramp"
date: 2019-10-23
categories: [SQC]
tags: [SQC]
math: true
pin: false
---



### 测量参数


$$
\Phi=\Phi_{D C}+\Delta \Phi \cos \left(\omega_{p} t\right)
$$



这部分把参放当成比特想，接入两个线，一个用直流源接bias，一个微波源接pump。

比较简单的一种是用的二倍频。

#### pump参数

- pump bias （bias） z线
- pump frequency (fc)  微波源频率
- pump power （uwavePower）微波源功率

（signal power/frequency等不用参放也能确定）

#### pump测量

根据所需读取的signal frequency 选择合适的pump bias。然后如果是二倍频原理的参放，那么pump frequency选择读取频率的二倍，加几MHz的差值（这里和比特f10与微波源混的fc一样，基带频率和混频频率过于接近会使混出来的信号很差），例如$f_{sig} = 6.6~\mathrm{GHz}, f_{pump} = 13.203 ~\mathrm{GHz}$。

pump bias 与pump power的二维图，提取增益大，噪声小的点作为参放工作点。

#### 工作点

- 选取原则简单来说就是：增益大，噪声小





### 噪声温度



**具体理论参考文献，以下为代码内容，大致方法是差不多的。**

在不同参数下，开与不开参放，测得$A_1,A_0$，每个点会重复测量，因此一般储存下对应的均值$E$和标准差$D$


$$
\mathrm{Gain} = E(A_1)/E(A_0)
$$


用dB为单位则是


$$
\mathrm{Gain} = E(A_1) -E(A_0), ~~\mathrm{(dB)}
$$


然后开与不开的信号对应的方差（记录下的是标准差，所以用平方）


$$
\alpha = \left(\frac{D(A_1)}{D(A_0)}\right)^2
$$


最后计算，（本来有一些常数系数，但可以忽略）


$$
T_{noise} =  (\alpha - 1) \frac{2}{\mathrm{Gain}}
$$






```python
def paramp_noise_tem(dv, dataset=5, dataset_floor=20, session =['','xx','xxx'],
                           gain_cut=15, t_cut=0.5, des=''):
    """
    Calculate the noise temperature of paramp Tp.
    We assume that the noise temperature of HEMT Th is 2 K. In fact, the noise temperature we get is the sum of noise temperature of paramp and signal.
    
    dataset: The dataset when pump on
    datasetFloor: The dataset when pump off
    """
    data = ds.getDataset(dv, dataset, session)
    data_floor = ds.getDataset(dv, dataset_floor, session)
    
    mat, info = ds.columns2Matrix(data, dependentColumn=[2,3,4,5,6])
    mat_floor, info_floor = ds.columns2Matrix(data_floor, dependentColumn=[2,3,4,5,6])
    
    xs = np.arange(info['Xmin'], info['Xmax']+info['Xstep']/10., info['Xstep'])
    ys = np.arange(info['Ymin'], info['Ymax']+info['Ystep']/10., info['Ystep'])
    
    gain_db = mat[:,:,1] - np.average(mat_floor[:, :, 1], 0)    
    
    alpha = (mat[:,:,2]/np.average(mat_floor[:,:,2], 0))**2 
    gain = 10**((gain_db-3)/10)
    noise_tem = 2 / (gain) * (alpha - 1)
    
    for idx0 in xrange(noise_tem.shape[0]):
        for idx1 in xrange(noise_tem.shape[1]):
            if noise_tem[idx0, idx1] >= 1:
                noise_tem[idx0, idx1] = 1
            if noise_tem[idx0, idx1] <= 0:
                noise_tem[idx0, idx1] = 0


    
    optimal_points = []
    
    for idx0 in xrange(gain_db.shape[0]):
        for idx1 in xrange(gain_db.shape[1]):
            if gain_db[idx0, idx1] >= gain_cut and noise_tem[idx0, idx1] <= t_cut:
                optimal_points.append([xs[idx0], ys[idx1]])
    noise_tem             
    print 'maximal gain %.3f dB'%np.max( gain_db)
    optimal_points = np.array(optimal_points)
    # print 'gain for maximal SNR: %.3f dB'%gain_db[optimal_points[idx_max][0], optimal_points[idx_max][1]]
    # print 'deviation for maximal SNR: %.3f'%mat_dev[optimal_points[idx_max][0], optimal_points[idx_max][1]]
    # print 'pump power for maximal SNR: %.3f dBm'%xs[optimal_points[idx_max][0]]
    # print 'pump bias for maximal SNR: %.3f V'%ys[optimal_points[idx_max][1]]
    # print 'Tp for maximal SNR: %.3f K'%Tp[optimal_points[idx_max][0], optimal_points[idx_max][1]]
    # print 'N1 for maximal SNR: %.3f'%data_floor_dev[optimal_points[idx_max][1]]
    
    
 
    extent = [info['Ymin'], info['Ymax'], info['Xmin'], info['Xmax']]
    figure()
    imshow(gain_db, extent=extent, origin='lower', aspect='auto', interpolation='nearest',vmin = 14)
    # plot(ys[optimal_points[idx_max][1]],xs[optimal_points[idx_max][0]],'o',markersize = 10,markerfacecolor = "w",markeredgecolor = "k")
    plot(optimal_points[:,1], optimal_points[:,0], 'o',markersize = 15,markerfacecolor = "w",markeredgecolor = "k" )
    ylabel('Pump Power (dBm)', size=18)
    xlabel('Flux Bias (V)', size=18)
    xticks(size=18)
    yticks(size=18)
    plt.ylim(info['Xmin'], info['Xmax'])
    plt.xlim(info['Ymin'], info['Ymax'])
    title('Gain' + des,size = 18)
    colorbar().set_label("dB",size = 18)
    

    figure()
    imshow(noise_tem, extent=extent, origin='lower', aspect='auto', interpolation='nearest')
    plot(optimal_points[:,1], optimal_points[:,0], 'o',markersize = 15,markerfacecolor = "w",markeredgecolor = "k" )
    # plot(ys[optimal_points[idx_max][1]],xs[optimal_points[idx_max][0]],'o',markersize = 10,markerfacecolor = "w",markeredgecolor = "k")
    ylabel('Pump Power (dBm)', size=18)
    xlabel('Flux Bias (V)', size=18)
    xticks(size=18)
    yticks(size=18)
    title('Noise Temperature'+ des,size = 18)
    colorbar().set_label("K",size = 18)
    plt.ylim(info['Xmin'], info['Xmax'])
    plt.xlim(info['Ymin'], info['Ymax'])
```

