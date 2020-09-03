#include 'totvs.ch'

/*/{Protheus.doc} Sienge
Rotina inclu�da no menu do programa MATA103 (Pedidos de Compras) pelo ponto de entrada MT120BRW,
que tem como objetivo buscar no Web Service do SIENGE os Pedidos de Compras nele cadastrados e
import�-los para base do Protheus
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
    @ 028, 005 SAY oSayDtAte PROMPT "Data at�:" SIZE 025, 007 OF oGrpData COLORS 0, 16777215 PIXEL
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
@param dDe, date, Data Inicial do per�odo
@param dAte, date, Data Final d Per�odo
/*/
static function ProcData( dDe, dAte )

    if dDe > dAte

        ApMsgStop( 'A data de In�cio deve ser menor ou igual do que a data Final.' )

    else
//TODO definir mensagem se n�o conseguit acesso ao end point do sienge
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

        ApMsgStop( 'Informe um Id de Pedido de Compra V�lido.' )

    else



    end if

return

/*/{Protheus.doc} siengefetch
Rotina gen�rica de requisi��es ao Web Service do SIENGE
@type static function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cPath, character, End Point a ser requisitado
@param cQuery, character, Par�metros da requisi��o a ser concatenado com a url
@param bProcess, codeblock, Bloco a ser processado e tem seu resultado retornado pela fun��o
@return undefined, retorno do processamento do bloco de c�digo recebido por par�metro
/*/
static function siengefetch( cPath, cQuery, bProcess )

    Local cUrl       := GetMv('SIE_URL') + cPath
    Local cMethod    := 'GET'
    Local cGETParms  := cQuery
    Local cPOSTParms := ''
    Local nTimeOut   := nil
    Local aHeadStr   :=  { 'Authorization: Basic ' + Encode64( AllTrim( GetMv( 'SIE_USR' ) ) + ':' + AllTrim( GetMv( 'SIE_PASWOR' ) ) ) }
//XXX continur daqui
//TODO alerta que o pedido de compras n�o est� pendente e ou autorizado

return fetch( cUrl, cMethod, cGETParms, cPOSTParms, nTimeOut, aHeadStr, bProcess )

/*/{Protheus.doc} DkFetch
Rotina gen�rica de requisi��o e processamento a um Web Service Rest
@type function
@version 12.1.27 
@author elton.alves@totvs.com.br
@since 02/09/2020
@param cUrl, character, cUrl corresponde ao endere�o HTTP, juntamente com a pasta e o documento solicitados.
@param cMethod, character, Define o HTTP Method que ser� utilizado, permitindo outros al�m de POST/GET.
@param cGETParms, character, cUrl corresponde ao endere�o HTTP, juntamente com a pasta e o documento solicitados.
@param cPOSTParms, character, cPostParms corresponde � StringList de par�metros a serem enviados ao servidor HTTP atrav�s do pacote HTTP. Caso n�o especificado, este par�metro � considerado vazio ("")
@param nTimeOut, numeric, Em nTimeOut especificamos o tempo em segundos m�ximo de inatividade permitido durante a recep��o do documento. Caso n�o especificado, o valor padr�o assumido � 120 segundos ( 2 minutos).
@param aHeadStr, array, Atrav�s deste par�metro, podemos especificar um array com strings a serem acrescentadas ao Header da requisi��o HTTP a ser realizada.
@param bProcess, codeblock, Bloco a ser processado e tem seu resultado retornado pela fun��o
@return undefined, retorno do processamento do bloco de c�digo recebido por par�metro
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
