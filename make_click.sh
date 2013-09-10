#!/bin/bash
FROMDIR="$(pwd)"
BUILDDIR="${FROMDIR}_click"
rm -rf $BUILDDIR
cp -r $FROMDIR $BUILDDIR
echo "Entering ${BUILDDIR}"
cd $BUILDDIR
rm -rf .git* debian desktop solitaire-games.qmlp* solitaire-games128.png solitaire-games16.png solitaire-games32.png solitaire-games64.png make_click.sh
cd po
echo "Generating mo files"
./generate_mo.sh
cd ../..
echo "Build click package in `pwd`"
click build $BUILDDIR
cd $FROMDIR

