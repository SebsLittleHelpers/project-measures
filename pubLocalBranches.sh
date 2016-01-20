#!/usr/bin/env bash

mkdir -p "results" 

scalaJS='scala-js'

if [ ! -d "$scalaJS" ]; then
  rm -rf "$scalaJS"
  git clone 'git@github.com:SebsLittleHelpers/scala-js.git' "$scalaJS"
fi

for branch in "master" "isInstanceOf"; do
  version="0.6.6-$branch-SNAPSHOT";
  echo "Publishing version: $version";
  
  
  localRepo="$HOME/.ivy2/local/org.scala-js/sbt-scalajs/scala_2.10/sbt_0.13/$version";

  if [ -d "$localRepo" ]; then 
    echo "Already published in $localRepo"
  else
    cd "$scalaJS";
  
    # Clean all generated files
    git checkout -- .;
    git clean -fxd
    git checkout $branch;
  
  
    # Replace current version with something nicer
    perl -i -pe "s/0.6.6-SNAPSHOT/$version/g" \
      ./ir/src/main/scala/org/scalajs/core/ir/ScalaJSVersions.scala;
  
    # Hack to avoid binary compat warnings
    perl -i -pe "s/val binaryEmitted: String = current/val binaryEmitted: String = \"0.6.5\"/g" \
      ./ir/src/main/scala/org/scalajs/core/ir/ScalaJSVersions.scala;
  
  
    # Publish ScalaJS version
    sbt ';clean
        ;++2.11.7
        ;compiler/publishLocal
        ;library/publishLocal
        ;javalibEx/publishLocal
        ;testInterface/publishLocal
        ;stubs/publishLocal
        ;jasmineTestFramework/publishLocal
        ;jUnitRuntime/publishLocal
        ;jUnitPlugin/publishLocal
        ;++2.10.6
        ;ir/publishLocal
        ;tools/publishLocal
        ;jsEnvs/publishLocal
        ;testAdapter/publishLocal
        ;sbtPlugin/publishLocal';
    
    # Return to parent folder
    cd ..
  fi
done
