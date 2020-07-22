//TODO INCLUIR BOTÃO DE ATUALIZAR NA TELA DE BROWSE
//TODO EXIBIR NA TELA DE BROWSE A QUANTIDADE DE REGISTROS EXIBIDOS
//TODO EXIBIR NA TELA DE BROWSE O TEMPO DE EXECUÇÃO DA QUERY
//TODO DEFINIR FUNÇÃO A CHECKBOX EXIBE DADOS CONFORME DICIONÁRIO

#INCLUDE 'TOTVS.CH'
#INCLUDE 'FILEIO.CH'

User Function DkQuery()

	Local oDfSzDlg   := FwDefSize():New( .F. )
	Local oDfSzBtn   := FwDefSize():New( .F. )
	Local oDlg       := Nil
	Local oBtnQuery  := Nil
	Local oBtnScript := Nil
	Local oBtnOpen   := Nil
	Local oBtnSave   := Nil
	Local oBtnCsv    := Nil
	Local oBtnEnd    := Nil
	Local oChkDic    := Nil
	Local lChkDic    := .F.
	Local oGet       := Nil
	Local cGet       := MemoRead( 'DkQuery.sql' )

	oDfSzDlg:AddObject ( 'oBtn', 000, 015, .T., .F. )
	oDfSzDlg:AddObject ( 'oGet', 000, 000, .T., .T. )
	oDfSzDlg:Process()

	oDfSzBtn:AddObject ( 'oBtnQuery'  , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnScript' , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnOpen'   , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnSave'   , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnCsv'    , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnEnd'    , 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oChkDic'    , 200, 015, .F., .F. )
	oDfSzBtn:lLateral := .T.
	oDfSzBtn:Process()

	oDlg := MsDialog():New(;
	/* nTop         */ oDfSzDlg:aWindSize[ 1 ] ,;
	/* nLeft        */ oDfSzDlg:aWindSize[ 2 ] ,;
	/* nBottom      */ oDfSzDlg:aWindSize[ 3 ] ,;
	/* nRight       */ oDfSzDlg:aWindSize[ 4 ] ,;
	/* cCaption     */                      '' ,;
	/* uParam6      */                         ,;
	/* uParam7      */                         ,;
	/* uParam8      */                         ,;
	/* uParam9      */                         ,;
	/* nClrText     */                         ,;
	/* nClrBack     */                         ,;
	/* uParam12     */                         ,;
	/* oWnd         */                         ,;
	/* lPixel       */                     .T. ,;
	/* uParam15     */                         ,;
	/* uParam16     */                         ,;
	/* uParam17     */                         ,;
	/* lTransparent */                          )

	oBtnQuery := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnQuery', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnQuery', 'COLINI' ) ,;
	/* cCaption */                                        'QUERY' ,;
	/* oWnd     */                                           oDlg ,;
	/* bAction  */              { || ProcQuery( cGet, 'QUERY' ) } ,;
	/* nWidth   */ oDfSzBtn:GetDimension( 'oBtnQuery', 'XSIZE'  ) ,;
	/* nHeight  */ oDfSzBtn:GetDimension( 'oBtnQuery', 'YSIZE'  ) ,;
	/* uParam8  */                                                ,;
	/* oFont    */            TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                                ,;
	/* lPixel   */                                            .T. ,;
	/* uParam12 */                                                ,;
	/* uParam13 */                                                ,;
	/* uParam14 */                                                ,;
	/* bWhen    */                                                ,;
	/* uParam16 */                                                ,;
	/* uParam17 */                                                 )

	oBtnScript := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnScript', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnScript', 'COLINI' ) ,;
	/* cCaption */                                        'SCRIPT' ,;
	/* oWnd     */                                            oDlg ,;
	/* bAction  */                       { || ProcScript( cGet ) } ,;
	/* nWidth   */ oDfSzBtn:GetDimension( 'oBtnScript', 'XSIZE'  ) ,;
	/* nHeight  */ oDfSzBtn:GetDimension( 'oBtnScript', 'YSIZE'  ) ,;
	/* uParam8  */                                                 ,;
	/* oFont    */             TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                                 ,;
	/* lPixel   */                                             .T. ,;
	/* uParam12 */                                                 ,;
	/* uParam13 */                                                 ,;
	/* uParam14 */                                                 ,;
	/* bWhen    */                                                 ,;
	/* uParam16 */                                                 ,;
	/* uParam17 */                                                  )

	oBtnOpen := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnOpen', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnOpen', 'COLINI' ) ,;
	/* cCaption */                                       'ABRIR' ,;
	/* oWnd     */                                          oDlg ,;
	/* bAction  */              { || cGet := ReadQuery( cGet ) } ,;
	/* nWidth   */  oDfSzBtn:GetDimension( 'oBtnOpen', 'XSIZE' ) ,;
	/* nHeight  */  oDfSzBtn:GetDimension( 'oBtnOpen', 'YSIZE' ) ,;
	/* uParam8  */                                               ,;
	/* oFont    */           TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                               ,;
	/* lPixel   */                                           .T. ,;
	/* uParam12 */                                               ,;
	/* uParam13 */                                               ,;
	/* uParam14 */                                               ,;
	/* bWhen    */                                               ,;
	/* uParam16 */                                               ,;
	/* uParam17 */                                                )

	oBtnSave := TButton():New(;
	/* nRow     */                                         oDfSzBtn:GetDimension( 'oBtnSave', 'LININI' ) ,;
	/* nCol     */                                         oDfSzBtn:GetDimension( 'oBtnSave', 'COLINI' ) ,;
	/* cCaption */                                                                              'SALVAR' ,;
	/* oWnd     */                                                                                  oDlg ,;
	/* bAction  */ { || MemoWrite( cGetFile ( '*.sql|*.sql', 'Consultas SQL',,,.T.,,.T., .T. ), cGet ) } ,;
	/* nWidth   */                                         oDfSzBtn:GetDimension( 'oBtnSave', 'XSIZE'  ) ,;
	/* nHeight  */                                         oDfSzBtn:GetDimension( 'oBtnSave', 'YSIZE'  ) ,;
	/* uParam8  */                                                                                       ,;
	/* oFont    */                                                   TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                                                                       ,;
	/* lPixel   */                                                                                   .T. ,;
	/* uParam12 */                                                                                       ,;
	/* uParam13 */                                                                                       ,;
	/* uParam14 */                                                                                       ,;
	/* bWhen    */                                                                                       ,;
	/* uParam16 */                                                                                       ,;
	/* uParam17 */                                                                                        )

	oBtnCsv := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnCsv', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnCsv', 'COLINI' ) ,;
	/* cCaption */                                        'CSV' ,;
	/* oWnd     */                                         oDlg ,;
	/* bAction  */              { || ProcQuery( cGet, 'CSV' ) } ,;
	/* nWidth   */ oDfSzBtn:GetDimension( 'oBtnCsv', 'XSIZE'  ) ,;
	/* nHeight  */ oDfSzBtn:GetDimension( 'oBtnCsv', 'YSIZE'  ) ,;
	/* uParam8  */                                              ,;
	/* oFont    */          TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                              ,;
	/* lPixel   */                                          .T. ,;
	/* uParam12 */                                              ,;
	/* uParam13 */                                              ,;
	/* uParam14 */                                              ,;
	/* bWhen    */                                              ,;
	/* uParam16 */                                              ,;
	/* uParam17 */                                               )

	oBtnEnd := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnEnd', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnEnd', 'COLINI' ) ,;
	/* cCaption */                                     'FECHAR' ,;
	/* oWnd     */                                         oDlg ,;
	/* bAction  */                            { || oDlg:End() } ,;
	/* nWidth   */ oDfSzBtn:GetDimension( 'oBtnEnd', 'XSIZE'  ) ,;
	/* nHeight  */ oDfSzBtn:GetDimension( 'oBtnEnd', 'YSIZE'  ) ,;
	/* uParam8  */                                              ,;
	/* oFont    */          TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                              ,;
	/* lPixel   */                                          .T. ,;
	/* uParam12 */                                              ,;
	/* uParam13 */                                              ,;
	/* uParam14 */                                              ,;
	/* bWhen    */                                              ,;
	/* uParam16 */                                              ,;
	/* uParam17 */                                               )

	oChkDic := TCheckBox():New(;
	/* nRow      */ oDfSzBtn:GetDimension( 'oChkDic', 'LININI' ) + 4 ,;
	/* nCol      */ oDfSzBtn:GetDimension( 'oChkDic', 'COLINI' ) ,;
	/* cCaption  */  'FORMATA OS CAMPOS CONFORME O DICIONÁRIO ?' ,;
	/* bSetGet   */                               { || lChkDic } ,;
	/* oDlg      */                                         oDlg ,;
	/* nWidth    */ oDfSzBtn:GetDimension( 'oChkDic', 'XSIZE'  ) ,;
	/* nHeight   */ oDfSzBtn:GetDimension( 'oChkDic', 'YSIZE'  ) ,;
	/* uParam8   */                                              ,;
	/* bLClicked */                                              ,;
	/* oFont     */          TFont():New( 'Consolas',,-14,,.T. ) ,;
	/* bValid    */                                              ,;
	/* nClrText  */                                              ,;
	/* nClrPane  */                                              ,;
	/* uParam14  */                                              ,;
	/* lPixel    */                                          .T. ,;
	/* cMsg      */                                              ,;
	/* uParam17  */                                              ,;
	/* bWhen     */                                               )

	oGet := TMultiGet():New(;
	/* nRow        */      oDfSzDlg:GetDimension( 'oGet', 'LININI' ) ,;
	/* nCol        */      oDfSzDlg:GetDimension( 'oGet', 'COLINI' ) ,;
	/* bSetGet     */ { | U | If( PCount() == 0, cGet, cGet := U ) } ,;
	/* oWnd        */                                           oDlg ,;
	/* nWidth      */       oDfSzDlg:GetDimension( 'oGet', 'XSIZE' ) ,;
	/* nHeight     */       oDfSzDlg:GetDimension( 'oGet', 'YSIZE' ) ,;
	/* oFont       */                TFont():New( 'Consolas',,-14, ) ,;
	/* uParam8     */                                                ,;
	/* uParam9     */                                                ,;
	/* uParam10    */                                                ,;
	/* uParam11    */                                                ,;
	/* lPixel      */                                            .T. ,;
	/* uParam13    */                                                ,;
	/* uParam14    */                                                ,;
	/* bWhen       */                                                ,;
	/* uParam16    */                                                ,;
	/* uParam17    */                                                ,;
	/* lReadOnly   */                                                ,;
	/* bValid      */                                                ,;
	/* uParam20    */                                                ,;
	/* uParam21    */                                                ,;
	/* lNoBorder   */                                                ,;
	/* lVScroll    */                                            .T. ,;
	/* cLabelText  */                                                ,;
	/* nLabelPos   */                                                ,;
	/* oLabelFont  */                                                ,;
	/* nLabelColor */                                                 )

	ACTIVATE DIALOG oDlg CENTERED

Return

Static Function ProcQuery( cQuery, cTipo )

	Local cErro  := ''
	Local bError := ErrorBlock( { | oErro | cErro := oErro:Description } )
	Local nX     := 0
	Local cAux   := ""
	Local aQuery := Nil

	Private cTrab  := ''

	MemoWrite( 'DkQuery.sql', cQuery )

	aQuery := StrTokArr2( cQuery, CHR(13)+CHR(10), .T. )

	For nX := 1 To Len( aQuery )

		If ! Empty( aQuery[ nX ] ) .And. SubStr( AllTrim(aQuery[nX]), 1, 2 ) != '--'

			cAux += aQuery[nX] + " "

		End If

	Next nX

	MsgRun ( 'Banco de Dados Processando a Query ...', 'Aguarde ...', { | | cTrab := MpSysOpenQuery( cAux ) } )

	If ! Empty( cErro )

		AutoGrLog( cErro )
		MostraErro()

	Else

		If cTipo == 'QUERY'

			MsgRun ( 'Montando Browse de Exibição ...', 'Aguarde ...', { | | ShowBrw() } )

		ElseIf cTipo == 'CSV'

			MsgRun ( 'Gerando Arquivo ...', 'Aguarde ...', { | | Query2Csv() } )

		EndIf

	End If

	ErrorBlock( bError )

Return

Static Function ProcScript( cScript )

	Local nStatus := 0

	MemoWrite( 'DkQuery.sql', cScript )

	MsgRun ( 'Banco de Dados Processando a Script ...', 'Aguarde ...', { | | nStatus := TCSqlExec( cScript ) } )

	If nStatus < 0

		AutoGrLog( TCSQLError() )
		MostraErro()

	Else

		ApMsgInfo( 'Script Processado Com Sucesso.', 'Atenção !!!' )

	End If

Return

Static Function ReadQuery( cGet )

	Local cRet := ''

	cRet := MemoRead( cGetFile ( '*.sql|*.sql', 'Consultas SQL',,,.F.,,.T., .T. )  )

	If Empty( cRet )

		cRet := cGet

	End If

Return cRet

Static Function ShowBrw()

	Local oDfSzDlg := FwDefSize():New( .F. )
	Local oDfSzBtn := FwDefSize():New( .F. )
	Local oDlg     := Nil
	Local oBtnCsv  := Nil
	Local oBtnEnd  := Nil
	Local oGet     := Nil
	Local cGet     := ''
	Local oBrowse   := Nil
	Local aAux      := {}
	Local bLine     := Nil
	Local nZ        := 0
	Local nX        := 0

	Private aHeaders  := {}
	Private aBrowse   := {}

	oDfSzDlg:AddObject ( 'oBtn'   , 000, 015, .T., .F. )
	oDfSzDlg:AddObject ( 'oBrowse', 000, 000, .T., .T. )
	oDfSzDlg:Process()

	oDfSzBtn:AddObject ( 'oBtnCsv', 050, 015, .F., .F. )
	oDfSzBtn:AddObject ( 'oBtnEnd', 050, 015, .F., .F. )
	oDfSzBtn:lLateral := .T.
	oDfSzBtn:Process()

	oDlg := MsDialog():New(;
	/* nTop         */ oDfSzDlg:aWindSize[ 1 ] ,;
	/* nLeft        */ oDfSzDlg:aWindSize[ 2 ] ,;
	/* nBottom      */ oDfSzDlg:aWindSize[ 3 ] ,;
	/* nRight       */ oDfSzDlg:aWindSize[ 4 ] ,;
	/* cCaption     */                      '' ,;
	/* uParam6      */                         ,;
	/* uParam7      */                         ,;
	/* uParam8      */                         ,;
	/* uParam9      */                         ,;
	/* nClrText     */                         ,;
	/* nClrBack     */                         ,;
	/* uParam12     */                         ,;
	/* oWnd         */                         ,;
	/* lPixel       */                     .T. ,;
	/* uParam15     */                         ,;
	/* uParam16     */                         ,;
	/* uParam17     */                         ,;
	/* lTransparent */                          )

	oBtnCsv := TButton():New(;
	/* nRow     */                                oDfSzBtn:GetDimension( 'oBtnCsv', 'LININI' ) ,;
	/* nCol     */                                oDfSzBtn:GetDimension( 'oBtnCsv', 'COLINI' ) ,;
	/* cCaption */                                                                       'CSV' ,;
	/* oWnd     */                                                                        oDlg ,;
	/* bAction  */ { || MsgRun ( 'Gerando Arquivo ...', 'Aguarde ...', { | | Array2Csv() } ) } ,;
	/* nWidth   */                                oDfSzBtn:GetDimension( 'oBtnCsv', 'XSIZE'  ) ,;
	/* nHeight  */                                oDfSzBtn:GetDimension( 'oBtnCsv', 'YSIZE'  ) ,;
	/* uParam8  */                                                                             ,;
	/* oFont    */                                         TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                                                             ,;
	/* lPixel   */                                                                         .T. ,;
	/* uParam12 */                                                                             ,;
	/* uParam13 */                                                                             ,;
	/* uParam14 */                                                                             ,;
	/* bWhen    */                                                                             ,;
	/* uParam16 */                                                                             ,;
	/* uParam17 */                                                                              )

	oBtnEnd := TButton():New(;
	/* nRow     */ oDfSzBtn:GetDimension( 'oBtnEnd', 'LININI' ) ,;
	/* nCol     */ oDfSzBtn:GetDimension( 'oBtnEnd', 'COLINI' ) ,;
	/* cCaption */                                     'FECHAR' ,;
	/* oWnd     */                                         oDlg ,;
	/* bAction  */                            { || oDlg:End() } ,;
	/* nWidth   */ oDfSzBtn:GetDimension( 'oBtnEnd', 'XSIZE'  ) ,;
	/* nHeight  */ oDfSzBtn:GetDimension( 'oBtnEnd', 'YSIZE'  ) ,;
	/* uParam8  */                                              ,;
	/* oFont    */          TFont():New( 'Consolas',,-12,,.T. ) ,;
	/* uParam10 */                                              ,;
	/* lPixel   */                                          .T. ,;
	/* uParam12 */                                              ,;
	/* uParam13 */                                              ,;
	/* uParam14 */                                              ,;
	/* bWhen    */                                              ,;
	/* uParam16 */                                              ,;
	/* uParam17 */                                               )

	( cTrab )->( DbGoTop() )

	Do While ! ( cTrab )->( Eof() )

		For nX := 1 To ( cTrab )->( FCount() )

			aAdd( aAux, ( cTrab )->&( FieldName( nX ) ) )

		Next nX

		aAdd( aBrowse, aClone( aAux ) )

		aSize( aAux, 0 )

		( cTrab )->( DbSkip() )

	End Do

	bLine := '{||{'

	For nX := 1 To ( cTrab )->( FCount() )

		aAdd( aHeaders, ( cTrab )->( FieldName( nX ) ) )

		bLine += 'aBrowse[ oBrowse:nAt, ' + cValToChar( nX ) + ']'

		If nX < ( cTrab )->( FCount() )

			bLine += ','

		End If

	Next nX

	bLine += '}}'

	bLine := &( bLine )

	oBrowse := TWBrowse():New(;
	/* nRow       */ oDfSzDlg:GetDimension( 'oBrowse', 'LININI' ) ,;
	/* nCol       */ oDfSzDlg:GetDimension( 'oBrowse', 'COLINI' ) ,;
	/* nWidth     */ oDfSzDlg:GetDimension( 'oBrowse', 'XSIZE'  ) ,;
	/* nHeight    */ oDfSzDlg:GetDimension( 'oBrowse', 'YSIZE'  ) ,;
	/* bLine      */                                              ,;
	/* aHeaders   */                                     aHeaders ,;
	/* aColSizes  */                                              ,;
	/* oDlg       */                                         oDlg ,;
	/* cField     */                                              ,;
	/* uValue1    */                                              ,;
	/* uValue2    */                                              ,;
	/* bChange    */                                              ,;
	/* bLDblClick */                                              ,;
	/* bRClick    */                                              ,;
	/* oFont      */              TFont():New( 'Consolas',,-12, ) ,;
	/* oCursor    */                                              ,;
	/* nClrFore   */                                              ,;
	/* nClrBack   */                                              ,;
	/* cMsg       */                                              ,;
	/* uParam20   */                                              ,;
	/* cAlias     */                                              ,;
	/* lPixel     */                                          .T. ,;
	/* bWhen      */                                              ,;
	/* uParam24   */                                              ,;
	/* bValid     */                                              ,;
	/* lHScroll   */                                          .T. ,;
	/* lVScroll   */                                          .T.  )

	oBrowse:SetArray( aBrowse )
	oBrowse:bLine    := bLine

	oDlg:Activate()

	If Select( cTrab ) > 0

		( cTrab )->( DbCloseArea() )

	End If

Return

Static Function Query2Csv()

	Local cFile     := GetTempPath( .T. ) + GetNextAlias() + '.csv'
	Local nHandle   := FCreate( cFile )
	Local cBuffer   := ''
	Local cAux      := ''
	Local nQtdBytes := 0
	Local nX        := 0
	Local cValType  := ''

	If nHandle # -1

		//-- Gera Cabeçalho do arquivo
		For nX := 1 To ( cTrab )->( FCount() )

			cBuffer += ( cTrab )->( FieldName( nX ) )

			If nX < ( cTrab )->( FCount() )

				cBuffer += ";"

			End If

		Next nX

		cBuffer += CRLF

		nQtdBytes := Len( cBuffer )

		FSeek(nHandle, 0, FS_END)

		FWrite( nHandle, cBuffer, nQtdBytes )

		cBuffer := ''

		//-- Gera dados do arquivo
		( cTrab )->( DbGoTop() )

		Do While ! ( cTrab )->( Eof() )

			For nX := 1 To ( cTrab )->( FCount() )

				cValType := ValType( ( cTrab )->&( FieldName( nX ) ) )

				If cValType == 'N'

					cAux    := cValTochar( ( cTrab )->&( FieldName( nX ) ) )
					cAux    := StrTran( cAux, '.', ',' )
					cBuffer += cAux

				ElseIf cValType $ 'DL'

					cBuffer +=  cValTochar( ( cTrab )->&( FieldName( nX ) ) )

				Else

					cBuffer += '="'
					cBuffer +=  cValTochar( ( cTrab )->&( FieldName( nX ) ) )
					cBuffer +=  '"'

				End If

				If nX < ( cTrab )->( FCount() )

					cBuffer += ";"

				End If

			Next nX

			cBuffer += CRLF

			nQtdBytes := Len( cBuffer )

			FSeek(nHandle, 0, FS_END)

			FWrite( nHandle, cBuffer, nQtdBytes )

			cBuffer := ''

			( cTrab )->( DbSkip() )

		End Do

	Else

	End If

	FClose( nHandle )

	If Select( cTrab ) > 0

		( cTrab )->( DbCloseArea() )

	End If

	ShellExecute( 'Open', cFile, '', '', 1 )

Return

Static Function Array2Csv()

	Local cFile     := GetTempPath( .T. ) + GetNextAlias() + '.csv'
	Local nHandle   := FCreate( cFile )
	Local cBuffer   := ''
	Local cAux      := ''
	Local nQtdBytes := 0
	Local nX        := 0
	Local nZ        := 0
	Local cValType  := ''

	If nHandle # -1

		//-- Gera Cabeçalho do arquivo
		For nX := 1 To Len( aHeaders )

			cBuffer += aHeaders[ nX ]

			If nX < Len( aHeaders )

				cBuffer += ";"

			End If

		Next nX

		cBuffer += CRLF

		nQtdBytes := Len( cBuffer )

		FSeek(nHandle, 0, FS_END)

		FWrite( nHandle, cBuffer, nQtdBytes )

		cBuffer := ''

		//-- Gera dados do arquivo

		For nZ := 1 To Len( aBrowse )

			For nX := 1 To Len( aBrowse[ nZ ] )

				cValType := ValType( aBrowse[ nZ, nX ] )

				If cValType == 'N'

					cAux    := cValTochar( aBrowse[ nZ, nX ] )
					cAux    := StrTran( cAux, '.', ',' )
					cBuffer += cAux

				ElseIf cValType $ 'DL'

					cBuffer +=  cValTochar( aBrowse[ nZ, nX ] )

				Else

					cBuffer += '="'
					cBuffer +=  cValTochar( aBrowse[ nZ, nX ] )
					cBuffer +=  '"'

				End If

				If nX < Len( aBrowse[ nZ ] )

					cBuffer += ";"

				End If

			Next nX

			cBuffer += CRLF

			nQtdBytes := Len( cBuffer )

			FSeek(nHandle, 0, FS_END)

			FWrite( nHandle, cBuffer, nQtdBytes )

			cBuffer := ''

		Next nZ

	Else

	End If

	FClose( nHandle )

	ShellExecute( 'Open', cFile, '', '', 1 )

Return


//Static Function DefKey( cTela )
//
//	Default cTela := ''
//
//	If cTela := ''
//
//	ElseIf cTela := 'Help'
//
//	ElseIf cTela := 'Abrir'
//
//	ElseIf cTela := ''
//
//	ElseIf cTela := ''
//
//		SetKey( VK_F1, { || } )
//		SetKey( VK_F2, { || } )
//		SetKey( VK_F3, { || } )
//		SetKey( VK_F4, { || } )
//		SetKey( VK_F5, { || } )
//		SetKey( VK_F6, { || } )
//		SetKey( VK_F7, { || } )

//	aAdd( aMultiBtn, { '<F1> Help'      , VK_F1, { || ExecF1() } } )
//	aAdd( aMultiBtn, { '<F2> Abrir'     , VK_F2, { || ExecF2() } } )
//	aAdd( aMultiBtn, { '<F3> Salvar'    , VK_F3, { || ExecF3() } } )
//	aAdd( aMultiBtn, { '<F4> CSV'       , VK_F4, { || ExecF4() } } )
//  aAdd( aMultiBtn, { '<F5> Executar'  , VK_F5, { || ExecF5( cMultiGet ) } } )
//	aAdd( aMultiBtn, { '<F6> ParÃ¢metros', VK_F6, { || ExecF6() } } )
//	aAdd( aMultiBtn, { '<F7> HistÃ³rico' , VK_F7, { || ExecF7() } } )
//	aAdd( aMultiBtn, { '<F8> Script' , VK_F7, { || ExecF7() } } )

//	End If
//
//Return

//	AutoGrLog( cMultiGet )
//
//	MostraErro()
//	If y = 1
//
//		cMultiGet := "Lorem ipsum fames cras dictumst non mollis id, taciti vel semper commodo interdum ad, eros rhoncus sapien curabitur pulvinar dictumst. neque non luctus vehicula imperdiet conubia netus quis torquent cubilia, vulputate quisque varius torquent posuere etiam maecenas integer. congue quisque volutpat lorem est erat dui posuere, malesuada aliquet etiam velit eget varius neque nisi, lacus tellus enim consequat tincidunt pellentesque. nisl ad at vehicula cursus duis himenaeos, nunc nostra maecenas euismod nibh, lorem per sociosqu himenaeos ullamcorper. nibh curabitur netus vivamus neque quisque venenatis blandit urna per odio, porttitor eleifend etiam porta massa sit nunc arcu. "
//
//	elseif y = 2
//
//		oMultiGet:SetFont( TFont():New( 'Consolas',,-18, ) )
//
//	endif
//
//	oMultiGet:Refresh()

/*
Static Function F550SldC(cTable,cCodigo,cLoja,cDC)

Local cQuery	:= ""
Local nValor	:= 0

DEFAULT cTable	:= ""
DEFAULT cCodigo := ""
DEFAULT cLoja	:= ""

	If !Empty(cCodigo)

		If oPreparC == nil
cQuery 	:= "SELECT SUM(ABS(VALOR)) VLRX FROM "+ cTable +" "
cQuery 	+= "WHERE CODIGO = ? AND"
cQuery 	+= " LOJA = ? AND"
cQuery 	+= " DATAEM < '" + DTOS(MV_PAR01) + "' AND "
cQuery 	+= " DC = ? "

cQuery 	:= ChangeQuery(cQuery)
oPreparC:= FWPreparedStatement():New(cQuery)
		Endif

oPreparC:SetString(1,cCodigo)
oPreparC:SetString(2,cLoja)
oPreparC:SetString(3,cDC)

cQuery := oPreparC:GetFixQuery()

nValor := ABS(MpSysExecScalar(cQuery,"VLRX"))

	Endif

Return nValor
*/
