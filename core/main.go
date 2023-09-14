package main

// #include <stdlib.h>
import (
	"C"
	"unsafe"

	"sync"
	"time"

	"fmt"

	"github.com/csbzy/gof/core/gameboy"
	pb "github.com/csbzy/gof/core/proto/gameboy"
	"gitlab.com/squarealfa/dart_bridge/ffi"
	proto "google.golang.org/protobuf/proto"
)
import (
	"github.com/dgraph-io/badger"
)

func main() {
	fmt.Println(8&1<<3, 8&(1<<3) , 253>>3&1 ,(253>>3)&1)

}

var (
	isInitialized     bool = false
	isInitializedLock sync.RWMutex
	game              gameboy.Gamer
)

//export initialize
func initialize(api unsafe.Pointer) {
	isInitializedLock.Lock()
	defer isInitializedLock.Unlock()

	if isInitialized {
		return
	}
	isInitialized = true

	ffi.Init(api)
}

//export loadGame
func loadGame(port int64, buffer *C.uchar, size int) {
	filePath := ffi.GetStringFromMessage(unsafe.Pointer(buffer), size)
	println(filePath)
	if game != nil {
		game.Stop()
	}
	var err error
	game, err = gameboy.Load(filePath)
	println("load err", err)
	if err != nil {
		ffi.SendMessage(port, &pb.EventToC{
			Type:  3,
			Value: []byte(err.Error()),
		})
		return
	}

	go game.Loop(port)
}

//export handleEvent
func handleEvent(port int64, buffer *C.uchar, size int) {
	if game == nil {
		return
	}
	bytes := C.GoBytes(unsafe.Pointer(buffer), C.int(size))

	request := &pb.ButtonEvent{}
	proto.Unmarshal(bytes, request)
	game.Rec(request)
}

//export receiveTime
func receiveTime(port int64, buffer *C.uchar, size int) {
	go func() {
		filePath := ffi.GetStringFromMessage(unsafe.Pointer(buffer), size)
		println(filePath)
		db, err := badger.Open(badger.DefaultOptions(filePath))
		if err != nil {
			ffi.SendStringMessage(port, err.Error())
		}
		defer db.Close()
		var t = time.Tick(time.Second)

		for {
			<-t
			s := 0
			if db == nil {
				db, err = badger.Open(badger.DefaultOptions(filePath))
				if err != nil {
					ffi.SendStringMessage(port, err.Error())
					continue
				}

			}
			seq, err := db.GetSequence([]byte("time"), 1000)
			if err != nil {
				ffi.SendStringMessage(port, err.Error())
				continue
			}
			a, _ := seq.Next()
			s = int(a)
			ffi.SendStringMessage(port, time.Now().String()+fmt.Sprintf("---\n%v", s))

		}
	}()

}
