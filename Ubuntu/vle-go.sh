#!/bin/bash

function Help {
    echo "Usage:"
    echo "p <project>"
    echo "    Go to the root folder of this project."
    echo "t <project>"
    echo "    Go to the \"Test/Linux\" folder of this project."
    echo "s <project>"
    echo "    Go to the \"Source\" folder of this project"
    echo "u [<project>]"
    echo "    Get the latset code of this project, or all projects if it is not specified."
}

function Go {
    local VPROJ="${VROOT}/$2"
    if ! [ -d $VPROJ ]; then
        echo "Folder \"${VPROJ}\" does not exist."
        return 1
    fi

    pushd $VPROJ > /dev/null
    local GITHEAD="$(git symbolic-ref HEAD 2>/dev/null)"
    if [ "${GITHEAD}" == "" ]; then
        echo "\"${VPROJ}\" is not a valid git repo."
        popd > /dev/null
        return 1
    fi

    local VPATH="${VPROJ}/$1"
    if ! [ -d $VPATH ]; then
        echo Fail "Folder \"${VPATH}\" does not exist."
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
    cd $VPATH
}

function Update {
    if [ "$1" == "" ]; then
        Update Tools
        Update Vlpp
        Update Workflow
        Update GacUI
        Update GacJS
        Update Release
        Update XGac
        Update iGac
        Update vczh-libraries.github.io
    else
        pushd . > /dev/null
        printf "${VC_LIGHTGREEN}Pulling from ${VC_LIGHTBLUE}$1${VC_DEFAULT}\n"
        Go "" $1
        if [ "$PWD" == "${VROOT}/$1" ]; then
            git pull --all
        fi

        local GITHEAD="$(git symbolic-ref HEAD 2>/dev/null)"
        local CURRENT_BRANCH="${GITHEAD##refs/heads/}"
        local BRANCHES=($(git branch | sed -r -e 's/^..//g'))
        for BRANCH in "${BRANCHES[@]}"; do
            printf "${VC_LIGHTGREEN}Updating branch: ${VC_LIGHTCYAN}${BRANCH}${VC_DEFAULT}\n"
            git checkout $BRANCH
            git pull origin $BRANCH
        done
        git checkout $CURRENT_BRANCH

        popd > /dev/null
    fi
}

case $1 in
    --help)
    Help
    ;;

    p)
    Go "" $2
    ;;

    t)
    Go "Test/Linux" $2
    ;;

    s)
    Go "Source" $2
    ;;

    u)
    Update $2
    ;;

    *)
    echo "Use --help for more information."
    ;;
esac
