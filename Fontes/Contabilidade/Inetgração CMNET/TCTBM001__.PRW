#INCLUDE "TOTVS.CH"

User Function TCTBM001()

	Local nX
	Local aArea         := GetArea()
	Local nDoc            := 1
	Local lRet            := .T.
	Local aCab            := {}
	Local aItens        := {}
	Local aLinha         := {}
	Local dDataLanc     := ctod("20/11/2020")
	Local nLinha        := '001'


	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private CTF_LOCK        := 0
	Private lSubLote         := .T.

	RpcSetEnv('99','01')

	aCab := {}
	aItem := {}

	aAdd(aCab,  {'DDATALANC'     ,ctod("20/11/2020")        ,NIL} )
	aAdd(aCab,  {'CLOTE'         ,'333333'         ,NIL} )
	aAdd(aCab,  {'CSUBLOTE'         ,'001'         ,NIL} )
	aAdd(aCab,  {'CDOC'             ,'000001'         ,NIL} )
	aAdd(aCab,  {'CPADRAO'         ,''             ,NIL} )
	aAdd(aCab,  {'NTOTINF'         ,0                 ,NIL} )
	aAdd(aCab,  {'NTOTINFLOT'     ,0                 ,NIL} )

	//{'CT2_FILIAL'      ,'0101   '     , NIL},;
		//{'CT2_CONVER'    ,'11'            , NIL},;
		aAdd(aItens,{ ;
		{'CT2_LINHA'      , nLinha        , NIL},;
		{'CT2_MOEDLC'      ,'01'          , NIL},;
		{'CT2_DC'           ,'3'          , NIL},;
		{'CT2_DEBITO'      ,'1111001'   , NIL},;
		{'CT2_CREDIT'      ,'1112001'   , NIL},;
		{'CT2_CCC'   , '101'               , Nil},;
		{'CT2_TPSALD'   , '1'               , Nil},;
		{'CT2_VALOR'      , 3000          , NIL},;
		{'CT2_ORIGEM'     ,'MSEXECAUT'    , NIL},;
		{'CT2_HP'           ,''           , NIL},;
		{'CT2_HIST'       ,'MSEXECCT2'    , NIL} } )

	MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

	If lMsErroAuto
		lMsErroAuto := .F.
		MsgAlert("ERRO Lançamento" , "Teste Carga CT2")
		mostraErro()

	Endif
	RestArea(aArea)

	RpcClearEnv()

Return
