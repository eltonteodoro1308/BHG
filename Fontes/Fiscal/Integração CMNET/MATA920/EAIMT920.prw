#Include "totvs.ch"


user function tstmt920()

	rpcsetenv('99','01')

	U_EaiMt920( memoread('C:\TOTVS\TDS.WorkSpace\BHG SA\Fontes\Fiscal\EAI\MATA920\EAIMT920.xml'), '', '', '' )

	rpcclearenv()

return


/*/{Protheus.doc} EAIMT920
Função utilizada para inclusão de documentos de saída pelo execauto mata920 integrados do CMNET e por intermédio do EAI
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
user function EAIMT920( cXML, cError, cWarning, cParams, oFWEAI )

	Local oXml   := XmlParser( cXML, "_", @cError, @cWarning )
	Local aCabec := {}
	Local aItens := {}

	if Empty( cError )

		MontaCabec( oXml, aCabec )
		MontaItens( oXml, aItens )
		ExAutMt920( aCabec, aItens, @cError )

	end if

return .T.

/*/{Protheus.doc} MontaCabec
Monta o lista de itens do documento de saída a ser incluído com base nos dados do XML
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 19/10/2020
@param oXml, object, Objeto xml parsedo do xml recebido como texto.
@param aCabec, array, Array a ser populado com os dados do cabeçalho do Documento de saída
/*/
static function	MontaCabec( oXml, aCabec )

	aAdd( aCabec, {'F2_TIPO'    ,       oXml:_EAIMT920:_F2_TIPO:TEXT      , nil } )
	aAdd( aCabec, {'F2_FORMUL'  ,       oXml:_EAIMT920:_F2_FORMUL:TEXT    , nil } )
	aAdd( aCabec, {'F2_DOC'     ,       oXml:_EAIMT920:_F2_DOC:TEXT       , nil } )
	aAdd( aCabec, {'F2_SERIE'   ,       oXml:_EAIMT920:_F2_SERIE:TEXT     , nil } )
	aAdd( aCabec, {'F2_EMISSAO' , StoD( oXml:_EAIMT920:_F2_EMISSAO:TEXT ) , nil } )
	aAdd( aCabec, {'F2_CLIENTE' ,       oXml:_EAIMT920:_F2_CLIENTE:TEXT   , nil } )
	aAdd( aCabec, {'F2_LOJA'    ,       oXml:_EAIMT920:_F2_LOJA:TEXT      , nil } )
	aAdd( aCabec, {'F2_ESPECIE' ,       oXml:_EAIMT920:_F2_ESPECIE:TEXT   , nil } )
	aAdd( aCabec, {'F2_DESCONT' , Val(  oXml:_EAIMT920:_F2_DESCONT:TEXT ) , nil } )
	aAdd( aCabec, {'F2_FRETE'   , Val(  oXml:_EAIMT920:_F2_FRETE:TEXT   ) , nil } )
	aAdd( aCabec, {'F2_SEGURO'  , Val(  oXml:_EAIMT920:_F2_SEGURO:TEXT  ) , nil } )
	aAdd( aCabec, {'F2_DESPESA' , Val(  oXml:_EAIMT920:_F2_DESPESA:TEXT ) , nil } )


return

/*/{Protheus.doc} MontaItens
description
@type function
@version 
@author elton.alves
@since 19/10/2020
@param oXml, object, Objeto xml parsedo do xml recebido como texto.
@param aItens, array, Array a ser populado com os dados dos itens do Documento de Saída
/*/
static function MontaItens( oXml, aItens )

	Local nX     := 0
	Local aLinha := {}

	if ValType( oxml:_EAIMT920:_ITENS:_ITEM ) == "A"

		for nX := 1 to len( oxml:_EAIMT920:_ITENS:_ITEM  )

			aAdd( aLinha, { 'D2_ITEM'   ,      oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_ITEM:TEXT     , nil } )
			aAdd( aLinha, { 'D2_COD'    ,      oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_COD:TEXT      , nil } )
			aAdd( aLinha, { 'D2_QUANT'  , Val( oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_QUANT:TEXT  ) , nil } )
			aAdd( aLinha, { 'D2_PRCVEN' , Val( oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_PRCVEN:TEXT ) , nil } )
			aAdd( aLinha, { 'D2_TOTAL'  , Val( oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_TOTAL:TEXT  ) , nil } )
			aAdd( aLinha, { 'D2_TES'    ,      oXml:_EAIMT920:_ITENS:_ITEM[nX]:_D2_TES:TEXT      , nil } )

			aAdd( aItens, aClone( aLinha ) )

			aSize( aLinha, 0 )

		next nx

	else

		aAdd( aLinha, { 'D2_ITEM'   ,      oXml:_EAIMT920:_ITENS:_ITEM:_D2_ITEM:TEXT     , nil } )
		aAdd( aLinha, { 'D2_COD'    ,      oXml:_EAIMT920:_ITENS:_ITEM:_D2_COD:TEXT      , nil } )
		aAdd( aLinha, { 'D2_QUANT'  , Val( oXml:_EAIMT920:_ITENS:_ITEM:_D2_QUANT:TEXT  ) , nil } )
		aAdd( aLinha, { 'D2_PRCVEN' , Val( oXml:_EAIMT920:_ITENS:_ITEM:_D2_PRCVEN:TEXT ) , nil } )
		aAdd( aLinha, { 'D2_TOTAL'  , Val( oXml:_EAIMT920:_ITENS:_ITEM:_D2_TOTAL:TEXT  ) , nil } )
		aAdd( aLinha, { 'D2_TES'    ,      oXml:_EAIMT920:_ITENS:_ITEM:_D2_TES:TEXT      , nil } )

		aAdd( aItens, aLinha )

		aSize( aLinha, 0 )

	end if

return

/*/{Protheus.doc} ExAutMt920
Processa o cabeçalho e a lista de itens com o execauto mata920 de inclusão de documento de saída
@type user function
@version 12.1.27
@author elton.alves@totvs.com.br
@since 19/10/2020
@param aCabec, array, Array a ser populado com os dados do cabeçalho do Documento de saída
@param aItens, array, Array a ser populado com os dados dos itens do Documento de saída
@param cError, character,  Variável passada por referência, serve para alimentar a mensagem de erro, nos casos em que a transação não foi bem sucedida.
Caso ocorra alguma erro com o execauto esta variável irá receber o erro retornado.
/*/
static function ExAutMt920( aCabec, aItens, cError )

	Local aErro   := {}
	Local nX      := 0
	Local aArea   := GetArea()
	Local cDoc    := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F2_DOC'     } ) ][ 2 ], TamSx3( 'F2_DOC'     )[ 1 ] )
	Local cSerie  := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F2_SERIE'   } ) ][ 2 ], TamSx3( 'F2_SERIE'   )[ 1 ] )
	Local cFornec := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F2_CLIENTE' } ) ][ 2 ], TamSx3( 'F2_CLIENTE' )[ 1 ] )
	Local cLoja   := PadR( aCabec[ aScan( aCabec, { | item | item[ 1 ] == 'F2_LOJA'    } ) ][ 2 ], TamSx3( 'F2_LOJA'    )[ 1 ] )
	Local cFormul := ''
	Local cTipo   := ''

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	DbSelectArea( 'SF2' )
	DbSetOrder( 1 ) // F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO

	if SF2->( DbSeek( xFilial() + cDoc + cSerie + cFornec + cLoja + cFormul + cTipo ) )

		cError := 'Nota já existe na base.'

		return

	end if

	RestArea( aArea )

	Begin Transaction

		MsExecAuto( { |a,b,c| MATA920(a,b,c) }, aCabec, aItens, 3 )

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
