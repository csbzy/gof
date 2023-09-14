package gba

import (
	"github.com/csbzy/gof/core/pkg/gba/ram"
)

var (
	wsN  = [4]int{4, 3, 2, 8}
	wsS0 = [2]int{2, 1}
	wsS1 = [2]int{4, 1}
	wsS2 = [2]int{8, 1}
)

func (g *GBA) cycleN(addr uint32) int {
	switch {
	case ram.EWRAM(addr):
		return 3
	case ram.GamePak0(addr):
		offset := ram.IOOffset(ram.WAITCNT)
		idx := g.RAM.IO[offset] >> 2 & 0b11
		return wsN[idx] + 1
	case ram.GamePak1(addr):
		idx := g._getRAM(ram.WAITCNT) >> 5 & 0b11
		return wsN[idx] + 1
	case ram.GamePak2(addr):
		idx := g._getRAM(ram.WAITCNT) >> 8 & 0b11
		return wsN[idx] + 1
	case ram.SRAM(addr):
		idx := g._getRAM(ram.WAITCNT) & 0b11
		return wsN[idx] + 1
	}
	return 1
}

func (g *GBA) cycleS(addr uint32) int {
	switch {
	case ram.EWRAM(addr):
		return 3
	case ram.GamePak0(addr):
		offset := ram.IOOffset(ram.WAITCNT)
		idx := g.RAM.IO[offset] >> 4 & 0b1
		return wsS0[idx] + 1
	case ram.GamePak1(addr):
		idx := g._getRAM(ram.WAITCNT) >> 7 & 0b1
		return wsS1[idx] + 1
	case ram.GamePak2(addr):
		idx := g._getRAM(ram.WAITCNT) >> 10 & 0b1
		return wsS2[idx] + 1
	case ram.SRAM(addr):
		idx := g._getRAM(ram.WAITCNT) & 0b11
		return wsN[idx] + 1
	}
	return 1
}

func (g *GBA) waitBus(addr uint32, size int, s bool) int {
	busWidth := ram.BusWidth(addr)
	if busWidth == 8 {
		return 5 * (size / 8)
	}

	if size > busWidth {
		if s {
			return 2 * g.cycleS(addr)
		}
		return g.cycleN(addr) + g.cycleS(addr+2)
	}

	if s {
		return g.cycleS(addr)
	}
	return g.cycleN(addr)
}
