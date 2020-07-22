#Include 'Totvs.ch'
/*/{Protheus.doc} F450OWN
Ponto de Entrada utilizado na montagem da express�o que comp�e o filtro da tabela SE1
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@return Caractere, Express�o caracter contendo o filtro desejado
/*/
User Function F450OWN()

    Local cString := ""

    //lTitFuturo

    cString +=   if( nDebCred == 2, " E1_FILIAL LIKE '" + SubStr( cFilAnt, 1, 2 ) + "%' AND ", "" )
    cString += " E1_CLIENTE = '" + cCli450 + "' AND "
    cString += " E1_LOJA = '" + cLjCli + "' AND "
    cString += " E1_VENCREA >= '" + DTOS( dVenIni450 ) + "' AND "
    cString += " E1_VENCREA <= '" + DTOS( dVenFim450 ) + "' AND "
    cString += " E1_MOEDA = " + Alltrim( Str( nMoeda, 2 ) ) + " AND "
    cString += " E1_SALDO > 0 AND "
    cString += " E1_TIPO " + if( nDebCred == 1, " NOT ", "" ) + " IN( 'RA', 'NCC' ) AND "
    cString += " D_E_L_E_T_ = ' ' "

Return cString
