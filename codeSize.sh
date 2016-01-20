#!/usr/bin/env bash

mkdir -p "results" 

repo='git@github.com:SebsLittleHelpers/scala-js.git'
repoFolder='scala-js'

if [ ! -d "$repoFolder" ]; then
  rm -rf "$repoFolder"
  git clone "$repo" "$repoFolder"
fi

cd $repoFolder

for branch in "master" "isInstanceOf"; do
  # Clean all generated files
  git clean -fxd

  echo "Measuring for $branch:"

  git checkout $branch

  sbt 'reversi/fastOptJS'
  mv "examples/reversi/target/scala-2.11/reversi-fastopt.js" "../results/$branch-reversi-fastopt.js"
  
  sbt 'reversi/fullOptJS'
  mv "examples/reversi/target/scala-2.11/reversi-opt.js" "../results/$branch-reversi-fullopt.js"
  

  sbt 'testSuite/test:fastOptJS'
  mv "test-suite/js/target/scala-2.11/scalajs-test-suite-test-fastopt.js" "../results/$branch-test-fastopt.js"

  sbt 'testSuite/test:fullOptJS'
  mv "test-suite/js/target/scala-2.11/scalajs-test-suite-test-opt.js" "../results/$branch-test-fullopt.js"

done
