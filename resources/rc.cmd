cls
echo *************************
echo    COMPILADOR RECURSOS 
echo *************************
del gmlibres.res
del gmmapres.res
brcc32 gmlibres.rc > Err_gmlibres.txt
brcc32 gmmapres.rc > Err_gmmapres.txt