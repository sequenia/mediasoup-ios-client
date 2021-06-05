1. склонируйте репозиторий
2. перейдите в папку updateDependencies
3. выполните команду chmod a+x build.sh 
4. запустите срипт ./build.sh 
5. по окончанию работы скрипта откроется проект xcode
6. попробуйте сбилдить проект - если не вышло, значит новые зависимости что-то сломали) чиним)
7. после того, как удалось сбилдить проект перетащите в папку build итоги билда - mediasoup-ios-client.framework и WebrRTC.framework из проекта (mediasoup-ios-client/updateDependencies/tempBuild/webrtc-ios/src/out_ios_libs/arm64_libs/WebRTC.framework). 
8. удалите папку tempBuild с артефактами сборки
9. запуште репозиторий в мастер
10. можно делать pod update
