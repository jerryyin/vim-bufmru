" autoload/bufmru.vim

function! bufmru#sort(b1, b2)
  let t1 = str2float(reltimestr(BufMRUTime(a:b1)))
  let t2 = str2float(reltimestr(BufMRUTime(a:b2)))
  return t1 == t2 ? 0 : t1 > t2 ? -1 : 1
endfunction

function! bufmru#enter()
  let i = bufnr("%")
  if buflisted(i)
    let s:bufmru_files[i] = reltime()  " Update with the current time when buffer is entered
    " Trigger UI update only if needed
    "silent doautocmd User BufMRUChange
    if get(g:, 'airline#extensions#tabline#enabled', 0)
      call airline#extensions#tabline#buflist#invalidate()
    endif
    if !empty(get(g:, 'lightline', {}))
      call lightline#update()
    endif
    if bufnr("$") > 1
      let stl = &showtabline
      set showtabline=0
      let &showtabline = stl
    endif
  endif
endfunction

function! BufMRUTime(bufn)
  return get(s:bufmru_files, a:bufn, s:bufmru_starttime)
endfunction

function! BufMRUList()
  let bufs = GetActiveBuffers()
  call sort(bufs, "bufmru#sort")
  return bufs
endfunction

function! bufmru#show()
  let bufs = BufMRUList()
  for buf in bufs
    let bufn = bufname(buf)
    let buft = reltimestr(BufMRUTime(buf))
    echom buf . " | " . buft . "s | " . bufn
  endfor
endfunction

function! bufmru#init()
  let s:bufmru_files = {}
  let s:bufmru_starttime = reltime()
  call bufmru#autocmd()
endfunction

function! bufmru#autocmd()
  augroup bufmru_buffers
    autocmd!
    autocmd BufEnter * call bufmru#enter()
    autocmd BufEnter * call bufmru#autoclose()
  augroup END
endfunction

" Set the default number of buffers to keep open
if !exists("g:bufmru_nb_to_keep")
  let g:bufmru_nb_to_keep = 25
endif

function! GetActiveBuffers()
  let l:blist = getbufinfo({'buflisted': 1})
  let l:result = []
  for l:item in l:blist
      " Skip unnamed buffers
      if empty(l:item.name)
          continue
      endif
      call add(l:result, l:item.bufnr)
  endfor
  return l:result
endfunction

" Function to limit open buffers to the specified maximum
function! bufmru#autoclose()
  " Get the sorted list of buffers
  let buffers = BufMRUList()

  " Only proceed if the buffer count exceeds the max allowed
  if len(buffers) <= g:bufmru_nb_to_keep
    return
  endif

  let to_delete = len(buffers) - g:bufmru_nb_to_keep
  " Delete the oldest buffers to maintain the max allowed
  for i in range(len(buffers) - 1, len(buffers) - to_delete, -1)
    execute 'bdelete' buffers[i]
  endfor
endfunction
