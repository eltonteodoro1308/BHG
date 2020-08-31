#Include 'Totvs.ch'
/*/{Protheus.doc} F450OWN1
Ponto de Entrada utilizado na montagem da expressão que compõe o filtro da tabela SE2 com o objetivo de exibir títulos de empresas diferentes.
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@return Caractere, Expressão caracter contendo o filtro desejado
/*/
User Function F450OWN1()

    Local cString := ""

    //lTitFuturo

    if nDebCred == 1

        cString := " E2_FILIAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' AND "

    else

        cString := " E2_FILIAL LIKE '" + SubStr( cFilAnt, 1, 2 ) + "%' AND "

    end if

    cString += " E2_FORNECE = '" + cFor450 + "' AND "
    cString += " E2_LOJA = '" + cLjFor + "' AND "
    cString += " E2_VENCREA >= '" + DTOS( dVenIni450 ) + "' AND "
    cString += " E2_VENCREA <= '" + DTOS( dVenFim450 ) + "' AND "
    cString += " E2_MOEDA = " + Alltrim( Str( nMoeda, 2 ) ) + " AND "
    cString += " E2_SALDO > 0 AND "
    cString += " E2_TIPO " + if( nDebCred == 1, ' NOT ', '' ) + " IN( 'PA', 'NDF' ) AND "
    cString += " D_E_L_E_T_ = ' ' "

Return cString
