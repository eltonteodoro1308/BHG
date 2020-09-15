#include 'totvs.ch'

/*/{Protheus.doc} Sienge
Rotina inclu�da no menu do programa MATA103 (Pedidos de Compras) pelo ponto de entrada MT120BRW,
que tem como objetivo buscar no Web Service do SIENGE os Pedidos de Compras nele cadastrados e
import�-los para base do Protheus
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@obs Esta rotina tem dep�ncia dos par�mtros: 
SIE_CONDPG
SIE_URL   
SIE_USER  
SIE_PASWOR
SIE_EMPRES (Deve ser definido para cada filial)
SIE_ATVPRJ (Deve ser definido para cada filial)
SIE_CCUSTO
A documenta��o da API de integra��o com SIENGE se encontra no link https://api.sienge.com.br/docs/
/*/
User Function Sienge()

    Local oBtnCancel := nil
    Local oBtnPrcDt  := nil
    Local oBtnPrcId  := nil
    Local oGetDtAte  := nil
    Local cGetDtAte  := dDataBase
    Local oGetDtDe   := nil
    Local cGetDtDe   := dDataBase
    Local oGetId     := nil
    Local cGetIdPic  := '9999999999'
    Local cGetId     := Space( Len( cGetIdPic ) )
    Local oGrpData   := nil
    Local oGrpId     := nil
    Local oSayDtAte  := nil
    Local oSayDtDe   := nil
    Local oSayId     := nil
    Local oDlgMain   := nil
    //Local cAviso     := ''

    Private cSIECONDPG := AllTrim( GetMv( 'SIE_CONDPG' ) )
    Private cSIEURL    := AllTrim( GetMv( 'SIE_URL'    ) )
    Private cSIEUSER   := AllTrim( GetMv( 'SIE_USER'   ) )
    Private cSIEPASWOR := AllTrim( GetMv( 'SIE_PASWOR' ) )
    Private cSIEEMPRES := AllTrim( GetMv( 'SIE_EMPRES' ) )
    Private cSIEATVPRJ := AllTrim( GetMv( 'SIE_ATVPRJ' ) )
    Private cSIECCUSTO := AllTrim( GetMv( 'SIE_CCUSTO' ) )
    Private cCodNomFil := SM0->( AllTrim( M0_CODFIL ) + ' - ' + AllTrim( M0_FILIAL ) )
    Private aHeader    :=  { 'Authorization: Basic ' + Encode64( cSIEUSER + ':' + cSIEPASWOR ) }

    // Se o Centro de Custo a ser aplicado aos Pedidos de Compras � v�lido e n�o est� bloqueado
    // Se o Item Cont�bil a ser aplicado aos Pedidos de Compras � v�lido e n�o est� bloqueado
    // Se condi��o de pagamento existe no cadastro e se n�o est� bloqueada

    if Empty( cSIECONDPG );
            .Or. Empty( cSIEURL );
            .Or. Empty( cSIEUSER );
            .Or. Empty( cSIEPASWOR );
            .Or. Empty( cSIEEMPRES );
            .Or. Empty( cSIEATVPRJ );
            .Or. Empty( cSIECCUSTO )

        Aviso ( cCodNomFil, ;
            'SIE_CONDPG' + CRLF + ;
            'SIE_URL'    + CRLF + ;
            'SIE_USER'   + CRLF + ;
            'SIE_PASWOR' + CRLF + ;
            'SIE_EMPRES -> ( Deve ser definido por Filial ) ' + CRLF + ;
            'SIE_ATVPRJ -> ( Deve ser definido por Filial ) ' + CRLF + ;
            'SIE_CCUSTO',;
            {'Fechar'}, 2,'Defina os par�metros de integra��o para a Empresa/Filial.')

        return

    end if

    DEFINE MSDIALOG oDlgMain TITLE cCodNomFil FROM 000, 000  TO 160, 410 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGrpData TO 062, 096 PROMPT "Requisitar Por Data do Pedido:" OF oDlgMain COLOR 0, 16777215 PIXEL
    @ 015, 005 SAY oSayDtDe PROMPT "Data de:" SIZE 025, 007 OF oDlgMain COLORS 0, 16777215 PIXEL
    @ 013, 030 MSGET oGetDtDe VAR cGetDtDe SIZE 060, 010 OF oDlgMain COLORS 0, 16777215 HASBUTTON PIXEL
    @ 028, 005 SAY oSayDtAte PROMPT "Data at�:" SIZE 025, 007 OF oGrpData COLORS 0, 16777215 PIXEL
    @ 026, 030 MSGET oGetDtAte VAR cGetDtAte SIZE 060, 010 OF oDlgMain COLORS 0, 16777215 HASBUTTON PIXEL
    @ 044, 051 BUTTON oBtnPrcDt PROMPT "Processar" SIZE 037, 012 OF oDlgMain ACTION ProcData(cGetDtDe,cGetDtAte) PIXEL

    @ 002, 099 GROUP oGrpId TO 063, 202 PROMPT "Requisitar por ID do Pedido" OF oDlgMain COLOR 0, 16777215 PIXEL
    @ 024, 105 SAY oSayId PROMPT "ID do Pedido:" SIZE 035, 007 OF oDlgMain COLORS 0, 16777215 PIXEL
    @ 022, 138 MSGET oGetId VAR cGetId SIZE 060, 010 OF oDlgMain PICTURE cGetIdPic COLORS 0, 16777215 PIXEL
    @ 046, 161 BUTTON oBtnPrcId PROMPT "Processar" SIZE 037, 012 OF oDlgMain ACTION ProcId(cGetId) PIXEL

    @ 065, 164 BUTTON oBtnCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlgMain ACTION oDlgMain:End() PIXEL

    ACTIVATE MSDIALOG oDlgMain CENTERED

Return

/*/{Protheus.doc} ProcData
Requista pedidos de compras em uma faixa de datas
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param dDe, date, Data Inicial do per�odo
@param dAte, date, Data Final d Per�odo
/*/
static function ProcData( dDe, dAte )

    Local aCabPedCmp := nil

    if dDe > dAte

        ApMsgAlert( 'A data de In�cio deve ser menor ou igual do que a data Final.', 'SIENGE' )

    else

        MsgRun ( 'Buscando Pedidos no Web Service do SIENGE...', 'Aguarde alguns instantes...', {|| aCabPedCmp := RunData( dDe, dAte ) } )

    end if

    if Empty( aCabPedCmp )

        ApMsgAlert( 'N�o houve retorno pedido na busca solicitada.', 'SIENGE' )

    else

        ProcPedCmp( aCabPedCmp )

    end if

return

/*/{Protheus.doc} RunData
Processa a requisi��o de pedidos de compras em uma faixa de datas
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param dDe, date, Data Inicial do per�odo
@param dAte, date, Data Final d Per�odo
/*/
static function RunData( dDe, dAte )

    Local cRet      := ""
    Local aRet      := {}
    Local cPath     := ""
    Local nLimit    := 200
    Local nOffSet   := 0
    Local nCount    := 0
    Local oFwRest   := nil
    Local oJson     := nil
    Local nX        := 0

    Do While .T.

        cPath += '/purchase-orders/'
        cPath += '?limit='
        cPath += cValToChar( nLimit )
        cPath += '&offset='
        cPath += cValToChar( nLimit * nOffSet )
        cPath += '&startDate='
        cPath += DateFormat( dDe )
        cPath += '&endDate='
        cPath += DateFormat( dAte )
        cPath += '&buildingId='
        cPath += cSIEEMPRES
        cPath += '&status=PENDING'
        cPath += '&authorized=true'

        oFwRest := FWRest():New( cSIEURL )

        oFwRest:SetPath( cPath )

        if oFwRest:Get( aHeader )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                nCount := oJson["resultSetMetadata"]["count"]

                for nX := 1 to len( oJson['results'] )

                    aAdd( aRet, oJson['results'][nX] )

                next nx

            else

                ApMsgStop(  'N�o Foi poss�vel montar o JSON da requisi��o:' + CRLF + cRet )

                aSize( aRet, 0 )

                Exit

            end if

        else

            ApMsgStop(  'N�o Foi poss�vel fazer esta requisi��o:' + CRLF + oFwRest:GetLastError(), 'SIENGE' )

            aSize( aRet, 0 )

            Exit

        end if

        nOffSet++
        cPath := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        //if nCount >= ( ( nLimit * nOffSet ) + 1 ) .And. nCount <= ( nLimit * ( nOffSet  + 1 ) )

        if nCount < ( nLimit * nOffSet ) + 1

            Exit

        End If

    End Do

return aRet

/*/{Protheus.doc} ProcId
Requisita um pedido de compras pelo ID
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cID, character, ID do Pedido de Compras requisitado
/*/
static function ProcId( cID )

    Local aCabPedCmp := nil

    if Empty( cId )

        ApMsgAlert( 'Informe um Id de Pedido de Compra V�lido.', 'SIENGE' )

    else

        MsgRun ( 'Buscando Pedidos no Web Service do SIENGE...', 'Aguarde alguns instantes...', {|| aCabPedCmp := RunId( cID ) } )

    end if

    if ! Empty( aCabPedCmp )

        ProcPedCmp( aCabPedCmp )

    end if

return

/*/{Protheus.doc} RunId
Processa a requisi��o de um pedido de compras pelo ID
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cID, character, ID do Pedido de Compras requisitado
/*/
static function RunId( cID )

    Local cRet    := ""
    Local aRet    := {}
    Local lOk     := .F.
    Local oFwRest := nil
    Local oJson   := nil

    oFwRest := FWRest():New( cSIEURL )

    oFwRest:SetPath( 'purchase-orders/' + AllTrim( cID ) )

    lOk := oFwRest:Get( aHeader )

    oJson := JsonObject():New()

    cRet := oJson:FromJSON( oFwRest:GetResult() )

    if ! Empty( cRet )

        ApMsgStop(  'N�o Foi poss�vel montar o JSON da requisi��o:' + CRLF + cRet )

        return aRet

    end if

    if lOk

        if oJson['status'] != 'PENDING'

            ApMsgAlert(  'Pedido de Compras "' + AllTrim( cID ) + '" n�o est� com a situa��o "PENDENTE"', 'SIENGE' )

        elseif ! oJson['authorized']

            ApMsgAlert(  'Pedido de Compras "' + AllTrim( cID ) + '" n�o est� Autorizado', 'SIENGE' )

        else

            aRet := { oJson }

        end if

    elseif oJson['developerMessage'] == "purchase.order.not_found"

        ApMsgAlert( 'Pedido de Compras "' + AllTrim( cID ) + '" n�o localizado', 'SIENGE' )

    else

        ApMsgStop(  'N�o Foi poss�vel fazer esta requisi��o:' + CRLF + oFwRest:GetLastError(), 'SIENGE' )

    end if

return aRet

/*/{Protheus.doc} ProcPedCmp
Processa a lista de pedidos de compras recebida buscando seus itens correspondentes e fazendo as valida��es do Pedido de Compras
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/09/2020
@param aCabPedCmp, array, array com a lista de cabe�alhos de pedidos de compras
/*/
static function ProcPedCmp( aCabPedCmp )

    Local nX       := 0
    Local cId      := ''

    for nX := 1 to Len( aCabPedCmp )

        cId := cValToChar( aCabPedCmp[ nX ]['id'] )

        MsgRun( 'Buscando itens do Pedido ' + cId + '...', 'Aguarde alguns instantes...', {|| GetItens( aCabPedCmp[ nX ] ) } )

        MsgRun( 'Buscando CNPJ do Fornecedor do Pedido ' + cId + '...', 'Aguarde alguns instantes...', {|| GetFornec( aCabPedCmp[ nX ] ) } )

        MsgRun( 'Validando dados do Pedido ' + cId + '...', 'Aguarde alguns instantes...', {|| VldPedCmp( aCabPedCmp[ nX ] ) } )

    next nX

    //TODO ShowPedCmp( aCabPedCmp )

return

/*/{Protheus.doc} GetItens
Busca no SIENGE os itens dos Pedido de Compra
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 14/09/2020
@param oJsonCabec, object, Objeto json com o cabe�alho do pedido de compras que ser� populado com seus itens correspondentes.
/*/
static function GetItens( oJsonCabec )

    Local cRet      := ""
    Local cPath     := ""
    Local nLimit    := 200
    Local nOffSet   := 0
    Local nCount    := 0
    Local oFwRest   := nil
    Local oJson     := nil
    Local nX        := 0

    oJsonCabec['itens'] := {}

    Do While .T.

        cPath += '/purchase-orders/'
        cPath += cValToChar( oJsonCabec['id'] )
        cPath += '/items/?limit='
        cPath += cValToChar( nLimit )
        cPath += '&offset='
        cPath += cValToChar( nLimit * nOffSet )

        oFwRest := FWRest():New( cSIEURL )

        oFwRest:SetPath( cPath )

        oFwRest:Get( aHeader )

        oJson := JsonObject():New()

        cRet := oJson:FromJSON( oFwRest:GetResult() )

        nCount := oJson["resultSetMetadata"]["count"]

        for nX := 1 to len( oJson['results'] )

            aAdd( oJsonCabec['itens'], oJson['results'][nX] )

        next nx

        nOffSet++
        cPath := ''
        FreeObj( oJson   )
        FreeObj( oFwRest )

        if nCount < ( nLimit * nOffSet ) + 1

            Exit

        End If

    End Do

return

/*/{Protheus.doc} GetItens
Busca no SIENGE o CNPJ do fornecedor do Pedido de Compra
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 14/09/2020
@param oJsonCabec, object, Objeto json com o cabe�alho do pedido de compras que ser� populado o CNPJ do fornecedor.
/*/
static function GetFornec( oJsonCabec )

    Local cRet    := ""
    Local lOk     := .F.
    Local oFwRest := nil
    Local oJson   := nil
    Local cCnpj   := ''

    oFwRest := FWRest():New( cSIEURL )

    oFwRest:SetPath( '/creditors/' + cValtoChar( oJsonCabec['supplierId'] ) )

    lOk := oFwRest:Get( aHeader )

    oJson := JsonObject():New()

    cRet := oJson:FromJSON( oFwRest:GetResult() )

    cCnpj := oJson['cnpj']
    cCnpj := StrTran( cCnpj , '.', '' )
    cCnpj := StrTran( cCnpj , '/', '' )
    cCnpj := StrTran( cCnpj , '-', '' )

    oJsonCabec['A2_CGC'] := cCnpj

return


static function VldPedCmp( oJsonCabec )

    oJsonCabec['situacao'] := 'apto'
    oJsonCabec['criticas'] := aClone( {} )

    // Se o ID do Pedido de Compras j� existe na base do Protheus
    JaImportado( oJsonCabec )

    // Se o ID ou o CNPJ do Fornecedor j� existe na base do Protheus e n�o se encontra bloqueado
    FornecOk( oJsonCabec )

    // Se o ID do Produto j� existe na base do Protheus e n�o se encontra Bloqueado
    // Se h� uma conta cont�bil vinculada ao Produto, se a mesma � v�lida e n�o est� bloqueada
    ItensOk( oJsonCabec )

return


static function JaImportado( oJsonCabec )

    Local aArea    := GetArea()
    Local aAreaSC7 := SC7->( GetArea() )

    SC7->( DBOrderNickname( 'SC7SIENGE' ) )
    If SC7->( DBSeek( cValTochar( oJsonCabec['id'] ) ) )

        oJsonCabec['situacao'] := 'importado'

    end if

    RestArea( aAreaSC7 )
    RestArea( aArea )

return


static function FornecOk( oJsonCabec )

    Local aArea    := GetArea()
    Local aAreaSA2 := SA2->( GetArea() )

    SA2->( DBOrderNickname( 'SA2SIENGE' ) )
    If SA2->( DBSeek( cValTochar( oJsonCabec['supplierId'] ) ) )

        oJsonCabec['A2_COD']  := SA2->A2_COD
        oJsonCabec['A2_LOJA'] := SA2->A2_LOJA

        if SA2->A2_MSBLQL == '1'

            oJsonCabec['situacao'] := 'inapto'

            aAdd( oJsonCabec['criticas'], 'Fornecedor Bloqueado.' )

        end if

    else

        SA2->( DBSetOrder( 3 ) )
        If SA2->( DBSeek( oJsonCabec['A2_CGC'] ) )

            oJsonCabec['A2_COD']  := SA2->A2_COD
            oJsonCabec['A2_LOJA'] := SA2->A2_LOJA

            if SA2->A2_MSBLQL == '1'

                oJsonCabec['situacao'] := 'inapto'

                aAdd( oJsonCabec['criticas'], 'Fornecedor Bloqueado.' )

            end if

        else

            oJsonCabec['situacao'] := 'inapto'
            oJsonCabec['A2_COD']   := ''
            oJsonCabec['A2_LOJA']  := ''
            aAdd( oJsonCabec['criticas'], 'Fornecedor n�o localizado na base.' )

        end if

    end if

    RestArea( aAreaSA2 )
    RestArea( aArea )

return

static function ItensOk( oJsonCabec )

    Local nX       := 0
    Local aArea    := GetArea()
    Local aAreaSB1 := SB1->( GetArea() )

    DbSelectArea( 'SB1' )
    SB1->( DBOrderNickname( 'SB1SIENGE' ) )

    for nX := 1 to len( oJsonCabec['itens'] )

        if SB1->( DbSeek( cValToChar( oJsonCabec['itens'][nX]['resourceId'] ) ) )

            oJsonCabec['itens'][nX]['B1_COD']   := SB1->B1_COD
            //TODO Conta Cont�bil Produto.

            if SB1->B1_MSBLQL == '1'

                oJsonCabec['itens'][nX]['situacao'] := 'Produto bloqueado.'

            else

                oJsonCabec['itens'][nX]['situacao'] := 'OK'

            end if

        else

            oJsonCabec['situacao'] := 'inapto'
            oJsonCabec['itens'][nX]['B1_COD']   := ''
            oJsonCabec['itens'][nX]['situacao'] := 'N�o Localizado no Cadastro'

        end if

    next nX

    RestArea( aAreaSB1 )
    RestArea( aArea )

return

/*/{Protheus.doc} DateFormat
Formata uma data para uma string no formato yyyy-MM-dd aceito pelo SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 10/09/2020
@param dDate, date, Data a ser convertida
@return caractere, Data convertida no formato yyyy-MM-dd de string para integra��o com o SIENGE
/*/
static function DateFormat( dDate )

    Local cYear  := cValToChar( Year( dDate )  )
    Local cMonth := StrZero( Month( dDate ), 2 )
    Local cDay   := StrZero( Day( dDate ), 2 )
    Local cRet   := cYear + '-' + cMonth + '-' +cDay

return cRet
