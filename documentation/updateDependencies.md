1. склонируйте репозиторий
2. перейдите в папку updateDependencies
3. выполните команду chmod a+x build.sh 
4. запустите срипт ./build.sh 
5. по окончанию работы скрипта откроется проект xcode
6. сбилдите проект
7. перетащите в свой проект итоги билда - mediasoup-ios-client.framework и WebrRTC.framework из проекта (mediasoup-ios-client/updateDependencies/tempBuild/webrtc-ios/src/out_ios_libs/arm64_libs/WebRTC.framework). Перетащить нужно в папку проекта, затем через меню - добавить фреймворки.
