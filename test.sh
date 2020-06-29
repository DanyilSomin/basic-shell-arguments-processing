#!/bin/sh

install=0
stepFilterUsed=0
allSteps="first second third fourth fifth"
stepsToInstall=$allSteps
iofile='test.env'

assertInstalationStepFilterNotUsed()
{
    if [ $stepFilterUsed -gt 0 ] ; then
        echo "only one type of instalation step filter are allowed at one time"
        exit
    fi
}

assertInstalationStepValid()
{
    if ! echo $allSteps | grep -q -w $1 ; then
        echo "$1 is not valid instalation step"
        exit
    fi
}

if [ $# -eq 0 ] ; then
    echo "use -h for help page"
    exit
fi

while [ $# -gt 0 ] 
do 
    case $1 in
    "-i")
        install=1
        shift 1
        ;;

    "-h")
        echo "this is help page"
        exit
        ;;

    "--set-test-var")
        if [ $# -le 1 ] ; then
            echo "you must to specify starting step after '--set-test-var'"
            exit
        fi

        shift 1

        if  [ -e $1 ] ; then
            sed -i 's/TEST_VAR=.*/TEST_VAR='$1'/' $iofile
        else
            echo "$1 is not valid file"
            exit
        fi

        shift 1
        ;;

    "--start-from")
        assertInstalationStepFilterNotUsed
        stepFilterUsed=1
        if [ $# -le 1 ] ; then
            echo "you must to specify starting step after '--start-from'"
            exit
        fi

        shift 1

        assertInstalationStepValid $1
        for step in $stepsToInstall
        do
            if [ "$1" = "$step" ] ; then 
                break
            else
                stepsToInstall=$(echo $stepsToInstall | sed -e "s/$step//")
            fi
        done

        shift 1
        ;;  

    "--all-exept")
        assertInstalationStepFilterNotUsed
        stepFilterUsed=1
        shift 1

        if [ $# -le 0 ] || echo $1 | grep -q '^-' ; then
            echo "you must to specify steps after '--all-exept'"
            exit
        fi

        while [ $# -gt 0 ] && ! echo $1 | grep -q '^-' ; do
            assertInstalationStepValid $1
            stepsToInstall=$(echo $stepsToInstall | sed -e "s/$1//")
            shift 1
        done
        ;;

    "--only")
        assertInstalationStepFilterNotUsed
        stepFilterUsed=1
        shift 1

        if [ $# -le 0 ] || echo $1 | grep -q '^-' ; then
            echo "you must to specify steps after '--only'"
            exit
        fi

        stepsToInstall=""
        while [ $# -gt 0 ] && ! echo $1 | grep -q '^-' ; do
            assertInstalationStepValid $1
            stepsToInstall="${stepsToInstall} $1"
            shift 1
        done
        ;;
    *)
        echo "uncnown argument '$1' passed"
        exit
        ;;
    esac
done

if [ $install -gt 0 ] ; then
    if echo $stepsToInstall | grep -q "first" ; then
        echo "first"
    fi

    if echo $stepsToInstall | grep -q "second" ; then
        echo "second"
    fi
    
    if echo $stepsToInstall | grep -q "third" ; then
        echo "third"
    fi
    
    if echo $stepsToInstall | grep -q "fourth" ; then
        echo "fourth"
    fi

    if echo $stepsToInstall | grep -q "fifth" ; then
        echo "fifth"
    fi
fi