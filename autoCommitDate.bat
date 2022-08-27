date /t|set theOneDate=
echo %DATE%
echo %TIME%
set datetimef=%date:~4%
echo %datetimef%

git add .
git commit -m %datetimef%
git push