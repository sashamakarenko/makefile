#!/bin/bash -e

token="Generated. Delete or move this line from first position if you edit this file."

main_dir=$1

all_dirs="$@"
reversed_dirs=$(echo "$all_dirs" | tr ' ' '\n' | tac)

isMyFile()
{
    head -1 $1 | grep -q "$token"
}

getPrjName()
{
    make -s --no-print-directory show-var-PRJ_NAME -C $1
}

getPrjNameVersion()
{
    local nameversion=$(make -s --no-print-directory show-var-PRJ_NAME show-var-PRJ_VERSION -C $1)
    echo $(sed -n 1p <<<"$nameversion")-$(sed -n 2p <<<"$nameversion")
}

getPrjType()
{
    make -s --no-print-directory  show-var-PRJ_TYPE -C $1
}

getPrjUnitTestNames()
{
    make -s --no-print-directory  show-var-TEST_NAMES -C $1
}

buildDefines()
{
    local defines="$(make -s --no-print-directory show-var-$2 -C $1 | sed -e 's/^-D//' -e 's/ -D/\n/g' -e 's/\t-D/\n/g' -e 's/"/\"/g' )"
    local d
    echo "$defines" | while read d; do
        if [[ -n "$d" ]]; then
            printf "\"%s\", " "$(sed s/\"//g <<<$d)"
        fi
    done
}

buildIncludes()
{
    local includes="$(make -s --no-print-directory show-var-$2 -C $1 | sed -e 's/^-I//' -e 's/ -I/\n/g' -e 's/\t-I/\n/g' )"
        local d
        echo "$includes" | while read d; do
            if [[ -n "$d" ]]; then
                 printf "\"$d\", "
            fi
        done
}


# param $1 = mode
# requires var: prjdeps
buildLdPath()
{
    local ldpath
    for d in $prjdeps; do
        local libtype=$(make -s --no-print-directory  show-var-PRJ_LIB_TYPE -C $d)
        if [[ x$libtype = xdynamc ]]; then
            ldpath="${ldpath}$d/build/lib/$1:"
        fi
    done
}

#  __   __   __      __   __   __   __   ___  __  ___    ___  __
# /  ` |__) |__)    |__) |__) /  \ |__) |__  |__)  |  | |__  /__`
# \__, |    |       |    |  \ \__/ |    |___ |  \  |  | |___ .__/
#
# required vars: dir prjdeps
generateCppProperties()
{
    local vscodedir=$dir/.vscode
    local out=$vscodedir/c_cpp_properties.json
    mkdir -p $vscodedir
    if test -f $out && ! isMyFile $out; then
        echo " - will not rebuild $out"
        return
    fi

    echo " - generating $out"
    cat <<EOF_PROPS_START>$out
// $token
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "\${default}",
                "src",
EOF_PROPS_START
    local dep
    for dep in $prjdeps; do
        echo "                 \"$dep/src\"," >>$out
    done
    cat <<EOF_PROPS_END>>$out
            $(buildIncludes $dir CPP_INCLUDES)
            ],
            "defines": [$(buildDefines $dir CPP_DEFINES)
            ]
        }
    ],
    "version": 4
}
EOF_PROPS_END

}

# ___       __        __
#  |   /\  /__` |__/ /__`
#  |  /~~\ .__/ |  \ .__/
#
# required vars: dir prjdeps
generateTasks()
{
    local vscodedir=$dir/.vscode
    local out=$vscodedir/tasks.json
    mkdir -p $vscodedir
    if test -f $out && ! isMyFile $out; then
        echo " - will not rebuild $out"
        #return
    fi

    echo " - generating $out"

    cat <<EOF_TASKS_START>$out
// $token
{
    "version": "2.0.0",
    "tasks": [
EOF_TASKS_START
    for mode in debug release; do
        cat <<EOF_TASKS_MAKE>>$out
        {
            "label": "make $mode",
            "type": "shell",
            "command": "make BUILD_MODE=$mode",
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
EOF_TASKS_MAKE
    done
    local utests=$(getPrjUnitTestNames $dir)
    if [[ -n "$utests" ]]; then
    for mode in debug release; do
        cat <<EOF_TASKS_BUILD_ALL_TESTS>>$out
        {
            "type": "shell",
            "label": "Build all tests ($mode)",
            "command": "make",
            "args": [ "build-all-tests", "BUILD_MODE=$mode" ],
            "options": {
                "cwd": "\${workspaceFolder}"
            },
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
EOF_TASKS_BUILD_ALL_TESTS
        for utest in $utests; do
        cat <<EOF_TASKS_BUILD_TEST>>$out
        {
            "label": "Build Test$utest ($mode)",
            "type": "shell",
            "command": "make",
            "args": [ "build/bin/${mode}/tests/Test$utest.exe", "BUILD_MODE=$mode" ],
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
EOF_TASKS_BUILD_TEST
        done
    done
    fi

    if [[ -n "$prjdeps" ]]; then
        cat <<EOF_TASKS_DEPS>>$out
        {
            "label": "Clean all (with depenencies)",
            "type": "shell",
            "command": "make clean-all",
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Rebuild all (with depenencies)",
            "type": "shell",
            "command": "make rebuild-all",
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
EOF_TASKS_DEPS
     fi

    cat <<EOF_TASKS_CLEAN>>$out
        {
            "label": "Clean",
            "type": "shell",
            "command": "make clean",
            "problemMatcher": [
                "\$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
EOF_TASKS_CLEAN
}

#                      __
# |     /\  |  | |\ | /  ` |__|
# |___ /~~\ \__/ | \| \__, |  |
#
# required vars: dir prjdeps
generateLaunch()
{
    local prjtype=$(getPrjType $dir)
    if [[ exe != $prjtype ]]; then
        local utests=$(getPrjUnitTestNames $dir)
        if [[ -z "$utests" ]]; then
            return
        fi
    fi
    local vscodedir=$dir/.vscode
    local out=$vscodedir/launch.json
    mkdir -p $vscodedir
    if test -f $out && ! isMyFile $out; then
        echo " - will not rebuild $out"
        return
    fi

    echo " - generating $out"
    cat <<EOF_LAUNCH_START>$out
// $token
{
    "version": "0.2.0",
    "configurations": [
EOF_LAUNCH_START


    if [[ exe = $prjtype ]]; then
    local prjname=$(getPrjName $dir)
    for mode in debug; do
        local ldpath=$(buildLdPath $mode)
        cat <<EOF_LAUNCH_EXE>>$out
        {
            "name": "$prjname ($mode)",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/build/bin/$mode/$prjname",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "environment": [
                { "name": "LD_LIBRARY_PATH", "value": "${ldpath}$dir/build/lib/$mode:\${env:LD_LIBRARY_PATH}" }
            ],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        },
EOF_LAUNCH_EXE
    done
    else
    for mode in debug; do
        local ldpath=$(buildLdPath $mode)
        for utest in $utests; do
        cat <<EOF_LAUNCH_TEST>>$out
        {
            "name": "Test$utest ($mode)",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/build/bin/$mode/tests/Test$utest.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "environment": [
                { "name": "LD_LIBRARY_PATH", "value": "${ldpath}$dir/build/lib/$mode:\${env:LD_LIBRARY_PATH}" }
            ],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        },
EOF_LAUNCH_TEST
        done
    done
    fi

    cat <<EOF_LAUNCH_END>>$out
    ]
}
EOF_LAUNCH_END
}

#  __   ___  __   ___       __   ___       __     ___  __
# |  \ |__  |__) |__  |\ | |  \ |__  |\ | /  ` | |__  /__`
# |__/ |___ |    |___ | \| |__/ |___ | \| \__, | |___ .__/
#
for dir in $reversed_dirs; do
    prj=$(getPrjNameVersion $dir)
    prjdeps=$(make -s --no-print-directory show-var-DEP_DIRS -C $dir)
    echo
    echo " $prj $dir "$(for d in $prjdeps; do echo $(basename $d); done)
    generateCppProperties
    if [[ $dir = $main_dir ]]; then
        generateTasks
        generateLaunch
    fi
done


#       __   __        __   __        __   ___
# |  | /  \ |__) |__/ /__` |__)  /\  /  ` |__
# |/\| \__/ |  \ |  \ .__/ |    /~~\ \__, |___
#

main_prj=$(getPrjName $main_dir)
workspace=$main_dir/.vscode/$main_prj.code-workspace

if test -f $workspace && ! isMyFile $workspace; then
    echo " - will not rebuild $workspace"
    exit
fi

echo " - generating $workspace"

cat <<EOF>$workspace
// $token
{
    "folders":
    [
EOF

for dir in $all_dirs; do
prj=$(getPrjNameVersion $dir)
cat <<EOF>>$workspace
        {
            "name": "$prj",
            "path": "$dir"
        },
EOF
done

cat <<EOF>>$workspace
    ]
}
EOF

echo
echo "  You can now open $workspace"
echo

exit

