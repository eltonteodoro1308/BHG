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

    Private cSIECONDPG := AllTrim( GetMv( 'SIE_CONDPG' ) )
    Private cSIEURL    := AllTrim( GetMv( 'SIE_URL'    ) )
    Private cSIEUSER   := AllTrim( GetMv( 'SIE_USER'   ) )
    Private cSIEPASWOR := AllTrim( GetMv( 'SIE_PASWOR' ) )
    Private aHeader    :=  { 'Authorization: Basic ' + Encode64( cSIEUSER + ':' + cSIEPASWOR ) }
    Private cSIEEMPRES := AllTrim( GetMv( 'SIE_EMPRES' ) )
    Private cSIEEMPNOM := GetEmpNome( cSIEEMPRES )
    Private cSIEATVPRJ := AllTrim( GetMv( 'SIE_ATVPRJ' ) )
    Private cSIECCUSTO := AllTrim( GetMv( 'SIE_CCUSTO' ) )
    Private cCodNomFil := SM0->( AllTrim( M0_CODFIL ) + ' - ' + AllTrim( M0_FILIAL ) )

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

    DbSelectArea( 'CTT' )
    DbSetOrder( 1 )
    if DbSeek( xFilial('CTT') + cSIECCUSTO )

        if CTT->CTT_MSBLQL == '1'

            ApMsgAlert( 'O Centro de Custos "' + cSIECCUSTO + '" definido no par�metro SIE_CCUSTO est� bloqueado.', 'SIENGE' )

            return

        end if

    else

        ApMsgAlert( 'O Centro de Custos "' + cSIECCUSTO + '" definido no par�metro SIE_CCUSTO n�o existe.', 'SIENGE' )

        return

    end if

    DbSelectArea( 'CTD' )
    DbSetOrder( 1 )
    if DbSeek( xFilial('CTD') + cSIEATVPRJ )

        if CTD->CTD_MSBLQL == '1'

            ApMsgAlert( 'O Item Cont�bil "' + cSIEATVPRJ + '" definido no par�metro SIE_ATVPRJ est� bloqueado.', 'SIENGE' )

            return

        end if

    else

        ApMsgAlert( 'O Item Cont�bil "' + cSIEATVPRJ + '" definido no par�metro SIE_ATVPRJ n�o existe.', 'SIENGE' )

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

/*/{Protheus.doc} GetEmpNome
Busca no SIENGE o nome de um Empreeendimento mediante o id
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param cId, character, id do Empreendimento
@return character, Nome da Empresa
/*/
static Function GetEmpNome( cId )

    Local cRet    := ""
    Local lOk     := .F.
    Local oFwRest := nil
    Local oJson   := nil

    oFwRest := FWRest():New( cSIEURL )

    oFwRest:SetPath( '/enterprises/' + cId )

    lOk := oFwRest:Get( aHeader )

    oJson := JsonObject():New()

    cRet := oJson:FromJSON( oFwRest:GetResult() )

    cRet := oJson['name']

return cRet

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

    elseif Empty( dDe ) .Or. Empty( dAte )

        ApMsgAlert( 'Informe as Datas De/At� para a requisi��o.', 'SIENGE' )

    else

        MsgRun ( 'Buscando Pedidos no Web Service do SIENGE...', 'Aguarde alguns instantes...', {|| aCabPedCmp := RunData( dDe, dAte ) } )

    end if

    if Empty( aCabPedCmp )

        ApMsgAlert( 'N�o houve retorno de pedidos na busca solicitada.', 'SIENGE' )

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
        //cPath += '&status=PENDING'
        cPath += '&authorized=true'

        oFwRest := FWRest():New( cSIEURL )

        oFwRest:SetPath( cPath )

        if oFwRest:Get( aHeader )

            oJson := JsonObject():New()

            cRet := oJson:FromJSON( oFwRest:GetResult() )

            if Empty( cRet )

                nCount := oJson["resultSetMetadata"]["count"]

                for nX := 1 to len( oJson['results'] )

                    if oJson['results'][nX]['status'] != 'CANCELED'

                        aAdd( aRet, oJson['results'][nX] )

                    end if

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

        if nCount < ( nLimit * nOffSet ) + 1

            Exit

        End If

    End Do

     aSort( aRet,,, { | X, Y | X['id'] < Y['id'] } )

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

        if oJson['status'] == 'CANCELED'

            ApMsgAlert(  'Pedido de Compras "' + AllTrim( cID ) + '" est� com a situa��o "CANCELADO"', 'SIENGE' )

        elseif cValtoChar( oJson["buildingId"] ) != cSIEEMPRES

            ApMsgAlert(  'Pedido de Compras "' + AllTrim( cID ) + '" n�o pertence a esta Empresa/Filial', 'SIENGE' )

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
e exibe a tela com a lista dos pedidos retornados
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/09/2020
@param aCabPedCmp, array, array com a lista de cabe�alhos de pedidos de compras
/*/
static function ProcPedCmp( aCabPedCmp )

    MsAguarde(  { || RunPedCmp( aCabPedCmp ) }, 'Aguarde alguns instantes...', '', .F. )

    ShowPedCmp( aCabPedCmp )

return

/*/{Protheus.doc} RunPedCmp
Processa a lista de pedidos de compras recebida buscando seus itens correspondentes e fazendo as valida��es do Pedido de Compras
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 09/09/2020
@param aCabPedCmp, array, array com a lista de cabe�alhos de pedidos de compras
/*/
static function RunPedCmp( aCabPedCmp )

    Local nX       := 0
    Local cId      := ''
    Local cTotPed  := cValToChar( Len( aCabPedCmp ) )

    for nX := 1 to Len( aCabPedCmp )

        cId := cValToChar( aCabPedCmp[ nX ]['id'] )

        MsProcTxt(  'Processando Pedidos retornados ' + cValToChar( nX ) + ' de ' + cTotPed )
        ProcessMessage()

        GetItens( aCabPedCmp[ nX ] )
        GetFornec( aCabPedCmp[ nX ] )
        VldPedCmp( aCabPedCmp[ nX ] )

    next nX

return

/*/{Protheus.doc} GetItens
Busca no SIENGE os itens dos Pedido de Compra
@type static function
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

/*/{Protheus.doc} GetFornec
Busca no SIENGE o CNPJ do fornecedor do Pedido de Compra
@type static function
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

    oFwRest := FWRest():New( cSIEURL )

    oFwRest:SetPath( '/creditors/' + cValtoChar( oJsonCabec['supplierId'] ) )

    lOk := oFwRest:Get( aHeader )

    oJson := JsonObject():New()

    cRet := oJson:FromJSON( oFwRest:GetResult() )

    oJsonCabec['A2_CGC']    := oJson['cnpj']
    oJsonCabec['A2_NOME']   := oJson['name']

return

/*/{Protheus.doc} VldPedCmp
Efetua as seguintes valida��es:
Se o ID do Pedido de Compras j� existe na base do Protheus
Se o ID ou o CNPJ do Fornecedor j� existe na base do Protheus e n�o se encontra bloqueado
Se o ID do Produto j� existe na base do Protheus e n�o se encontra Bloqueado
Se h� uma conta cont�bil vinculada ao Produto, se a mesma � v�lida e n�o est� bloqueada
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oJsonCabec, object, Objeto json com os dados do pedido de compras.
/*/
static function VldPedCmp( oJsonCabec )

    oJsonCabec['criticas']  := aClone( {} )
    oJsonCabec['C7_NUM']    := ''

    JaImportado( oJsonCabec )

    FornecOk( oJsonCabec )

    ItensOk( oJsonCabec )

return

/*/{Protheus.doc} JaImportado
Se o ID do Pedido de Compras j� existe na base do Protheus
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oJsonCabec, object, Objeto json com os dados do pedido de compras.
/*/
static function JaImportado( oJsonCabec )

    Local aArea    := GetArea()
    Local aAreaSC7 := SC7->( GetArea() )

    SC7->( DBOrderNickname( 'SC7SIENGE' ) )
    If SC7->( DBSeek( cValTochar( oJsonCabec['id'] ) ) )

        oJsonCabec['C7_NUM'] := SC7->C7_NUM

    end if

    RestArea( aAreaSC7 )
    RestArea( aArea )

return

/*/{Protheus.doc} FornecOk
Se o ID ou o CNPJ do Fornecedor j� existe na base do Protheus e n�o se encontra bloqueado
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oJsonCabec, object, Objeto json com os dados do pedido de compras.
/*/
static function FornecOk( oJsonCabec )

    Local aArea    := GetArea()
    Local aAreaSA2 := SA2->( GetArea() )
    Local cCnpj    := ''

    cCnpj := oJsonCabec['A2_CGC']
    cCnpj := StrTran( cCnpj , '.', '' )
    cCnpj := StrTran( cCnpj , '/', '' )
    cCnpj := StrTran( cCnpj , '-', '' )

    SA2->( DBOrderNickname( 'SA2SIENGE' ) )
    If SA2->( DBSeek( cValTochar( oJsonCabec['supplierId'] ) ) )

        oJsonCabec['A2_COD']  := SA2->A2_COD
        oJsonCabec['A2_LOJA'] := SA2->A2_LOJA

        if SA2->A2_MSBLQL == '1'

            aAdd( oJsonCabec['criticas'], 'Fornecedor Bloqueado.' )

        end if

    else

        SA2->( DBSetOrder( 3 ) )
        If SA2->( DBSeek( xFilial('SA2') + cCnpj ) )

            oJsonCabec['A2_COD']  := SA2->A2_COD
            oJsonCabec['A2_LOJA'] := SA2->A2_LOJA

            if SA2->A2_MSBLQL == '1'

                aAdd( oJsonCabec['criticas'], 'Fornecedor Bloqueado.' )

            end if

        else

            oJsonCabec['A2_COD']   := ''
            oJsonCabec['A2_LOJA']  := ''
            aAdd( oJsonCabec['criticas'], 'Fornecedor n�o localizado na base.' )

        end if

    end if

    RestArea( aAreaSA2 )
    RestArea( aArea )

return

/*/{Protheus.doc} ItensOk
Se o ID do Produto j� existe na base do Protheus e n�o se encontra Bloqueado
Se h� uma conta cont�bil vinculada ao Produto, se a mesma � v�lida e n�o est� bloqueada
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oJsonCabec, object, Objeto json com os dados do pedido de compras.
/*/
static function ItensOk( oJsonCabec )

    Local nX       := 0
    Local aArea    := GetArea()
    Local aAreaSB1 := SB1->( GetArea() )
    Local aAreaCT1 := CT1->( GetArea() )

    DbSelectArea( 'SB1' )
    SB1->( DBOrderNickname( 'SB1SIENGE' ) )

    for nX := 1 to len( oJsonCabec['itens'] )

        if SB1->( DbSeek( cValToChar( oJsonCabec['itens'][nX]['resourceId'] ) ) )

            oJsonCabec['itens'][nX]['B1_COD']   := SB1->B1_COD

            if SB1->B1_MSBLQL == '1'

                oJsonCabec['itens'][nX]['situacao'] := 'Produto bloqueado.'

            else

                if Empty( SB1->B1_CONTA )

                    oJsonCabec['itens'][nX]['situacao'] := 'Produto sem Conta Cont�bil'

                else

                    DbSelectArea( 'CT1' )
                    CT1->( DbSetOrder( 1 ) )

                    if CT1->( DbSeek( SB1->( xFilial('CT1') + B1_CONTA ) ) )

                        oJsonCabec['itens'][nX]['B1_CONTA']   := SB1->B1_CONTA

                        if CT1->CT1_MSBLQL == '1'

                            oJsonCabec['itens'][nX]['situacao'] := 'Conta Cont�bil Bloqueada.'

                        else

                            oJsonCabec['itens'][nX]['situacao'] := 'OK'

                        end if

                    else

                        oJsonCabec['itens'][nX]['B1_CONTA'] := ''

                        oJsonCabec['itens'][nX]['situacao'] := 'Conta Cont�bil n�o Localizada.'

                    end if

                end if

            end if

        else

            oJsonCabec['itens'][nX]['B1_COD']   := ''
            oJsonCabec['itens'][nX]['situacao'] := 'N�o Localizado no Cadastro'

        end if

    next nX

    RestArea( aAreaSB1 )
    RestArea( aAreaCT1 )
    RestArea( aArea )

return

/*/{Protheus.doc} ShowPedCmp
Exibe a tela com a lista de pedidos de compras retornados na requisi��o.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param aCabPedCmp, array, Array com a lista de Pedidos de Compras 
/*/
static Function ShowPedCmp( aCabPedCmp )

    Local oBtnCanc    := nil
    Local oBtnProc    := nil
    Local oButton2    := nil
    Local oChkMrkAll  := nil
    Local lChkMrkAll  := .F.
    Local oGetCndPag  := nil
    Local cGetCndPag  := cSIECONDPG
    Local oGetDscCdPg := nil
    Local cGetDscCdPg := Posicione( 'SE4', 1, xFilial('SE4') + cSIECONDPG, 'E4_DESCRI' )
    Local oGetEmp     := nil
    Local cGetEmp     := DecodeUTF8( cSIEEMPRES + ' - ' + cSIEEMPNOM )
    Local oSayCndPag  := nil
    Local oSayEmp     := nil
    Local oBrwLstPed  := nil
    Local aBrwLstPed  := {}
    Local oDlg        := nil
    Local aLegenda    := {}
    Local oVERDE      := LoadBitmap( GetResources(), 'BR_VERDE'    )
    Local oVERMELHO   := LoadBitmap( GetResources(), 'BR_VERMELHO' )
    Local oAMARELO    := LoadBitmap( GetResources(), 'BR_AMARELO'  )
    Local oOK         := LoadBitmap( GetResources(), 'LBOK'        )
    Local oNO         := LoadBitmap( GetResources(), 'LBNO'        )
    Local oLegenda    := nil
    Local nX          := 0

    aAdd( aLegenda, {'BR_VERDE'   ,'Apto para Importa��o'} )
    aAdd( aLegenda, {'BR_VERMELHO','Inapto para Importa��o'} )
    aAdd( aLegenda, {'BR_AMARELO' ,'Pedido Importado'} )

    for nX := 1 to Len( aCabPedCmp )

        if ! Empty( aCabPedCmp[nX]['C7_NUM'] )

            oLegenda := oAMARELO

        else

            if Len( aCabPedCmp[nX]['criticas'] ) # 0 .Or.;
                    aScan( aCabPedCmp[nX]['itens'], { |item|  item['situacao'] # 'OK' } ) # 0

                oLegenda := oVERMELHO

            else

                oLegenda := oVERDE

            end if

        end if

        Aadd(aBrwLstPed,{ .F., oLegenda, cValToChar( aCabPedCmp[nX]['id'] ),;
            aCabPedCmp[nX]['C7_NUM'], SubStr( DecodeUTF8( aCabPedCmp[nX]['A2_NOME'] ), 1, 45 ), aCabPedCmp[nX]['buyerId'] } )

    next nX

    DEFINE MSDIALOG oDlg TITLE "Pedidos de Compras - SIENGE" FROM 000, 000  TO 500, 750 COLORS 0, 16777215 PIXEL

    @ 002, 002 BUTTON oBtnProc PROMPT "Processar" SIZE 037, 012 OF oDlg ACTION Eval( { || cSIECONDPG := cGetCndPag, iif( PrcPedCmp( oBrwLstPed, aCabPedCmp ), oDlg:End(), nil ) } ) PIXEL
    @ 002, 042 BUTTON oButton2 PROMPT "Detalhar" SIZE 037, 012 OF oDlg ACTION DetPedCmp( aCabPedCmp[oBrwLstPed:nAt] ) PIXEL
    @ 002, 082 BUTTON oBtnLegenda PROMPT "Legenda" SIZE 037, 012 OF oDlg ACTION BrwLegenda( 'Situa��o dos Pedidos de Compras', '', aLegenda) PIXEL
    @ 002, 122 BUTTON oBtnCanc PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
    @ 022, 005 CHECKBOX oChkMrkAll VAR lChkMrkAll PROMPT "Marca todos os Aptos" SIZE 063, 008 OF oDlg COLORS 0, 16777215 ON CHANGE MarcaTodos( oBrwLstPed, lChkMrkAll ) PIXEL
    @ 022, 075 SAY oSayCndPag PROMPT "Cond. de Pagamento:" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 133 MSGET oGetCndPag VAR cGetCndPag SIZE 030, 010 OF oDlg COLORS 0, 16777215 ON CHANGE VldCndPgt( oGetCndPag, oGetDscCdPg ) F3 "SE4" HASBUTTON PIXEL
    @ 021, 172 MSGET oGetDscCdPg VAR cGetDscCdPg SIZE 195, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 037, 005 SAY oSayEmp PROMPT "Empresa:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 031 MSGET oGetEmp VAR cGetEmp SIZE 337, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 055, 005 LISTBOX oBrwLstPed Fields HEADER "","","ID","Num. Pedido","Fornecedor","Comprador" SIZE 363, 190 OF oDlg PIXEL ColSizes 50,50
    oBrwLstPed:SetArray(aBrwLstPed)
    oBrwLstPed:bLine := {|| {;
        iif(aBrwLstPed[oBrwLstPed:nAt,01],oOK,oNO),;
        aBrwLstPed[oBrwLstPed:nAt,2],;
        aBrwLstPed[oBrwLstPed:nAt,3],;
        aBrwLstPed[oBrwLstPed:nAt,4],;
        aBrwLstPed[oBrwLstPed:nAt,5],;
        aBrwLstPed[oBrwLstPed:nAt,6];
        }}

    oBrwLstPed:bLDblClick := {||;
        iif( oBrwLstPed:aArray[oBrwLstPed:nAt][2]:cName == 'BR_VERDE', aBrwLstPed[oBrwLstPed:nAt][1] := ! aBrwLstPed[oBrwLstPed:nAt][1], nil ),;
        oBrwLstPed:Refresh()}

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} VldCndPgt
Faz a valida��o da condi��o de pagamento informada/selecionada, verifica se existe no cadastro e se n�o est� bloqueada.
Tamb�m atualiza o conte�do do campo de descri��o da Condi��o de Pagamento.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oGetCndPag, object, Objeto Tget com o c�digo da condi��o de pagamento a ser valida
@param oGetDscCdPg, object, Obejto Tget com a Descri��o da Condi��o de pagamento
/*/
static function VldCndPgt( oGetCndPag, oGetDscCdPg )

    Local aArea    := GetArea()
    Local aAreaSE4 := SE4->( GetArea() )

    DbSelectArea( 'SE4' )
    SE4->( DBSetOrder( 1 ) )

    if SE4->( DbSeek( xFilial( 'SE4' ) + oGetCndPag:cText ) )

        if SE4->E4_MSBLQL == '1'

            ApMsgAlert( 'Condi��o de Pagamento Bloqueada.', 'SIENGE' )

            oGetCndPag:cText  := Space( TAMSX3('E4_CODIGO')[1] )
            oGetDscCdPg:cText := ''
            oGetCndPag:CtrlRefresh()
            oGetDscCdPg:CtrlRefresh()


        else

            oGetDscCdPg:cText := SE4->E4_DESCRI
            oGetDscCdPg:CtrlRefresh()

        end if

    else

        ApMsgAlert( 'Informe uma Condi��o de Pagamento V�lida.', 'SIENGE' )

        oGetCndPag:cText  := Space( TAMSX3('E4_CODIGO')[1] )
        oGetDscCdPg:cText := ''
        oGetCndPag:CtrlRefresh()
        oGetDscCdPg:CtrlRefresh()

    end if

    RestArea( aAreaSE4 )
    RestArea( aArea    )

return

/*/{Protheus.doc} MarcaTodos
Faz a marca��o de todos os pedidos Aptos para importa��o na tela de exibi��o dos pedidos retornados na rrequisi��o
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 16/09/2020
@param oBrwLstPed, object, Objeto com a lista dos pedidos de compras para marcar/desmarcar conforme sinaliza a CheckBox  
@param lChkMrkAll, logical, Indica se o ckeckbox de marcar todos est� marcado ou n�o 
/*/

static function MarcaTodos( oBrwLstPed, lChkMrkAll )

    Local nX := 0

    for nX := 1 to Len( oBrwLstPed:aArray )

        if oBrwLstPed:aArray[nX][2]:cName == 'BR_VERDE'

            oBrwLstPed:aArray[nX][1] := lChkMrkAll

        end if

    next nX

    oBrwLstPed:Refresh()

return

/*/{Protheus.doc} PrcPedCmp
Processa os pedidos marcados, montando e enviando para grava��o na base
@type static function
@version 12.1.27
@author elton.alves@gmail.com   
@since 17/09/2020
@param oBrwLstPed, object, Objeto que representa o Browse com a lista de pedido marcados para importa��o.
@param aCabPedCmp, array, Array com a lista de Pedidos de compras a serem importados.
@obs O posi��o do pedido no browse corresponde a posi��o do mesmo no array,
assim � considerado para importa��o quem estiver marcado para importar.
O que tiverem legenda diferente de BR_VERDE n�o podem ser marcados e assim n�o ser�o importados.
@return logical, Retorna .T caso tenha executado a inclus�o de pedidos e .F. caso apenas tenha exibido alguma mensagem ao usu�rio,
tem a finalidade de sinalizar para a tela com a lista de pedido se a mesma deve ou n�o ser fechada..
/*/
static function PrcPedCmp( oBrwLstPed, aCabPedCmp )

    Local aCabec    := {}
    Local aItens    := {}
    Local aLinha    := {}
    Local nX        := 0
    Local nY        := 0
    Local nQuantid  := 0
    Local nPrecUnit := 0
    Local aResProc  := {}

    if Empty( cSIECONDPG )

        ApMsgAlert( 'Informe uma Condi��o de Pagamento V�lida', 'SIENGE' )

        return .F.

    elseif aScan( oBrwLstPed:aArray, { |item| item[1] } ) == 0

        ApMsgAlert( 'Nenhum Pedido foi selecionado para ser importado', 'SIENGE' )

        return .F.

    end if

    for nX := 1 to Len( oBrwLstPed:aArray )

        if oBrwLstPed:aArray[nX][1]

            aadd( aCabec, { "C7_NUM"     , ''                                                  } )
            aadd( aCabec, { "C7_EMISSAO" , StoD( StrTran( aCabPedCmp[nX]['date'], '-', '' ) )  } )
            aAdd( aCabec, { "C7_FORNECE" , aCabPedCmp[nX]['A2_COD']                            } )
            aAdd( aCabec, { "C7_LOJA"    , aCabPedCmp[nX]['A2_LOJA']                           } )
            aAdd( aCabec, { "C7_COND"    , cSIECONDPG                                          } )
            aAdd( aCabec, { "C7_CONAPRO" , 'L'                                                 } )
            aAdd( aCabec, { "C7_XSIENGE" , cValTochar( aCabPedCmp[nX]['id'] )                  } )
            aAdd( aCabec, { "C7_OBS"     , cValTochar( aCabPedCmp[nX]['id'] )  +;
                '/' + aCabPedCmp[nX]['buyerId'] } )

            for nY := 1 to Len( aCabPedCmp[nX]['itens'] )

                nQuantid  := aCabPedCmp[nX]['itens'][nY]['quantity']
                nPrecUnit := aCabPedCmp[nX]['itens'][nY]['unitPrice']

                aAdd( aLinha, { "C7_ITEM"     , StrZero( nY, 4 )                                                 , NIL } )
                aAdd( aLinha, { "C7_PRODUTO"  , aCabPedCmp[nX]['itens'][nY]['B1_COD']                            , nil } )
                aAdd( aLinha, { "C7_DESCRI"   , DecodeUtf8( aCabPedCmp[nX]['itens'][nY]['resourceDescription'] ) , nil } )
                aAdd( aLinha, { "C7_QUANT"    , aCabPedCmp[nX]['itens'][nY]['quantity']                          , nil } )
                aAdd( aLinha, { "C7_PRECO"    , aCabPedCmp[nX]['itens'][nY]['unitPrice']                         , nil } )
                aAdd( aLinha, { "C7_TOTAL"    , nQuantid * nPrecUnit                                             , nil } )
                aAdd( aLinha, { "C7_OBSM"     , DecodeUtf8( aCabPedCmp[nX]['itens'][nY]['notes'] )               , nil } )
                aAdd( aLinha, { "C7_LOCAL"    , '01'                                                             , nil } )
                aAdd( aLinha, { "C7_CC"       , cSIECCUSTO                                                       , nil } )
                aAdd( aLinha, { "C7_ITEMCTA"  , cSIEATVPRJ                                                       , nil } )
                aAdd( aLinha, { "C7_CONTA"    , aCabPedCmp[nX]['itens'][nY]['B1_CONTA']                          , nil } )

                aAdd( aItens, aClone( aLinha ) )

                aSize( aLinha, 0 )

            next nY

            MsgRun( 'Importando o Pedido ' + cValTochar( aCabPedCmp[nX]['id'] ), 'Aguarde alguns instantes...',;
                { || aAdd( aResProc, ExAutMT120( aCabec, aItens ) ) } )

                aSize( aCabec, 0 )
                aSize( aItens, 0 )

        end if

    next nX

    PutMv( 'SIE_CONDPG', cSIECONDPG )

    ShowResProc( aResProc )

return .T.

/*/{Protheus.doc} ExAutMT120
Processa o execauto MATA120 com a inclus�o do pedido de compras.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/09/2020
@param aCabec, array, Array com a lista de campos e valores do cabe�alho do pedido de compras
@param aItens, array, Array com a lista de campos e valores dos itens do pedido de compras
@return array, Array com a descri��o dos erros, caso n�o tenha ocorrido erros retorna um array vazio
/*/
static function ExAutMT120( aCabec, aItens )

    Local aErro    := {}
    Local cErro    := ''
    Local nX       := 0
    Local aRet     := {}
    Local cId      := aCabec[aScan( aCabec, { | X | X[1] == 'C7_XSIENGE' } )][2]
    Local cObs     := aCabec[aScan( aCabec, { | X | X[1] == 'C7_OBS'     } )][2]
    Local cNum     := ''
    Local aAreaSC7 := SC7->( GetArea() )

    Private lMsErroAuto    := .F.
    Private lMsHelpAuto    := .T.
    Private lAutoErrNoFile := .T.

    Begin Transaction

        cNum := GetNumSC7()

        aCabec[ aScan( aCabec, { | X | X[1] == 'C7_NUM' } )][2] := cNum

        MsExecAuto( { |a,b,c,d| MATA120(a,b,c,d) }, 1, aCabec, aItens, 3 )

        If lMsErroAuto

            lMsErroAuto := .F.

            aErro := aClone( GetAutoGRLog() )

            for nX := 1 to Len( aErro )

                cErro += aErro[ nX ] + CRLF

            next nX

            DisarmTransaction()

            aRet := { cId, '', 'Problemas na Gera��o do Pedido', cErro }

        else

            if SC7->( DbSeek( xFilial('SC7') + cNum ) )

                Do While SC7->( ! Eof() .And. C7_FILIAL + C7_NUM == xFilial() + cNum )

                    RecLock( 'SC7', .F. )

                    SC7->C7_XSIENGE := cId
                    SC7->C7_CONAPRO := 'L'
                    SC7->C7_OBS     := cObs

                    SC7->( MsUnlock() )

                    SC7->( DbSkip() )

                End Do

            end if

            SC7->( RestArea( aAreaSC7 ) )

            aRet := { cId, cNum, 'Pedido Gerado', 'Pedido Gerado' }

        end if

    End Transaction

return aRet

/*/{Protheus.doc} ShowResProc
Exibe o resultado do processamento e nos detalhes o erro que possa ter ocorrido
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/09/2020
@param aResProc, array, Array com a lista de erros para cada pedido importado
/*/
static function  ShowResProc( aResProc )

    Local oBtnDet    := nil
    Local oBtnFechar := nil
    Local oDlg       := nil
    Local oResProc   := nil

    DEFINE MSDIALOG oDlg TITLE "Pedidos de Compras - SIENGE" FROM 000, 000  TO 500, 750 COLORS 0, 16777215 PIXEL

    @ 002, 002 BUTTON oBtnDet PROMPT "Detalhar" SIZE 037, 012 OF oDlg ACTION Eval( { || AutoGrLog( aResProc[oResProc:nAt, 4 ] ), MostraErro() } ) PIXEL
    @ 002, 045 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
    @ 020, 004 LISTBOX oResProc Fields HEADER "ID","N�mero","Situa��o" SIZE 364, 224 OF oDlg PIXEL ColSizes 50,50
    oResProc:SetArray(aResProc)
    oResProc:bLine := {|| {;
        aResProc[oResProc:nAt,1],;
        aResProc[oResProc:nAt,2],;
        aResProc[oResProc:nAt,3];
        }}

    ACTIVATE MSDIALOG oDlg CENTERED

return

/*/{Protheus.doc} DetPedCmp
Exibe detalhes do pedido de compras posicinado na lista exibida.
� exibido dados dos itens e tamb�m cr�ticas que impedem o pedido de ser importado.
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 17/09/2020
@param oJsonCabec, object, Objeto json com os dados do pedido de compras
/*/
Static Function DetPedCmp( oJsonCabec )

    Local oBtnEnd     := nil
    Local oGetCNPJ    := nil
    Local cGetCNPJ    := oJsonCabec['A2_CGC']
    Local oGetCodLoja := nil
    Local cGetCodLoja := AllTrim( oJsonCabec['A2_COD'] ) + '/' + AllTrim( oJsonCabec['A2_LOJA'] )
    Local oGetID      := nil
    Local cGetID      := cValToChar( oJsonCabec['supplierId'] )
    Local oGetNome    := nil
    Local cGetNome    := DecodeUTF8( oJsonCabec['A2_NOME'] )
    Local oGrpCritic  := nil
    Local oGrpFornec  := nil
    Local oGrpItPed   := nil
    Local oMltGetCrt  := nil
    Local cMltGetCrt  := ''
    Local oSayCNPJ    := nil
    Local oSayCodLoja := nil
    Local oSayID      := nil
    Local oSayNome    := nil
    Local oDlg        := nil
    Local oBrwItPed   := nil
    Local aBrwItPed   := {}
    Local nX          := 0
    Local cCriticas   := ''

    for nX := 1 to Len( oJsonCabec['itens'] )

        Aadd( aBrwItPed, {;
            cValToChar( oJsonCabec['itens'][nX]['resourceId'] ),;
            oJsonCabec['itens'][nX]['B1_COD'],;
            DecodeUtf8( oJsonCabec['itens'][nX]['resourceDescription'] ),;
            iif( Empty( oJsonCabec['C7_NUM'] ), oJsonCabec['itens'][nX]['situacao'], '' ) } )

    next nX

    if Empty( oJsonCabec['C7_NUM'] )

        for nX := 1 to Len( oJsonCabec['criticas'] )

            cCriticas += oJsonCabec['criticas'][nX] + CRLF

        next nX

        if aScan( oJsonCabec['itens'], { |item|  item['situacao'] # 'OK' } ) # 0

            cCriticas += 'H� itens com cr�ticas'

        end if

    end if

    DEFINE MSDIALOG oDlg TITLE "Pedidos de Compras - SIENGE - ID: " + cValToChar( oJsonCabec['id'] ) FROM 000, 000  TO 500, 750 COLORS 0, 16777215 PIXEL

    @ 002, 002 BUTTON oBtnEnd PROMPT "Fechar" SIZE 037, 012 OF oDlg ACTION oDlg:End() PIXEL
    @ 020, 002 GROUP oGrpFornec TO 058, 370 PROMPT "Fornecedor" OF oDlg COLOR 0, 16777215 PIXEL
    @ 030, 007 SAY oSayID PROMPT "ID" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 053 SAY oSayCodLoja PROMPT "C�digo/Loja" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 109 SAY oSayCNPJ PROMPT "CNPJ" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 030, 189 SAY oSayNome PROMPT "Nome" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 007 MSGET oGetID VAR cGetID SIZE 040, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 040, 053 MSGET oGetCodLoja VAR cGetCodLoja SIZE 051, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 040, 110 MSGET oGetCNPJ VAR cGetCNPJ SIZE 074, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 040, 188 MSGET oGetNome VAR cGetNome SIZE 177, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 063, 002 GROUP oGrpItPed TO 172, 370 PROMPT "Itens do Pedido" OF oDlg COLOR 0, 16777215 PIXEL
    @ 074, 008 LISTBOX oBrwItPed Fields HEADER "ID","CODIGO","DESCRI��O","SITUA��O" SIZE 355, 091 OF oDlg PIXEL ColSizes 50,50
    oBrwItPed:SetArray(aBrwItPed)
    oBrwItPed:bLine := {|| {;
        aBrwItPed[oBrwItPed:nAt,1],;
        aBrwItPed[oBrwItPed:nAt,2],;
        aBrwItPed[oBrwItPed:nAt,3],;
        aBrwItPed[oBrwItPed:nAt,4];
        }}
    @ 176, 003 GROUP oGrpCritic TO 247, 370 PROMPT "Cr�ticas" OF oDlg COLOR 0, 16777215 PIXEL
    @ 185, 005 GET oMltGetCrt VAR cMltGetCrt OF oDlg MULTILINE SIZE 360, 058 COLORS 0, 16777215 READONLY HSCROLL PIXEL

    oMltGetCrt:EnableVScroll( .T. )
    oMltGetCrt:AppendText( cCriticas )

    ACTIVATE MSDIALOG oDlg CENTERED

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
    Local cRet   := cYear + '-' + cMonth + '-' + cDay

return cRet
