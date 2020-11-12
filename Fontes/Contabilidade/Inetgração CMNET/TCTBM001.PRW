#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#define CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TCTBM001    ³ Autor ³ Manoel Crispim     ³ Data ³ 04/09/17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importar Lancamentos Contabeis para o Protheus              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ NB Hoteis e Empreendimentos LTDA                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nao existe                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                            ALTERACOES                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data    ³ Programador   ³ Solic Cliente ³ Alteracoes                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ³               ³               ³                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TCTBM001()

	Local cCadastro 	:= "Importação Contábil"
	Local bProcesso 	:= {|oSelf| TCTB02(oSelf)}
	Local cDescricao 	:= "Está rotina efetua a importação da CTB"

	tNewProcess():New( "TCTBM001" , cCadastro , bProcesso , cDescricao , , , , , , .T. , .T.)

Return()

/*
Rotina que inicia o processo de importacao
*/
Static Function TCTB02(oSelf)

	Local nCountReg	:= 0
	Local cArq

	//Busca o arquivo a ser importado
	cArq := AllTrim( cGetFile( 'Arquivo TXT| *.txt |Arquivo CSV | *.csv', 'Selecione o arquivo', 0, "", .T.,  GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE  ) )

	If Empty(cArq)
		Return()
	EndIf

	//Abre o arquivo para uso
	FT_FUSE(cArq)

	//Posiciona no inicio do arquivo
	FT_FGOTOP()

	nCountReg := FT_FLASTREC()

	If nCountReg > 0

		oSelf:SetRegua1(nCountReg)

		oSelf:SaveLog( "Importação CTB"+" - "+"Inicio do processamento")

		TCTB03(oSelf)

		oSelf:SaveLog( "Importação Contábil"+" - "+"Final do processamento")

	Else
		Help( " ", 1, "TCTBM001", , "Não há registro para serem processados", 1, 0 )
	EndIf

	//Fecha o Arquuivo
	FT_FUSE()

Return()

/*
Rotina que realiza efetivamente a importacao
*/
Static Function TCTB03(oSelf)

	local cLinha   := ''
	local cItem    := ''
	local aLctos   := {}
	local nPos     := 0
	local dData    := ctod('')
	local cTipo    := ''
	local cConta   := ''
	local cCCusto  := ''
	local cItemCtb := ''
	local nValor   := 0
	local cHist    := ''
	local nX       := 0

	Private lMsErroAuto    := .F.
	//Private lMsHelpAuto    := .T.
	//Private lAutoErrNoFile := .T.

	//Posiciona no inicio do arquivo
	FT_FGOTOP()

	Do While ( !FT_FEOF() )

		oSelf:IncRegua1("Processando Arquivo")

		cLinha := FT_FREADLN()

		dData    := cToD( SubStr( cLinha, 1, 10 ) )
		cTipo    := If( SubStr( cLinha, 12, 1 ) == 'D', '1', '2' )
		cConta   := SubStr( cLinha, 239, 17 )
		cCCusto  := SubStr( cLinha, 229, 10 )
		cItemCtb := '0'
		nValor   := Val( SubStr( cLinha, 257, 17 ) )
		cHist    := NoAcento( AllTrim( SubStr( cLinha, 29, 210 ) ) )

		nPos := aScan( aLctos, { | item | item[1] == dData } )

		if nPos == 0

			aAdd( aLctos, {  dData, {} } )

			nPos := Len( aLctos )

		end if

		cItem := StrZero( Len( aLctos[nPos][2] ) + 1, 3 )

		aAdd( aLctos[nPos][2], {;
			{'CT2_LINHA' , cItem                          , nil },;
			{'CT2_DC'    , cTipo                          , nil },;
			{'CT2_TPSALD', '1'                            , nil },;
			{'CT2_DEBITO', If( cTipo=='1', cConta, '' )   , nil },;
			{'CT2_CREDIT', If( cTipo=='2', cConta, '' )   , nil },;
			{'CT2_VALOR' , nValor                         , nil },;
			{'CT2_ORIGEM', 'TCTBM001'                     , nil },;
			{'CT2_CCD'   , If( cTipo=='1', cCCusto, '' )  , nil },;
			{'CT2_CCC'   , If( cTipo=='2', cCCusto, '' )  , nil },;
			{'CT2_ITEMD' , If( cTipo=='1', cItemCtb, '' ) , nil },;
			{'CT2_ITEMC' , If( cTipo=='2', cItemCtb, '' ) , nil },;
			{'CT2_HIST'  , cHist                          , nil }})

		FT_FSKIP()

	End Do

	Begin Transaction

		for nX := 1 to Len( aLctos )

			MSExecAuto( {| X , Y , Z | CTBA102( X , Y , Z )} ,;
				{ { 'DDATALANC' , aLctos[nX][1] , Nil } , { 'CLOTE' , '000001' , Nil } } ,;
				aLctos[nX][2] , 3 )

			If lMsErroAuto

				lMsErroAuto := .F.

				MsgAlert( 'Ocorreu um erro durante a importação a mesma será interrompida.', 'Atenção !!!' )
				mostraErro()

				DisarmTransaction()

				Exit

			end if

		Next nX

	End Transaction

Return
