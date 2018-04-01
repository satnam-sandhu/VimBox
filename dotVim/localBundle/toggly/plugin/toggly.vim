" Implementation of a "HUD" style overlay that does not disrupt your
" coding windows when toggling the quickfix/location lists!

if exists("g:loaded_toggly")
  finish
endif

let g:loaded_toggly=1


" includes window position code coppied from
" [asyncrun](https://github.com/skywind3000/asyncrun.vim)
" See LICENSE in this file's directory.

" We keep track of whether or not the quickfix or location list is currently
" open via Toggly, and then based on that always keep the variable
" g:VimSplitBalancerSupress up to date. The convention is that we will supress
" all automatic split balancing while either location or quickfix is open
" because you're tabbing around to get to that location list.
" We also set VimSplitBalancerSupress to 1 just while we figure out if the qf
" is open because it involves jumping around a bunch of windows
" programatically.
let g:TogglyLocationListOpen=0
let g:TogglyQuickFixOpen=0
function! Toggly(locationList)
  " Supress auto-resizing just while we even find out if quickfix is open.
  let g:VimSplitBalancerSupress=1
  function! s:WindowCheck(mode)
    if getbufvar('%', '&buftype') == 'quickfix'
      let s:quickfix_open = 1
      return
    endif
    if a:mode == 0
      let w:quickfix_save = winsaveview()
    else
      call winrestview(w:quickfix_save)
    endif
  endfunc
  let s:quickfix_open = 0
  let l:winnr = winnr()
  windo call s:WindowCheck(0)
  try
    " Move to the window you were in before windo
    silent exec ''.l:winnr.'wincmd w'
  catch /.*/
  endtry
  if s:quickfix_open == 0
    try
      if a:locationList
        if exists("g:toggly_lopen_command")
          exec(g:toggly_lopen_command)
        else
          exec ("bo lopen 5")
        endif
        let g:TogglyLocationListOpen=1
      else
        if exists("g:toggly_copen_command")
          exec(g:toggly_copen_command)
        else
          exec ("bo copen 5")
        endif
        let g:TogglyQuickFixOpen=1
      endif
      " Moves cursor to the top
      wincmd k
    catch /E776/
        " Problem: these aren't printed without the redraw
        " Strangely, try to print it a second time and it works.
        redrawstatus
        echohl ErrorMsg
        echo "Location List is Empty."
        echohl None
        let g:TogglyLocationListOpen=0
        let g:VimSplitBalancerSupress=g:TogglyLocationListOpen || g:TogglyQuickFixOpen ? 1 : 0
        return 0
    endtry
  else
    if a:locationList
      let g:TogglyLocationListOpen=0
      lclose
    else
      let g:TogglyQuickFixOpen=0
      cclose
    endif
  endif
  windo call s:WindowCheck(1)
  try
    " Move to the window you were in before windo
    silent exec ''.l:winnr.'wincmd w'
  catch /.*/
  endtry
  let g:VimSplitBalancerSupress=g:TogglyLocationListOpen || g:TogglyQuickFixOpen ? 1 : 0
endfunction

" TODO: Back up old winwidth/minwidthwidth/winheigh/minwidthheight before
" doing the commands above because window sizes will reset.


" See dotVim/keysVimRc
" nmap <script> <silent> <D-r> :call Toggly(1)<CR>
" nmap <script> <silent> <D-R> :call Toggly(0)<CR>

