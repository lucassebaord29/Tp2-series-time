# TP 2 - Series de Tiempo

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



Se observa un efecto de un polinomio de grado 3

Realizamos los valores predicho para obtener **tendencia** y por otro lado a traves de los residuales de la regresion obtenemos la serie sin tendencia.
```
reg D.logipc tiempo tiempo2 tiempo3  if fecha <= tm(2022m9) // tendencia significativa
predict tendencia
predict infla_sin_tendencia, resid

```

Para el analisis de estacionalidad creamos $Q-1$ Dummy con los meses respectivos para descomponener el efecto mensual

```

reg D.logipc i.b(1).mes tiempo
predict estacionalidad
predict clean_infla_desnit, residuals

```
![image](https://user-images.githubusercontent.com/67765423/202884844-ba67c816-4f3a-44c2-805a-cce23a51a0b7.png)

No es significativo

3) Contraste de Dickey Fuller
Anteriormente observamos que la serie con la que estamos trabajando presenta un **componente tendencial** por ende la serie **no puede ser estacionaria**

Aplicamos este test con el objetivo de buscar **Raices unitarias**

1° Test simple de Dickey-Fuller

```
dfuller logipc

dfuller d.logipc /*rechazo H0, no hay raiz unitaria */
```
Rechazo $H_0$ con un coeficiente signicativo, pdemos
![image](https://user-images.githubusercontent.com/67765423/202884919-32b99aff-16f1-4a8c-9f7e-67d52bcad2f4.png)

2° Test de Dickey-Fuller ampliado

```

*1) se busca la cantidad de lags

varsoc d.logipc if fecha <= tm(2022m9), maxlag (36)
```
Con este comando vemos la cantidad de rezagos optimos en nuestro modelo, optamos por un rezago por criterio Bayesiano

![image](https://user-images.githubusercontent.com/67765423/202884979-ff8dcc81-363d-4e75-bd4b-9047b00a5cd3.png)

luego Testeo a traves de estos rezagos en el test

```
*2) testeo 
dfuller d.logipc if fecha<=tm(2022m8),lag(1)
```
![image](https://user-images.githubusercontent.com/67765423/202885022-247436c6-ccef-4789-9c0c-9a0c5fb6d4ec.png)

Tambien a traves del Test puedo observar la significancia de la tendencia

```
dfuller d.logipc if fecha<=tm(2022m9),lag(1) trend reg

```
![image](https://user-images.githubusercontent.com/67765423/202885056-74e7747e-bc82-491e-afc1-9bde1c9c8c03.png)


# ejercicio 2

vemos autocorrelacion

```
corrgram infla_sin_tendencia
```

A traves de un analisis en AC y PAC

```

ac infla_sin_tendencia/* MA(3)*/

```
<img width="1245" alt="image" src="https://user-images.githubusercontent.com/67765423/202885174-ed7a88f8-b45a-420a-8a82-348f810701a1.png">

Concluimos un MA(3)

```
pac infla_sin_tendencia /*AR(1) */

```
<img width="1205" alt="image" src="https://user-images.githubusercontent.com/67765423/202885232-6d632b9a-100c-4716-b577-99378a9ff786.png">

Concluimos un AR(1)

En forma exhaustiva debemos analizar modelo por modelo y seleccionarlos a traves de los criterios de información

AR(1)
```
qui arima infla_sin_tendencia , arima(1,0,0)
estat ic
Akaike's information criterion and Bayesian information criterion


-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   790.5666       3   -1575.133  -1564.885
----------------------------------------------------------------------------


```

AR(2)
```
qui arima infla_sin_tendencia, arima(2,0,0)
estat ic
Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   790.6459       4   -1573.292  -1559.627
-----------------------------------------------------------------------------
```


MA(3)
```
qui arima infla_sin_tendencia , arima(0,0,3)
estat ic
Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   790.0066       5   -1570.013  -1552.933
-----------------------------------------------------------------------------
```

MA(4)
```
qui arima infla_sin_tendencia, arima(0,0,4)
estat ic
Akaike's information criterion and Bayesian information criterion


-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   791.1062       6   -1570.212  -1549.716
-----------------------------------------------------------------------------

```
ARMA(1,4)
```
qui arima infla_sin_tendencia, arima(1,0,4)
estat ic
Akaike's information criterion and Bayesian information criterion


-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   791.6297       7   -1569.259  -1545.347
-----------------------------------------------------------------------------
```

ARMA(1,3)
```
qui arima infla_sin_tendencia, arima(1,0,3)
estat ic
Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   791.6297       6   -1571.259  -1550.763
-----------------------------------------------------------------------------
```


En base a los criterios de información el AR(1) Y AR(2) son los mejores modelos a utilizar

checkeo la correalcion con los ruidos blancos del AR(1)

```
arima infla_sin_tendencia, arima(1,0,0)

predict er, resid
corrgram er
```
Como no rechazo son ruido blanco

# Ejercicio 3

Estimamos un modelo para **2004 y 2021**

### Modelo AR(1)
1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores y con valores conocidos (estimacion de regresion arima)

```
arima infla_sin_tendencia if fecha<=tm(2021m12), arima(1,0,0)
```

2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando contra valores conocido(ya realizados expost

```
predict pronostico_infla_ar1, dynamic(tm(2021m12))
tsline infla_sin_tendencia pronostico_infla_ar1  if fecha<=tm(2022m6) 
```

### Modelo AR(2)
1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores y con valores conocidos (estimacion de regresion arima)

```
arima infla_sin_tendencia if fecha<=tm(2021m12), arima(2,0,0) 

```
2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando contra valores conocido(ya realizados expost

```
predict pronostico_infla_ar2, dynamic(tm(2021m12))
tsline infla_sin_tendencia pronostico_infla_ar2  if fecha<=tm(2022m2) 
```

Para evaluar nuestro mejor modelo buscamos el que presente un menor error de pronostico,utilizamos la siguiente sintaxis para modelar nuestro analisis

```
** para evaluar pronostico y el menor error
gen error_pron_ar2 = infla_sin_tendencia - pronostico_infla_ar2 if fecha >= tm(2022m1) & fecha <= tm(2022m4)

gen error_pron_ar2_cuadrado = error_pron_ar2^2 // normalizamos de forma cuadratica


** para evaluar pronostico y el menor error
gen error_pron_ar1 = infla_sin_tendencia - pronostico_infla_ar1 if fecha >= tm(2022m1) & fecha <= tm(2022m4)

gen error_pron_ar1_cuadrado = error_pron_ar1 ^2 // normalizamos de forma cuadratica

```

utilizamos el comando sum para obtener tablas de información

```
sum error_pron_ar1_cuadrado error_pron_ar2_cuadrado // AR(1) presenta un menor error de pronostico

```

![image](https://user-images.githubusercontent.com/67765423/202885876-f92df9ab-afba-42ed-8b4b-51c9f47aacb5.png)

Concluimos que el modelo AR(1) presente menor error en su prediccion

3) ex ante out of sample forecast: pronostico mas alla de la muestra de la regresion y de los valores conocidos. estimo el futuro

```
gen pronostico_inflacion22 = pronostico_infla_ar1 + tendencia 

tsline pronostico_inflacion22 dlogipc 
***** agrego estacionalidad que le saque

tsline pronostico_inflacion22 dlogipc if fecha <= tm(2022m4)
tsline pronostico_inflacion22 dlogipc if fecha >= tm(2021m1)

```
<img width="1240" alt="image" src="https://user-images.githubusercontent.com/67765423/202886005-8103e356-5307-43da-a0c7-a82e22aa6aad.png">

# ejercicio 4

1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores y con valores conocidos (estimacion de regresion arima)

```
arima infla_sin_tendencia if fecha<=tm(2021m12), arima(1,0,0) 
```
![image](https://user-images.githubusercontent.com/67765423/202886071-588268c3-9576-4d2b-8dd6-7c4bf8e3602b.png)

2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando contra valores conocido(ya realizados expost

```
predict pronostico_infla_ar1ok, dynamic(tm(2021m12))
```

3) ex ante out of sample forecast: pronostico mas alla de la muestra de la regresion y de los valores conocidos. estimo el futuro

```
arima infla_sin_tendencia if fecha <= tm(2022m1), arima (1,0,0) // condiciono para que no me tome valores siguientes

predict pron_exante2022, dynamic(tm(2022m9))

```

Agrego estacionalidad que saque anteriormente y grafico

```
gen pron_infla_2022ok = pron_exante2022 + tendencia  // linea 112 tendencia

tsline pron_infla_2022ok dlogipc if fecha >= tm(2021m1) & fecha <= tm(2022m12)
```
![image](https://user-images.githubusercontent.com/67765423/202886213-6369b709-2b0b-4748-a474-c36ed64a9739.png)


```
