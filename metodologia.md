empezamos linkeando la base

```
clear all
import excel "/Users/lucasordonez/Desktop/TP 2/ipc", firstrow case(lower)
set more off
tsset fecha, monthly
```

********************************************************************************
*								ejercicio 1
********************************************************************************

```
gen logipc = ln(ipc)
```

grafico en niveles



