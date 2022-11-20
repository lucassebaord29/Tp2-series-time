Empezamos linkeando la base

```
clear all
import excel "/Users/lucasordonez/Desktop/TP 2/ipc", firstrow case(lower)
set more off
tsset fecha, monthly
```

# ejercicio 1

```
gen logipc = ln(ipc)
```

grafico en niveles

![image](https://user-images.githubusercontent.com/67765423/202881063-d435201e-6ea3-4466-bdfa-b6e2bb775d6d.png)

Para estimar y hacer infereencia sobre la serie necestiamos qie la serie de tiempo sea estacionaria. ante un analisis grafico se puede observar una intuicion acerca de la estacionariedad en sentido debil.
Las condiciones estadisticas que buscamos es que $E[Y_t] y VAR(y_t)$ sean constantes a lo largo del tiempo y por otro lado que $COV(y_t; y_{t-1})$

grafico en diferencias con logaritmo
Al aplicar diferencias sobre la serie de IPC

$$ \DeltaIPC = IPC_t - IPC_{t-1}$$
podemos observar el componente tendencial, lo que conlleva que a medida que el tiempo pasa la serie crece y presente una mayor volatilidad

Por otro lado se puede observar un comportamiento ciclico a simple vista, reflejando la forma regular de acuerdo al calendario argentino economico

<img width="1246" alt="image" src="https://user-images.githubusercontent.com/67765423/202881098-73c977b6-891d-41d9-b81b-764b8d3d7f57.png">

```
tsline d.logipc // para observar inflacion y lidiar heterocedasticidad

arima d.logipc, arima(1,0,0)
*esperanza: .0223071
```
Aplicamos logaritmo con el objetivo de suavizar y lidiar problemas de heterocedasticidad

<img width="1258" alt="image" src="https://user-images.githubusercontent.com/67765423/202881548-6ac680a7-e645-455d-aed6-950b4e250427.png">

Podemos seguir observando que los componentes tendenciales y estacionales aun se encuentran en la serie.
Por este motivo recurrimos a aplicar diferencia de los logaritmos de la serie IPC

$$ \Delta ln(IPC) = ln(IPC_t) - ln(IPC_{t-1}) $$

De esta forma obtenemos la **inflacion**.

### Analisis Estadistico de la serie

1) Aplicamos filtro de Hodrick - Prescott, con el objetivo de conocer la descomposicion de la serie, la tendencia y el ciclo

```
hprescott dlogipc, stub(hplipc)

*Genera las siguientes variables, por un lado ciclo y por otro tendencia

* hplipc_dlogipc_1 // ciclo
* tsline hplipc_dlogipc_sm_1  // tendencia

rename hplipc_dlogipc_1 ciclo_hp
rename hplipc_dlogipc_sm_1 tendencia_hp

* Grafico HP
tsline ciclo_hp tendencia_hp
```

Grafico
<img width="1248" alt="image" src="https://user-images.githubusercontent.com/67765423/202883238-7d19412f-8ac6-4182-b29b-47ed58293bbf.png">

2) Aproximacion de observacion de tendencia y estacionalidad

Buscamo un polinomio de grado n, que se asemeje mas a nuestro modele

```
gen tiempo2 = tiempo ^2
gen tiempo3 = tiempo^3
gen tiempo4 = tiempo^4
```

Presento regresiones

```
reg D.logipc tiempo
predict Dlogipc_hat

reg D.logipc tiempo tiempo2
predict Dlogipc_hat2


reg D.logipc tiempo tiempo2 tiempo3
predict Dlogipc_hat3

reg D.logipc tiempo tiempo2 tiempo3 tiempo4
predict Dlogipc_hat4

```
![image](https://user-images.githubusercontent.com/67765423/202883317-e0ea800c-b8ec-4a22-84b8-508990958b50.png)

Comparacion de tendencias en base al polinomio
![image](https://user-images.githubusercontent.com/67765423/202884356-ac4aff4e-1400-4050-8f4e-3d540e2b1c2d.png)

Obtamos por un polinomio de Grado 3


