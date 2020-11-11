"" ELixirLS

let g:ElixirLS = {}
let ElixirLS.path = printf('%s/%s', stdpath('config'), 'elixir-ls')
let ElixirLS.lsp = printf('%s/%s', ElixirLS.path, 'release/language_server.sh')
let ElixirLS.cmd = join([
        \ 'cp .release-tool-versions .tool-versions &&',
        \ 'asdf install &&',
        \ 'mix do',
        \ 'local.hex --force --if-missing,',
        \ 'local.rebar --force,',
        \ 'deps.get,',
        \ 'compile,',
        \ 'elixir_ls.release &&',
        \ 'rm .tool-versions'
        \ ], ' ')

function ElixirLS.on_stdout(_job_id, data, _event)
  let self.output[-1] .= a:data[0]
  call extend(self.output, a:data[1:])
endfunction

let ElixirLS.on_stderr = function(ElixirLS.on_stdout)

function ElixirLS.on_exit(_job_id, exitcode, _event)
  if a:exitcode[0] == 0
    echom '>>> ElixirLS compiled'
  else
    echoerr join(self.output, ' ')
    echoerr '>>> ElixirLS compilation failed'
  endif
endfunction

function ElixirLS.compile()
  let me = copy(g:ElixirLS)
  echom '>>> compiling ElixirLS'
  let me.output = ['']
  let me.id = jobstart('cd ' . me.path . ' && git pull && ' . me.cmd, me)
endfunction

call coc#config('elixir', {
  \ 'command': g:ElixirLS.lsp,
  \ 'filetypes': ['eelixir', 'elixir']
  \})
call coc#config('elixir.pathToElixirLS', g:ElixirLS.lsp)
