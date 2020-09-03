#INCLUDE "rwMake.ch"                        
#INCLUDE "PROTHEUS.CH" 

#DEFINE DMPAPER_A4 9                                                                                                      
// A4 210 x 297 mm
                                                                                      
#DEFINE DMPAPER_A4SMALL 10
// A4 Small 210 x 297 mm

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MULTIBOL ³ Autor ³ Microsiga             ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO BANCARIO COM CODIGO DE BARRAS          ³±±
±±³          ³ Banco Santander                                            ³±±
±±³          ³ Banco do Brasil                                            ³±±
±±³          ³ Banco Bradesco                                             ³±±
±±³          ³ Banco Itau                                                 ³±±
±±³          ³ Banco Caixa Economica Federal // por Barbieri em 26/09/16  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MULTIBOL()                             


	Local	aPergs     := {} 
	Private lExec      := .F.
	Private cIndexName := ''
	Private cIndexKey  := ''
	Private cFilter    := ''
	Private lChk       := .F.
	Private cMarca  	:= GetMark()
	Private cCadastro   := 'Impressao de Boleto com Codigo de Barras'
	Private aRotina 	:= {	{ 'Imprime Boletos' , 'U_RF01BImp' , 0, 1 } }

	Tamanho            := "M"
	titulo             := "Impressao de Boleto com Codigo de Barras"                                                                            
	cDesc1             := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	cDesc2             := ""
	cDesc3             := ""
	cString            := "SE1"
	wnrel              := "RFINR01"
	cPerg              := "MULTIBOL  "
	aReturn            := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
	nLastKey           := 00
	lEnd               := .F.

	dbSelectArea( "SE1" )

	ValidPerg()
	Pergunte(cPerg,.T.)
    
//If MV_PAR20 == "033"
//	U_MFINR02()
//	Return()
//Endif
	


	cIndexName	:= Criatrab(Nil,.F.)
	cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And." 
	cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
	cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
	cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "'.And." 
	cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR10 + "'.And."
	cFilter		+= "E1_LOJA>='" + MV_PAR11 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
	cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"'.And."
	cFilter		+= 'DTOS(E1_VENCREA)>="'+DTOS(mv_par15)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par16)+'".And.' 
	cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
	cFilter     += "!(E1_TIPO$MVABATIM)"
//	cFilter     += "Posicione('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'A1_TIPO') != 'X' .And. "//
//	cFilter		+= "E1_PORTADO = '" + MV_PAR20 + "' .And. E1_AGEDEP = '" + MV_PAR21 + "' .And. E1_CONTA = '" + MV_PAR22 + "' " //

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	dbSelectArea("SE1")
	dbGoTop()

	DbSelectArea("SE1")
	#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF
	dbGoTop()

	MarkBrow ("SE1","E1_OK",,,,cMarca,"U_RF01BMarcaT(.T.)",,,,"U_RF01BMarcaT(.F.)",,,,,,,,.F.)

	RetIndex("SE1")
	Ferase(cIndexName+OrdBagExt())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³MARCATODOSºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para marcar/desmarcar todos os itens do    º±±
±±º          ³ ListBox ativo                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RF01BImp()

	/*	Wnrel := SetPrint( cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,, )

	If nLastKey == 27               
	Set Filter to
	Return
	Endif

	SetDefault(aReturn,cString)*/

	lExec := .T.
	dbGoTop()
	If lExec
		Processa({|lEnd| U_RF01B062()})
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³MARCATODOSºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para marcar/desmarcar todos os itens do    º±±
±±º          ³ ListBox ativo                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RF01BMarcaT( lMarkAll )

	Local aArea	:= GetArea()
	Local cMarkAll

	If lMarkAll
		dbSelectArea("SE1")
		dbGotop()
		If !SE1->(Eof())
			cMarkAll := IIf(SE1->E1_OK == cMarca ,Space(2), cMarca)
			While !SE1->(Eof())
				RecLock( "SE1", .F. )
				Replace E1_OK With cMarkAll
				MsUnLock()
				SE1->(dbSkip())
			EndDo
		EndIf
	Else
		RecLock( "SE1", .F. )
		Replace E1_OK With IIf(SE1->E1_OK == cMarca ,Space(2), cMarca)
		MsUnLock()
	EndIf

	RestArea(aArea)
	Return

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RF01B062 ³ Autor ³                       ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DE BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Desta forma posso chamar direto da nota por exemplo, passando os parametros
User Function RF01B062(xBanco,xAgencia,xConta,xSubCt,lSetup,cNotIni,cNotFim,cSerie)

	Local oPrint
	Local oPrn
	Local nX := 0
	Local cNroDoc 	   :=  " "
	Local aDadosEmp 


	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	Local aBolText

	Local nI           := 1
	Local aCB_RN_NN    := {}
	Local nVlrAbat	   := 0
	Local xSetup       := iif(lSetup==nil,.f.,lSetup)
	Local nDvnn 	   := 0

	Private cBanco   := ""
	Private cAgencia := ""
	Private cConta   := ""
	//Private cSubCt   := ""
	Private aCabec  := {}
	Private cTipCobr := "" //Incluido por Barbieri
	Private cDvConta := "" //Incluido por Barbieri       
	Private cFaixaAtu := "" //Incluido por Barbieri
	Private cNNumCEF := "" //Incluido por Barbieri                                         

	Private oFont5   := TFont():New("Arial",9,5,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont6   := TFont():New("Arial",9,6,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont7   := TFont():New("Arial",9,7,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont8n  := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont13  := TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	Private oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	Private oBrush1  := TBrush():New( , CLR_BLACK )

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)


	//oPrint:= TMSPrinter():New( "Boleto Laser" )
	oPrint:= tNewMsprinter():New( "Boleto Laser" )
	//oPrint:SetPaperSize( DMPAPER_A4 ) //A4
	//oPrint:SetPortrait() // ou SetLandscape()

	//oPrint:StartPage()   // Inicia uma nova página

	//oPrint:Setup()
	/*
	If xSetup

	cIndexName := ''
	cIndexKey  := ''
	cFilter    := ''

	Tamanho            := "M"
	titulo             := "Impressao de Boleto com Codigo de Barras"
	cDesc1             := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
	cDesc2             := ""
	cDesc3             := ""
	cString            := "SE1"
	wnrel              := "RFINR01"
	cPerg              := "FINR01"
	aReturn            := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
	nLastKey           := 00
	lEnd               := .F.

	Wnrel := SetPrint( cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,, )

	SetDefault(aReturn,cString)

	cIndexName	:= Criatrab(Nil,.F.)
	//cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cIndexKey	:= "E1_PREFIXO+E1_NUM"
	cFilter		+= "E1_FILIAL =='"+xFilial("SE1")+"'.And.E1_SALDO>0.And."
	cFilter		+= "E1_PREFIXO =='" + cSerie + "'.And." 
	cFilter		+= "E1_NUM>='" + cNotIni + "'.And.E1_NUM<='" + cNotFim + "'.And."
	cFilter		+= "!(E1_TIPO$MVABATIM) .and."
	cFilter		+= "!(E1_TIPO$'FIC/FID')"

	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	dbSelectArea("SE1")
	EndIf	
	*/

	aDadosEmp    := {	SM0->M0_NOMECOM															             ,;	//	[1]	Nome da Empresa
	SM0->M0_ENDCOB																                ,;	//	[2]	Endereço
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;	//	[3]	Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)			    ,;	//	[4]	CEP
	"PABX/FAX: "+SM0->M0_TEL													             ,;	//	[5]	Telefones
	"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+				 ;	   //	[6]
	Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+					   	 ;	   //	[6]
	Subs(SM0->M0_CGC,13,2)													              	 ,;	//	[6]	CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+			    ;	   //	[7]
	Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)							   }	   //	[7]	I.E

	SE1->(dbGoTop())

	//ProcRegua(RecCount())

	ProcRegua(0)

	While SE1->(!EOF())

		IncProc("Processando Boleto: " + SE1->E1_NUM + " , Parcela: " + SE1->E1_PARCELA )

		If !Marked("E1_OK") //Caio de Castro - 30/07/12 - Somente registro marcados
			SE1->(dbSkip())
			Loop
		EndIf

		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

		xBanco   := SA1->A1_BCO1
		aBco	 := VerBco(Alltrim(SA1->A1_BCO1))

		xAgencia := aBco[1]
		xConta   := aBco[2]

		If !Empty(xAgencia) .and. !Empty(xConta)
			xSubct   := aBco[3]   
		Else
			xSubct   := MV_PAR19
		EndIf

		If !Empty(MV_PAR20) .and. Empty(xBanco) 
			xBanco := MV_PAR20         
		EndIf

		If !Empty(MV_PAR21) .and. Empty(xAgencia)
			xAgencia := MV_PAR21        
		EndIf

		If !Empty(MV_PAR22) .and. Empty(xConta)
			xConta := MV_PAR22         
		EndIf

		cBanco   := iif(Empty(xBanco)  ,SE1->E1_PORTADO ,xBanco  )
		cAgencia := iif(Empty(xAgencia),SE1->E1_AGEDEP  ,xAgencia)
		cConta   := iif(Empty(xConta)  ,SE1->E1_CONTA   ,xConta  )
		cSubct   := iif(Empty(xSubCt)  ,MV_PAR19        ,xSubCt  )

		//Posiciona o SA6 (Bancos)
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))
		If !SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))     
			Aviso(OemToAnsi("ATENÇÃO"),OemToAnsi("Banco não localizado"),{"OK"})
			DbSelectArea("SE1")
			SE1->(dbSkip())
			Loop
		EndIf
		cDvConta := SA6->A6_DVCTA //Incluido por Barbieri

		// Posiciona na Arq de Parametros CNAB
		DbSelectArea("SEE")
		DbSetOrder(1)
		If !SEE->(DbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCt))
			Aviso(OemToAnsi("ATENÇÃO"),OemToAnsi("Não localizado banco no cadastro de parâmetros para envio"),{"OK"})
			DbSelectArea("SE1")
			SE1->(dbSkip())
			Loop
		EndIf
		cTipCobr  := SEE->EE_TPCOBRA //Incluido por Barbieri
		cNNumCEF  := IIf(cTipCobr == "1","14","24") // Alterado por Barbieri

		// Posiciona o SA1 (Cliente)
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.))

		DbSelectArea("SE1")

		if alltrim(see->ee_codigo) $'341'
			_cconta :=  StrZero(Val(Subs(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)),5) 
		elseif alltrim(see->ee_codigo) $'033'
			_cconta := StrZero(Val(Subs(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)),Len(AllTrim(SA6->A6_NUMCON))-1) 
		elseif alltrim(see->ee_codigo) $'104' //Incluido por Barbieri
			_cconta := StrZero(Val(Subs(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)),6)
		else  
			_cconta := StrZero(Val(Subs(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)),7) 
		endif

		If Empty(SE1->E1_NUMBCO)
			
		    //atualiza SEE
				DbSelectArea("SEE")
				RecLock("SEE",.f.)
				
				SEE->EE_FAXATU	:= Soma1(SEE->EE_FAXATU)			//INCREMENTA P/ TODOS OS BANCOS
				cFaixaAtu		:= StrZero(val(SEE->EE_FAXATU),15)	//Incluido por Barbieri
				
				DbUnlock()
				DbSelectArea("SE1")

		Else 
			If alltrim(see->ee_codigo) = '341' // alterado em 12/06/17 para retirar o DAC do campo
				cFaixaAtu  := StrZero(val(Subs(SE1->E1_NUMBCO,1,Len(Alltrim(StrTran(SE1->E1_NUMBCO,"-","")))-1)),15) //pega numero sem o DAC, o DAC eh gravado com hifen antes
			Else
				cFaixaAtu  := StrZero(val(SE1->E1_NUMBCO),15) //Incluido por Barbieri
			Endif	
		Endif

		aDadosBanco  := {SEE->EE_CODIGO     					,;	//	[1]	Numero do Banco
		SUBSTR(Alltrim(SA6->A6_NOME),1,15)						,;	//	[2]	Nome do Banco
		SUBSTR(SEE->EE_AGENCIA,1,4) 							,;	//	[3]	Agência OLD: STRZERO(VAL(RIGHT(alltrim(SEE->EE_AGENCIA),1,4)),4,0)
		SUBSTR(SA6->A6_NUMCON,1,6)								,;	//	[4]	Conta Corrente OLD:STRZERO(VAL(RIGHT(alltrim(SA6->A6_NUMCON),1,6)),6,0) // COLOCADO ZERO PARA
		SUBSTR(SA6->A6_DVCTA,1,1) 								,;	//	[5]	Dígito da conta corrente
		SUBSTR(SEE->EE_CODCART,1,3)								,;  //  [6] Código da Carteira
		SUBSTR(SEE->EE_DVAGE,1,1)								,;  //  [7] Dígito da Agência
		SUBSTR(SEE->EE_TPCOBRA,1,1)								,;  //  [8] Tipo de cobrança 1-Registrada / 2-Não registrada // Incluido por Barbieri
		cFaixaAtu												,;  //  [9] Nosso numero na SEE (Parametros Banco) // Incluido por Barbieri
		cNNumCEF												,;  //  [10] Código de controle CEF // Incluido por Barbieri 								
		Alltrim(SEE->EE_CODEMP)   	 							,;  //  [11] Código de controle CEF // Incluido por Barbieri
		AllTrim(SA6->A6_NUMCON)} 

		cmsg1 := " " 
		cmsg2 := " "
		cmsg3 := " "
		cmsg4 := " "

		If SE1->E1_DESCFIN > 0
			cmsg1 := "DESC. CONTRATO DE R$ " + AllTrim(Transform(SE1->E1_DESCFIN / 100 * SE1->E1_SALDO,"@E 999,999,999.99")) + ". "
		EndIf

		If !Empty(SEE->EE_FORMEN1)
			cmsg1 += SEE->EE_FORMEN1
		
		//If !Empty(SEE->EE_XBOL1)//
			//cmsg1 += SEE->EE_XBOL1//
		EndIf                                                                       

		If !Empty(SEE->EE_FORMEN2)
			cmsg2 := SEE->EE_FORMEN2
			
		//If !Empty(SEE->EE_XBOL2)//
			//cmsg2 := SEE->EE_XBOL2//	
		EndIf                                                                       

		If !Empty(SEE->EE_FOREXT1)
			cmsg3 := SEE->EE_FOREXT1
		EndIf                                                                       

		If !Empty(SEE->EE_FOREXT2)
			cmsg4 := SEE->EE_FOREXT2
		EndIf                                                                       

		aBolText     := {   cmsg1                                                   ,; //[1] TEXTO 1
		cmsg2                                               	,; //[2] TEXTO 1
		cmsg3													,; //[3] TEXTO 1
		cmsg4													     }  //[4] TEXTO 1

		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)				,;	//	[1]	Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	//	[2]	Código
			AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,;	//	[3]	Endereço
			AllTrim(SA1->A1_MUN )								      ,;	//	[4]	Cidade
			SA1->A1_EST											         ,;	//	[5]	Estado
			SA1->A1_CEP											         ,;	//	[6]	CEP
			SA1->A1_CGC											         ,;	//	[7]	CGC
			SA1->A1_PESSOA										         ,;	//	[8]	PESSOA
			SA1->A1_EMAIL								          		}	//	[9]	E-mail
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)				,;	//	[1]	Razão Social
			AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	//	[2]	Código
			AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	//	[3]	Endereço
			AllTrim(SA1->A1_MUNC)						        		,;	//	[4]	Cidade
			SA1->A1_ESTC										         ,;	//	[5]	Estado
			SA1->A1_CEPC						         				,;	//	[6]	CEP
			SA1->A1_CGC										         	,;	//	[7]	CGC
			SA1->A1_PESSOA										         ,;	//	[8]	PESSOA
			SA1->A1_EMAIL									         	}	//	[9]	E-mail
		Endif

		nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		cParcel  := If(Empty(SE1->E1_PARCELA),"00",SE1->E1_PARCELA)

		If !Empty(SE1->E1_NUMBCO) // reimpressao

			If aDadosBanco[1] == "001"
				cNroDoc	:= StrZero(Val(SE1->E1_NUMBCO),5)
			ElseIf aDadosBanco[1] = "237"
				cNroDoc := StrZero(Val(SE1->E1_NUMBCO),11)
			ElseIf aDadosBanco[1] == "341"
				cNroDoc := StrZero(Val(Subs(SE1->E1_NUMBCO,1,Len(Alltrim(StrTran(SE1->E1_NUMBCO,"-","")))-1)),8) //StrZero(Val(SE1->E1_NUMBCO),8) //alterado em 12/06/17, para retirar o DAC do campo, pois antes o campo era gravado sem o DAC para o Itau, agora eh gravado com o DAC
			ElseIf aDadosBanco[1] == "033"
				cNroDoc := StrZero(Val(SE1->E1_NUMBCO),12)
			ElseIf aDadosBanco[1] == "104" //Incluido por Barbieri
				IF aDadosBanco[8] == "1"
					cNroDoc := "14"+StrZero(Val(SE1->E1_NUMBCO),15)
				ELSE
					cNroDoc := "24"+StrZero(Val(SE1->E1_NUMBCO),15)
				ENDIF
			EndIf

		ElseIf !Empty(SEE->EE_FAXATU)   // a partir da 2 vez vez

			If aDadosBanco[1] == "001"
				cNroDoc	:= StrZero(Val(SEE->EE_FAXATU),5)
			ElseIf aDadosBanco[1] = "237"
				cNroDoc := StrZero(Val(SEE->EE_FAXATU),11)
			ElseIf aDadosBanco[1] == "341"
				cNroDoc := StrZero(Val(SEE->EE_FAXATU),8)
			ElseIf aDadosBanco[1] == "033"
				cNroDoc := StrZero(Val(SEE->EE_FAXATU),12)
			ElseIf aDadosBanco[1] == "104" //Incluido por Barbieri
				IF aDadosBanco[8] == "1"
					cNroDoc := "14"+cFaixaAtu
				ELSE
					cNroDoc := "24"+cFaixaAtu
				ENDIF
			EndIf

		Else
			cNroDoc	:= StrZero(1,8)//STRZERO(VAL(SE1->E1_NUM),10)	// primeira vez
		EndIf

		//Monta codigo de barras  
		aCB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9" 	    ,;//[1]Banco
		Subs(aDadosBanco[3],1,4)			    ,;//[2]Agencia
		aDadosBanco[4]						,;//[3]Conta  // tg aqui
		aDadosBanco[5]						,;//[4]Digito da Conta
		aDadosBanco[6]						,;//[5]Carteira
		AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;//[6]Documento
		(E1_SALDO+E1_SDACRES-E1_SDDECRE-E1_IRRF-E1_CSLL-E1_PIS-E1_COFINS)					,;//[7]Valor do Titulo
		SE1->E1_VENCTO						,;//[8]Vencimento               // ALTERADO EM 20.09.2010 ERA E1_VENCREA, MAS TAVA DANDO ERRO ERRO DE FATOR DE VENCTO
		AllTrim(SEE->EE_CODEMP)				,;//[9]Convenio
		cNroDoc  								,;//[10]Sequencial
		0									,;//[11]Se tem desconto
		SE1->E1_PARCELA						,;//[12]Parcela
		aDadosBanco[3])                         //[13]Agencia Completa

		aDadosTit := {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  //	[1]	Número do título
		E1_EMISSAO						,;  //	[2]	Data da emissão do título
		dDataBase						,;  //	[3]	Data da emissão do boleto
		E1_VENCTO						,;  //	[4]	Data do vencimento
		(E1_SALDO+E1_SDACRES-E1_SDDECRE-E1_IRRF-E1_CSLL-E1_PIS-E1_COFINS),;  //	[5]	Valor do título
		aCB_RN_NN[3]					,;  //	[6]	Nosso número (Ver fórmula para calculo)
		E1_PREFIXO						,;  //	[7]	Prefixo da NF
		E1_TIPO							,;  //	[8]	Tipo do Titulo
		iif(aDadosBanco[1] == "104",aDadosBanco[10]+aDadosBanco[9],aDadosBanco[9])}   //  [9] Nosso numero CAIXA // Incluido por Barbieri

		If xBanco == nil
			If Marked("E1_OK")
				Impres2(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
				nX := nX + 1
			EndIf
		Else
			Impres2(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
			nX := nX + 1
		EndIf
        
		DbSelectArea("SE1")
		SE1->(dbSkip())
		IncProc()
		nI := nI + 1

	EndDo

	//oPrint:EndPage()     // Finaliza a página

//	If MsgYesNo("Deseja viasualizar os boletos em tela?")
	oPrint:Preview()// Visualiza antes de imprimir
//	FreeObj(oPrint) 
//	Else
//		oPrint:Print()
//	EndIf

Return nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³                       ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Del Valle                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.

	L := Len(cData)  //TAMANHO DE BYTES DO CARACTER
	B := .T.   
	D := 0     //DIGITO VERIFICADOR
	While L > 0 
		P := Val(SubStr(cData, L, 1))
		If (B) 
			P := P * 2
			If P > 9 
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End

Return(D)             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³                       ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11(cData,cBanc)
	Local L, D, P := 0  

	If cBanc == "001" // Banco do brasil
		L := Len(cdata)
		D := 0
		P := 10
		While L > 0 
			P := P - 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 2 
				P := 10
			End
			L := L - 1
		End
		D := mod(D,11)
		If D == 10
			D := "X"
		Else
			D := AllTrim(Str(D))
		End           
	ElseIf cBanc == "341" .Or. cBanc == "453" .Or. cBanc == "399" .or. cBanc == "422" // Itau/Mercantil/Rural/HSBC/Safra
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := 11 - (mod(D,11))  

		If (D == 10 .Or. D == 11) .and. (cBanc == "341" .or. cBanc == "422")
			D := 1
		End
		If (D == 1 .Or. D == 0 .Or. D == 10 .Or. D == 11) .and. (cBanc == "289" .Or. cBanc == "453" .Or. cBanc == "399")
			D := 0
		End
		D := AllTrim(Str(D))   

	ElseIf cBanc == "237" // Bradesco Calculo do Modulo11 base 7

		L := Len(cdata)
		D := 0
		P := 2

		While L > 0 
			D := D + Val(SubStr(cdata, L, 1)) * P
			P := P + 1
			L := L - 1
			IF P == 8 // ERA 8
				P:= 2
			End
		End

		If mod(D,11) = 0
			D := str(0)
		Else
			D := str(11 - (mod(D,11)))
		End 

		If D = str(10)
			D := "P"  
		End

		D := AllTrim(D)

	ElseIf cBanc == "389" //Mercantil
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End   
		D := mod(D,11)
		If D == 1 .Or. D == 0
			D := 0
		Else
			D := 11 - D
		End
		D := AllTrim(Str(D))
	ElseIf cBanc == "479"  //BOSTON
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := Mod(D*10,11)
		If D == 10
			D := 0
		End
		D := AllTrim(Str(D))
	ElseIf cBanc == "409"  //UNIBANCO
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := Mod(D*10,11)
		If D == 10 .or. D == 0
			D := 0
		End
		D := AllTrim(Str(D))

	ElseIf cBanc == "356"  //Real
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := Mod(D*10,11)
		If D == 10 .or. D == 0
			D := 0
		End
		D := AllTrim(Str(D))

	ElseIf cBanc == "104"  //CEF - Incluido por Barbieri
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := Mod(D*10,11)
		If D > 9 .or. D == 0
			D := 1
		End
		D := AllTrim(Str(D))

	ElseIf cBanc == "748"// Sicredi Calculo do Modulo11 base 7

		L := Len(cdata)
		D := 0
		P := 2

		While L > 0 
			D := D + Val(SubStr(cdata, L, 1)) * P
			P := P + 1
			L := L - 1
			IF P = 8
				P:= 2
			End
		End

		If mod(D,11) = 0
			D := str(0)
		Else
			D := str(11 - (mod(D,11)))
		End 

		If D = str(10)
			D := "P"  
		End

		D := AllTrim(D)

	Else

		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9 
				P := 1
			End
			L := L - 1
		End
		D := 11 - (mod(D,11))
		If (D == 10 .Or. D == 11)
			D := 1
		End
		D := AllTrim(Str(D))
	Endif   

Return(D)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³                       ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor,dvencimento,cConvenio,cSequencial,_lTemDesc,_cParcela,_cAgCompleta,_NSOMA,_NDVCALC,_NmULT,_CNOSSONUM,_LGEROU,_AAREA)

	//Local cCodEmp := StrZero(Val(SubStr(cConvenio,1,4)),4)
	//Local cNumSeq := strzero(val(cSequencial),5)
	//Local cNumSeq := strzero(val(SubStr(cNroDoc,1,7)),7)
	//Local bldocnufinal := strzero(val(cNroDoc),9)

	Local cCodEmp := StrZero(Val(SubStr(cConvenio,1,6)),6)
	Local cNumSeq := strzero(val(Right(cSequencial,5)),5)
	Local blvalorfinal := strzero((nValor*100),10) 
	Local cNNumSDig := cCpoLivre := cCBSemDig := cCodBarra := cNNum := cFatVenc := ''
	Local cNossoNum
	Local _cDigito := ""
	Local _cSuperDig := ""
	IF Substr(cBanco,1,3) == '341'
		cCarteira := Right(cCarteira,3)
	Else   
		cCarteira := Right(cCarteira,3)
	Endif   

	_cParcela := NumParcela(_cParcela)

	//Fator Vencimento - POSICAO DE 06 A 09
	cFatVenc := STRZERO(dvencimento - CtoD("07/10/1997"),4)

	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

	//Campo Livre (Definir campo livre com cada banco)

	If Substr(cBanco,1,3) == "001"  // Banco do brasil

		If Len(AllTrim(cConvenio)) == 7
			//Nosso Numero sem digito
			cNNumSDig := AllTrim(cConvenio)+strzero(val(cSequencial),10)
			//Nosso Numero com digito
			cNNum := cNNumSDig

			//Nosso Numero para impressao
			cNossoNum := cNNumSDig

			//		cCpoLivre := "000000"+cNNumSDig+AllTrim(cConvenio)+strzero(val(cSequencial),10)+ cCarteira
			cCpoLivre := "000000"+cNNumSDig+cCarteira
		Else
			//Nosso Numero sem digito
			cNNumSDig := cCodEmp+cNumSeq	 
			//Nosso Numero com digito
			cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))

			//Nosso Numero para impressao
			cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

			cCpoLivre := cNNumSDig+cAgencia + StrZero(Val(cConta),8) + cCarteira

		Endif

	ElseIf Substr(cBanco,1,3) == "033"

//		cNumSeq := strzero(val(cNumSeq),12)
		//Nosso Numero sem digito
//		cNNumSDig := cNumSeq
		//Nosso Numero
//		cNNum := cNumSeq
		//Nosso Numero para impressao
//		cNossoNum := cNNumSDig +"-"+ sMod11(cNNumSDig,2,9) 

 //		cCpoLivre := "9" + cCodEmp + cNNumSDig + sMod11(cNNumSDig,2,9) + "0" + cCarteira 
  //		cCpoLivre := "9" + cCodEmp + cNNumSDig + sMod11(cNNumSDig,2,9) + cCarteira 




	Elseif Substr(cBanco,1,3) == "389" // Banco mercantil
		//Nosso Numero sem digito
		cNNumSDig := "09"+cCarteira+ strzero(val(cSequencial),6)
		//Nosso Numero
		cNNum := "09"+cCarteira+ strzero(val(cSequencial),6) + modulo11(cAgencia+cNNumSDig,SubStr(cBanco,1,3))
		//Nosso Numero para impressao
		cNossoNum := "09"+cCarteira+ strzero(val(cSequencial),6) +"-"+ modulo11(cAgencia+cNNumSDig,SubStr(cBanco,1,3))

		cCpoLivre := cAgencia + cNNum + StrZero(Val(SubStr(cConvenio,1,9)),9)+Iif(_lTemDesc,"0","2")

		//Elseif Substr(cBanco,1,3) == "237" // Banco bradesco
		//Nosso Numero sem digito
		//	cNNumSDig := cCarteira + bldocnufinal
		//Nosso Numero
		//	cNNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )
		//Nosso Numero para impressao
		//	cNossoNum := cCarteira + '/' + bldocnufinal + '-' + AllTrim( Str( modulo10( cNNumSDig ) ) )

		//	cCpoLivre := cAgencia + cCarteira + cNNumSDig + StrZero(Val(cConta),7) + "0"       
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Composicao do Campo Livre (25 posições)                              ³
		//³                                                                     ³
		//³20 a 23 - (04) - Agencia cedente (sem o digito), completar com zeros ³
		//³                 a esquerda se necessario	                        ³
		//³24 a 25 - (02) - Carteira                                            ³
		//³26 a 36 - (11) - Nosso Numero (sem o digito verificador)             ³
		//³37 a 43 - (07) - Conta do cedente, sem o digito verificador, complete³
		//³                 com zeros a esquerda, se necessario                 ³
		//³44 a 44 - (01) - Fixo "0"                                            ³
		//³                                                                     ³
		//³Composicao do Nosso Número                                           ³
		//³01 a 02 - (02) - Número da Carteira (SEE->EE_SUBCTA)                 ³
		//³                 06 para Sem Registro 19 para Com Registro           ³
		//³03 a 13 - (11) - Nosso Número (SEE->EE_FAXATU)                       ³
		//³04 a 14 - (01) - Dígito do Nosso Número (Modulo 11)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Elseif Substr(cBanco,1,3) == "237" // Banco bradesco

		cNrDoc := Right(cSequencial,11)

		//Nosso Numero sem digito
		cNNumSDig := StrZero(Val(cCarteira),2) + cNrDoc

		//Nosso Numero
		//cNNum := cNNumSDig + AllTrim( Str( modulo11( cNNumSDig ) ) )
		cNNum := cNNumSDig + AllTrim( modulo11( cNNumSDig ) )

		//Nosso Numero para impressao
		//cNossoNum := cCarteira + '/' + Substr(cNrDoc,1,2)+"/"+Substr(cNrDoc,3,9) + '-' + AllTrim( Str( modulo11( cNNumSDig ) ) )
		cNossoNum := StrZero(Val(cCarteira),2) + '/'+ Right(cNrDoc,11) + '-' + AllTrim( modulo11( cNNumSDig,"237" ) )

		//cCpoLivre := "8888" + "09" + "12345678901" + "7777777" + "0"   

		cCpoLivre := cAgencia + STRZERO(val(cCarteira),2) + Right(cNrDoc,11) + "0" + StrZero(Val(alltrim(cConta)),6) + "0" //tg tirar espaco

		//cCpoLivre := cAgencia + Right(cCarteira,2) + cNrDoc + StrZero(Val(cConta),7) + "0"       

		//cCpoLivre := strzero(val(substr(cAgencia,1,3)),4) + Right(cCarteira,2) + substr(digv,3,11) + StrZero(Val(cConta),7) + "0"       
		//cCpoLivre := cConta + cDvConta + substr(cNNum,3,3) + cTipCobr + substr(cNNum,6,3) + "4" + substr(cNNum,9,9) + Modulo10(cNNum,2,9)
		//cCpoLivre := cNNumSDig+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) ) ) )+"000"

	Elseif Substr(cBanco,1,3)$("341")  // Banco Itau
		//Nosso Numero sem digito
		cNNumSDig := cCarteira+strzero(val(/*cNroDoc*/cSequencial),/*6*/8)/*+ _cParcela*/
		//MSGALERT("CART"+cCarteira+" "+strzero(val(/*cNroDoc*/cSequencial),/*6*/8))

		//Nosso Numero
		cNNum := cCarteira+strzero(val(/*cNroDoc*/cSequencial),/*6*/8) /*+_cParcela*/ + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )
		//Nosso Numero para impressao
		cNossoNum := cCarteira+"/"+strzero(val(/*cNroDoc*/cSequencial),/*6*/8)/*+_cParcela*/ +'-' + AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) + cNNumSDig ) ) )

		cCpoLivre := cNNumSDig+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) ) ) )+"000"
		//msgalert("xx"+cNNumSDig+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+cNNumSDig ) ) )+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5)+AllTrim( Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),5) ) ) )+"000")



	Elseif Substr(cBanco,1,3) == "453"  // Banco rural
		//Nosso Numero sem digito
		cNNumSDig := strzero(val(cSequencial),7)
		//Nosso Numero
		cNNum := cNNumSDig + AllTrim( Str( modulo10( cNNumSDig ) ) )
		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ AllTrim( Str( modulo10( cNNumSDig ) ) )

		cCpoLivre := "0"+StrZero(Val(cAgencia),3) + StrZero(Val(cConta),10)+cNNum+"000"

	Elseif Substr(cBanco,1,3) == "399"  // Banco HSBC
		//Nosso Numero sem digito
		cNNumSDig := StrZero(Val(SubStr(cConvenio,1,5)),5)+strzero(val(cSequencial),5)
		//Nosso Numero
		cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

		cCpoLivre := cNNum+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+"001"

	Elseif Substr(cBanco,1,3) == "422"  // Banco Safra
		//Nosso Numero sem digito
		cNNumSDig := strzero(val(cSequencial),8)
		//Nosso Numero
		cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

		cCpoLivre := "7"+StrZero(Val(cAgencia),4) + StrZero(Val(cConta),10)+cNNum+"2"

	Elseif Substr(cBanco,1,3) == "479" // Banco Boston
		cNumSeq := strzero(val(cSequencial),8)            
		cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
		//Nosso Numero sem digito
		cNNumSDig := strzero(val(cSequencial),8)  	 
		//Nosso Numero
		cNNum := cNNumSDig + modulo11(cNNumSDig,SubStr(cBanco,1,3))
		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ modulo11(cNNumSDig,SubStr(cBanco,1,3))

		cCpoLivre := cCodEmp+"000000"+cNNum+"8"

	Elseif Substr(cBanco,1,3) == "409" // Banco UNIBANCO
		cNumSeq := strzero(val(cSequencial),10)            
		cCodEmp := StrZero(Val(SubStr(cConvenio,1,9)),9)
		//Nosso Numero sem digito
		cNNumSDig := strzero(val(cSequencial),10)  	 
		//Nosso Numero
		_cDigito := modulo11(cNNumSDig,SubStr(cBanco,1,3))
		//Calculo do super digito
		_cSuperDig := modulo11("1"+cNNumSDig + _cDigito,SubStr(cBanco,1,3))
		cNNum := "1"+cNNumSDig + _cDigito + _cSuperDig
		//Nosso Numero para impressao
		cNossoNum := "1/" + cNNumSDig + "-" + _cDigito + "/" + _cSuperDig
		// O codigo fixo "04" e para a combranco som registro
		cCpoLivre := "04" + SubStr(DtoS(dvencimento),3,6) + StrZero(Val(StrTran(_cAgCompleta,"-","")),5) + cNNumSDig + _cDigito + _cSuperDig

	Elseif Substr(cBanco,1,3) == "356" // Banco REAL
		cNumSeq := strzero(val(cNumSeq),13)
		//Nosso Numero sem digito
		cNNumSDig := cNumSeq
		//Nosso Numero
		cNNum := cNumSeq
		//Nosso Numero para impressao
		cNossoNum := cNNum
		cCpoLivre := StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7) + AllTrim(Str( modulo10( StrZero(Val(cAgencia),4) + StrZero(Val(cConta),7)+cNNumSDig ) ) ) + cNNumSDig

	ElseIf Substr(cBanco,1,3) == "104" //Incluido por Barbieri

		cNumSeq   := cSequencial
		//cNumSeq := strzero(val(right(cNumSeq,18)),18)
		//Nosso Numero completo sem digito
		cNNumSDig := cNumSeq
		//Nosso Numero com dígito
		cNNum := substr(cNNumSDig,1,2) + substr(cNNumSDig,3,18)
		//Nosso Numero para impressao com dígito
		cNossoNum := cNNum +"-"+ sMod11(cNNum,2,9) 

		//cCpoLivre := cConta + cDvConta + substr(cNNum,3,3) + cTipCobr + substr(cNNum,6,3) + "4" + substr(cNNum,9,9) + sMod11(cNNum,2,9)
		cCpoLivre := cConvenio+Modulo11(cConvenio,'104')+substr(cNumSeq,3,3)+cTipCobr+substr(cNumSeq,6,3)+"4"+substr(cNumSeq,9,9)+sMod11(cNumSeq,2,9)
	Endif	
	
	If Substr(cBanco,1,3) == "033"
    
		cNumSeq := strzero(val(cNumSeq),12)
		//Nosso Numero sem digito
		cNNumSDig := cNumSeq
		//Nosso Numero
		cNNum := cNumSeq
		//Nosso Numero para impressao
		cNossoNum := cNNumSDig +"-"+ sMod11(cNNumSDig,2,9) 


 	cPos1 := Substr(cBanco,1,3) + "9"   //banco + 9 1 a 4
 	
 	cpos2 := cFatVenc // fator vencimento 6  a 9
 	
 	cPos3 := blvalorfinal  //valor nominal 10 a 19
 	
 	cPos4 := "9"   // posição 20 valor 9 fixo 
 	
 	cPos5 := cConvenio  //codigo do cedente santander 21-27
 	
 	cPos6 := cNumSeq + sMod11(cNumSeq,2,9) //nosso numero + digito verificador Pos 28 a 40   
 	
 	cPos7 := "0" //posição 41 0 fixo 
 	
 	cPos8 := "101"
 	
 	cPos9 := cPos1 +cPos2 +cPos3 +cPos4 +cPos5 +cPos6 +cPos7 +cPos8    
 	
 	cDigFull := Modulo11(cPos1 +cPos2 +cPos3 +cPos4 +cPos5 +cPos6 +cPos7 +cPos8 ) 
 	
 	cPosFull := cPos1 +cDigFull + cPos2 +cPos3 +cPos4 +cPos5 +cPos6 +cPos7 +cPos8

	cCodBarra := cPosFull
	
	    vCod1 := substr(cCodBarra,1,4)+ substr(cCodBarra,20,5)
		vCod2 := MOD10(vCod1)
		vCod3 := substr(cCodBarra,25,10)
		vCod4 := MOD10(vCod3)
		vCod5 := substr(cCodBarra,35,10)
		vCod6 := MOD10(vCod5) 
		vCod7:= substr(cCodBarra,5,1)
		vCod8:= substr(cCodBarra,6,4)
		vCod9 := substr(cCodBarra,10,10)
		
	cLinDig := vCod1+cValToChar(MOD10(vCod1))+vCod3+cValToChar(MOD10(vCod3))+vCod5+cValToChar(MOD10(vCod5)) +vCod7+vCod8+vCod9
	cLinDig := substr(cLinDig,1,5)+"."+substr(cLinDig,6,5)+"."+substr(cLinDig,11,5)+"."+substr(cLinDig,16,6);
	+"."+substr(cLinDig,22,5)+"."+substr(cLinDig,27,6)+" "+substr(cLinDig,33,1)+" "+substr(cLinDig,34,14)
	 	

	else
		
	//Dados para Calcular o Dig Verificador Geral
	cCBSemDig := cBanco + cFatVenc + blvalorfinal + cCpoLivre
	//Codigo de Barras Completo
	cCodBarra := cBanco + Modulo11(cCBSemDig) + cFatVenc + blvalorfinal + cCpoLivre
	//msgalert("aqui "+cBanco +" "+ Modulo11(cCBSemDig)+" " + cFatVenc+" " + blvalorfinal+" " + cCpoLivre)
	//                 3419         7                         7274           0000805200
	//msgalert("codbar "+cBanco+" " + Modulo11(cCBSemDig)+" " + cFatVenc+" " + blvalorfinal+" " + cCpoLivre)

	//Digito Verificador do Primeiro Campo                  

	//msgalert("codigo "+cCodBarra)
	//msgalert("codigo "+cBanco + SubStr(cCodBarra,20,5))

	cPrCpo := cBanco + SubStr(cCodBarra,20,5)
	cDvPrCpo := AllTrim(Str(Modulo10(cPrCpo)))

	//Digito Verificador do Segundo Campo
	cSgCpo := SubStr(cCodBarra,25,10)
	cDvSgCpo := AllTrim(Str(Modulo10(cSgCpo)))

	//Digito Verificador do Terceiro Campo
	cTrCpo := SubStr(cCodBarra,35,10)
	cDvTrCpo := AllTrim(Str(Modulo10(cTrCpo)))

	//Digito Verificador Geral
	cDvGeral := SubStr(cCodBarra,5,1)

	//Linha Digitavel
	cLindig := SubStr(cPrCpo,1,5) + "." + SubStr(cPrCpo,6,4) + cDvPrCpo + " "   //primeiro campo
	cLinDig += SubStr(cSgCpo,1,5) + "." + SubStr(cSgCpo,6,5) + cDvSgCpo + " "   //segundo campo
	cLinDig += SubStr(cTrCpo,1,5) + "." + SubStr(cTrCpo,6,5) + cDvTrCpo + " "   //terceiro campo
	cLinDig += " " + cDvGeral              //dig verificador geral
	cLinDig += "  " + SubStr(cCodBarra,6,4)+SubStr(cCodBarra,10,10)  // fator de vencimento e valor nominal do titulo
	//cLinDig += "  " + cFatVenc +blvalorfinal  // fator de vencimento e valor nominal do titulo
Endif

	Return({cCodBarra,cLinDig,cNossoNum})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³NumParcelaº Autor ³                    º Data ³  30/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Ajusta a parcela.                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function NumParcela(_cParcela)
	Local _cRet := ""
	If ASC(_cParcela) >= 65 .or. ASC(_cParcela) <= 90
		_cRet := StrZero(Val(Chr(ASC(_cParcela)-16)),2)
	Else
		_cRet := StrZero(Val(_cParcela),2)
	Endif
Return(_cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³VALIDPERG º Autor ³                    º Data ³  03/05/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Verifica a existencia das perguntas criando-as caso seja   º±±
±±º          ³ necessario (caso nao existam).                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg()

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j   


	dbSelectArea("SX1")
	dbSetOrder(1)

	//cPerg := PADR(cPerg,6)
	aAdd(aRegs,{cPerg,"01","De Prefixo     ?","","","mv_ch1","C",TamSX3("E1_PREFIXO")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Prefixo    ?","","","mv_ch2","C",TamSX3("E1_PREFIXO")[1],0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Numero      ?","","","mv_ch3","C",TamSX3("F2_DOC")[1],0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Numero     ?","","","mv_ch4","C",TamSX3("F2_DOC")[1],0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","De Parcela     ?","","","mv_ch5","C",TamSX3("E1_PARCELA")[1],0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Parcela    ?","","","mv_ch6","C",TamSX3("E1_PARCELA")[1],0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","De Portador    ?","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA6BCO","","","",""})
	aAdd(aRegs,{cPerg,"08","Ate Portador   ?","","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","SA6BCO","","","",""})
	aAdd(aRegs,{cPerg,"09","De Cliente     ?","","","mv_ch9","C",TamSX3("A1_COD")[1],0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	aAdd(aRegs,{cPerg,"10","Ate Cliente    ?","","","mv_cha","C",TamSX3("A1_COD")[1],0,0,"G","","MV_PAR10","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
	aAdd(aRegs,{cPerg,"11","De Loja        ?","","","mv_chb","C",TamSX3("A1_LOJA")[1],0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Ate Loja       ?","","","mv_chc","C",TamSX3("A1_LOJA")[1],0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","De Emissao     ?","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Ate Emissao    ?","","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","De Vencimento  ?","","","mv_chf","D",8,0,0,"G","","MV_PAR15","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"16","Ate Vencimento ?","","","mv_chg","D",8,0,0,"G","","MV_PAR16","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"17","Do Bordero     ?","","","mv_chh","C",6,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"18","Ate Bordero    ?","","","mv_chi","C",6,0,0,"G","","MV_PAR18","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"19","SubConta       ?","","","mv_chj","C",3,0,1,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"20","Banco          ?","","","mv_chk","C",3,0,1,"G","","MV_PAR20","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
	aAdd(aRegs,{cPerg,"21","Agencia        ?","","","mv_chl","C",5,0,1,"G","","MV_PAR21","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"22","Conta          ?","","","mv_chm","C",10,0,1,"G","","MV_PAR22","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	//aAdd(aRegs,{cPerg,"20","Env.E-mail     ?","","","mv_chk","N",1,0,2,"C","","MV_PAR20","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)


Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³                       ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impres2(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

	LOCAL nI := 0
	LOCAL cMailDestino := Space(70)
	LOCAL oMailDestino
	LOCAL _oDlg

	LOCAL cMsg 	  := " "

	Local cBitmap      := "\SYSTEM\001.BMP" // Logo da empresa


	oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/
	If aDadosBanco[1] != "104"
		nRow1 := 0

		tms_Line(oPrint,nRow1+0150,500,nRow1+0070, 500)
		tms_Line(oPrint,nRow1+0150,710,nRow1+0070, 710)

		If aDadosBanco[1] == "237"											// Incluido por Barbieri
			cBitmap      := "\SYSTEM\LOGOBRADESCO.JPG"   					// Logo do Banco
			oPrint:SayBitMap(nRow1+0084,100,cBitMap,0250,0066)
		Elseif aDadosBanco[1] == "001"										// Incluido por Barbieri
			cBitmap      := "\SYSTEM\LOGOBB.JPG"   							// Logo do Banco
			oPrint:SayBitMap(nRow1+0084,100,cBitMap,0250,0066)
		ElseIf aDadosBanco[1] == "104"                                      // Incluido por Barbieri
			cBitmap      := "\SYSTEM\LOGOCAIXA.JPG"   						// Logo do Banco
			oPrint:SayBitMap(nRow1+0084,100,cBitMap,0250,0066)
		ElseIf aDadosBanco[1] == "033"                                      // Incluido por Barbieri
			cBitmap      := "\SYSTEM\LOGOSANTANDER.JPG"   					// Logo do Banco
			oPrint:SayBitMap(nRow1+0084,100,cBitMap,0250,0066)
		ElseIf aDadosBanco[1] == "341"                                      // Incluido por Barbieri
			cBitmap      := "\SYSTEM\LOGOITAU.JPG"   						// Logo do Banco
			oPrint:SayBitMap(nRow1+0084,100,cBitMap,0250,0066)
		Else
			oPrint:Say  (nRow1+0084,100,aDadosBanco[2],oFont13 )			// [2]Nome do Banco
		EndIf

		If aDadosBanco[1] $ "341/033"
			oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-7",oFont20 )		// [1]Numero do Banco
		ElseIf aDadosBanco[1] $ "409/104" // Incluido por Barbieri
			If aDadosBanco[1] == '104'
				oPrint:Say  (nRow1+0075,511.3,aDadosBanco[1]+"-0",oFont21 )	// 	[1]Numero do Banco
			Else
				oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-0",oFont20 )	// 	[1]Numero do Banco
			EndIf
		ElseIf aDadosBanco[1] == "237"
			oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-2",oFont20 )	// 	[1]Numero do Banco
		Else
			oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-9",oFont20 )		// [1]Numero do Banco
		Endif

		oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
		tms_Line(oPrint,nRow1+0150,100,nRow1+0150,2300)

		If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" .or. aDadosBanco[1] == "104" // Incluido por Barbieri
			oPrint:Say  (nRow1 + 0150, 100 ,"Beneficiário",oFont8)
			//oPrint:Say  (nRow1 + 0150, 300 , alltrim(aDadosEmp[1])																, oFont8) //Nome + CNPJ
		Else
			oPrint:Say  (nRow1+0150,100 ,"Cedente",oFont8)
		EndIf

		// ALTERACAO
		//oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ
		oPrint:Say  (nRow1 + 0190, 100 , alltrim(aDadosEmp[1])																, oFont8) //Nome + CNPJ
		oPrint:Say  (nRow1 + 0225, 100 , alltrim(aDadosEmp[2]) + "-" + alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4])	, oFont5) //Nome + CNPJ
		//oPrint:Say  (nRow1 + 0190, 100 , alltrim(aDadosEmp[2])								, oFont7) //Nome + CNPJ
		//oPrint:Say  (nRow1 + 0225, 100 , alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4]), oFont7) //Nome + CNPJ

		/*
		SM0->M0_ENDCOB																          ,;	//	[2]	Endereço
		AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,;	//	[3]	Complemento
		"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)			    ,;	//	[4]	CEP
		*/


		If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" .or. aDadosBanco[1] == "104" // Incluido por Barbieri
			oPrint:Say  (nRow1+0150,1060,"Agência/Código Beneficiário",oFont8)
		Else
			oPrint:Say  (nRow1+0150,1060,"Agência/Código Cedente",oFont8)
		EndIf

		// alterado em 16.09.2010 - incluido o digito da agencia para o banco do brasil
		If aDadosBanco[1] == "001"
			//oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"-"+aDadosBanco[7]+"/"+STR(VAL(aDadosBanco[4]),4)+"-"+aDadosBanco[5],oFont10)
			oPrint:Say  (nRow1+0200,1060,Alltrim(aDadosBanco[3]+"-"+aDadosBanco[7]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]),oFont10) 
		elseIf aDadosBanco[1] == "104"
			oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[11],oFont10)
		else
			oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
		endif

		oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
		oPrint:Say  (nRow1+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

		If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" .or. aDadosBanco[1] == "104" // Incluido por Barbieri
			oPrint:Say  (nRow1+0250,100 ,"Pagador",oFont8)
		Else
			oPrint:Say  (nRow1+0250,100 ,"Sacado",oFont8)
		EndIf 


		oPrint:Say  (nRow1+0300,100 ,left(aDatSacado[1],40),oFont10)				//Nome

		oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
		oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

		oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
		oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

		oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título"	,oFont10 )
		oPrint:Say  (nRow1+0450,0100,"com as características acima."	,oFont10 )
		oPrint:Say  (nRow1+0350,1060,"Data"								,oFont8  )
		oPrint:Say  (nRow1+0350,1410,"Assinatura"						,oFont8  )
		oPrint:Say  (nRow1+0450,1060,"Data"								,oFont8  )
		oPrint:Say  (nRow1+0450,1410,"Entregador"						,oFont8  )

		tms_Line(oPrint,nRow1+0250, 100,nRow1+0250,1900 )
		tms_Line(oPrint,nRow1+0350, 100,nRow1+0350,1900 )
		tms_Line(oPrint,nRow1+0450,1050,nRow1+0450,1900 )
		tms_Line(oPrint,nRow1+0550, 100,nRow1+0550,2300 )

		tms_Line(oPrint,nRow1+0550,1050,nRow1+0150,1050 )
		tms_Line(oPrint,nRow1+0550,1400,nRow1+0350,1400 )
		tms_Line(oPrint,nRow1+0350,1500,nRow1+0150,1500 )
		tms_Line(oPrint,nRow1+0550,1900,nRow1+0150,1900 )

		oPrint:Say  ( nRow1+0165,1910,"(  )Mudou-se"					,oFont8 )
		oPrint:Say  ( nRow1+0205,1910,"(  )Ausente"						,oFont8 )
		oPrint:Say  ( nRow1+0245,1910,"(  )Não existe nº indicado"		,oFont8 )
		oPrint:Say  ( nRow1+0285,1910,"(  )Recusado"					,oFont8 )
		oPrint:Say  ( nRow1+0325,1910,"(  )Não procurado"				,oFont8 )
		oPrint:Say  ( nRow1+0365,1910,"(  )Endereço insuficiente"		,oFont8 )
		oPrint:Say  ( nRow1+0405,1910,"(  )Desconhecido"				,oFont8 )
		oPrint:Say  ( nRow1+0445,1910,"(  )Falecido"					,oFont8 )
		oPrint:Say  ( nRow1+0485,1910,"(  )Outros(anotar no verso)"		,oFont8 )

	Endif
	/*****************/
	/* SEGUNDA PARTE */
	/*****************/
	If aDadosBanco[1] == "104" //incluido por Barbieri
		nRow2 := -571
	Else
		nRow2 := 0
	Endif
                                                      
	tms_Line(oPrint,nRow2+0710,100,nRow2+0710,2300)
	tms_Line(oPrint,nRow2+0710,500,nRow2+0630, 500)
	tms_Line(oPrint,nRow2+0710,710,nRow2+0630, 710)

	If aDadosBanco[1] == "237"											// Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOBRADESCO.JPG"   					// Logo do Banco
		oPrint:SayBitMap(nRow2+0644,100,cBitMap,0250,0066)
	Elseif aDadosBanco[1] == "001"										// Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOBB.JPG"   							// Logo do Banco
		oPrint:SayBitMap(nRow2+0644,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "104"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOCAIXA.JPG"   						// Logo do Banco
		oPrint:SayBitMap(nRow2+0644,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "033"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOSANTANDER.JPG"   					// Logo do Banco
		oPrint:SayBitMap(nRow2+0644,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "341"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOITAU.JPG" 		  					// Logo do Banco
		oPrint:SayBitMap(nRow2+0644,100,cBitMap,0250,0066)
	Else
		oPrint:Say  (0644,100,aDadosBanco[2],oFont13 )		// [2]Nome do Banco
	EndIf

	If aDadosBanco[1] $ "341/033"
		oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-7",oFont20 )	// [1]Numero do Banco
	ElseIf aDadosBanco[1] $ "104/409" // Incluido por Barbieri
		If aDadosBanco[1] == '104'
			oPrint:Say  (nRow2+0634,511.3,aDadosBanco[1]+"-0",oFont21 )	// 	[1]Numero do Banco
		Else
			oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-0",oFont20 )	// 	[1]Numero do Banco
		EndIf
	ElseIf aDadosBanco[1] == "237"
		oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-2",oFont20 )	// 	[1]Numero do Banco
	Else
		oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-9",oFont20 )	// [1]Numero do Banco
	EndIf

	If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" .or. aDadosBanco[1] == "104" // Incluido por Barbieri 
		If aDadosBanco[1] == "104"
			oPrint:Say(nRow2+0644,735,aCB_RN_NN[2],oFont15n)			//		Linha Digitavel do Codigo de Barras
		Else
			oPrint:Say  (nRow2+0644,1800,"Recibo do Pagador",oFont10)
		EndIf
	Else
		oPrint:Say  (nRow2+0644,1800,"Recibo do Sacado",oFont10)
	EndIf

	If aDadosBanco[1] == "104" //Incluido por Barbieri
		tms_Line(oPrint,nRow2+0810,100,nRow2+0810,2300 )
		tms_Line(oPrint,nRow2+0910,100,nRow2+0910,2300 )
		tms_Line(oPrint,nRow2+1010,100,nRow2+1010,2300 )
		tms_Line(oPrint,nRow2+1110,100,nRow2+1110,2300 )
		tms_Line(oPrint,nRow2+1210,100,nRow2+1210,1300 )

		tms_Line(oPrint,nRow2+0810,500,nRow2+0910,500)
		//tms_Line(oPrint,nRow2+0880,750,nRow2+09,750)
		tms_Line(oPrint,nRow2+0810,1000,nRow2+0910,1000)
		tms_Line(oPrint,nRow2+0810,1300,nRow2+0910,1300)
		//tms_Line(oPrint,nRow2+0810,1480,nRow2+1050,1480)
		tms_Line(oPrint,nRow2+0710,1800,nRow2+1010,1800 )
		tms_Line(oPrint,nRow2+1110,1300,nRow2+1410,1300 )
	Else
		tms_Line(oPrint,nRow2+0810,100,nRow2+0810,2300 )
		tms_Line(oPrint,nRow2+0910,100,nRow2+0910,2300 )
		tms_Line(oPrint,nRow2+0980,100,nRow2+0980,2300 )
		tms_Line(oPrint,nRow2+1050,100,nRow2+1050,2300 )

		tms_Line(oPrint,nRow2+0910,500,nRow2+1050,500)
		tms_Line(oPrint,nRow2+0980,750,nRow2+1050,750)
		tms_Line(oPrint,nRow2+0910,1000,nRow2+1050,1000)
		tms_Line(oPrint,nRow2+0910,1300,nRow2+0980,1300)
		tms_Line(oPrint,nRow2+0910,1480,nRow2+1050,1480)
	Endif

	If aDadosBanco[1] == "104" //Incluido por Barbieri
		oPrint:Say  (nRow2+0710,100 ,"Pagador",oFont8)
	Else
		oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
	Endif
	If aDadosBanco[1] == "237"
		oPrint:Say  (nRow2+0725,400 ,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
	Elseif aDadosBanco[1] == "341"
		oPrint:Say  (nRow2+0725,400 ,"Até o vencimento, preferencialmente no Itaú. Após o vencimento, somente no Itaú.",oFont10)
		oPrint:Say  (nRow2+0765,400 ," ",oFont10)
	Elseif aDadosBanco[1] == "033"
		oPrint:Say  (nRow2+0725,400 ,"Pagável preferencialmente nas agências do Banco Santander.",oFont10)
		oPrint:Say  (nRow2+0765,400 ," ",oFont10)
	Elseif aDadosBanco[1] == "104" // Incluido por Barbieri
		//oPrint:Say  (nRow2+0750,100 ,"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE",oFont10)
		oPrint:Say  (nRow2+0750,100 ,LEFT(aDatSacado[1],45)+" ("+aDatSacado[2]+")",oFont10)
		oPrint:Say  (nRow2+0765,100 ," ",oFont10)
	else
		oPrint:Say  (nRow2+0725,400 ,"Pagavél em qualquer Banco até o vencimento",oFont10)
		oPrint:Say  (nRow2+0765,400 ," ",oFont10)
	EndIf

	If aDadosBanco[1] == "104" //incluido por Barbieri
		oPrint:Say  (nRow2+0710,1810,"CPF/CNPJ do Pagador",oFont8)
		if aDatSacado[8] = "J"
			oPrint:Say  (nRow2+0750,1810,TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
		Else
			oPrint:Say  (nRow2+0750,1810,TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
		EndIf
	Else
		oPrint:Say  (nRow2+0710,1810,"Vencimento",oFont8)
		cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
		nCol := 1810+(374-(len(cString)*22))
		oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)
	Endif

	If aDadosBanco[1] == "341" .or. aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237" //.or. aDadosBanco[1] == "104" // Incluido por Barbieri 
		oPrint:Say  (nRow2+0810,100 ,"Beneficiário",oFont8)
		oPrint:Say  (nRow2+0850,100 ,alltrim(aDadosEmp[1])+"-"+alltrim(aDadosEmp[6]),oFont10) //Nome + CNPJ
		//oPrint:Say  (nRow2+0850,100 ,Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+;
		//Subs(SM0->M0_CGC,13,2)+"-"+alltrim(SM0->M0_CGC),oFont10) 

		// endereço so para bradesco - claudio 19/03/18 TG
		IF aDadosBanco[1] == "237"
			//oPrint:Say  (nRow2+0880,100 ,alltrim(aDadosEmp[2]) + "-" + alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4]), oFont8) //Nome + CNPJ
			oPrint:Say  (nRow1 + 0880, 100 , alltrim(aDadosEmp[2]) + "-" + alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4])	, oFont5) //Nome + CNPJ

		ENDIF

	ElseIf aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow2+0910,100 ,"Beneficiário",oFont8)
		oPrint:Say  (nRow2+0950,100 ,alltrim(aDadosEmp[1]),oFont10) //Nome
		oPrint:Say  (nRow2+1010,100 ,"Endereço do Beneficiário",oFont8)
		//oPrint:Say  (nRow2+1050,100 ,alltrim(aDadosEmp[2]),oFont10) //Endereço
		oPrint:Say  (nRow2+1050,100 , alltrim(aDadosEmp[2]) + "-" + alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4])	, oFont10) //incluido TG 21/03/18

		oPrint:Say  (nRow2+1110,100 ,"Agência/Código do Beneficiário",oFont8)
	Else
		oPrint:Say  (nRow2+0810,100 ,"Cedente",oFont8)
		oPrint:Say  (nRow2+0850,100 ,alltrim(aDadosEmp[1])+"-"+alltrim(aDadosEmp[6]),oFont10) //Nome + CNPJ
	EndIf

	If aDadosBanco[1] == "341" .or. aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237" //.or. aDadosBanco[1] == "104" // Incluido por Barbieri 
		oPrint:Say  (nRow2+0810,1810,"Agência/Código Beneficiário",oFont8)
	ElseIf aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow2+0910,1810,"CPF/CNPJ do Beneficiário",oFont8)
		oPrint:Say  (nRow2+0950,1810,alltrim(substr(aDadosEmp[6],7,len(aDadosEmp[6]))),oFont10) //CNPJ
	Else
		oPrint:Say  (nRow2+0810,1810,"Agência/Código Cedente",oFont8)
	EndIf

	If aDadosBanco[1] == "104" //incluido por Barbieri
		cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[11]+"-"+Modulo11(aDadosBanco[3] + aDadosBanco[11],'104'))
	Else
		//cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[7]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])//
		cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
	Endif

	If aDadosBanco[1] == "104" //incluido por Barbieri
		//oPrint:Say  (nRow2+1160,100,cString,oFont10) tg
	Else
		nCol := 1810+(374-(len(cString)*22))
		oPrint:Say  (nRow2+0850,nCol,cString,oFont11c)
	Endif

	If aDadosBanco[1] == "104" //incluido por Barbieri
		oPrint:Say  (nRow2+0810,100 ,"Nosso Número",oFont8)

		oPrint:Say  (nRow2+0810,505 ,"Nro.Documento",oFont8)
		oPrint:Say  (nRow2+0850,505 ,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

		oPrint:Say  (nRow2+0810,1005,"Vencimento",oFont8n)
		cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
		nCol    := 0850+(374-(len(cString)*22))
		oPrint:Say  (nRow2+0850,nCol,cString,oFont10)

		oPrint:Say  (nRow2+0810,1305,"Valor do Documento",oFont8n)
		cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
		nCol := 1205+(374-(len(cString)*22))
		oPrint:Say  (nRow2+0850,nCol,cString ,oFont10)

		oPrint:Say  (nRow2+0810,1810,"Valor Cobrado",oFont8)
	Else
		oPrint:Say  (nRow2+0910,100 ,"Data do Documento",oFont8)
		oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

		oPrint:Say  (nRow2+0910,505 ,"Nro.Documento",oFont8)
		oPrint:Say  (nRow2+0940,605 ,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

		oPrint:Say  (nRow2+0910,1005,"Espécie Doc.",oFont8)
		//oPrint:Say  (nRow2+0940,1050,aDadosTit[8],oFont10) //Tipo do Titulo
		//Alterado em 28/06/2019 por Cristian Gutierrez. Solicitante Roberto Thomaz
		//If aDadosBanco[1] == "341"//
			//oPrint:Say  (nRow2+0940,1050,"DM",oFont10) //Tipo do Titulo  28.06.19 por Cristian Gutierrez.
		//Else//
			oPrint:Say  (nRow2+0940,1050,"R$",oFont10) //Tipo do Titulo  ALTERADO EM 16.09.2010
		//EndIf//
		oPrint:Say  (nRow2+0910,1305,"Aceite",oFont8)
		oPrint:Say  (nRow2+0940,1400,"N",oFont10)

		oPrint:Say  (nRow2+0910,1485,"Data do Processamento",oFont8)
		oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

		oPrint:Say  (nRow2+0910,1810,"Nosso Número",oFont8)
	Endif

	If aDadosBanco[1] == "001"
		cString := Alltrim(aCB_RN_NN[3])
		nCol 	:= 1810+(374-(len(cString)*22))
	ElseIf aDadosBanco[1] == "104"
		cNNCEFa := aDadosTit[9]
		cNNCEF  := substr(cNNCEFa,1,2) + substr(cNNCEFa,4,18)
		cString := Alltrim(cNNCEFa) + "-" + sMod11(cNNCEF,2,9)
		nCol 	:= 150+(374-(len(cString)*22)) //Incluido por Barbieri
	Else
		cString := Alltrim(aDadosTit[6])
		nCol 	:= 1810+(374-(len(cString)*22))
	EndIf

	If aDadosBanco[1] == "104" //Incluido por Barbieri
		oPrint:Say  (nRow2+0850,nCol,cString,oFont10) //nosso numero
	Else
		oPrint:Say  (nRow2+0940,nCol,cString,oFont11c)
	Endif

	If aDadosBanco[1] != '104' // Incluido por Barbieri
		oPrint:Say  (nRow2+0980,100 ,"Uso do Banco",oFont8)

		oPrint:Say  (nRow2+0980,505 ,"Carteira",oFont8)

		If aDadosBanco[1] == '237'
			oPrint:Say  (nRow2+1010,555 ,substr(aDadosBanco[6],1,2),oFont10)
		elseIf aDadosBanco[1] == '104'
			//oPrint:Say  (nRow2+1010,555 ,IIF(aDadosBanco[10]=='1','RG','SR'),oFont10)
			oPrint:Say  (nRow2+1010,555 ,'RG',oFont10)
		else
			oPrint:Say  (nRow2+1010,555 ,aDadosBanco[6],oFont10)
		endif

		oPrint:Say  (nRow2+0980,755 ,"Espécie",oFont8)
		oPrint:Say  (nRow2+1010,805 ,"R$",oFont10)

		oPrint:Say  (nRow2+0980,1005,"Quantidade",oFont8)
		oPrint:Say  (nRow2+0980,1485,"Valor"     ,oFont8)

		oPrint:Say  (nRow2+0980,1810,"Valor do Documento",oFont8)
		cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
		nCol := 1810+(374-(len(cString)*22))
		oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

		//oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
	Endif

	If aDadosBanco[1] == "341"
		oPrint:Say  (nRow2+1050,100 ,"Instruções de responsabilidade do BENEFICIÁRIO. Qualquer duvida sobre este boleto, contade o BENEFICIÁRIO",oFont8)
	Elseif aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237" 
		oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)
	Elseif aDadosBanco[1] == "104" // Incluido por Barbieri 
		oPrint:Say  (nRow2+1220,100 ,"SAC CAIXA: ",oFont8n)
		oPrint:Say  (nRow2+1220,270 ,"0800 726 0101 (informações, reclamações, sugestões e elogios)",oFont8)

		oPrint:Say  (nRow2+1260,100 ,"Para pessoas com deficiência auditiva ou de fala: ",oFont8n)
		oPrint:Say  (nRow2+1260,770 ,"0800 726 2492",oFont8)

		oPrint:Say  (nRow2+1300,100 ,"Ouvidoria: ",oFont8n)
		oPrint:Say  (nRow2+1300,270 ,"0800 725 7474",oFont8)

		oPrint:Say  (nRow2+1340,100 ,"caixa.gov.br",oFont8)

		oPrint:Say  (nRow2+1110,1305,"Autenticação Mecânica - ",oFont8)
		oPrint:Say  (nRow2+1110,1615,"Recibo do Pagador",oFont8n)
	Else
		oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
	EndIf

	oPrint:Say  (nRow2+1150,100 ,aBolText[1] /*/+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))       /*/,oFont10)
	oPrint:Say  (nRow2+1200,100 ,aBolText[2] /*/+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  /*/,oFont10)
	oPrint:Say  (nRow2+1250,100 ,aBolText[3],oFont10)
	oPrint:Say  (nRow2+1300,100 ,aBolText[4],oFont10)

	If aDadosBanco[1] != "104" // incluido por Barbieri 
		oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento",oFont8)
		oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"    ,oFont8)
		oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"         ,oFont8)
		oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"  ,oFont8)
		oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"      ,oFont8)


		If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" //.or. aDadosBanco[1] == "104" //Incluido por Barbieri
			oPrint:Say  (nRow2+1400,100 ,"Pagador",oFont8)
		Else
			oPrint:Say  (nRow2+1400,100 ,"Sacado",oFont8)
		EndIf

		oPrint:Say  (nRow2+1430,400 ,LEFT(aDatSacado[1],45)+" ("+aDatSacado[2]+")",oFont10)
		oPrint:Say  (nRow2+1483,400 ,aDatSacado[3],oFont10)
		oPrint:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

		if aDatSacado[8] = "J"
			oPrint:Say  (nRow2+1430,1750 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
		Else
			oPrint:Say  (nRow2+1430,1750 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
		EndIf

		If aDadosBanco[1] == "409"
			oPrint:Say  (nRow2+1589,1850,aDadosTit[6],oFont10)
		ElseIf aDadosBanco[1] == "104"  
			oPrint:Say  (nRow2+1589,1850,"CPF/CNPJ: ",oFont8) 
		ElseIf aDadosBanco[1] == "033"
	   		oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)
		Else
			oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+" "+Substr(aDadosTit[6],4)  ,oFont10)
		EndIf

		If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" 
			oPrint:Say  (nRow2+1605,100 ,"Pagador/Avalista",oFont8)
		Else
			oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8)
		EndIf

		oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

	Endif

	If aDadosBanco[1] != '104' // Incluido por Barbieri
		tms_Line(oPrint,nRow2+0710,1800,nRow2+1400,1800 )
		tms_Line(oPrint,nRow2+1120,1800,nRow2+1120,2300 )
		tms_Line(oPrint,nRow2+1190,1800,nRow2+1190,2300 )
		tms_Line(oPrint,nRow2+1260,1800,nRow2+1260,2300 )
		tms_Line(oPrint,nRow2+1330,1800,nRow2+1330,2300 )
		tms_Line(oPrint,nRow2+1400,100 ,nRow2+1400,2300 )
		tms_Line(oPrint,nRow2+1640,100 ,nRow2+1640,2300 )
	Endif

	/******************/
	/* TERCEIRA PARTE */
	/******************/

	nRow3 := 170
	// Pontilhado separador
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
	Next nI

	tms_Line(oPrint,nRow3+2000,100,nRow3+2000,2300)
	tms_Line(oPrint,nRow3+2000,500,nRow3+1920, 500)
	tms_Line(oPrint,nRow3+2000,710,nRow3+1920, 710)

	If aDadosBanco[1] == "237"											// Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOBRADESCO.JPG"   					// Logo do Banco
		oPrint:SayBitMap(nRow3+1934,100,cBitMap,0250,0066)
	Elseif aDadosBanco[1] == "001"										// Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOBB.JPG"   							// Logo do Banco
		oPrint:SayBitMap(nRow3+1934,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "104"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOCAIXA.JPG"   						// Logo do Banco
		oPrint:SayBitMap(nRow3+1934,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "033"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOSANTANDER.JPG"   					// Logo do Banco
		oPrint:SayBitMap(nRow3+1934,100,cBitMap,0250,0066)
	ElseIf aDadosBanco[1] == "341"                                      // Incluido por Barbieri
		cBitmap      := "\SYSTEM\LOGOITAU.JPG"		   					// Logo do Banco
		oPrint:SayBitMap(nRow3+1934,100,cBitMap,0250,0066)
	Else
		oPrint:Say  (nRow3+1934,100,aDadosBanco[2],oFont13 )		// 	[2]Nome do Banco
	EndIf

	If aDadosBanco[1] $ "341/033"
		oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-7",oFont20 )	// 	[1]Numero do Banco
	ElseIf aDadosBanco[1] $ "409/104" // Incluido por Barbieri
		If aDadosBanco[1] == '104'
			oPrint:Say  (nRow3+1924,511.3,aDadosBanco[1]+"-0",oFont21 )	// 	[1]Numero do Banco
		Else
			oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-0",oFont20 )	// 	[1]Numero do Banco
		EndIf
	ElseIf aDadosBanco[1] == "237"
		oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-2",oFont20 )	// 	[1]Numero do Banco
	Else
		oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-9",oFont20 )	// 	[1]Numero do Banco
	EndIf


	If aDadosBanco[1] == '104'
		oPrint:Say(nRow3+1934,735,aCB_RN_NN[2],oFont15n)			//		Linha Digitavel do Codigo de Barras
	Else
		oPrint:Say(nRow3+1934,735,aCB_RN_NN[2],oFont16n)			//		Linha Digitavel do Codigo de Barras
	EndIf                                             

	tms_Line(oPrint,nRow3+2100,100,nRow3+2100,2300 )
	tms_Line(oPrint,nRow3+2200,100,nRow3+2200,2300 )
	tms_Line(oPrint,nRow3+2270,100,nRow3+2270,2300 )
	tms_Line(oPrint,nRow3+2340,100,nRow3+2340,2300 )

	tms_Line(oPrint,nRow3+2200,500 ,nRow3+2340,500 )
	tms_Line(oPrint,nRow3+2270,750 ,nRow3+2340,750 )
	tms_Line(oPrint,nRow3+2200,1000,nRow3+2340,1000)
	tms_Line(oPrint,nRow3+2200,1300,nRow3+2270,1300)
	tms_Line(oPrint,nRow3+2200,1480,nRow3+2340,1480)

	oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
	If aDadosBanco[1] == "237"
		oPrint:Say  (nRow3+2015,400 ,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
	Elseif aDadosBanco[1] == "341"
		oPrint:Say  (nRow3+2015,400 ,"Até o vencimento, preferencialmente no Itaú. Após o vencimento, somente no Itaú.",oFont10)
		oPrint:Say  (nRow3+2055,400 ," ",oFont10)
	Elseif aDadosBanco[1] == "033"
		oPrint:Say  (nRow3+2015,400 ,"Pagável preferencialmente nas agências do Banco Santander.",oFont10)
		oPrint:Say  (nRow3+2055,400 ," ",oFont10)
	Elseif aDadosBanco[1] == "104"
		oPrint:Say  (nRow3+2040,100 ,"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE.",oFont10)
		oPrint:Say  (nRow3+2055,100 ," ",oFont10)
	else
		oPrint:Say  (nRow3+2015,400 ,"Pagavél em qualquer Banco até o vencimento",oFont10)
		oPrint:Say  (nRow3+2055,400 ," ",oFont10)
	EndIf
	//oPrint:Say  (nRow3+2015,400 ,"Pagavél em qualquer Banco até o vencimento",oFont10)
	oPrint:Say  (nRow3+2055,400 ," ",oFont10)

	oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol	 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

	If aDadosBanco[1] == "341" .or. aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237"  .or. aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow3+2100,100 ,"Beneficiário",oFont8)
	Else
		oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
	EndIf

	If aDadosBanco[1] == "104" .or. aDadosBanco[1] == "237"// Incluido por Barbieri tg 
		oPrint:Say  (nRow3+2100,270 ,alltrim(aDadosEmp[1])+"-"+alltrim(aDadosEmp[6]),oFont10) //Nome + CNPJ
		//oPrint:Say  (nRow3+2140,100 ,alltrim(aDadosEmp[2]),oFont10) //Endereço
		oPrint:Say  (nRow3 + 2140, 100 , alltrim(aDadosEmp[2]) + "-" + alltrim(aDadosEmp[3]) + "-" + alltrim(aDadosEmp[4])	, oFont5) //Nome + CNPJ
	Elseif aDadosBanco[1] == "341" //TRATAMENTO ITAU
		oPrint:Say  (nRow3+2100,270 ,alltrim(aDadosEmp[1])+"-"+alltrim(aDadosEmp[6]),oFont10)
	Else
		oPrint:Say  (nRow3+2140,100 ,alltrim(aDadosEmp[1])+"-"+alltrim(aDadosEmp[6]),oFont10) //Nome + CNPJ
	Endif

	If aDadosBanco[1] == "341" .or. aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237" .or. aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow3+2100,1810,"Agência/Código Beneficiário",oFont8)
	Else
		oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
	EndIf

	If aDadosBanco[1] == "104"
		cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[11]+"-"+Modulo6(aDadosBanco[3] + aDadosBanco[11],'104')) //Incluido por Barbieri  TG ERA MODULO11
	Else
		cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
	Endif

	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)

	oPrint:Say  (nRow3+2200,100 ,"Data do Documento",oFont8)
	oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

	oPrint:Say  (nRow3+2200,505 ,"Nro.Documento",oFont8)
	oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow3+2200,1005,"Espécie Doc.",oFont8)
	oPrint:Say  (nRow3+2230,1050,"R$",oFont10) //Tipo do Titulo  -- alterado em 16.09.2010

	oPrint:Say  (nRow3+2200,1305,"Aceite",oFont8)
	oPrint:Say  (nRow3+2230,1400,"N"     ,oFont10)

	oPrint:Say  (nRow3+2200,1485,"Data do Processamento",oFont8)
	oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

	oPrint:Say  (nRow3+2200,1810,"Nosso Número",oFont8)

	If aDadosBanco[1] == "001"
		cString := Alltrim(aCB_RN_NN[3])
		nCol 	:= 1810+(374-(len(cString)*22))
	ElseIf aDadosBanco[1] == "104"
		cNNCEFa := aDadosTit[9]
		cNNCEF  := substr(cNNCEFa,1,2) + substr(cNNCEFa,4,18)
		cString := Alltrim(cNNCEFa) + "-" + sMod11(cNNCEF,2,9)
		nCol 	:= 1875+(374-(len(cString)*22)) //Incluido por Barbieri
	Else
		cString := Alltrim(aDadosTit[6])
		nCol 	:= 1810+(374-(len(cString)*22))
	EndIf

	oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)


	oPrint:Say  (nRow3+2270,100 ,"Uso do Banco",oFont8)

	oPrint:Say  (nRow3+2270,505 ,"Carteira",oFont8)


	If aDadosBanco[1] == '237'
		oPrint:Say  (nRow3+2300,555 ,substr(aDadosBanco[6],1,2),oFont10)
	ElseIf aDadosBanco[1] == '104'
		//oPrint:Say  (nRow3+2300,555 ,IIF(aDadosBanco[10]=='1','RG','SR'),oFont10)
		oPrint:Say  (nRow3+2300,555 ,'RG',oFont10)
	else
		oPrint:Say  (nRow3+2300,555 ,aDadosBanco[6],oFont10)
	endif

	oPrint:Say  (nRow3+2270,755 ,"Espécie",oFont8)
	oPrint:Say  (nRow3+2300,805 ,"R$"     ,oFont10)

	oPrint:Say  (nRow3+2270,1005,"Quantidade",oFont8)
	oPrint:Say  (nRow3+2270,1485,"Valor"     ,oFont8)

	oPrint:Say  (nRow3+2270,1810,"Valor do Documento",oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

	//oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
	If aDadosBanco[1] == "341"
		oPrint:Say  (nRow3+2340,100 ,"Instruções de responsabilidade do BENEFICIÁRIO. Qualquer duvida sobre este boleto, contade o BENEFICIÁRIO",oFont8)
	Elseif aDadosBanco[1] == "748" .or. aDadosBanco[1] == "237" 
		oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)
	Elseif aDadosBanco[1] == "104" // Incluido por Barbieri 
		oPrint:Say  (nRow3+2340,100 ,"Instruções (Texto de Responsabilidade do Beneficiário):",oFont8)	
	Else
		oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
	Endif

	oPrint:Say  (nRow3+2440,100 ,aBolText[1] /*/+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))      /*/,oFont10)
	oPrint:Say  (nRow3+2490,100 ,aBolText[2] /*/+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  /*/,oFont10)
	oPrint:Say  (nRow3+2540,100 ,aBolText[3],oFont10)
	oPrint:Say  (nRow3+2590,100 ,aBolText[4],oFont10)

	oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento",oFont8)
	oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"    ,oFont8)
	oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"         ,oFont8)
	oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"  ,oFont8)
	oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"      ,oFont8)

	If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" .or. aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow3+2690,100 ,"Pagador",oFont8)
	Else
		oPrint:Say  (nRow3+2690,100 ,"Sacado",oFont8)
	EndIf

	oPrint:Say  (nRow3+2700,400 ,LEFT(aDatSacado[1],45)+" ("+aDatSacado[2]+")",oFont10)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	IF aDadosBanco[1] == "104" // Incluido por Barbieri
		oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]+" - "+aDatSacado[4],oFont10)
		oPrint:Say  (nRow3+2753,1750 ,"UF: "+aDatSacado[5]+"   CEP: "+aDatSacado[6],oFont10) // UF+CEP
	Else
		oPrint:Say  (nRow3+2753,400 ,aDatSacado[3],oFont10)
		oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	Endif

	If aDadosBanco[1] == "409"
		oPrint:Say  (nRow3+2806,1750,aDadosTit[6] ,oFont10)
	ElseIf aDadosBanco[1] == "104"  
		oPrint:Say  (nRow3+2806,1850,"CPF/CNPJ: ",oFont8)
	ElseIf aDadosBanco[1] == "033"
		oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)
	Else
		oPrint:Say  (nRow3+2806,1850,Substr(aDadosTit[6],1,3)+" "+Substr(aDadosTit[6],4)  ,oFont10)
	EndIf

	If aDadosBanco[1] == "237" .or. aDadosBanco[1] == "341" 
		oPrint:Say  (nRow3+2815,100 ,"Pagador/Avalista",oFont8)
	Else
		oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista",oFont8)
	EndIf

	oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação",oFont8)

	tms_Line(oPrint,nRow3+2000,1800,nRow3+2690,1800)
	tms_Line(oPrint,nRow3+2410,1800,nRow3+2410,2300)
	tms_Line(oPrint,nRow3+2480,1800,nRow3+2480,2300)
	tms_Line(oPrint,nRow3+2550,1800,nRow3+2550,2300)
	tms_Line(oPrint,nRow3+2620,1800,nRow3+2620,2300)
	tms_Line(oPrint,nRow3+2690,100 ,nRow3+2690,2300)
	tms_Line(oPrint,nRow3+2850,100 ,nRow3+2850,2300)

	//MSBAR("INT25"  ,25.75,1, aCB_RN_NN[1] ,oPrint,.F.,,,0.029,1.3,,,,.F.)

	//MSBAR("INT25"  ,26.6,1.7, aCB_RN_NN[1] ,oPrint,.F.,,,0.028,1.3,,,,.F.)

	//MSBAR("INT25"  ,13.4,0.8, aCB_RN_NN[1] ,oPrint,.F.,,,0.018,0.7,,,,.F.)

	MSBAR("INT25"  ,26.6,1, aCB_RN_NN[1] ,oPrint,.F.,,,0.035,1.5,,,,.F.)

	//If Empty(SE1->E1_NUMBCO) //Caio de Castro - 10/08 - Somente atualiza faixa se não for reimpressão de boleto
	//	If ALltrim(SEE->EE_FAXATU) <> ALltrim(StrZero(Val(SEE->EE_FAXATU) + 1,12))
	//		DbSelectArea("SEE")
	//		RecLock("SEE",.f.)
	//			SEE->EE_FAXATU := StrZero(Val(SEE->EE_FAXATU) + 1,12)  //INCREMENTA P/ TODOS OS BANCOS
	//		SEE->(MsUnlock())
	//	EndIf
	//EndIf
    //
	//DbSelectArea("SE1")

	If aDadosBanco[1] == "001"
  
		//cNumBco := SubStr(Alltrim(aCB_RN_NN[3]),8,10)
		cNumBco := SubStr(Alltrim(aCB_RN_NN[3]),1,11)+SubStr(Alltrim(aCB_RN_NN[3]),13,1) //SubStr(Alltrim(aCB_RN_NN[3]),7,5)//Right(Alltrim(aCB_RN_NN[3]),10)
	ElseIf aDadosBanco[1] == "237"
		//cNumBco := SubStr(Alltrim(aCB_RN_NN[3]),4,11)//+SubStr(Alltrim(aCB_RN_NN[3]),16,1)//SubStr(Alltrim(aCB_RN_NN[3]),1,AT("-",Alltrim(aCB_RN_NN[3]))-1)//substr(digv,4,11)+substr(digv,16,1) //GRAVA NOSSO NUMERO NO TITULO
		cNumBco := SubStr(Alltrim(aCB_RN_NN[3]),6,9)+"-"+SubStr(Alltrim(aCB_RN_NN[3]),16,1)//validado dia 02/03/18

	ElseIf aDadosBanco[1] == "341"
		cNumBco := SubStr(aCB_RN_NN[3],5,10) //SubStr(aCB_RN_NN[3],5,8) // alterado em 12/06/12 para gravar o DAC tambem
	ElseIf aDadosBanco[1] == "033"
		cNumBco := Right(aCB_RN_NN[3],12)
	ElseIf aDadosBanco[1] == "104"
		cNumBco := StrZero(Val(Right(cNNumCEF+cFaixaAtu,15)),15) //Incluido por Barbieri
	EndIf

	If Alltrim(SE1->E1_NUMBCO) <> Alltrim(cNumBco) .or. Alltrim(SE1->E1_PORTADO) <> Alltrim(aDadosBanco[1]) .or.; 
	Alltrim(SE1->E1_AGEDEP)  <> Alltrim(cAgencia) .or. Alltrim(SE1->E1_CONTA) <> Alltrim(cConta)

		RecLock("SE1",.f.)

		If Empty(SE1->E1_NUMBCO) // inserido em 31/05/17 a pedido do Claudio
			SE1->E1_NUMBCO 	:= cNumBco //
		Endif	

		SE1->E1_PORTADO := aDadosBanco[1]//Banco
		SE1->E1_AGEDEP  := cAgencia			//Agencia
		SE1->E1_CONTA   := cConta		  //Conta
		SE1->(MsUnlock())

	EndIf

	oPrint:EndPage() // Finaliza a página

	//MS_FLUSH()

Return Nil

////////////////////////////////////////////////////////////////////////////////

Static Function tms_Line(oPrint,n1,n2,n3,n4)

	if n1 = n3
		oPrint:FillRect( {n1,n2,n3+2,n4}, oBrush1)
	Elseif n2 = n4
		oPrint:FillRect( {n1,n2,n3,n4}, oBrush1)
	endif

Return (NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ sMod11   ³ Autor ³ Wanderley Monteiro    ³ Data ³ 01/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o digito verificador com Modelo 11                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function sMod11(cStr,nPeso1,nPeso2) // módulo 11, com pesos nPeso1 (inicial) a nPeso2 (final), que
	local nTot := 0                     // serão utilizados no multiplicador dos dígitos, apanhados da
	local nMul := nPeso1                 // direita para a esquerda. Tal multiplicador será reciclado e
	local i                              // voltará para nPeso1, quando o limite (nPeso2) for atingido.

	for i := Len(cStr) to 1 step -1
		nTot += Val(SubStr(cStr,i,1)) * nMul
		nMul := if(nMul=nPeso2, nPeso1, nMul+1)
	next
return if(nTot%11 < 2, "0", Str(11-(nTot%11),1))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VerBco   ³ Autor ³                       ³ Data ³  Abr/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica informacoes de banco.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VerBco(cBanco)

	Local cAg		:= " "
	Local cCta		:= " "
	Local cSubCta 	:= " "
	Local cQuery	:= " "

	//Se existir mais de uma conta do mesmo banco que seja com registro, sera considerado o primeiro registro
	cQuery := "SELECT EE_AGENCIA AGENCIA,EE_CONTA CONTA,EE_SUBCTA SUBCTA "
	cQuery += " FROM "+RetSqlName("SEE")+" SEE "
	cQuery += " WHERE EE_FILIAL = '"+xFilial("SEE")+"' "
	cQuery += " AND EE_CODIGO = '"+cBanco+"' "
//	cQuery += " AND EE_XBOL =  1"
	cQuery += " AND SEE.D_E_L_E_T_ <> '*' "

	U_MONTAQRY(cQuery,"TRB")

	If Select("TRB") > 0

		cAg	:=  TRB->AGENCIA
		cCta	:= TRB->CONTA
		cSubCta := TRB->SUBCTA

		DbSelectArea("TRB")
		//DbCloseArea("TRB")

		("TRB") -> (DbCloseArea())

	EndIf

Return({cAg,cCta,cSubCta})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MontaQry  ³ Autor ³       TOTVS           ³ Data ³ Abr/2009  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Cria tabela temporaria com Select via query.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Varivel com a query desejada.                        ³±±
±±³          ³ ExpA2: Nome da tabela temporaria a ser criada.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numeros de registros retornados pela Select.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Exemplo da chamada da funcao

cQuery := "SELECT COUNT(*) "
cQuery += " FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "
cQuery += " WHERE SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQuery += " SA1.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A1_COD DESC "

U_MONTAQRY(cQuery,"TRB")
*/
User Function MontaQry(cSql,cAliasTRB)

	Local nCnt := 0
	Local bSql := ChangeQuery( cSql )

	// Verificar se o Alias ja esta aberto.
	If Select(cAliasTRB) > 0
		DbSelectArea(cAliasTRB)
		//DbCloseArea(cAliasTRB)
		(cAliasTRB) -> (DbCloseArea())
	EndIf

	//Grava o script da query no system
	//MemoWrit(Alltrim(FunName())+Alltrim(cAliasTRB)+".SQL",cSql)

	DbUseArea( .T., "TOPCONN", TcGenQry(,,bSql), cAliasTRB, .T., .F. )
	DbSelectArea(cAliasTRB)
	DbGoTop()

	// Conta quantos sao os registros retornados pelo Select.
	DbEval( {|| nCnt++ })      

	DbSelectArea(cAliasTRB)
	DbGoTop()        

Return(nCnt)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³                       ³ Data ³ 29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo6(cData,cBanc)
	Local L, D, P := 0  

	If cBanc == "104"  //CEF - Incluido por Barbieri
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0 
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 6 
				P := 1
			End
			L := L - 1
		End
		D := Mod(D*10,11)
		If D > 9 .or. D == 0
			D := 0
		End
		D := AllTrim(Str(D))

	Endif   

Return(D)     

Static Function Mod10(cData)
Local  L,D,P := 0
Local B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return D
