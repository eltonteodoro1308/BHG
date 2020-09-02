#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ
±±³Programa³ INFCONTRI³ Autor ³ Valéria Leal³ Data ³ 23/01/2020  	 ³±±
±±³Alterado : 								 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do arquivo cnab para retornar         ³±±
±±³                 ³  Informações Complementares - Campo 111-230.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CNAB:  SISPAG, 						 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function INFCONTRI()

local cCodre    := ""
local cContr    := ""
local cIdcon    := ""
local cTribu    := ""
local dPerio    := ""
local cRefer    := ""
local nValor    := 0
local nMultaJ   := 0
local dVencr	:= ""
Local _cReturn
Local cModelo 	 := ""
Local cBanco  	 := ""
Local cExerc	 := ""
Local cRenav	 := ""
Local cUF	     := ""
Local cMunic	 := ""
Local cPlaca	 := ""
Local cOppgt	 := ""
Local cTipo	     := ""  
local dVenc	     := ""
Local cCodBa	 := ""
/*
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Informações Complementares para o Modelo 16 (DARF -NORMAL) Campo 111-230³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/              

cModelo := ALLTRIM(SEA->EA_MODELO)
cBanco:= SA6->A6_COD

DO CASE

	CASE cModelo  == "16"
		
		cCodre  :=  PadL(SE2->E2_CODRET,4," ")
		cContr  := "01"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cTribu  := SEA->EA_MODELO
		dPerio  := SE2->E2_DTAPUR 
		cRefer  := SE2->E2_NROREF 
		cDtRefe := Substr( Dtos(SE2->E2_DTAPUR), 5, 2 ) + Substr( Dtos(SE2->E2_DTAPUR), 1, 4 )
		nValor  := SE2->E2_SALDO
		nMultaJ := SE2->E2_XMULTA
		nJuros  := SE2->E2_XJUROS
		dVencr  := SE2->E2_VENCREA
		dVenc   := SE2->E2_VENCTO
		cFille  := SPACE(018)  
		cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)       

	CASE  cModelo == "17"
				
		cCodre  :=  PadL(Alltrim(SE2->E2_CODRET),4,"0")
		cContr  := "01"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cTribu  := SEA->EA_MODELO
		dVencr  := SE2->E2_VENCREA
		dVenc   := SE2->E2_VENCTO		
		cInscr  := PadL(SM0->M0_INSC,12," ")
		cDivid  := Space(013)
		cDtRefe := Substr( Dtos(SE2->E2_DTAPUR), 5, 2 ) + Substr( Dtos(SE2->E2_DTAPUR), 1, 4 )
		dPerio  := SE2->E2_DTAPUR 
 		cParce  := SE2->E2_PARCELA 
		nValor  := SE2->E2_SALDO
 		nMultaJ := SE2->E2_SDACRES
		cFille  := SPACE(01) 
		cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)

	CASE  cModelo == "22"
				
		cCodre  :=  PadL(SE2->E2_CODRET,4," ")
		cContr  := "01"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cTribu  := SEA->EA_MODELO
		dVencr  := SE2->E2_VENCREA
		cInscr  := PadL(SM0->M0_INSC,12," ")
		cDivid  := Replicate("0",13)
		cDtRefe := Substr( Dtos(SE2->E2_DTAPUR), 5, 2 ) + Substr( Dtos(SE2->E2_DTAPUR), 1, 4 )
 		cParce  := SE2->E2_PARCELA 
		nValor  := SE2->E2_SALDO
 		nMultaJ := SE2->E2_SDACRES
		cFille  := SPACE(01) 
		cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)    
		
	CASE cModelo  == "35"
		
   	    cCodre  :=  PadL(SE2->E2_CODRET,4," ")
		cContr  := "02"
	    cIdcon  := PadL(SM0->M0_CGC,14," ")
		cTribu  := SEA->EA_MODELO
		//cCodBa  := SUBSTR(SE2->E2_CODBAR,1,48) 
		cCodBa  := SUBSTR(SE2->E2_LINDIG,1,48)
	    cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)
	    dVencr  := SE2->E2_VENCREA
	    nValor  := SE2->E2_SALDO + SE2->E2_SDACRES - SE2->E2_SDDECRE
		      
		
	/*CASE cModelo  == "25"
		
		cContr  := "07"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cExerc  := PadL(SE2->E2_XEXERC,4," ")   
		cRenav  := PadL(SE2->E2_XRENAV,9," ")
		cUF		:= PadL(SE2->E2_XUF,2," ")
		cMunic	:= PadL(SE2->E2_XMUNIC,5," ")   
		cPlaca	:= PadL(SE2->E2_XPLACA,7," ")
		cOppgt	:= PadL(SE2->E2_XOPPGT,1," ")
		nValor 	:= SE2->E2_SALDO
		nDescon	:= SE2->E2_SDDECRE
		dVenc	:= SE2->E2_VENCTO
        cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)	
		          
		
		CASE cModelo  == "27"
		
		cContr  := "08"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cExerc  := PadL(SE2->E2_XEXERC,4," ")   
		cRenav  := PadL(SE2->E2_XRENAV,9," ")
		cUF		:= PadL(SM0->M0_ESTENT,2," ")
		cMunic	:= PadL(SM0->M0_CIDENT,5," ")   
		cPlaca	:= PadL(SE2->E2_XPLACA,7," ")
		cOppgt	:= PadL(SE2->E2_XOPPGT,1," ")
		nValor 	:= SE2->E2_SALDO
	 	nDescon	:= SE2->E2_SDDECR
		dVenc	:= SE2->E2_VENCTO
		cNom    := SUBSTR(SM0->M0_NOMECOM,1,30)	
		 		
		*/	 
		
	OTHERWISE
		
		cCodre  :=  PadL(SE2->E2_CODRET,4," ")
		cContr  := "01"
		cIdcon  := PadL(SM0->M0_CGC,14," ")
		cTribu  := SEA->EA_MODELO
		cDtRefe := Substr( Dtos(SE2->E2_DTAPUR), 5, 2 ) + Substr( Dtos(SE2->E2_DTAPUR), 1, 4 )
		nValor  := SE2->E2_SALDO
		dPerio  := SE2->E2_DTAPUR 
		
EndCASE


/*
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Informações Complementares para o Banco Itaú                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±   
*/

IF    cBanco == "341" .and. SEA->EA_MODELO == "16"
     //_cReturn:="02"+StrZero(Val(cCodre),4)+"2"+cIdcon+GravaData(dPerio,.F.,5)+PADR(cRefer,17,"0")+StrZero(Int(Round(nValor*100,2)),14)+StrZero(Int(Round(nMultaJ*100,2)),14)+Repl("0",14)+StrZero(Int(Round((nValor+nMultaJ)*100,2)),14)+GravaData(dVencr,.F.,5)+GravaData(dVencr,.F.,5)+SPACE(30)+cNom 
       _cReturn:="02"+StrZero(Val(cCodre),4)+"2"+cIdcon+GravaData(dPerio,.F.,5)+PADR(cRefer,17,"0")+StrZero(Int(Round(nValor*100,2)),14)+StrZero(Int(Round(nMultaJ*100,2)),14)+StrZero(Int(Round(nJuros*100,2)),14)+StrZero(Int(Round((nValor+nMultaJ+nJuros)*100,2)),14)+GravaData(dVencr,.F.,5)+GravaData(dVenc,.F.,5)+SPACE(30)+cNom
	 
	 
ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "22"
      _cReturn := "05"+StrZero(Val(cCodre),4)+"1"+cIdcon+cInscr+cDivid+cDtRefe+STRZERO(VAL(cParce),13)+StrZero(Int(Round(nValor*100,2)),14)+REPLICATE("0",14)+StrZero(Int(Round(nMultaJ*100,2)),14)+StrZero(Int(Round((nValor+nMultaJ)*100,2)),14)+GravaData(dVenc,.F.,5)+GravaData(dVencr,.F.,5)+SPACE(11)+cNom


ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "17"
 	   _cReturn:= "01"+StrZero(Val(cCodre),4)+cDtRefe+cIdcon+StrZero(Int(Round(nValor*100,2)),14)+StrZero(Int(Round(nMultaJ*100,2)),14)+Repl("0",14)+StrZero(Int(Round((nValor+nMultaJ)*100,2)),14)+GravaData(dVencr,.F.,5)+GravaData(dVenc,.F.,5)+SPACE(58)+cNom 
	   
ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "35"
        // _cReturn:="11"+StrZero(Val(cCodre),4)+"2"+cIdcon+cCodBa+Repl("0",27)+cNom+GravaData(dVencr,.F.,5)+StrZero(Int(Round(nValor*100,2)),14)+SPACE(30) 
           _cReturn:="11"+StrZero(Val(cCodre),4)+"1"+cIdcon+cCodBa+Repl("0",27)+cNom+GravaData(dVencr,.F.,5)+StrZero(Int(Round(nValor*100,2)),14)+SPACE(30)
          
    
/*ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "21"
     _cReturn:= "04"+StrZero(Val(cCodre),4)+cDtRefe+cIdcon+StrZero(Int(Round(nValor*100,2)),14)+Repl("0",28)+StrZero(Int(Round(nValor*100,2)),14)+GravaData(dPerio,.F.,5)+SPACE(58)+cNom


ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "25"
     _cReturn:= "07"+Space(4)+"2"+cIdcon+cExerc+cRenav+cUF+cMunic+cPlaca+cOPPgt+StrZero(Int(Round(nValor*100,2)),14)+StrZero(Int(Round(nDescon*100,2)),14)+StrZero(Int(Round((nValor-nDescon)*100,2)),14)+GravaData(dVenc,.F.,5)+GravaData(dVenc,.F.,5)+SPACE(41)+cNom


ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "27"
     _cReturn:= "08"+Space(4)+"2"+cIdcon+cExerc+cRenav+cUF+cMunic+cPlaca+cOPPgt+StrZero(Int(Round(nValor*100,2)),14)+StrZero(Int(Round(nDescon*100,2)),14)+StrZero(Int(Round((nValor-nDescon)*100,2)),14)+GravaData(dVenc,.F.,5)+GravaData(dVenc,.F.,5)+SPACE(41)+cNom
    
 
ELSEIF cBanco == "341" .and. SEA->EA_MODELO == "35"        // _cReturn:="11"+StrZero(Val(cCodre),4)+"2"+cIdcon+cCodBa+Repl("0",27)+cNom+GravaData(dVencr,.F.,5)+StrZero(Int(Round(nValor*100,2)),14)+SPACE(30) 
        // _cReturn:="11"+StrZero(Val(cCodre),4)+"1"+cIdcon+cCodBa+Repl("0",27)+cNom+GravaData(dVencr,.F.,5)+StrZero(Int(Round(nValor*100,2)),14)+SPACE(30)
           _cReturn:= "11"+StrZero(Val(cCodre),4)+"1"+cIdcon+cCodBa+Repl("0",27)+StrZero(Int(Round(nValor*100,2)),14)+GravaData(dVencr,.F.,5)+SPACE(30)+cNom 
 */ 

Endif

Return(_cReturn)