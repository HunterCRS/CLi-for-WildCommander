;---------------------------------------
; CLi (Command Line Interface) API
;---------------------------------------

wcKernel	equ	#6006				; WildCommander API

;---------------------------------------
_openStream	ld	d,#00				; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
		ld	a,_STREAM
		jp	wcKernel
;---------------------------------------
_pathToRoot	ld	d,#ff				; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
		ld	bc,#ffff			; устройство (#ffff = не создавать заново, использовать текущий поток)
		ld	a,_STREAM
		jp	wcKernel
;---------------------------------------
_checkKeyEnter	ld	a,_ENKE
		jp	wcKernel
;---------------------------------------
_checkKeyDel	ld	a,_BSPC
		jp	wcKernel
;---------------------------------------
_checkKeyUp	ld	a,_UPPP
		jp	wcKernel
;---------------------------------------
_checkKeyDown	ld	a,_DWWW
		jp	wcKernel
;---------------------------------------
_checkKeyLeft	ld	a,_LFFF
		jp	wcKernel
;---------------------------------------
_checkKeyRight	ld	a,_RGGG
		jp	wcKernel
;---------------------------------------
_checkKeyAlt	ld	a,_ALT
		jp	wcKernel
;---------------------------------------
_checkKeyEsc	ld	a,_ESC
		jp	wcKernel
;---------------------------------------
_checkKeyF1	ld	a,_F1
		jp	wcKernel
;---------------------------------------
_checkKeyF2	ld	a,_F2
		jp	wcKernel
;---------------------------------------
_waitKeyCalm	ld	a,_USPO
		jp	wcKernel
;---------------------------------------
_waitAnyKey	call	waitKeyCalm
		ld	a,_NUSP				; wait 4 anykey
		jp	wcKernel
;---------------------------------------
_getKey		ld	a,#01				; #01 - всегда выдает код из TAI1
		ex	af,af'
		ld	a,_KBSCN
		jp	wcKernel
;---------------------------------------
_getKeyWithShift
		ld	a,#00				; #00 - учитывает SHIFT
		ex	af,af'
		ld	a,_KBSCN
		jp	wcKernel
;---------------------------------------
_setRamPage	ex	af,af'				; A' - номер страницы (от 0)
		ld	a,_MNGC_PL			; #FE - первый текстовый экран (в нём панели)
		jp	wcKernel			; #FF - страница с фонтом (1го текстового экрана)
;---------------------------------------
_setVideoPage	ex	af,af'				; #00-#0F - страницы из 1го видео буфера
		ld	a,_MNGCVPL			; #10-#1F - страницы из 2го видео буфера
		jp	wcKernel
;---------------------------------------
_setVideoBuffer	ex	af,af'				; #01 - 1й видео буфер (16 страниц)
		ld	a,_MNGV_PL			; #02 - 2й видео буфер (16 страниц)
		jp	wcKernel
;---------------------------------------
_setVideoMode	ex	af,af'
		ld	a,_GVmod
		jp	wcKernel
;---------------------------------------
_restoreWC	ld	a,#00				; Восстановление видеорежима для WC (#00 - основной экран (тхт))
		ex	af,af'
		ld	a,_MNGV_PL
		jp	wcKernel
;---------------------------------------
_searchEntry	ld	a,_FENTRY
		jp	wcKernel
;---------------------------------------
_setFileBegin	ld	a,_GFILE
		jp	wcKernel
;---------------------------------------
_setDirBegin	ld	a,_GDIR
		jp	wcKernel
;---------------------------------------
_load512bytes	ld	a,_LOAD512
		jp	wcKernel
;---------------------------------------
_setPosBegin	ld	a,_GIPAGPL
		jp	wcKernel
;---------------------------------------
;---------------------------------------
_setHOffset	ld	a,_GXoff
		jp	wcKernel
;---------------------------------------
_setVOffset	ld	a,_GYoff
		jp	wcKernel
;---------------------------------------
DMAPL							; Для совместимости с сорцами Budder/MGN
_callDma	ex	af,af'
		ld	a,_DMAPL
		jp	wcKernel
;---------------------------------------
_getFatEntry	ld	a,_TENTRY
		jp	wcKernel
;---------------------------------------



;---------------------------------------
_checkSync	ld	hl,(_TMN)
		ld	a,h
		or	l
		ret	z				; Z - ещё не было обновлений - выход
		ld	hl,#0000
		ld	(_TMN),hl
		ld	a,1				; NZ - обновление было
		or	a
		ret
;---------------------------------------
_printString	call	printStr
		ret
;---------------------------------------
_setScreen	cp	#00				; в A - 0 - txt, 1 - gfx
		jp	z,setVideo0
		cp	#01
		jp	z,setVideo1
		ret
;---------------------------------------
_clearGfxScreen	call	gfxCls
		ld	a,appBank
		call	setVideoPage
		ret
;---------------------------------------
_chToHomePath	push	hl,bc,af

		ld	hl,pathCString
		ld	de,pathCString+1
		ld	bc,pathStrSize
		xor	a
		ld	(hl),a
		ldir

		ld	de,pathCString
		call	storePathCall
 		call	restoreHomePath
 		ld	de,pathString
 		call	changeDir

		pop	af,bc,hl
		ret
;---------------------------------------
_chToCallPath	push	hl,bc,af

 		ld	de,pathCString
 		call	changeDir

		pop	af,bc,hl
		ret
;---------------------------------------
_loadResource	ex	de,hl
		ld	hl,exitResource
		push	hl
		cp	resPal				; загрузка палитры
		jp	z,loadGfxPal
		
		cp	resSpr				; загрузка спрайтов
		jp	z,loadSprites

		pop	hl				; тип ресурса не найден
							; TODO: сделать ERROR MSG

exitResource	push	af
		ex	af,af'
		push	af
		ld	a,appBank
		call	setVideoPage
		pop	af
		ex	af,af'
		pop	af

		ret

;---------------------------------------
_printOkStatus	ex	af,af'
		cp	#00
		ret	nz
		ld	hl,statusOkMsg
		jp	printString

;---------------------------------------
_getPanelStatus	ld	ix,(storeIx)			; wc panel status
		ld	a,(ix+29)
		ret

;---------------------------------------
_eSearch	ld	hl,entryForSearch
		jp	searchEntry

;---------------------------------------
_storeFileLen	ld	(fileLength),hl
		ld	(fileLength+2),de
		ret

;---------------------------------------
_printRestore	ld	hl,restoreMsg
		jp	printString

;---------------------------------------
_setCliResol						; reserved
		ret

_setCliGfxResol	and	%00000011
		rrca
		rrca
		ld	c,a
		ld	a,(currentVMode)
		and	%00000011
		or	c
		ld	(currentVMode),a
		ret
;---------------------------------------
initCallBack	ld	hl,callBackRet			; инициализирует callBack при переключении ALT+F1/F2
_setAppCallBack	ld	(callBackApp),hl
		ret
;---------------------------------------
