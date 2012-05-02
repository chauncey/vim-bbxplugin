if exists( "loaded_bbxplugin" )
  finish
endif
let loaded_bbxplugin = 1

let s:OVERWRITE = "N"
let s:PRO5LST = "/usr/local/basis/pro5/pro5lst"
let s:PRO5CPL = "/usr/local/basis/pro5/pro5cpl -m1024"

" I don't think we are using this
"function! BBXLoadFile( BBXSRCFILE )
"  call BBXLoad( a:BBXSRCFILE )
"endfunction

function! BBXLoadInput()
  " First, don't lose unsaved changes
  if &modified
    let s:OVERWRITE = input( "Current buffer not saved!  Continue? <Y/N> ", "N" )
    if s:OVERWRITE != "Y"
      return
    endif  
  endif
  let r = input( "BBx Program: " )
  " glob() does shell expansion on filenames
  let r = glob( r )
  if r != ""
    call BBXLoad( r )
  else
    echo "No file to load."
  endif
  return
endfunction

function! BBXLoad( f )
  let BBxSrcFile = a:f
  if BBxSrcFile != "" && filereadable( BBxSrcFile )
    " open a temporary file for the listing
    let BBxTmpFile = tempname()
    let r = system( "cat " . BBxSrcFile . " | " . s:PRO5LST . " > " . BBxTmpFile )
    if s:OVERWRITE == "Y"
      execute "edit! " . BBxTmpFile
    else
      execute "edit " . BBxTmpFile
    endif
    " store the filenames as buffer variables
    call setbufvar( BBxTmpFile, "BBxTmpFile", BBxTmpFile )
    call setbufvar( BBxTmpFile, "BBxSrcFile", BBxSrcFile )
    " for syntax highlighting if &syntax is on
    setfiletype bbx
    " set the statusline to give temporary and BBx file names, status, and cursor position
    "set statusline=%{getbufvar(bufname(\"%\"),\"BBxSrcFile\")}\ \(%<%f\)\ %h%m%r\ %=%-15.(%l,%c%V%)\ %P
    "set statusline=%{GitStatusLine()}%{getbufvar(bufname(\"%\"),\"BBxSrcFile\")}\ \(%<%f\)\ %h%m%r\ %=%-14.(%l,%c%V%)\ %P
  else
    echo "No file to load."
  endif
  return
  let s:OVERWRITE = "N"
endfunction

"function! GitStatusLine()
"python <<EOF
"import subprocess

"EOF
"endfunction

function! BBXSave()
  " get the files
  let BBxSrcFile = getbufvar( bufname( "%" ), "BBxSrcFile" )
  let BBxTmpFile = getbufvar( bufname( "%" ), "BBxTmpFile" )
  if BBxTmpFile != "" && filewritable( BBxTmpFile )
    " save any pending changes
    execute "write"
    " get a temporary file for the tokenized data
    let l:tmpfile2 = tempname()
    " tokenize it
    let l:r = system( "cat " . BBxTmpFile . " | " . s:PRO5CPL . " > " . l:tmpfile2 )
    if l:r != ""
      echo l:r
    else
      " and replace the existing file with the edited, tokenized file
      let t = system( "mv " . l:tmpfile2 . " " . BBxSrcFile )
      echo BBxSrcFile . " saved."
    endif
  else
    echo "No file to save."
  endif
  return
endfunction
