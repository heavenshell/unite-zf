let s:save_cpo = &cpo
set cpo&vim

" Variables  "{{{
call unite#util#set_default('g:unite_source_zf_ignore_pattern',
      \'^\%(/\|\a\+:/\)$\|\%(^\|/\)\.\.\?$\|empty$\|\~$\|\.\%(o|exe|dll|bak|sw[po]\)$')
"}}}
"
function! s:zf_app()
  let dir = finddir("app" , ".;")
  if dir == ""
    return finddir("application" , ".;")
  endif
  return dir
endfunction

function! s:zf_root()
  let dir = s:zf_app()
  if dir == "" | return "" | endif
  return  dir . "/../"
endfunction

let s:app = fnamemodify(s:zf_app(), ":t:r")

let s:places = [
      \ {'name' : ''            , 'path' : '/' . s:app                    } ,
      \ {'name' : s:app         , 'path' : '/' . s:app                    } ,
      \ {'name' : 'controllers' , 'path' : '/' . s:app . '/controllers'   } ,
      \ {'name' : 'models'      , 'path' : '/' . s:app . '/models'        } ,
      \ {'name' : 'views'       , 'path' : '/' . s:app . '/views'         } ,
      \ {'name' : 'modules'     , 'path' : '/' . s:app . '/modules'       } ,
      \ {'name' : 'configs'     , 'path' : '/' . s:app . '/configs'       } ,
      \ {'name' : 'layouts'     , 'path' : '/' . s:app . '/layouts'       } ,
      \ {'name' : 'helpers'     , 'path' : '/' . s:app . '/views/helpers' } ,
      \ {'name' : 'filters'     , 'path' : '/' . s:app . '/views/filters' } ,
      \ {'name' : 'plugins'     , 'path' : '/' . s:app . '/plugins'       } ,
      \ {'name' : 'services'    , 'path' : '/' . s:app . '/services'      } ,
      \ {'name' : 'forms'       , 'path' : '/' . s:app . '/forms'         } ,
      \ {'name' : 'test'        , 'path' : '/tests'                       } ,
      \  ]


" if resources and locales directories are exists, add to places.
" Using resources and locales are decided by project use-case.
if isdirectory(s:zf_root() . '/resources')
  call add(s:places, {'name' : 'resources', 'path' : '/resources'})
elseif isdirectory(s:zf_app() . '/resources')
  call add(s:places, {'name' : 'resources', 'path' : '/' . s:app . '/resources'})
endif
if isdirectory(s:zf_root() . '/locales')
  call add(s:places, {'name' : 'locales', 'path' : '/locales'})
elseif isdirectory(s:zf_app() . '/locales')
  call add(s:places, {'name' : 'locales', 'path' : '/' . s:app . '/locales'})
endif

let s:source = {}

function! s:source.gather_candidates(args, context)
  return s:create_sources(self.path)
endfunction

" zf/command
"   history
"   [command] zf

let s:source_command = {}

function! unite#sources#zf#define()
  return map(s:places ,
        \   'extend(copy(s:source),
        \    extend(v:val, {"name": "zf/" . v:val.name,
        \   "description": "candidates from history of " . v:val.name}))')
endfunction

function! s:create_sources(path)
  let root = s:zf_root()
  if root == "" | return [] | end
  let files = map(split(globpath(root . a:path , '**') , '\n') , '{
        \ "name" : fnamemodify(v:val , ":t:r") ,
        \ "path" : v:val
        \ }')

  let list = []
  for f in files
    if isdirectory(f.path) | continue | endif

    if g:unite_source_zf_ignore_pattern != '' &&
          \ f.path =~  string(g:unite_source_zf_ignore_pattern)
        continue
    endif

    call add(list , {
          \ "abbr" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "word" : substitute(f.path , root . a:path . '/' , '' , ''),
          \ "kind" : "file" ,
          \ "action__path"      : f.path ,
          \ "action__directory" : fnamemodify(f.path , ':p:h:h') ,
          \ })
  endfor

  return list
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
