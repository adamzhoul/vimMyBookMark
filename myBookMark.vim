""this is a practice vimplugin 

nnoremap mm :call AddMark()<cr>
let g:MyBookMark = {}
let g:BookMarkWindowName = "MyBookMark"
let g:latestBufnr = 1
let g:isMyBookMarkOpen = 0

function AddMark()

	:let FileFullPath = expand('%:p')
	:let line = line(".")
	":let MarkContent = getline(".")
	:let MarkContent = substitute(getline('.'),'^\s\+','','')

	:let tmpItem = {line : MarkContent}
	:let value =  get(g:MyBookMark, FileFullPath)

	if !has_key(g:MyBookMark, FileFullPath)
		:let g:MyBookMark[FileFullPath] = {line : MarkContent}
	else
		:let g:MyBookMark[FileFullPath] = extend(value, tmpItem)
	endif
	"let a =  EchoBookMark()
endfunction

function EchoBookMark()
:for key in keys(g:MyBookMark)

:let value = get(g:MyBookMark, key)
echo key
:echo GetFileName(key)
 for itemKey in keys(value)
 echo "\t".itemKey. "=>". value[itemKey]
 endfor
 :endfor
 endfunction

function! GetFileName(FileFullPath)
	:let lastSplash = strridx(a:FileFullPath, "/") + 1
	
	if lastSplash <=0 
		:let lastSplash = 0
	endif

	return strpart(a:FileFullPath, lastSplash)
endfunction

nnoremap 3 :call NewWindow()<cr>

function GetContentFromBookMark()
	:let content = ""
	:for key in keys(g:MyBookMark)
		:let value = get(g:MyBookMark, key)
"		:let content = content ."". GetFileName(key)."\<cr>\t"
		:let content = content ."". key."\<cr>\t"
		for itemKey in keys(value)
			:let content = content."[".itemKey. "]\t". value[itemKey]."\<cr>\t"
		endfor
		:let content = content . "\<cr>"
	:endfor
	return content
endfunction

function NewWindow()


	if g:isMyBookMarkOpen == 1
		return
	endif

"	execute "topleft vertical 20 split  MyBook"
	execute "rightbelow 15 split MyBook"
	"设置粘贴方式，防止自动tab
	setlocal paste
	"设置可以编辑
	execute  "set modifiable"
	"这里最后的操作，是在输出后，不知道为啥多输出了一项，这里把他删掉
	execute "normal i " .GetContentFromBookMark(). "\<ESC>ggGddddgg"
	"设置不可编辑
	execute  "setlocal nomodifiable"
	execute "set nowrap"

	let  g:isMyBookMarkOpen = 1

	"fold选项，目前看没啥效果
	setlocal foldenable
    setlocal foldmethod=indent
    setlocal foldlevel=1
	"设置左边的图标东东
	setlocal foldcolumn=1
	setlocal nonu
	setlocal norelativenumber
	"打开当前
    nnoremap <buffer> <silent> + :silent! foldopen<CR>
	"关闭当前
    nnoremap <buffer> <silent> - :silent! foldclose<CR>
	"打开所有
    nnoremap <buffer> <silent> * :silent! %foldopen!<CR>
	"关闭所有
    nnoremap <buffer> <silent> = :silent! %foldclose<CR>
 

	"设置以下选项，就可以退出窗口，而提示未保存
	setlocal buftype=nofile
	""设置，当窗口关闭时候，buf也消失
	"delete	delete the buffer from the buffer list, also when
	silent! setlocal bufhidden=delete
    
	nnoremap <buffer> <silent> <cr>
					\ :call Jump2SelectPosition()<CR>

	nnoremap <buffer> <silent> dd
					\ :echo RmCurrentMark()<CR>

autocmd BufLeave * call SetLatestBufNr()
autocmd BufWinLeave * call SetMark()


endfunction

function SetLatestBufNr()
	let g:latestBufnr = bufnr('%')
endfunction

function SetMark()
	let bufname =bufname('%')
	if bufname == 'MyBook'
		let g:isMyBookMarkOpen = 0
	endif
endfunction

function RmCurrentMark()
	
	let currentLine = GetLine()
	let index = GetFilePath()

	if currentLine == -1
		return
	endif

	setlocal modifiable
		"从当前行删除到当前行
		exec ".,.d"
		exec RmBookMarkIndex(g:MyBookMark[index], currentLine)
		if empty(g:MyBookMark[index]) == 1
			exec RmBookMarkIndex(g:MyBookMark, index)
		endif
	setlocal nomodifiable

endfunction

function RmBookMarkIndex(dict, index)
	unlet a:dict[a:index]	
endfunction

function Jump2SelectPosition()

	"let bufnr = bufnr('#')
	let file = GetFilePath()
	let line = GetLine()

	if line == -1
		echo file
	endif

	exec "call JumpSpecificLocation(".g:latestBufnr.",\"".file."\",".line.")"
endfunction

function GetFilePath()
	
	let line = line('.')
	while line >= 0
		let content = getline(line)
		let fangkuohao = stridx(content,"[")
		if fangkuohao < 0 
			return substitute(content,'^\s\+','','')
		"	return content
		endif
		let line = line - 1
	endwhile
endfunction

function GetLine()
	let content = getline(line('.'))
	let fangkuohao_start = stridx(content,"[")
	let fangkuohao_end = stridx(content,"]")
	if fangkuohao_start < 0 
		return -1
	endif

	return strpart(content, fangkuohao_start + 1 , fangkuohao_end - fangkuohao_start - 1)

endfunction


function JumpSpecificLocation(bufnr, targetFile, line)

	let window = bufwinnr(a:bufnr)
	exec window."wincmd w"
	exec "e ".a:targetFile
	exec a:line

endfunction

