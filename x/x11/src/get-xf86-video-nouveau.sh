# Pull a stable branch + patches
BRANCH=master

#rm -rf xf86-video-nouveau
if [ -d xf86-video-nouveau ]; then
  cd xf86-video-nouveau
  git pull -f
  cd ..
else
  git clone git://anongit.freedesktop.org/git/nouveau/xf86-video-nouveau/
fi

# use master branch
#( cd xf86-video-nouveau 
#  git checkout $BRANCH || exit 1
#)

HEADISAT="$(cat xf86-video-nouveau/.git/packed-refs | grep refs/remotes/origin/$BRANCH | cut -b1-7)"
# Cleanup.  We're not packing up the whole git repo.
( cd xf86-video-nouveau && find . -type d -name ".git*" -exec rm -rf {} \; 2> /dev/null )
DATE=$(date +%Y%m%d)
mv xf86-video-nouveau xf86-video-nouveau-git_${DATE}_${HEADISAT}
tar cf xf86-video-nouveau-git_${DATE}_${HEADISAT}.tar xf86-video-nouveau-git_${DATE}_${HEADISAT}
xz -9 xf86-video-nouveau-git_${DATE}_${HEADISAT}.tar
rm -rf xf86-video-nouveau-git_${DATE}_${HEADISAT}
echo
echo "xf86-video-nouveau branch $BRANCH with HEAD at $HEADISAT packaged as xf86-video-nouveau-git_${DATE}_${HEADISAT}.tar.xz"
echo
