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

	Local cLin		:= ""

	//Posiciona no inicio do arquivo
	FT_FGOTOP()
	nLinha := 0

    c_Buffer := Alltrim(FT_FREADLN())

    a_Buffer := {}
    
    AADD(a_Buffer,SubStr(c_Buffer,1,10))     //Data
    AADD(a_Buffer,SubStr(c_Buffer,12,1))     //D-Debito / C-credito
    AADD(a_Buffer,SubStr(c_Buffer,29,210))   //Historico
    AADD(a_Buffer,'0'+SubStr(c_Buffer,239,17))   //Conta Contabil
    AADD(a_Buffer,SubStr(c_Buffer,257,17))   //Valor
    AADD(a_Buffer,SubStr(c_Buffer,229,10))   //Centro de Custo
    //colocar o centro de custo
	aCabecalho := { { 'DDATALANC' , Ctod(a_Buffer[01]), Nil } , { 'CLOTE' , '000001' , Nil } }
	aItens     := {}
    d_Data     := Ctod(a_Buffer[01])
    l_GravaCtb := .F.

	Do While ( !FT_FEOF() )
	   oSelf:IncRegua1("Processando Arquivo")
       //adson 11.10.2017 não faz se tiver valor zerado 
       If Val(a_Buffer[05])>0
       If d_Data = Ctod(a_Buffer[01]) 
  	      nLinha := nLinha + 1

		  Aadd( aItens ,{ {'CT2_DATA'  , Ctod(a_Buffer[01])                  , Nil},;
		    			  {'CT2_LINHA' , StrZero( nLinha , 3 )               , Nil},;
			  			  {'CT2_DC'    , IIF(a_Buffer[02]="D",1,2)           , Nil},;
                          {'CT2_TPSALD','1'                                   , Nil},;
						  {'CT2_DEBITO', IIF(a_Buffer[02]="D",a_Buffer[04],""), Nil},;
						  {'CT2_CREDIT', IIF(a_Buffer[02]="C",a_Buffer[04],""), Nil},;
						  {'CT2_VALOR' , Val(a_Buffer[05])                    , Nil},;
						  {'CT2_ORIGEM', "TCTBM001"                           , Nil},; 
						  {'CT2_CCD'   , IIF(a_Buffer[02]="D",a_Buffer[06],""), Nil},; 
						  {'CT2_CCC'   , IIF(a_Buffer[02]="C",a_Buffer[06],""), Nil},; 
						  {'CT2_HIST'  , SemAcento(Alltrim(a_Buffer[03]))     , Nil}})

          l_GravaCtb := .T.
       Else
          If l_GravaCtb
	         lMSErroAuto := .F.

   	         MSExecAuto( {| X , Y , Z | CTBA102( X , Y , Z )} , aCabecalho , aItens , 3 )

             If lMSErroAuto
                MostraErro()
             EndIf
             

  	         aCabecalho := { { 'DDATALANC' , Ctod(a_Buffer[01]) , Nil } , { 'CLOTE' , '000001' , Nil } }
	         aItens     := {}
             d_Data     := Ctod(a_Buffer[01])
  		     nLinha     := 0
  	         l_GravaCtb := .T.

  	      nLinha := nLinha + 1

		  Aadd( aItens ,{ {'CT2_DATA'  , Ctod(a_Buffer[01])                   , Nil},;
		    			  {'CT2_LINHA' , StrZero( nLinha , 3 )                 , Nil},;
			  			  {'CT2_DC'    , IIF(a_Buffer[02]="D",1,2)            , Nil},;
                          {'CT2_TPSALD','1'                                    , Nil},;
						  {'CT2_DEBITO', IIF(a_Buffer[02]="D",a_Buffer[04],""), Nil},;
						  {'CT2_CREDIT', IIF(a_Buffer[02]="C",a_Buffer[04],""), Nil},;
						  {'CT2_VALOR' , Val(a_Buffer[05])                     , Nil},;
						  {'CT2_ORIGEM', "TCTBM001"                            , Nil},;
						  {'CT2_HIST'  , SemAcento(Alltrim(a_Buffer[05]))     , Nil}})

          EndIf
       EndIf
       Endif
	   //Proxima linha
	   FT_FSKIP()

       c_Buffer := Alltrim(FT_FREADLN())

       a_Buffer := {}

       AADD(a_Buffer,SubStr(c_Buffer,1,10))     //Data
       AADD(a_Buffer,SubStr(c_Buffer,12,1))     //D-Debito / C-credito
       AADD(a_Buffer,SubStr(c_Buffer,29,210))   //Historico
       AADD(a_Buffer,'0'+SubStr(c_Buffer,239,17))   //Conta Contabil
       AADD(a_Buffer,SubStr(c_Buffer,257,17))   //Valor       
       AADD(a_Buffer,SubStr(c_Buffer,229,10))   //Centro de Custo       
    EndDo

	lMSErroAuto := .F.

    If l_GravaCtb
	   MSExecAuto( {| X , Y , Z | CTBA102( X , Y , Z )} , aCabecalho , aItens , 3 )
    EndIf

	If lMSErroAuto
		MostraErro()
	EndIf
Return()

Static Function SemAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙº" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString