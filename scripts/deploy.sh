#!/bin/bash
set -e

REPONAME="neovim-nightly"
OWNER="ram02z"
GHIO="${OWNER}.github.io"
TARGET_BRANCH="gh-pages"
EMAIL="omarzeghouanii@gmail.com"
BUILD_DIR="void-packages/hostdir/binpkgs/libluv"
case "$ARCH" in
    *musl* ) LIBC="musl" ;;
    * ) LIBC="glibc" ;;
esac

echo "### Started deploy to $GITHUB_REPOSITORY/$TARGET_BRANCH"

# Prepare build_dir
mkdir -p $HOME/build/$BUILD_DIR
cp -R $BUILD_DIR/* $HOME/build/$BUILD_DIR/

# Create or clone the gh-pages repo
mkdir -p $HOME/branch/
cd $HOME/branch/
git config --global user.name "$GITHUB_ACTOR"
git config --global user.email "$EMAIL"

if [ -z "$(git ls-remote --heads https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git ${TARGET_BRANCH})" ]; then
  echo "Create branch '${TARGET_BRANCH}'"
  git clone --quiet https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git $TARGET_BRANCH > /dev/null
  cd $TARGET_BRANCH
  git checkout --orphan $TARGET_BRANCH
  git rm -rf .
  echo "$REPONAME" > README.md
  git add README.md
  git commit -a -m "Create '$TARGET_BRANCH' branch"
  git push origin $TARGET_BRANCH
  cd ..
else
  echo "Clone branch '${TARGET_BRANCH}'"
  git clone --quiet --branch=$TARGET_BRANCH https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git $TARGET_BRANCH > /dev/null
fi

# Copy files
cd $TARGET_BRANCH
find . -maxdepth 1 -type f -delete
rm -rf $LIBC
mkdir -p $LIBC
cp -Rf $HOME/build/$BUILD_DIR/* $LIBC

# Generate homepage
cat << EOF > index.html
<html>
<head><title>Index of /$REPONAME</title></head>
<body>
<h1>Index of /$REPONAME</h1>
<hr><pre><a href="https://$GHIO">../</a>
EOF

for d in */; do
    dir=$(basename $d)
    size=$(du -s $d | awk '{print $1;}')
    s=$(stat -c %y $d)
    stat=${s%%.*}

    if [ -d "$d" ]; then
        printf '<a href="%s">%-40s%35s%20s\n' "$dir" "$dir</a>" "$stat" "$size" >> index.html
    fi
done

cat << EOF >> index.html
</pre><hr></body>
</html>
EOF

COMMIT_MESSAGE="$GITHUB_ACTOR published a site update"

# Deploy/Push (or not?)
if [ -z "$(git status --porcelain)" ]; then
  result="Nothing to deploy"
else
  git add -Af .
  git commit -m "$COMMIT_MESSAGE"
  git push -fq origin $TARGET_BRANCH > /dev/null
  # push is OK?
  if [ $? = 0 ]
  then
    result="Deploy succeeded"
  else
    result="Deploy failed"
  fi
fi

# Set output
echo $result
echo "::set-output name=result::$result"

echo "### Finished deploy"
