set -e
VERSION=$1
UPDATE=${2:-0}
MINOR=${3:-master}

if [ -z "$VERSION" ]; then
   echo "No version set"
   exit 1
fi

rm .git/hooks/post-commit || true

if [ -z "$ENHANCE_CONTINUE" ]; then
   git -c advice.detachedHead=false checkout $VERSION
   if ! git cherry-pick ${MINOR}..${MINOR}_crac; then
      NCOMMITS=$(git log --format=oneline ${MINOR}..${MINOR}_crac | wc -l) 
      echo '[ $(git log --format=oneline '$VERSION'..HEAD | wc -l) = '$NCOMMITS' ] && ENHANCE_CONTINUE=true '$(pwd)'/enhance.sh '$VERSION $UPDATE $MINOR > .git/hooks/post-commit
      chmod a+x .git/hooks/post-commit
      exit 1
   fi
fi
mvn versions:set -DnewVersion=${VERSION}.CRAC.${UPDATE} -DgenerateBackupPoms=false
mvn versions:set-property -Dproperty=forked.version -DnewVersion=$VERSION -DgenerateBackupPoms=false
git commit -a -m "CRaC-enhanced release ${VERSION}.CRAC.${UPDATE}"
git tag ${VERSION}.CRAC.${UPDATE}
set +x
echo "Now type:"
echo -e "\tgit push crac ${VERSION}.CRAC.${UPDATE}"
