date /t|set theOneDate=
echo %DATE%
echo %TIME%
set datetimef=%date:~4%_%time:10,1
echo %datetimef%

git add .
git commit -m %datetimef%
git push