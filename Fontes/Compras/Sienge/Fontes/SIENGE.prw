#include 'totvs.ch'

/*/{Protheus.doc} Sienge
Rotina incluída no menu do programa MATA103 (Pedidos de Compras) pelo ponto de entrada MT120BRW,
que tem como objetivo buscar no Web Service do SIENGE os Pedidos de Compras nele cadastrados e
importá-los para base do Protheus
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
/*/
User Function Sienge()

    Local oDlg       := nil
    Local oBtnCancel := nil
    Local oBtnPrcDt  := nil
    Local oBtnPrcId  := nil
    Local oGetDtAte  := nil
    Local cGetDtAte  := dDataBase
    Local oGetDtDe   := nil
    Local cGetDtDe   := dDataBase
    Local oGetId     := nil
    Local cGetIdPic  := '9999999999'
    Local cGetId     := Space(Len(cGetIdPic))
    Local oGrpData   := nil
    Local oGrpId     := nil
    Local oSayDtAte  := nil
    Local oSayDtDe   := nil
    Local oSayId     := nil

    DEFINE MSDIALOG oDlg TITLE "Sienge - Requisitar Pedidos de Compras" FROM 000, 000  TO 160, 410 COLORS 0, 16777215 PIXEL

    @ 002, 002 GROUP oGrpData TO 062, 096 PROMPT "Por Data" OF oDlg COLOR 0, 16777215 PIXEL
    @ 015, 005 SAY oSayDtDe PROMPT "Data de:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 013, 030 MSGET oGetDtDe VAR cGetDtDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 HASBUTTON PIXEL
    @ 028, 005 SAY oSayDtAte PROMPT "Data até:" SIZE 025, 007 OF oGrpData COLORS 0, 16777215 PIXEL
    @ 026, 030 MSGET oGetDtAte VAR cGetDtAte SIZE 060, 010 OF oDlg COLORS 0, 16777215 HASBUTTON PIXEL
    @ 044, 051 BUTTON oBtnPrcDt PROMPT "Processar" SIZE 037, 012 OF oDlg ACTION ProcData(cGetDtDe,cGetDtAte) PIXEL


    @ 002, 099 GROUP oGrpId TO 063, 202 PROMPT "Por ID" OF oDlg COLOR 0, 16777215 PIXEL
    @ 024, 105 SAY oSayId PROMPT "ID do Pedido:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 022, 138 MSGET oGetId VAR cGetId SIZE 060, 010 OF oDlg PICTURE cGetIdPic COLORS 0, 16777215 PIXEL
    @ 046, 161 BUTTON oBtnPrcId PROMPT "Processar" SIZE 037, 012 OF oDlg ACTION ProcId(cGetId) PIXEL

    @ 065, 164 BUTTON oBtnCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION Odlg:End() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcData
Requista pedidos de compras em uma faixa de datas
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param dDe, date, Data Inicial do período
@param dAte, date, Data Final d Período
/*/
static function ProcData( dDe, dAte )

    if dDe > dAte

        ApMsgStop( 'A data de Início deve ser menor ou igual do que a data Final.' )

    else
//TODO definir mensagem se não conseguit acesso ao end point do sienge
    end if

return

/*/{Protheus.doc} ProcId
Requisita um pedido de compras pelo ID
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cID, character, ID do Pedido de Compras requisitado
/*/
static function ProcId( cID )

    if Empty( cId )

        ApMsgStop( 'Informe um Id de Pedido de Compra Válido.' )

    else



    end if

return

/*/{Protheus.doc} siengefetch
Rotina genérica de requisições ao Web Service do SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cPath, character, End Point a ser requisitado
@param cQuery, character, Parâmetros da requisição a ser concatenado com a url
@param bProcess, codeblock, Bloco a ser processado e tem seu resultado retornado pela função
@return undefined, retorno do processamento do bloco de código recebido por parâmetro
/*/
static function siengefetch( cPath, cQuery, bProcess )

    Local cUrl       := GetMv('SIE_URL') + cPath
    Local cMethod    := 'GET'
    Local cGETParms  := cQuery
    Local cPOSTParms := ''
    Local nTimeOut   := nil
    Local aHeadStr   :=  { 'Authorization: Basic ' + Encode64( AllTrim( GetMv( 'SIE_USR' ) ) + ':' + AllTrim( GetMv( 'SIE_PASWOR' ) ) ) }
//XXX continur daqui
//TODO alerta que o pedido de compras não está pendente e ou autorizado

return fetch( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, bProcess )

/*/{Protheus.doc} DkFetch
Rotina genérica de requisição e processamento a um Web Service Rest
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cUrl, character, cUrl corresponde ao endereço HTTP, juntamente com a pasta e o documento solicitados.
@param cMethod, character, Define o HTTP Method que será utilizado, permitindo outros além de POST/GET.
@param cGETParms, character, cUrl corresponde ao endereço HTTP, juntamente com a pasta e o documento solicitados.
@param cPOSTParms, character, cPostParms corresponde à StringList de parâmetros a serem enviados ao servidor HTTP através do pacote HTTP. Caso não especificado, este parâmetro é considerado vazio ("")
@param nTimeOut, numeric, Em nTimeOut especificamos o tempo em segundos máximo de inatividade permitido durante a recepção do documento. Caso não especificado, o valor padrão assumido é 120 segundos ( 2 minutos).
@param aHeadStr, array, Através deste parâmetro, podemos especificar um array com strings a serem acrescentadas ao Header da requisição HTTP a ser realizada.
@param bProcess, codeblock, Bloco a ser processado e tem seu resultado retornado pela função
@return undefined, retorno do processamento do bloco de código recebido por parâmetro
@obs //TODO documentar o que o code block recebe
/*/
static function fetch( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, bProcess )

    Local cHeaderRet   := ''
    Local aHeaderRet   := {}
    Local cProperty    := ''
    Local cValue       := ''
    Local nPos         := 0
    Local cHttpCode    := ''
    Local cContentType := ''
    Local uResponse    := nil
    Local uJsonXml     := nil
    Local aAux         := {}
    Local nX           := 0

    uResponse  := HttpQuote ( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, @cHeaderRet )

    aAux := StrTokArr2( StrTran( cHeaderRet, Chr(13), '' ), Chr(10), .T. )

    cHttpCode := StrTokArr2( aAux[ 1 ], " ", .T. )[2]

    for nX := 2 to len( aAux )

        nPos := At( ":", aAux[ nX ] )

        cProperty := SubString( aAux[ nX ], 1, nPos - 1 )
        cValue    := SubString( aAux[ nX ], nPos + 2, Len( aAux[ nX ] )  )

        aAdd( aHeaderRet, { cProperty, cValue } )

        if cProperty == 'Content-Type'

            cContentType := cValue

        end if

    next nX

    if 'xml' $ Lower(cContentType)

        uJsonXml := TXmlManager():New()

        uJsonXml:Parse( uResponse )

    elseif 'json' $ Lower(cContentType)

        uJsonXml := JsonObject():New()

        uJsonXml:FromJson( uResponse )

    endif

return Eval( bProcess, cHeaderRet, uResponse, cHttpCode, cContentType, uJsonXml )
