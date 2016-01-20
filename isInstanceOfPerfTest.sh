#!/usr/bin/env bash

# Make sure all branches are published
./pubLocalBranches.sh

mkdir -p "results" 

perf='perf-isInstanceOf'

if [ ! -d "$perf" ]; then
  rm -rf "$perf"
  git clone 'git@github.com:SebsLittleHelpers/perf-isInstanceOf.git' "$perf"
fi

cd "$perf"

for branch in "master" "isInstanceOf"; do

  version="0.6.6-$branch-SNAPSHOT"
     
  echo "addSbtPlugin(\"org.scala-js\" % \"sbt-scalajs\" % \"$version\")" \
    > project/plugins.sbt;

  for i in {1..5}; do
    sbt ';clean
        ;set scalaJSUseRhino in Global := false
        ;set scalaJSStage in Global := FastOptStage
        ;run' | tee "../results/$branch-perf-fastopt-raw-$i.txt";
    
    grep -A7 "All Test finished :" \
      "../results/$branch-perf-fastopt-raw-$i.txt" > "../results/$branch-perf-fastopt-$i.txt";

  
    sbt ';clean
        ;set scalaJSUseRhino in Global := false
        ;set scalaJSStage in Global := FullOptStage
        ;run' | tee "../results/$branch-perf-fullopt-raw-$i.txt";
    
    grep -A7 "All Test finished :" \
      "../results/$branch-perf-fullopt-raw-$i.txt" > "../results/$branch-perf-fullopt-$i.txt";
  done 
done
