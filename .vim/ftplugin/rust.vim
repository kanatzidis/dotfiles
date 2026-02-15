" Run the test under the cursor with Ctrl+K
function! s:FindRustTestFunctionName()
    let lnum = line('.')
    let function_name = ""

    " find the nearest fn declaration above the cursor
    while lnum > 0
        let line_text = getline(lnum)
        if match(line_text, '^\s*fn\s\+\(\k\+\)') >= 0
            let function_name = matchstr(line_text, '^\s*fn\s\+\zs\k\+')
            break
        endif
        let lnum -= 1
    endwhile

    if function_name == ""
        return ""
    endif

    " check if we're inside a mod tests block
    while lnum > 0
        let line_text = getline(lnum)
        if match(line_text, '^\s*mod tests\s*{') >= 0
            return function_name
        endif
        let lnum -= 1
    endwhile

    return ""
endfunction

function! s:RunTests()
    let function_name = s:FindRustTestFunctionName()
    let filename = expand('%:t:r')
    if function_name != ""
        let command = "cargo test " . filename . "::tests::" . function_name . " -- --nocapture"
    else
        let command = "cargo test -- --nocapture"
    endif
    write
    execute "!" . command
endfunction

nnoremap <buffer> <C-k> :call <SID>RunTests()<CR>
