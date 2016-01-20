#!/usr/bin/env bash

mkdir -p "results" 

repo='git@github.com:SebsLittleHelpers/scala-js.git'
repoFolder='scala-js'

if [ ! -d "$repoFolder" ]; then
  rm -rf "$repoFolder"
  git clone "$repo" "$repoFolder"
fi

cd $repoFolder

for i in {1..3}; do
  for branch in "master" "isInstanceOf"; do
    git checkout $branch
  
    printf "\n$branch-fastopt-$i:\n\n"
    sbt ';clean 
        ;set jsEnv in toolsJS :=
          NodeJSEnv(args = Seq("--max_old_space_size=4096")).value.withSourceMap(false)
        ;set scalaJSUseRhino in Global := false
        ;toolsJS/test' | tee "../results/$branch-fastopt-toolJS-raw-$i.txt";
    
    grep -A13 "Linker: Compute reachability:" \
      "../results/$branch-fastopt-toolJS-raw-$i.txt" > "../results/$branch-fastopt-toolJS-$i.txt"

  
    printf "\n$branch-fullopt-$i:\n\n"
    sbt ';clean
        ;set jsEnv in toolsJS :=
          NodeJSEnv(args = Seq("--max_old_space_size=4096")).value.withSourceMap(false)
        ;set scalaJSUseRhino in Global := false
        ;set scalaJSStage in Global := FullOptStage
        ;toolsJS/test' | tee "../results/$branch-fullopt-toolJS-raw-$i.txt";
    
    grep -A13 "Linker: Compute reachability:" \
      "../results/$branch-fullopt-toolJS-raw-$i.txt" > "../results/$branch-fullopt-toolJS-$i.txt"
  
  done
done
