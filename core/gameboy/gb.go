package gameboy

import (
	"archive/zip"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"
	"time"

	"github.com/csbzy/gof/core/pkg/gb"
	"github.com/csbzy/gof/core/pkg/gba"
	pb "github.com/csbzy/gof/core/proto/gameboy"
	"gitlab.com/squarealfa/dart_bridge/ffi"
)

const (
	keyModeRelease = 1
	keyModePress   = 0
)

func Load(filename string) (Gamer, error) {
	var (
		actualFileName string
		isZip          bool
	)
	if strings.HasSuffix(filename, ".zip") {
		reader, err := zip.OpenReader(filename)
		if err != nil {
			return nil, err
		}
		if len(reader.File) != 1 {
			return nil, errors.New("zip must contain one file")
		}
		actualFileName = reader.File[0].FileHeader.Name
		isZip = true
	}

	println(filename, actualFileName)
	var g Gamer
	if strings.HasSuffix(actualFileName, ".gb") || strings.HasSuffix(actualFileName, ".gbc") {
		g = &Gameboy{
			Close: make(chan struct{}),
			Event: make(chan *pb.ButtonEvent, 10),
		}
	}

	if strings.HasSuffix(actualFileName, ".gba") {
		g = &GameboyAdvanced{
			Close: make(chan struct{}),
			Event: make(chan *pb.ButtonEvent, 10),
		}
	}
	if g == nil {
		return nil, errors.New("unknow file format " + filename)
	}
	fmt.Println(g)

	if err := g.Load(filename, isZip); err != nil {
		return nil, err
	}

	return g, nil

}

type Gamer interface {
	Load(path string, isZip bool) error
	Stop()
	Loop(port int64)
	Rec(e *pb.ButtonEvent)
	GameType() string
}

type GameboyAdvanced struct {
	Core      *gba.GBA
	Close     chan struct{}
	Event     chan *pb.ButtonEvent
	pressFlag byte
}

func (g *GameboyAdvanced) btnA() bool      { return ((g.pressFlag >> gba.A) & 1) == 1 }
func (g *GameboyAdvanced) btnB() bool      { return ((g.pressFlag >> gba.B) & 1) == 1 }
func (g *GameboyAdvanced) btnSelect() bool { return ((g.pressFlag >> gba.Select) & 1) == 1 }
func (g *GameboyAdvanced) btnStart() bool  { return ((g.pressFlag >> gba.Start) & 1) == 1 }
func (g *GameboyAdvanced) btnRight() bool  { return ((g.pressFlag >> gba.Right) & 1) == 1 }
func (g *GameboyAdvanced) btnLeft() bool   { return ((g.pressFlag >> gba.Left) & 1) == 1 }
func (g *GameboyAdvanced) btnUp() bool     { return ((g.pressFlag >> gba.Up) & 1) == 1 }
func (g *GameboyAdvanced) btnDown() bool   { return ((g.pressFlag >> gba.Down) & 1) == 1 }
func (g *GameboyAdvanced) btnR() bool      { return false }
func (g *GameboyAdvanced) btnL() bool      { return false }

func (g *GameboyAdvanced) Rec(e *pb.ButtonEvent) {
	g.Event <- e
}

func (g *GameboyAdvanced) GameType() string {
	return "gba"
}

func (g *GameboyAdvanced) Load(path string, isZip bool) error {
	if g.Core != nil {
		g.Stop()
	}

	var (
		bytes []byte
		err1  error
	)
	if isZip {
		reader, err := zip.OpenReader(path)
		if err != nil {
			return err
		}
		if len(reader.File) != 1 {
			return errors.New("zip must contain one file")
		}
		f := reader.File[0]
		fo, err := f.Open()
		if err != nil {
			return err
		}

		bytes, err1 = io.ReadAll(fo)
	} else {
		bytes, err1 = os.ReadFile(path)

	}

	if err1 != nil {
		return err1
	}

	g.Core = gba.New(bytes, nil, true, false)
	g.Core.SoftReset()
	g.Core.SetJoypadHandler([10]func() bool{
		g.btnA, g.btnB, g.btnSelect, g.btnStart, g.btnRight, g.btnLeft, g.btnUp, g.btnDown, g.btnR, g.btnL,
	})

	return nil
}

func (g *GameboyAdvanced) Stop() {
	g.Close <- struct{}{}
}

func (g *GameboyAdvanced) Loop(port int64) {
	frameTime := time.Second / gb.FramesSecond

	ticker := time.NewTicker(frameTime)
	defer ticker.Stop()
	start := time.Now()
	frames := 0

	for {
		select {
		case <-ticker.C:
			frames++
			defer g.Core.PanicHandler("core", true)
			g.Core.Update()

			ffi.SendMessage(port, &pb.EventToC{
				Type:  1,
				Value: g.Core.Draw(),
			})
			since := time.Since(start)
			if since > time.Second {
				start = time.Now()

				ffi.SendMessage(port, &pb.EventToC{
					Type:  2,
					Value: []byte(fmt.Sprintf("%s (FPS: %2v)\n", g.Core.CartInfo(), frames)),
				})

				frames = 0
			}
		case e := <-g.Event:
			if e.Mode == keyModePress {
				g.pressFlag = g.pressFlag | byte(1<<e.Key)
			} else {
				g.pressFlag = g.pressFlag & ^(1 << e.Key)
			}

		case <-g.Close:
			return

		}
	}
}

type Gameboy struct {
	Core  *gb.Gameboy
	Close chan struct{}
	Event chan *pb.ButtonEvent
}

func (g *Gameboy) Rec(e *pb.ButtonEvent) {
	g.Event <- e
}

func (g *Gameboy) GameType() string {
	return "gb"
}

func (g *Gameboy) Load(path string, isZip bool) error {
	var opts []gb.GameboyOption
	if g.Core != nil {
		g.Stop()
	}

	var err error
	g.Core, err = gb.NewGameboy(path, opts...)
	return err
}

func (g *Gameboy) Stop() {
	g.Close <- struct{}{}
}

func (g *Gameboy) Loop(port int64) {
	frameTime := time.Second / gb.FramesSecond

	ticker := time.NewTicker(frameTime)
	defer ticker.Stop()
	start := time.Now()
	frames := 0

	var cartName string
	if g.Core.IsGameLoaded() {
		cartName = g.Core.Memory.Cart.GetName()
	}

	for {
		select {
		case <-ticker.C:
			frames++
			_ = g.Core.Update()
			var b = []byte{}

			for y := 0; y < gb.ScreenHeight; y++ {
				for x := 0; x < gb.ScreenWidth; x++ {
					col := g.Core.PreparedData[x][y]
					b = append(b, col[0], col[1], col[2])
				}
			}
			ffi.SendMessage(port, &pb.EventToC{
				Type:  1,
				Value: b,
			})

			since := time.Since(start)
			if since > time.Second {
				println("loop ", b[:20])

				start = time.Now()

				ffi.SendMessage(port, &pb.EventToC{
					Type:  2,
					Value: []byte(fmt.Sprintf("%s (FPS: %2v)\n", cartName, frames)),
				})

				frames = 0
			}

		case r := <-g.Event:
			var bs = gb.ButtonInput{}
			if r.Mode == keyModePress {
				bs.Pressed = append(bs.Pressed, gb.Button(r.Key))
			} else {
				bs.Released = append(bs.Released, gb.Button(r.Key))
			}
			g.Core.ProcessInput(bs)
		case <-g.Close:
			return
		}
	}
}
