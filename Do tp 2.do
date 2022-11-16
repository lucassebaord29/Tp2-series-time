import excel "/Users/lucasordonez/Desktop/TP 2/ipc.xlsx", firstrow case(lower)

tsset fecha, monthly

********************************************************************************
*ejercicio 1
********************************************************************************
*Genero el logipc*

gen logipc = ln(ipc)

*graficos

tsline ipc

*Grafico en diferencias*

tsline d.logipc /*Para observar la inflacion*/

/*Analisis de estacionariedad */
*Debemos verificar si la serie presenta raiz unitaria

dfuller d.logipc /*rechazo H0, no hay raiz unitaria */

*test de fuller ampliado

*1) se busca la cantidad de lags

varsoc d.logipc if fecha <= tm(2022m8), maxlag (36)

*2) testeo 
dfuller d.logipc if fecha<=tm(2022m8),lag(1)

* si analizo tendencia deterministica(el tiempo afecta Y_t

dfuller d.logipc if fecha<=tm(2022m9),lag(1) trend reg  

* el p.value es =.0, por ende no hay tendencia deterministica

********************************************************************************
*ejercicio 2
********************************************************************************


gen tiempo2 = tiempo ^2
gen tiempo3 = tiempo^3

******observacion de tendencia  y desestacionalización
preserve
reg D.logipc tiempo
predict Dlogipc_hat

reg D.logipc tiempo tiempo2
predict Dlogipc_hat2


reg D.logipc tiempo tiempo2 tiempo3
predict Dlogipc_hat3

line D.logipc Dlogipc_hat Dlogipc_hat2 Dlogipc_hat3 tiempo

restore
*****
* se observa un efecto de un polinomio cubico(se comporta bastante bien)

reg D.logipc tiempo tiempo2 tiempo3 // tendencia significativa
predict tendencia
predict infla_sin_tendencia, resid


**Inflacion sin tendencia 
line infla_sin_tendencia d.logipc fecha


* realizamos una regresion de la serie (infla_sin_tendencia) junto con un analisis
*a traves de dummy para chequear estacionalidad

reg D.logipc i.mes tiempo
predict clean_infla_desnit, residuals
line  clean_infla_desnit fecha

****observacion

line clean_infla_desnit infla_sin_tendencia fecha
/*
**otra forma

reg clean_infla i.mes
predict infla_limpia, residual
line infla_limpia fecha
*/
*o tsline
***ahora vemos autocorrelacion

corrgram clean_infla_desnit

ac clean_infla_desnit /* MA(3)*/

pac clean_infla_desnit /*AR(1) */

qui arima clean_infla_desnit , arima(1,0,0)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .    802.985       3    **-1599.97**  **-1589.722**
-----------------------------------------------------------------------------


qui arima clean_infla_desnit, arima(2,0,0)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.1033       4   -1598.207 -1584.542
-----------------------------------------------------------------------------


qui arima clean_infla_desnit , arima(0,0,3)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   799.7169       5   -1589.434  -1572.353
-----------------------------------------------------------------------------


qui arima clean_infla_desnit, arima(0,0,4)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .    801.278       6   -1590.556  -1570.059
-----------------------------------------------------------------------------

qui arima clean_infla_desnit, arima(1,0,4)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.3678       7   -1592.736  -1568.823
-----------------------------------------------------------------------------


qui arima clean_infla_desnit, arima(1,0,3)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        225         .   803.3212       6   -1594.642  -1574.146
-----------------------------------------------------------------------------

*** checkeo la correlacion con los ruidos blancos de los modelos

arima clean_infla_desnit, arima(1,0,0)
predict er, resid
corrgram er
drop er

**como no rechazo son ruido blanco
*conclusion AR(1)
* primero intuimos graficamente las caracteristicas del modelo, luego tomamos 
* un criterio de caracterizacion de la serie, llegando a la conclusion que el AR(1)
* es el mejor modelo que explica la variacion del indice de precios

********************************************************************************
*ejercicio 3
********************************************************************************


*****estacionalidad y tendencia****
preserve
reg D.logipc tiempo  if fecha <= tm(2021m12)
predict tendencia 
predict infla_sin_tendencia,residuals

reg infla_sin_tendencia i.mes if fecha <= tm(2021m12)
predict estacionalidad
predict inflalimpia, residuals

*sabemos que es ar(1)
qui arima infla_limpia if fecha <= tm(2021m12), arima(1,0,0)
estat ic

Akaike's information criterion and Bayesian information criterion

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        216         .   780.2898       3    -1554.58  -1544.454
-----------------------------------------------------------------------------

pac inflalimpia2 if fecha <= tm(2021m12)


restore




