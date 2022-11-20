# Tp2-series-time

clear all
import excel "/Users/lucasordonez/Desktop/TP 2/ipc", firstrow case(lower)
set more off
tsset fecha, monthly

********************************************************************************
*								ejercicio 1
********************************************************************************

gen logipc = ln(ipc)

* grafico en niveles

tsline ipc

* grafico en diferencias con logaritmo


tsline d.ipc // diferencias ipc


tsline d.logipc // para observar inflacion yy lidiar heterocedasticidad


*** filtro hp

gen dlogipc = d.logipc

hprescott dlogipc, stub(hplipc)

*Genera las siguientes variables, por un lado ciclo y por otro tendencia

* hplipc_dlogipc_1 // ciclo
* tsline hplipc_dlogipc_sm_1  // tendencia

rename hplipc_dlogipc_1 ciclo_hp
rename hplipc_dlogipc_sm_1 tendencia_hp

* Grafico HP
tsline ciclo_hp tendencia_hp


* Primera aproximacion de observacion de tendencia y estacionalidad

*** Tendencia

gen tiempo2 = tiempo ^2
gen tiempo3 = tiempo^3
gen tiempo4 = tiempo^4
******observacion de tendencia  y desestacionalización
preserve
reg D.logipc tiempo
predict Dlogipc_hat

reg D.logipc tiempo tiempo2
predict Dlogipc_hat2


reg D.logipc tiempo tiempo2 tiempo3
predict Dlogipc_hat3

reg D.logipc tiempo tiempo2 tiempo3 tiempo4
predict Dlogipc_hat4
*********************************************************************************

tsline  Dlogipc_hat3 tendencia_hp, name(tendencia3)
tsline  Dlogipc_hat4 tendencia_hp, name(tendencia4)
graph combine tendencia3 tendencia4
tsline ciclo_hp tendencia_hp 
*********************************************************************************
*observar la tendencia es simil a traves del filtro de hp y por otro lado con el ajuste polinomico


restore


*****
* se observa un efecto de un polinomio cubico(se comporta bastante bien)

reg D.logipc tiempo tiempo2 tiempo3  if fecha <= tm(2022m9) // tendencia significativa
predict tendencia
predict infla_sin_tendencia, resid

tsline tendencia

/*Analisis de estacionariedad */
*Debemos verificar si la serie presenta raiz unitaria

dfuller logipc

dfuller d.logipc /*rechazo H0, no hay raiz unitaria */

*test de fuller ampliado

*1) se busca la cantidad de lags

varsoc d.logipc if fecha <= tm(2022m9), maxlag (36)

*2) testeo 
dfuller d.logipc if fecha<=tm(2022m8),lag(1)

* si analizo tendencia deterministica(el tiempo afecta Y_t

dfuller d.logipc if fecha<=tm(2022m9),lag(1) trend reg  

* el p.value es =.0, por ende no hay tendencia deterministica



*** estacionalidad

* realizamos una regresion de la serie (infla_sin_tendencia) junto con un analisis
*a traves de dummy para chequear estacionalidad

reg D.logipc i.b(1).mes tiempo
predict estacionalidad
predict clean_infla_desnit, residuals // no presenta estacionalidad 
tsline  clean_infla_desnit infla_sin_tendencia dlogipc // ruidooo 

// Trabajamos con la serie sin tendencia y sin estacionalidad



********************************************************************************
*								ejercicio 2 cambiar a tendencia
********************************************************************************

*ahora vemos autocorrelacion

corrgram infla_sin_tendenciadest

ac infla_sin_tendenciadest /* MA(4)*/

pac infla_sin_tendenciadest /*AR(1) */

qui arima infla_sin_tendenciadest , arima(1,0,0)
estat ic
/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .    802.985       3     *-1599.97*  *-1589.722*
-----------------------------------------------------------------------------
*/

qui arima infla_sin_tendenciadest, arima(2,0,0)
estat ic

/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.1033       4   *-1598.207*  -1584.542
-----------------------------------------------------------------------------
*/



qui arima infla_sin_tendenciadest , arima(0,0,3)
estat ic

/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   799.7169       5   -1589.434  -1572.353
-----------------------------------------------------------------------------
*/



qui arima infla_sin_tendenciadest, arima(0,0,4)
estat ic

/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .    801.278       6   -1590.556  -1570.059
-----------------------------------------------------------------------------
*/


qui arima infla_sin_tendenciadest, arima(1,0,4)
estat ic
/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.3678       7   -1592.736  -1568.823
-----------------------------------------------------------------------------
*/


qui arima infla_sin_tendenciadest, arima(1,0,3)
estat ic
/*
Akaike's information criterion and Bayesian information criterion
-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.3212       6   -1594.642  -1574.146
-----------------------------------------------------------------------------
*/


*** checkeo la correlacion con los ruidos blancos de los modelos

arima infla_sin_tendenciadest, arima(1,0,0)

predict er, resid
corrgram er
drop er
**como no rechazo son ruido blanco


//conclusion AR(1)
//el segundo modelo a probar es AR(2)


* primero intuimos graficamente las caracteristicas del modelo, luego tomamos 
* un criterio de caracterizacion de la serie, llegando a la conclusion que el AR(1)
* es el mejor modelo que explica la variacion del indice de precios

********************************************************************************
*								ejercicio 3
********************************************************************************

** variable a seguir : infla_sin_tendenciadest

*** estimamos un modelo para 2004 y 2021


********************************************************************************
*								modelo AR(1)
********************************************************************************
*1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores
*y con valores conocidos (estimacion de regresion arima)

arima infla_sin_tendencia if fecha<=tm(2021m12), arima(1,0,0) 

* 2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando
*contra valores conocido(ya realizados expost

predict pronostico_infla_ar1, dynamic(tm(2021m12))
tsline infla_sin_tendencia pronostico_infla_ar1  if fecha<=tm(2022m6) // a modo visuAl agregar linea vertical en 2021m12

** para evaluar pronostico y el menor error
gen error_pron_ar1 = infla_sin_tendencia - pronostico_infla_ar1 if fecha >= tm(2022m1) & fecha <= tm(2022m4)

gen error_pron_ar1_cuadrado = error_pron_ar1 ^2 // normalizamos de forma cuadratica


********************************************************************************
*								modelo AR(2)
********************************************************************************
*1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores
*y con valores conocidos (estimacion de regresion arima)

arima infla_sin_tendencia if fecha<=tm(2021m12), arima(2,0,0) 

* 2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando
*contra valores conocido(ya realizados expost

predict pronostico_infla_ar2, dynamic(tm(2021m12))
tsline infla_sin_tendencia pronostico_infla_ar2  if fecha<=tm(2022m2) // a modo visuAl agregar linea vertical en 2021m12

** para evaluar pronostico y el menor error
gen error_pron_ar2 = infla_sin_tendencia - pronostico_infla_ar2 if fecha >= tm(2022m1) & fecha <= tm(2022m4)

gen error_pron_ar2_cuadrado = error_pron_ar2^2 // normalizamos de forma cuadratica


sum error_pron_ar1_cuadrado error_pron_ar2_cuadrado // AR(1) presenta un menor error de pronostico



* 3) ex ante out of sample forecast: pronostico mas alla de la muestra de la regresion y de los valores 
* conocidos. estimo el futuro

gen pronostico_inflacion22 = pronostico_infla_ar1 + tendencia 

tsline pronostico_inflacion22 dlogipc 
***** agrego estacionalidad que le saque

tsline pronostico_inflacion22 dlogipc if fecha <= tm(2022m4)
tsline pronostico_inflacion22 dlogipc if fecha >= tm(2021m1)


********************************************************************************
*								ejercicio 4
********************************************************************************



*1) in sample forecast o parte training: entrenamos al modelo dentro de la muestra y con valores
*y con valores conocidos (estimacion de regresion arima)

arima infla_sin_tendencia if fecha<=tm(2021m12), arima(1,0,0) 

* 2) Ex post out of sample forecast o parte testing: pornostico mas alla de la muestra de la regresion testeando
*contra valores conocido(ya realizados expost

predict pronostico_infla_ar1ok, dynamic(tm(2021m12))

* 3) ex ante out of sample forecast: pronostico mas alla de la muestra de la regresion y de los valores 
* conocidos. estimo el futuro

arima infla_sin_tendencia if fecha <= tm(2022m1), arima (1,0,0) // condiciono para que no me tome valores siguientes

predict pron_exante2022, dynamic(tm(2022m9))

***** agrego estacionalidad que le saque

gen pron_infla_2022ok = pron_exante2022 + tendencia  // linea 112 tendencia

tsline pron_infla_2022ok dlogipc if fecha >= tm(2021m1) & fecha <= tm(2022m12)
