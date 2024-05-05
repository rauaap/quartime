# Digital Clock in VHDL

Digital clock to be implemented on an Intel MAX10 FPGA.

## Component diagrams

### M1: S, M, H Splitter

```mermaid
graph TB
    input((INPUT))
    d1["IN * 139811\n >> 23"]
    d2["IN * 139811\n >> 23"]
    sub1["IN1 - \n IN2 * 60"]
    sub2["IN1 - \n IN2 * 60"]
    out1((OUT1))
    out2((OUT2))
    out3((OUT3))

    input --> d1
    input --->|IN1| sub1
    sub1 --> out1
    d1 --->|IN2| sub1
    d1 --> d2
    d1 -->|IN1| sub2
    d2 -->|IN2| sub2
    d2 ---> out3
    sub2 --> out2
```

### M2: Tens and Ones Splitter

```mermaid
graph TB
    input((INPUT))
    d1["IN * 103\n >> 10"]
    sub1["IN1 - \n IN2 * 10"]
    out1((OUT1))
    out2((OUT2))

    input --> d1
    input -->|IN1| sub1
    d1 -->|IN2| sub1
    sub1 --> out1
    d1 --> out2
```

### M3: Combined Circuit

```mermaid
graph TB
    input((INPUT))
    m1[M1]
    m2a[M2_a]
    m2b[M2_b]
    m2c[M2_c]
    7seg1{{"7seg\ndecoder"}}
    7seg2{{"7seg\ndecoder"}}
    7seg3{{"7seg\ndecoder"}}
    7seg4{{"7seg\ndecoder"}}
    7seg5{{"7seg\ndecoder"}}
    7seg6{{"7seg\ndecoder"}}

    input --> m1
    m1 ---->|OUT1| m2a
    m1 -->|OUT2| m2b
    m1 --->|OUT3| m2c

    m2a --> 7seg1 & 7seg2
    m2b --> 7seg3 & 7seg4
    m2c --> 7seg5 & 7seg6
```

## Proof of Concept

The concept can be demonstrated with the following python code:

```python
import time

def sub(IN1, IN2, multiplier = 60):
    return IN1 - IN2 * multiplier

def div(IN, multiplier = 139811, shift = 23):
    return IN * multiplier >> shift

def M1(seconds):
    minutes = div(seconds)
    OUT1 = sub(seconds, minutes)
    hours = div(minutes)
    OUT2 = sub(minutes, hours)
    OUT3 = hours
    return OUT3, OUT2, OUT1

def M2(IN):
    OUT2 = div(IN, multiplier = 103, shift = 10)
    OUT1 = sub(IN, OUT2, multiplier = 10)
    return OUT2, OUT1

def M3(seconds):
    return (M2(n) for n in M1(seconds))

seconds = 0
while True:
    # clears the screen using an ANSI escape codes
    print('\033[2J\033[H', end = '')
    print(*M3(seconds))
    seconds += 1
    time.sleep(1)

```
