" Vim syntax file
" Language:     PKGBUILD
" Maintainer:   Alessio 'mOLOk' Bolognino <themolok at gmail.com>
" Last Change:  2007/05/08
" Version Info: PKGBUILD-0.2 (colorphobic)

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
    finish
endif

let b:main_syntax = "sh"
runtime! syntax/sh.vim

" case on
syn case match

" pkgname
" FIXME if '=' is in pkgname/pkgver, it highlights whole string, not just '='
syn keyword pb_k_pkgname pkgname contained
syn match pbValidPkgname /\([[:alnum:]]\|+\|-\|_\){,32}/ contained contains=pbIllegalPkgname
syn match pbIllegalPkgname /[[:upper:]]\|[^[:alnum:]-+_=]\|=.*=\|=['"]\?.\{33,\}['"]\?/ contained
syn match pbPkgnameGroup /^pkgname=.*/ contains=pbIllegalPkgname,pb_k_pkgname,shDoubleQuote,shSingleQuote

" pkgver
syn keyword pb_k_pkgver pkgver contained
syn match pbValidPkgver /\([[:alnum:]]\|\.\|+\|_\)/ contained contains=pbIllegalPkgver
syn match pbIllegalPkgver /[^[:alnum:]+=\.\_]\|=.*=/ contained
syn match pbPkgverGroup /^pkgver=.*/ contains=pbIllegalPkgver,pbValidPkgver,pb_k_pkgver,shDoubleQuote,shSingleQuote

" pkgrel
syn keyword pb_k_pkgrel pkgrel contained
syn match pbValidPkgrel /[[:digit:]]*/ contained contains=pbIllegalPkgver
syn match pbIllegalPkgrel /[^[:digit:]=]\|=.*=/ contained
syn match pbPkgrelGroup /^pkgrel=.*/ contains=pbIllegalPkgrel,pbValidPkgrel,pb_k_pkgrel,shDoubleQuote,shSingleQuote

" pkgdesc
syn keyword pb_k_desc pkgdesc contained
" 90 chars: 80 for description, 8 for pkgdesc and 2 for ''
syn match pbIllegalPkgdesc /.\{90,}\|=['"]\?.*['" ]\+[iI][sS] [aA]/ contained contains=pbPkgdescSign
syn match pbValidPkgdesc /[^='"]\.\{,80}/ contained contains=pbIllegalPkgdesc
syn match pbPkgdescGroup /^pkgdesc=.*/ contains=pbIllegalPkgdesc,pb_k_desc,pbValidPkgdesc,shDoubleQuote,shSingleQuote
syn match pbPkgdescSign /[='"]/ contained

" url
syn keyword pb_k_url url contained
syn match pbValidUrl /['"]*\(https\|http\|ftp\)\:\/.*\.\+.*/ contained

syn match pbIllegalUrl /[^=]/ contained contains=pbValidUrl
syn match pbUrlGroup /^url=.*/ contains=pbValidUrl,pb_k_url,pbIllegalUrl,shDoubleQuote,shSingleQuote

" license
syn keyword pb_k_license license contained
syn keyword pbLicense  APACHE CDDL EPL FDL GPL LGPL MPL PHP RUBY ZLIB ISC MIT BSD contained
syn match pbLicenseCustom /custom\(:[[:alnum:]]*\)*/ contained
syn match pbIllegalLicense /[^='"() ]/ contained contains=pbLicenseCustom,pbLicense
syn match pbLicenseGroup /^license=.*/ contains=pb_k_license,pbLicenseCustom,pbLicense,pbIllegalLicense,shDoubleQuote,shSingleQuote

" backup
syn keyword pb_k_backup backup contained
syn match pbValidBackup   /\.\?[[:alpha:]]*\/[[:alnum:]\{\}+._$-]*]*/ contained
syn match pbBackupGroup /^backup=.*/ contains=pb_k_backup,pbValidBackup,shDoubleQuote,shSingleQuote

" arch
syn keyword pb_k_arch arch contained
syn keyword pbArch i686 x86_64 ppc contained
syn match pbIllegalArch /[^='() ]/ contained contains=pbArch
syn match pbArchGroup /^arch=.*/ contains=pb_k_arch,pbArch,pbIllegalArch,shDoubleQuote,shSingleQuote

" makedepends
syn keyword pb_k_makedepends makedepends contained
syn match pbValidMakedepends /\([[:alnum:]]\|+\|-\|_\)*/ contained
syn region pbMakedependsGroup start=/^makedepends=(/ end=/)/ contains=pb_k_makedepends,pbValidMakedepends,shDoubleQuote,shSingleQuote

" depends
syn keyword pb_k_depends depends contained
syn match pbValidDepends /\([[:alnum:]]\|+\|-\|_\)*/ contained
syn region pbDependsGroup start=/^depends=(/ end=/)/ contains=pb_k_depends,pbValidDepends,shDoubleQuote,shSingleQuote

" XXX little hack to color conflicts/provides/replaces keyword even without =()
syn match  pbkw /^\(conflicts\|provides\|replaces\)/ contains=pb_k_conflicts,pb_k_provides,pb_k_replaces
hi link pbkw keyword

" conflicts
syn keyword pb_k_conflicts conflicts contained
syn match pbValidConflicts /\([[:alnum:]]\|+\|-\|_\)*/ contained
syn region pbConflictsGroup start=/^conflicts=(/ end=/)/ contains=pb_k_conflicts,pbValidConflicts,shDoubleQuote,shSingleQuote

" provides
syn keyword pb_k_provides provides contained
syn match pbValidProvides /\([[:alnum:]]\|+\|-\|_\)*/ contained
syn region pbProvidesGroup start=/^provides=(/ end=/)/ contains=pb_k_provides,pbValidProvides,shDoubleQuote,shSingleQuote

" replaces
syn keyword pb_k_replaces replaces contained
syn match pbValidReplaces /\([[:alnum:]]\|+\|-\|_\)*/ contained
syn region pbReplacesGroup start=/^replaces=(/  end=/)/ contains=pb_k_replaces,pbValidReplaces,shDoubleQuote,shSingleQuote

" install
" XXX remove install from bashStatement, fix strage bug
syn clear bashStatement
syn keyword bashStatement chmod clear complete du egrep expr fgrep find gnufind gnugrep grep less ls mkdir mv rm rmdir rpm sed sleep sort strip tail touch

syn keyword pb_k_install install contained
syn match pbValidInstall /\([[:alnum:]]\|\$\|+\|-\|_\)*\.install/ contained
syn match pbIllegalInstall /[^=]/ contained contains=pbValidInstall
syn match pbInstallGroup /^install=.*/ contains=pb_k_install,pbValidInstall,pbIllegalInstall,shDeref,shDoubleQuote,shSingleQuote

" source:
" XXX remove source from shStatement, fixstrange bug
syn clear shStatement
syn keyword shStatement xxx wait getopts return autoload whence printf true popd nohup enable r trap readonly fc fg kill ulimit umask disown stop pushd read history logout times local exit test pwd time eval integer suspend dirs shopt hash false newgrp bg print jobs continue functions exec help cd break unalias chdir type shift builtin let bind

syn keyword pb_k_source source contained
syn match pbIllegalSource /\(http\|ftp\|https\).*\.\+\(dl\|download.\?\)\.\(sourceforge\|sf\).net/
syn region pbSourceGroup  start=/^source=(/ end=/)/ contains=pb_k_source,pbIllegalSource,shNumber,shDoubleQuote,shSingleQuote,pbDerefEmulation
syn match pbDerefEmulation /\$[{]\?[[:alnum:]_]*[}]\?/ contained
hi link pbDerefEmulation PreProc

" md5sums

syn keyword pb_k_md5sums md5sums contained
syn match pbIllegalMd5sums /[^='"()\/ ]/ contained contains=pbValidMd5sums
syn match pbValidMd5sums /[[:alnum:]]\{32\}/ contained
syn region pbMd5sumsGroup start=/^md5sums/ end=/)/ contains=pb_k_md5sums,pbMd5Quotes,pbMd5Hash,pbIllegalMd5sums
syn match pbMd5Quotes /'.*'\|".*"/ contained contains=pbMd5Hash,pbIllegalMd5sums
syn match pbMd5Hash /[[:alnum:]]\+/ contained contains=pbValidMd5sums
hi link pbMd5Quotes Keyword
hi link pbMd5Hash Error
hi link pbValidMd5sums  Number

" sha1sums
syn keyword pb_k_sha1sums sha1sums contained
syn match pbIllegalSha1sums /[^='"()\/ ]/ contained contains=pbValidSha1sums
syn match pbValidSha1sums /[[:alnum:]]\{40\}/ contained
syn region pbSha1sumsGroup start=/^sha1sums/ end=/)/ contains=pb_k_sha1sums,pbSha1Quotes,pbSha1Hash,pbIllegalSha1sums
syn match pbSha1Quotes /'.*'\|".*"/ contained contains=pbSha1Hash,pbIllegalSha1sums
syn match pbSha1Hash /[[:alnum:]]\+/ contained contains=pbValidSha1sums
hi link pbSha1Quotes Keyword
hi link pbSha1Hash Error
hi link pbValidSha1sums  Number

" options
syn keyword pb_k_options options contained
syn match pbOptions /\(no\)\?\(strip\|docs\|libtool\|emptydirs\|ccache\|distcc\|makeflags\|force\)/ contained
syn match   pbOptionsNeg     /\!/ contained
syn match   pbOptionsDeprec  /no/ contained
syn region pbOptionsGroup start=/^options=(/ end=/)/ contains=pb_k_options,pbOptions,pbOptionsNeg,pbOptionsDeprec,pbIllegalOption,shDoubleQuote,shSingleQuote
syn match pbIllegalOption /[^!"'()= ]/ contained contains=pbOptionsDeprec,pbOptions

" noextract
syn match pbNoextract /[[:alnum:]+._${}-]\+/ contained
syn keyword pb_k_noextract noextract  contained
syn region pbNoextractGroup  start=/^noextract=(/ end=/)/ contains=pb_k_noextract,pbNoextract,shDoubleQuote,shSingleQuote

" comments
syn keyword    pb_k_maintainer Maintainer Contributor contained
syn match      pbMaintainerGroup /Maintainer.*/ contains=pbMaintainer contained

syn match pbDate /[0-9]\{4}\/[0-9]\{2}\/[0-9]\{2}/ contained

syn cluster    pbCommentGroup	contains=pbTodo,pb_k_maintainer,pbMaintainerGroup,pbDate
syn keyword    pbTodo	contained	COMBAK FIXME TODO XXX
syn match      pbComment	"^#.*$"	contains=@pbCommentGroup
syn match      pbComment	"[^0-9]#.*$"	contains=@pbCommentGroup

" quote
syn region  shExSingleQuote	matchGroup=Error start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial contained
syn region  shSingleQuote	matchgroup=shOperator start=+'+ end=+'+		contains=shStringSpecial, at Spell contained
syn region  shDoubleQuote	matchgroup=shOperator start=+"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial, at Spell contained
syn match   shStringSpecial	"[^[:print:]]"	contained
syn match   shSpecial	"\\[\\\"\'`$()#]" contained

hi link pbComment Comment
hi link pbTodo Todo

hi link pbIllegalPkgname Error
hi link pb_k_pkgname pbKeywords

hi link pbIllegalPkgver Error
hi link pb_k_pkgver pbKeywords

hi link pbIllegalPkgrel Error
hi link pb_k_pkgrel pbKeywords

hi link pbIllegalPkgdesc Error
hi link pb_k_desc pbKeywords

hi link pbIllegalUrl Error
hi link pb_k_url pbKeywords

hi link pb_k_license pbKeywords
hi link pbIllegalLicense Error

hi link pb_k_backup pbKeywords

hi link pb_k_arch pbKeywords
hi link pbIllegalArch Error

hi link pb_k_makedepends pbKeywords
hi link pb_k_depends pbKeywords
hi link pb_k_replaces pbKeywords
hi link pb_k_conflicts pbKeywords
hi link pb_k_provides pbKeywords

hi link pbIllegalInstall Error
hi link pb_k_install pbKeywords

hi link pb_k_source pbKeywords
hi link pbIllegalSource Error

hi link pb_k_md5sums pbKeywords
hi link pbIllegalMd5sums Error

hi link pb_k_sha1sums pbKeywords
hi link pbIllegalSha1sums Error

hi link pb_k_options pbKeywords
hi link pbOptionsDeprec Todo
hi link pbIllegalOption Error

hi link pb_k_noextract pbKeywords
hi link pbNoextract Normal

hi link pb_k_maintainer pbKeywords

hi link pbKeywords Keyword

hi link pbDate Special

"syntax include @SHELL syntax/sh.vim
"syntax region BUILD start=/^build()/ end=/^}/ contains=@SHELL
"let b:current_syntax = "PKGBUILD"

" vim: ft=vim