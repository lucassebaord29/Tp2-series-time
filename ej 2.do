import excel "/Users/lucasordonez/Library/CloudStorage/OneDrive-Económicas-UBA/Econometria-Montes Rojas/TP 2/ipc.xlsx",firstrow case(lower)

tsset fecha, monthly

gen logipc = ln(ipc)

gen tiempo2 = tiempo ^2
gen tiempo3 = tiempo^3

******observacion de tendencia 
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

reg D.logipc tiempo tiempo2 tiempo3
predict tendencia
predict infla_sin_tendencia, resid


**Inflacion sin tendencia
line infla_sin_tendencia fecha

*** tambien sacamos estacionalidad

*creamos dummy ==> desestacionalizamos(solo para dummy) y sacamos tendencia

reg D.logipc i.mes tiempo
predict clean_infla, residuals
line  clean_infla fecha

**otra forma

reg clean_infla i.mes
predict infla_limpia, residual
line infla_limpia fecha

*o tsline
***ahora vemos autocorrelacion

ac infla_limpia  /* MA(3)*/

pac infla_limpia /*AR(1) */

qui arima infla_limpia , arima(1,0,0)
estat ic

----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        220         .   792.5628       3   -1579.126  -1568.945
-----------------------------------------------------------------------------

qui arima infla_limpia, arima(2,0,0)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        220         .   792.5858       4   -1577.172  -1563.597
-----------------------------------------------------------------------------

qui arima infla_limpia , arima(0,0,3)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        220         .   792.0254       5   -1574.051  -1557.083
-----------------------------------------------------------------------------

qui arima infla_limpia, arima(1,0,3)
estat ic

-----------------------------------------------------------------------------
       Model |        Obs  ll(null)  ll(model)      df         AIC        BIC
-------------+---------------------------------------------------------------
           . |        220         .   792.7013       6   -1573.403  -1553.041
-----------------------------------------------------------------------------

*conclusion AR(1)
* primero intuimos graficamente las caracteristicas del modelo, luego tomamos 
* un criterio de caracterizacion de la serie, llegando a la conclusion que el AR(1)
* es el mejor modelo que explica la variacion del indice de precios

