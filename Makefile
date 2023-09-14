all:proto
	go mod tidy
	#ANDROID_NDK_HOME=~/Android/Sdk/ndk/25.1.8937393/
	#GO111MODULE=on GOARCH=amd64 CGO_ENABLED=1 GOOS=android  CXX=/home/bobo/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang++ CC=/home/bobo/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android21-clang go build -tags android  -ldflags ' -w -s ' -buildmode=c-shared -o ./android/app/libs/x86_64/libgo.so core/main.go
	#echo Build x86_64 finish
	#GO111MODULE=on GOARCH=arm64 CGO_ENABLED=1 GOOS=android  CXX=/home/bobo/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++ CC=/home/bobo/Android/Sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang go build -tags android  -ldflags ' -w -s ' -buildmode=c-shared -o ./android/app/libs/arm64-v8a/libgo.so core/main.go
	#echo Build arm64-v8a finish

	#go build -tags nosqlite -ldflags="-w -s" -buildmode=c-shared -o linux/bundle/lib/libgo.so core/main.go
	#cp linux/bundle/lib/libgo.so .
	go build -tags nosqlite -ldflags="-w -s" -buildmode=c-shared -o macos/Frameworks/lib/libgo.dylib core/main.go
	dart run ffigen


proto: 
	protoc --go_out=./core/proto core/proto/gameboy.proto 
	protoc --dart_out=./lib/proto core/proto/gameboy.proto 
