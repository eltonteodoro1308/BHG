#include 'totvs.ch'

#define PREVISTO  1
#define REALIZADO 2

/*/{Protheus.doc} BFINR001
Gera planlha excel com Fluxo de Caixa por Natureza.
@type user function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 29/09/2020
/*/
user function BFINR001()

    Local cCodVisao    := ''
    Local nNivel       := 0
    Local nTipoSaldo   := ''
    Local nDiasAgrup   := 0
    Local dDataDe      := StoD('')
    Local dDataAte     := StoD('')
    Local nOcultaCol   := 0
    Local cQryBanco    := ''
    Local dAux1        := StoD('')
    Local dAux2        := StoD('')
    Local jRelatorio   := JsonObject():New()

    // Exibe pergunta com os par�metros para processamento dos dados
    // Caso seja clicado em cancelar o programa � encerrado 
    If Pergunte( 'BFINR001' )

        cCodVisao  := MV_PAR01
        nNivel     := MV_PAR02
        nTipoSaldo := MV_PAR03
        nDiasAgrup := MV_PAR04
        dDataDe    := MV_PAR05
        dDataAte   := MV_PAR06
        nOcultaCol := MV_PAR07

    else

        return

    end if

    // Verifica se a data de In�cio do Per�odo de Refer�ncia n�o � maior que a data Final.
    // Encerra o programa caso seja maior
    if !( dDataDe <=  dDataAte )

        ApMsgStop( 'A data de In�cio do Per�odo de Refer�ncia n�o pode ser maior que a data Final', 'BFINR001' )

        return

    end if

    // Busca a lista de bancos a serem considerados
    // Encerra o processamento caso seja clicado no bot�o cancelar
    if ! GetBanco( @cQryBanco )

        return

    end if

    // Monta as datas das colunas com base no agrupamento para exibi��o no Fluxo de Caixa
    jRelatorio['COLUNAS'] := {}

    dAux1 := dDataDe
    dAux2 := dDataDe + nDiasAgrup - 1

    do while .T.

        if dAux2 > dDataAte

            dAux2 := dDataAte

            aAdd( jRelatorio['COLUNAS'], { dAux1, dAux2 } )

            exit

        else

            aAdd( jRelatorio['COLUNAS'], { dAux1, dAux2 } )

        end if

        dAux1 := dAux2 + 1
        dAux2 := dAux1 + nDiasAgrup - 1

    end do

    //TODO Posibilidade de exibir apenas as naturezas anal�ticas ou sint�ticas definindo o n�vel 
    //TODO Busca Saldos Iniciais dos Bancos
    //TODO Busca as movimenta��es previstas SE1/SE2
    //TODO Busca as movimenta��es realizadas SE5
    //TODO Monta a Lista ordenada de Naturezas
    //TODO Popula a Lista de Naturezas com os saldos
    //TODO Monta a Vis�o Gerencial
    //TODO Popula a Vis�o Gerecial com os saldos
    //TODO Popula as naturezas com seus saldos baseados em previsto/realizado

return

/*/{Protheus.doc} GetBanco
Fun��o que exibe tela de marca��o dos bancos que ir�o compor o fluxo de caixa
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 30/09/2020
@param cQryBanco, character, Vari�vel recebida por vari�vel a ser populada com a lista de bancos em formato a ser utilizado na cl�usula IN de uma query
@return logical, Retorna true se clicado no bot�o ok e falso se clicado no bot�o cancelar 
/*/
Static Function GetBanco( cQryBanco )

    Local oOK     := LoadBitmap( GetResources(),'LBTIK')
    Local oNO     := LoadBitmap( GetResources(),'LBNO' )
    Local oDlg    := Nil
    Local oBrowse := Nil
    Local oBtnOk1 := Nil
    Local oBtnOk2 := Nil
    Local lOk     := .F.
    Local aCabec  := { '', 'Banco', 'Ag�ncia', 'Conta', 'Nome' }
    Local aCabLen := { 20, 30, 30, 30, 50 }
    Local aBrowse := {}
    Local aBanco  := {}
    Local aAux    := {}
    Local cAux    := ''
    Local aArea   := GetArea()
    Local nX      := 0
    Local nY      := 0

    // Popula array a ser utilizado no componente
    // de marca��o de com a lista de bancos cadastrados
    DbSelectArea( 'SA6' )
    SA6->( DbSetOrder( 1 ) )
    SA6->( DbGoTop() )

    Do While ! SA6->( Eof() )

        // Verifica se o Banco Pertence a Filial Corrente
        If xFilial( 'SA6' ) == SA6->A6_FILIAL

            // Popula array com dados do banco
            aAdd( aBanco, .F.             )
            aAdd( aBanco, SA6->A6_COD     )
            aAdd( aBanco, SA6->A6_AGENCIA )
            aAdd( aBanco, SA6->A6_NUMCON  )
            aAdd( aBanco, SA6->A6_NOME   )

            // Inclui linha do banco no array de lista de bancos
            aAdd( aBrowse, aClone( aBanco ) )

            // Esvazia array auxiliar
            aSize( aBanco, 0 )

        End If

        // Pr�xima Linha da Tabela
        SA6->( DbSkip() )

    End Do

    // Encerra a area da tabela de bancos
    SA6->( DbCloseArea() )

    // Retaura ambiente
    RestArea( aArea )

    // Monta janela de marca��o de banco a serem
    // considerados no Fluxo de Caixa
    DEFINE DIALOG oDlg TITLE 'Selecione os Bancos' FROM 180,180 TO 550,700 PIXEL

    // Cria o componete de marca��o
    oBrowse := TWBrowse():New( 01, 01, 260, 170,, aCabec, aCabLen, oDlg;
        ,,,,,{||},,,,,,, .F.,, .T.,, .F.,,, )

    // Seta o array com a lista de bancos
    oBrowse:SetArray( aBrowse )

    // Define o bloco de c�dico a ser executado para
    // cada linha para popular o componente de marca��o
    oBrowse:bLine := { || {;
        IIf( aBrowse[ oBrowse:nAt , 01 ], oOK, oNO ),;
        aBrowse[ oBrowse:nAt, 02 ],;
        aBrowse[ oBrowse:nAt, 03 ],;
        aBrowse[ oBrowse:nAt, 04 ],;
        aBrowse[ oBrowse:nAt, 05 ] } }

    // Define o Bloco de C�digo a ser executado ao
    // clicar duas vezes na linha para marca��o da
    // mesma
    oBrowse:bLDblClick := { ||;
        aBrowse[ oBrowse:nAt, 1 ] := !aBrowse[ oBrowse:nAt, 1 ],;
        oBrowse:DrawSelect() }

    // Define Bloco de C�digo a ser executado ao
    // clicar no cabe�alho da coluna de marca��o
    // para inverter a sele��o
    oBrowse:bHeaderClick := { | oBrowse, nLinha | InvSelec( oBrowse, nLinha ) }

    // Define bot�o OK da tela de marca��o
    // que encerra a tela e segue com o programa
    // e o bot�o de cancelar que encerra a aplica�ao sem executar nada
    oBtnOk1 := SButton():New( 173, 200, 1, { || lOk := ValidaOk( aBrowse ), IIf( lOk, oDlg:End(), ApMsgInfo( 'Selecione os bancos para serem Processados', 'BFINR001' ) ) }, oDlg, .T. )
    oBtnOk2 := SButton():New( 173, 230, 2, { || lOk := .F., oDlg:End() }, oDlg, .T. )

    ACTIVATE DIALOG oDlg CENTERED

    // Verifica se foi clicado no bot�o cancela sai sem executar nenhuma a��o
    If lOk

        // Popula array auxiliar com os bancos marcados
        For nX := 1 To Len( aBrowse )

            If aBrowse[ nX, 1 ]

                For nY := 2 To Len( aBrowse[ nX ] ) - 1

                    cAux += aBrowse[ nX, nY ]

                Next nY

                aAdd( aAux, cAux )

                cAux := ''

            End If

        Next nX

        // Popula vari�vel de retorno com a lista de bancos marcados
        For nX := 1 To Len( aAux )

            cQryBanco += aAux[ nX ]

            If nX # Len( aAux )

                cQryBanco += ','

            End If

        Next nX

        // Verifica se nenhum banco foi selecionado e assim exibe alerta e encerra aplica��o
        If ! Empty( aAux )

            // Formata lista de bancos em formato a ser utilizado na cl�usula IN do SQL
            cQryBanco := FormatIn( cQryBanco, ',' )

        End If

    End If

Return lOk

/*/{Protheus.doc} ValidaOk
Recebe um array com a lista de bancos e verificar se algum foi marcado
@type static function
@version 12.1.17
@author elton.alves@totvs.com.br
@since 30/09/2020
@param aBrowse, array, Array com a lista de bancos
@return logical, Retorna true se algum banco foi marcado
/*/
static function ValidaOk( aBrowse )

return aScan( aBrowse, {  | linha | linha[1] } ) <> 0

/*/{Protheus.doc} InvSelec
Fun��o que faz a invers�o da sele��o ao clicar no cabe�alho da coluna de marca��o da linha
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 30/09/2020
@param oBrowse, objeto, Objeto que representa o componente de marca��o dos bancos
@param nLinha, num�rico, Linha posicionada no componente de marca��o dos bancos
/*/
Static Function InvSelec( oBrowse, nLinha )

    Local nX := 0

    // Percorre array de marca��o invertente a sele��o
    For nX := 1 To Len( oBrowse:aArray )

        oBrowse:aArray[ nX, 1 ] := ! oBrowse:aArray[ nX, 1 ]

    Next nX

    // For�a a atualiza��o da tela de marca��o
    oBrowse:Refresh()

Return


/**Tabelas
FJ1
FJ2
FJ3
SED
SE1
SE2
SE5
FIV
FIW
SA6
SE8
*/

/**Modelo Objeto Fluxo de Caixa por Natureza
[

]

*/
