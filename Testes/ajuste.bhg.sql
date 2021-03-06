UPDATE SE5010 SET 

E5_BANCO   = 'CXX',  
E5_AGENCIA = 'CXX',
E5_CONTA   = 'CXX'

WHERE 

R_E_C_N_O_ IN(

SELECT

    SE5.R_E_C_N_O_

FROM SE5010 SE5

    LEFT JOIN SA6010 SA6
    ON  SE5.D_E_L_E_T_ = SA6.D_E_L_E_T_
        AND SE5.E5_BANCO   = SA6.A6_COD
        AND SE5.E5_AGENCIA = SA6.A6_AGENCIA
        AND SE5.E5_CONTA   = SA6.A6_NUMCON

WHERE SE5.E5_BANCO <> '   '
    AND COALESCE(SA6.A6_NOME,'null') = 'null'
    AND SE5.D_E_L_E_T_ = ' '

)

--------------------------------------------------------

UPDATE SE5010 SET 

E5_NATUREZ = 'D02.15' 

WHERE 

R_E_C_N_O_ IN(

SELECT

    SE5.R_E_C_N_O_

FROM SE5010 SE5

    LEFT JOIN SED010 SED
    ON  SE5.D_E_L_E_T_ = SED.D_E_L_E_T_
        AND SE5.E5_NATUREZ = SED.ED_CODIGO

WHERE COALESCE(SED.ED_CODIGO,'null') = 'null'
    AND SE5.E5_RECPAG = 'P'
    AND SE5.D_E_L_E_T_ = ' ' )

--------------------------------------------------------

UPDATE SE5010 SET 

E5_NATUREZ = 'R25.03' 

WHERE 

R_E_C_N_O_ IN(

SELECT

    SE5.R_E_C_N_O_

FROM SE5010 SE5

    LEFT JOIN SED010 SED
    ON  SE5.D_E_L_E_T_ = SED.D_E_L_E_T_
        AND SE5.E5_NATUREZ = SED.ED_CODIGO

WHERE COALESCE(SED.ED_CODIGO,'null') = 'null'
    AND SE5.E5_RECPAG = 'R'
    AND SE5.D_E_L_E_T_ = ' ' )

--------------------------------------------------------

UPDATE SE1010 SET 

E1_NATUREZ = 'R25.03' 

WHERE 

R_E_C_N_O_ IN(

SELECT

    SE1.R_E_C_N_O_

FROM SE1010 SE1

    LEFT JOIN SED010 SED
    ON  SE1.D_E_L_E_T_ = SED.D_E_L_E_T_
        AND SE1.E1_NATUREZ = SED.ED_CODIGO

WHERE COALESCE(SED.ED_CODIGO,'null') = 'null'
    AND SE1.D_E_L_E_T_ = ' ' )

--------------------------------------------------------

UPDATE SE2010 SET 

E2_NATUREZ = 'D02.15' 

WHERE 

R_E_C_N_O_ IN(

SELECT

    SE2.R_E_C_N_O_

FROM SE2010 SE2

    LEFT JOIN SED010 SED
    ON  SE2.D_E_L_E_T_ = SED.D_E_L_E_T_
        AND SE2.E2_NATUREZ = SED.ED_CODIGO

WHERE COALESCE(SED.ED_CODIGO,'null') = 'null'
    AND SE2.D_E_L_E_T_ = ' ' )