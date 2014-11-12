" Prevent multi loads and disable in compatible mode
" check if vim version is at least 7.3
" (relativenumber is not supported below)
if exists('g:loaded_numbertoggle') || &cp || v:version < 703
  finish
endif

let g:loaded_numbertoggle = 1
let g:insertmode = 0
let g:focus = 1

" 0: no number
" 1: absolute number
" 2: relative number
let g:numbermode = 0

function! DisableNumbers()
  Decho "disabling numbers"
  set nonumber
  set norelativenumber
endfunction

function! EnableAbsoluteNumbers()
  Decho "enabling absolute numbers"
  set number
  set norelativenumber
endfunction

function! EnableRelativeNumbers()
  Decho "enabling relative numbers"
  set number
  set relativenumber
endfunction

" NumberToggle toggles between modi
function! NumberToggle()
  if(g:numbermode == 0)
    call EnableAbsoluteNumbers()
    let g:numbermode = 1
  elseif(g:numbermode == 1)
    call EnableRelativeNumbers()
    let g:numbermode = 2
  else
    call DisableNumbers()
    let g:numbermode = 0
  endif
endfunc

function! UpdateMode()
  Decho "number: " g:numbermode
  Decho "focus:  " g:focus
  Decho "insert: " g:insertmode
  if(g:numbermode != 0)
    if(g:focus == 0)
      Decho "absolute numbers"
      call EnableAbsoluteNumbers()
    elseif(g:insertmode == 0 && g:numbermode == 2)
      Decho "relative numbers"
      call EnableRelativeNumbers()
    else
      Decho "absolute numbers"
      call EnableAbsoluteNumbers()
    endif
  else
    Decho "no numbers"
    call DisableNumbers()
  endif
  Decho ""

  if !exists("&numberwidth") || &numberwidth <= 4
    " Avoid changing actual width of the number column with each jump between
    " number and relativenumber:
    let &numberwidth = max([4, 1+len(line('$'))])
  else
    " Explanation of the calculation:
    " - Add 1 to the calculated maximal width to make room for the space
    " - Assume 4 as the minimum desired width if &numberwidth is not set or is
    "   smaller than 4
    let &numberwidth = max([&numberwidth, 1+len(line('$'))])
  endif
endfunc

function! FocusGained()
  let g:focus = 1
  call UpdateMode()
endfunc

function! FocusLost()
  let g:focus = 0
  call UpdateMode()
endfunc

function! InsertLeave()
  let g:insertmode = 0
  call UpdateMode()
endfunc

function! InsertEnter()
  let g:insertmode = 1
  call UpdateMode()
endfunc

" Automatically set relative line numbers when opening a new document
autocmd BufNewFile * :call UpdateMode()
autocmd BufReadPost * :call UpdateMode()
autocmd FilterReadPost * :call UpdateMode()
autocmd FileReadPost * :call UpdateMode()

" Automatically switch to absolute numbers when focus is lost and switch back
" when the focus is regained.
autocmd FocusLost * :call FocusLost()
autocmd FocusGained * :call FocusGained()
autocmd WinLeave * :call FocusLost()
autocmd WinEnter * :call FocusGained()

" Switch to absolute line numbers when the window loses focus and switch back
" to relative line numbers when the focus is regained.
autocmd WinLeave * :call FocusLost()
autocmd WinEnter * :call FocusGained()

" Switch to absolute line numbers when entering insert mode and switch back to
" relative line numbers when switching back to normal mode.
autocmd InsertEnter * :call InsertEnter()
autocmd InsertLeave * :call InsertLeave()

" ensures default behavior / backward compatibility
if ! exists ( 'g:UseNumberToggleTrigger' )
  let g:UseNumberToggleTrigger = 1
endif

if exists('g:NumberToggleTrigger')
  exec "nnoremap <silent> " . g:NumberToggleTrigger . " :call NumberToggle()<cr>"
elseif g:UseNumberToggleTrigger
  nnoremap <silent> <C-n> :call NumberToggle()<cr>
endif
