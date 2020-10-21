---
layout: post
title: "singleton python"
description: "singleton python"
date: 2020-10-22
tags: coding
---

# Case

For the objects that are frequently called, but only created once in the beginning (or not usually changed), we should try to use Singleton pattern to improve performance and reduce memory consumption.

For example, the information of our devices, servers of devices, and others only initiated once at the start. 



# Code

In python, we can use

```python
from abc import ABC
from functools import wraps


def singleton(class_):
    class SingletonFactory(ABC):
        instance = None
        def __new__(cls,*args, **kwargs):
            if not cls.instance:
                cls.instance = class_(*args, **kwargs)
            return cls.instance
    SingletonFactory.register(class_)
    return SingletonFactory

@singleton
class yourClass:
```



We find that the cost of time for calling functions, calculation and compiling in our local computer is around several millisecond (ms) after using singleton, while hundreds of ms are required before using singleton. 



To creating multiple objects from the same class, but each one behave like a singleton, we can modify it into

```python
def singletonMany(class_):
    """
    We do not want to initialize the same device after we created it.
    obj_name: required to identify whether the device object has been created
    
    Example: 
        
        @singleton
        class MyDevice(object)
            def __init__(self,obj_name,*args, **kwargs):
        
        Therefore, we can use like: 
        
        obj_names = ['1','2']
        for i,devId in enumerate(obj_names):
            if i == 0:
                devs = MyDevice(devId)
            else:
                MyDevice(devId)
        
        Then if you call 'devs', it gives a dict of those objects
        devs = {'1':MyDevice('1'),'2':MyDevice('2')}
        
        If you lose your parameters for some reason, and want to create it again, 
        dev1 = MyDevice('1')
        The object will not be initialized again, but just give it to you, since it always 
        stored in your cache even you forget it.
    """

    class SingletonFactory(ABC):
        instance = {}
        def __new__(cls,obj_name,*args, **kwargs):
            if obj_name not in cls.instance:
                cls.instance[obj_name] = class_(obj_name,*args, **kwargs)
            return cls.instance
    SingletonFactory.register(class_)
    return SingletonFactory
```

# Summary

We use the Singleton pattern in the class of device control, which improves the speed of running. 

By the way, passing the object as an argument or storing in global are also considered before, but directly calling the class `foo()` without re-initiating them are more feasible and easy-to-write, where we frequently call `foo()` and do not want to remember or store a global variable in the script. 



 

