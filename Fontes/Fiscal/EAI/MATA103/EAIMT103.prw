
#Include "totvs.ch"

/*/{Protheus.doc} EAIMT103
Função utilizada patra inclusão de documentos de entrada pelo execauto mata103 integrados do CMNET e por intermédio do EAI
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 19/10/2020
@param cXML, character, O conteúdo da tag Content do XML recebido pelo EAI Protheus.
@param cError, character,  Variável passada por referência, serve para alimentar a mensagem de erro, nos casos em que a transação não foi bem sucedida.
@param cWarning, character, Variável passada por referência, serve para alimentar uma mensagem de warning para o EAI. A alteração deste valor por rotinas tratadas neste tópico não causam nenhum efeito para o EAI
@param cParams, character, Parâmetros passados na mensagem do EAI.
@param oFWEAI, object, O objeto de EAI criado na camada do EAI Protheus.
@return logical, Fixo true
/*/
user function EAIMT103( cXML, cError, cWarning, cParams, oFWEAI )

	Local oXml   := XmlParser( cXML, "_", @cError, @cWarning )
	Local aCabec := {}
	Local aItens := {}

	if Empty( cError )

		MontaCabec( oXml, aCabec )
		MontaItens( oXml, aItens )
		ExAutMt103( aCabec, aItens, @cError )

	end if

return .T.

/*/{Protheus.doc} MontaCabec
Monta o lista de itens do documento de entrada a ser incluído com base nos dados do XML
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 19/10/2020
@param oXml, object, Objeto xml parsedo do xml recebido como texto.
@param aCabec, array, Array a ser populado com os dados do cabeçalho do Documento do Entrada
/*/
static function	MontaCabec( oXml, aCabec )

	aAdd( aCabec, {'F1_FORMUL'  ,       oXml:_EAIMT103:_F1_FORMUL:TEXT    , nil } )
	aAdd( aCabec, {'F1_TIPO'    ,       oXml:_EAIMT103:_F1_TIPO:TEXT      , nil } )
	aAdd( aCabec, {'F1_DOC'     ,       oXml:_EAIMT103:_F1_DOC:TEXT       , nil } )
	aAdd( aCabec, {'F1_SERIE'   ,       oXml:_EAIMT103:_F1_SERIE:TEXT     , nil } )
	aAdd( aCabec, {'F1_EMISSAO' , StoD( oXml:_EAIMT103:_F1_EMISSAO:TEXT ) , nil } )
	aAdd( aCabec, {'F1_DTDIGIT' , StoD( oXml:_EAIMT103:_F1_DTDIGIT:TEXT ) , nil } )
	aAdd( aCabec, {'F1_FORNECE' ,       oXml:_EAIMT103:_F1_FORNECE:TEXT   , nil } )
	aAdd( aCabec, {'F1_LOJA'    ,       oXml:_EAIMT103:_F1_LOJA:TEXT      , nil } )
	aAdd( aCabec, {'F1_ESPECIE' ,       oXml:_EAIMT103:_F1_ESPECIE:TEXT   , nil } )
	aAdd( aCabec, {'F1_COND'    ,       oXml:_EAIMT103:_F1_COND:TEXT      , nil } )
	aAdd( aCabec, {'F1_DESPESA' , Val(  oXml:_EAIMT103:_F1_DESPESA:TEXT ) , nil } )
	aAdd( aCabec, {'F1_DESCONT' , Val(  oXml:_EAIMT103:_F1_DESCONT:TEXT ) , nil } )
	aAdd( aCabec, {'F1_SEGURO'  , Val(  oXml:_EAIMT103:_F1_SEGURO:TEXT  ) , nil } )
	aAdd( aCabec, {'F1_FRETE'   , Val(  oXml:_EAIMT103:_F1_FRETE:TEXT   ) , nil } )
	aAdd( aCabec, {'F1_MOEDA'   , Val(  oXml:_EAIMT103:_F1_MOEDA:TEXT   ) , nil } )
	aAdd( aCabec, {'F1_TXMOEDA' , Val(  oXml:_EAIMT103:_F1_TXMOEDA:TEXT ) , nil } )
	aAdd( aCabec, {'F1_STATUS'  ,       oXml:_EAIMT103:_F1_STATUS:TEXT    , nil } )

return

/*/{Protheus.doc} MontaItens
description
@type function
@version 
@author elton.alves
@since 19/10/2020
@param oXml, object, Objeto xml parsedo do xml recebido como texto.
@param aItens, array, Array a ser populado com os dados dos itens do Documento do Entrada
/*/
static function MontaItens( oXml, aItens )

	Local nX     := 0
	Local aLinha := {}

	if ValType( oxml:_EAIMT103:_ITENS:_ITEM ) == "A"

		for nX := 1 to len( oxml:_EAIMT103:_ITENS:_ITEM  )

			aAdd( aLinha, { 'D1_ITEM'   ,      oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_ITEM:TEXT    , nil } )
			aAdd( aLinha, { 'D1_COD'    ,      oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_COD:TEXT     , nil } )
			aAdd( aLinha, { 'D1_QUANT'  , Val( oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_QUANT:TEXT ) , nil } )
			aAdd( aLinha, { 'D1_VUNIT'  , Val( oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_VUNIT:TEXT ) , nil } )
			aAdd( aLinha, { 'D1_TOTAL'  , Val( oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_TOTAL:TEXT ) , nil } )
			aAdd( aLinha, { 'D1_TES'    ,      oXml:_EAIMT103:_ITENS:_ITEM[nX]:_D1_TES:TEXT     , nil } )

			aAdd( aItens, aClone( aLinha ) )

			aSize( aLinha, 0 )

		next nx

	else

		aAdd( aLinha, { 'D1_ITEM'   ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_ITEM:TEXT    , nil } )
		aAdd( aLinha, { 'D1_COD'    ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_COD:TEXT     , nil } )
		aAdd( aLinha, { 'D1_UM'     ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_UM:TEXT      , nil } )
		aAdd( aLinha, { 'D1_LOCAL'  ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_LOCAL:TEXT   , nil } )
		aAdd( aLinha, { 'D1_QUANT'  , Val( oXml:_EAIMT103:_ITENS:_ITEM:_D1_QUANT:TEXT ) , nil } )
		aAdd( aLinha, { 'D1_VUNIT'  , Val( oXml:_EAIMT103:_ITENS:_ITEM:_D1_VUNIT:TEXT ) , nil } )
		aAdd( aLinha, { 'D1_TOTAL'  , Val( oXml:_EAIMT103:_ITENS:_ITEM:_D1_TOTAL:TEXT ) , nil } )
		aAdd( aLinha, { 'D1_TES'    ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_TES:TEXT     , nil } )
		aAdd( aLinha, { 'D1_RATEIO' ,      oXml:_EAIMT103:_ITENS:_ITEM:_D1_RATEIO:TEXT  , nil } )

		aAdd( aItens, aLinha )

		aSize( aLinha, 0 )

	end if

return

/*/{Protheus.doc} ExAutMt103
Processa o cabeçalho e a lista de itens com o execauto mata103 de inclusão de documento de entradas
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 19/10/2020
@param aCabec, array, Array a ser populado com os dados do cabeçalho do Documento do Entrada
@param aItens, array, Array a ser populado com os dados dos itens do Documento do Entrada
@param cError, character,  Variável passada por referência, serve para alimentar a mensagem de erro, nos casos em que a transação não foi bem sucedida.
Caso ocorra alguma erro com o execauto esta variável irá receber o erro retornado.
/*/
static function ExAutMt103( aCabec, aItens, cError )

	Local aErro   := {}
	Local nX      := 0
	Local aArea   := GetArea()
	Local cDoc    := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F1_DOC'     } ) ][ 2 ], TamSx3( 'F1_DOC'     )[ 1 ] )
	Local cSerie  := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F1_SERIE'   } ) ][ 2 ], TamSx3( 'F1_SERIE'   )[ 1 ] )
	Local cFornec := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F1_FORNECE' } ) ][ 2 ], TamSx3( 'F1_FORNECE' )[ 1 ] )
	Local cLoja   := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F1_LOJA'    } ) ][ 2 ], TamSx3( 'F1_LOJA'    )[ 1 ] )
	Local cTipo   := 'N' //PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F1_TIPO'    } ) ][ 2 ], TamSx3( 'F1_TIPO'    )[ 1 ] )

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	DbSelectArea( 'SF1' )
	DbSetOrder( 1 ) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

	if SF1->( DbSeek( xFilial() + cDoc + cSerie + cFornec + cLoja + cTipo ) )

		cError := 'Nota já existe na base.'

		return

	end if

	RestArea( aArea )

	Begin Transaction

		MsExecAuto( { |a,b,c| MATA103(a,b,c) }, aCabec, aItens, 3 )

		If lMsErroAuto

			lMsErroAuto := .F.

			aErro := aClone( GetAutoGRLog() )

			for nX := 1 to Len( aErro )

				cError += aErro[ nX ] + CRLF

			next nX

			DisarmTransaction()

		end if

	End Transaction

return
