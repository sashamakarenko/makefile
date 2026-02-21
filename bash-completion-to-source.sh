
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
        words="$(grep '^\w.*:' Makefile | grep -v = | egrep -v % | grep -v '\$' | cut -f1 -d:) all release debug clean clean-tests clean-lcov lcov check recheck go gdb ldd gdb-debug gdb-release gdb-test- build-all-tests rebuild rebuild-all test- new-class generate-vscode show-git-status show-var-"
    fi
    if [[ ${#COMP_WORDS[@]} -ge 2 ]]; then
        if [[ ${COMP_WORDS[1]} = new-class ]]; then
            if [[ ${#COMP_WORDS[@]} -eq 3 ]]; then
                words="$words CLASS="
            fi
        else
            words="$words BUILD_MODE=debug BUILD_MODE=release"
        fi
    fi
    COMPREPLY=($(compgen -W "$words" -- "$cur" ))
}

complete -F __makefile_maka_complete make
