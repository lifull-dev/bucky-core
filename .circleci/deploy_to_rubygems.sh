VERSION=$(git describe --tags | sed -e 's/^v//')
git config user.email "bucky-operator@users.noreply.github.com"
git config user.name "bucky-operator"
# Update version.rb
sed -i '' -e "s/VERSION = '[0-9]\{1,\}.[0-9]\{1,\}.[0-9]\{1,\}'/VERSION = '$VERSION'/" lib/bucky/version.rb
git diff
git checkout master
git add lib/bucky/version.rb
git commit -m "Version $VERSION"
# Build and release gem
gem build bucky-core.gemspec
gem push "bucky-core-$VERSION.gem"
# Push to master
git push origin master