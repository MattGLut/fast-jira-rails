# Ruby environment setup for Windows with Smart App Control workaround
$env:RI_FORCE_PATH_FOR_DLL = "1"
$env:PATH = "C:\Ruby33-x64\bin;C:\Ruby33-x64\lib\ruby\3.3.0\x64-mingw-ucrt;C:\Ruby33-x64\msys64\ucrt64\bin;C:\Ruby33-x64\msys64\usr\bin;" + $env:PATH
