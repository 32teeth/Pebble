#!/bin/bash
version=0.0.0

github() {
  version="$1"
  git add .
  git commit -am "build: $version"
  git tag $version -m "build: $version"
  git push origin $version
  git push
  gh release create $version --generate-notes --title $version --notes "Release $version"
}

changelog() {
  file="CHANGELOG.md"
  version="$1"
  changes="What change in this version?"
  list="* Change 1\n* Change 2\n* Change 3"

  sed '1,2d' "$file" > temp_changelog.mdx

  markdown="# Changelog\n\n### $version\n\n$changes\n\n$list\n\n$(cat temp_changelog.mdx)"

  echo -e "$markdown" > "$file"

  rm temp_changelog.mdx
}

update() {
  local package="package.json"
  version=$(jq -r '.version' "$package")

  IFS='.' read -r major minor patch <<< "$version"

  if ((patch < 9)); then
    ((patch++))
  elif ((minor < 9)); then
    ((minor++))
    patch=0
  else
    ((major++))
    minor=0
    patch=0
  fi

  version="$major.$minor.$patch"

  jq ".version = \"$version\"" "$package" > temp.json && mv temp.json "$package"
  changelog "$version"
  npm run sass:build
  github "$version"
}

update