#Include 'Totvs.ch'
/*/{Protheus.doc} F450OWN
Ponto de Entrada utilizado na montagem da expressão que compõe o filtro da tabela SE1
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/07/2020
@return Caractere, Expressão caracter contendo o filtro desejado
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

/*/{Protheus.doc} CFINP081
Função usada na pergunta do relatório para selecionar os tipos de cobrança
@type user function
@version 12.1.25
@author elton.alves@totvs.com.br
@since 03/07/2020
@return logico, Fixo .T.
/*/
User Function CFINP081()

    Local cTitulo  := 'Empresas/Filiais'
    Local aOpcoes  := {}
    Local cOpcoes  := ''
    Local aArea    := GetArea()
    Local MvPar    := &( Alltrim( ReadVar( ) ) ) // Carrega Nome da Variavel do Get em Questao
    Local MvRet    := Alltrim( ReadVar( ) )      // Iguala Nome da Variavel ao Nome variavel de Retorno
    Local nTam     := Len( AllTrim( SM0->M0_CODFIL ) )

    DbSelectArea( 'SM0' )
    SM0->( DbSetOrder( 1 ) )
    SM0->( DbGoTop( ) )

    Do While( SM0->( ! Eof( ) ) )

        cOpcoes += AllTrim( SM0->M0_CODFIL )

        aAdd( aOpcoes, SM0->( AllTrim( M0_CODFIL ) + ' - ' + AllTrim( M0_FILIAL ) ) )

        SM0->( DbSkip( ) )

    End Do

    f_Opcoes( @MvPar, cTitulo, aOpcoes, cOpcoes,,, .F., nTam )

    &MvRet := MvPar

    RestArea( aArea )

Return .T.
