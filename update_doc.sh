#! /usr/bin/env sh

cd doc/sphinx
make html
cd -
cd ../hutte-doc
cp -r ../hutte/doc/sphinx/_build/html/* .
git add .
git commit -am "Update documentation"
git push origin gh-pages
