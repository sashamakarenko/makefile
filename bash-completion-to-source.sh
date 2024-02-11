
__makefile_maka_complete()
{
    local words
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ -n "$cur" && t = "${cur:0:1}" ]]; then
        words=$( for f in src/tests/Test*.cpp; do if [[ -f $f ]]; then ff=$(basename $f); fff=${ff%%.cpp}; echo test-${fff#Test}; fi; done )
    elif [[ -n "$cur" && gdb-t = "${cur:0:5}" ]]; then
        words=$( for f in src/tests/Test*.cpp; do if [[ -f $f ]]; then ff=$(basename $f); fff=${ff%%.cpp}; echo gdb-test-${fff#Test}; fi; done )
    elif [[ -n "$cur" && r = "${cur:0:1}" ]]; then
        words=$( for f in src/tests/Test*.cpp; do if [[ -f $f ]]; then ff=$(basename $f); fff=${ff%%.cpp}; echo retest-${fff#Test}; fi; done )
    elif [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
        words="all release debug clean clean-tests check recheck go gdb gdb-debug gdb-release gdb-test build-all-tests test-"
    #elif [[ "BUILD_MODE=" = "$cur" ]]; then
    #    words="BUILD_MODE=debug BUILD_MODE=release"        
    fi
    if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
        words="$words BUILD_MODE=debug BUILD_MODE=release"        
    fi
    COMPREPLY=($(compgen -W "$words" -- "$cur" ))
}

complete -F __makefile_maka_complete make
