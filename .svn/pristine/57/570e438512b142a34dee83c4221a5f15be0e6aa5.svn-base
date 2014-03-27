set MAVEN_OPTS=-Dfile.encoding=utf-8
cd /d %~dp0
call mvn clean
call mvn install -Dmaven.test.skip=true
call mvn package -Dmaven.test.skip=true
pause