/*
 * Author: Dirk W. Hoffmann. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "C64GUI.h"
#import "C64.h"
#import "VirtualC64-Swift.h"

struct C64Wrapper { C64 *c64; };
struct CpuWrapper { CPU *cpu; };
struct MemoryWrapper { C64Memory *mem; };
struct VicWrapper { VIC *vic; };
struct CiaWrapper { CIA *cia; };
struct KeyboardWrapper { Keyboard *keyboard; };
struct ControlPortWrapper { ControlPort *port; };
struct SidBridgeWrapper { SIDBridge *sid; };
struct IecWrapper { IEC *iec; };
struct ExpansionPortWrapper { ExpansionPort *expansionPort; };
struct Via6522Wrapper { VIA6522 *via; };
struct DiskWrapper { Disk *disk; };
struct Vc1541Wrapper { VC1541 *vc1541; };
struct DatasetteWrapper { Datasette *datasette; };
struct ContainerWrapper { File *container; };

// DEPRECATED
struct SnapshotWrapper { Snapshot *snapshot; };
struct ArchiveWrapper { Archive *archive; };
struct TAPContainerWrapper { TAPFile *tapcontainer; };
struct CRTContainerWrapper { CRTFile *crtcontainer; };


// --------------------------------------------------------------------------
//                                    CPU
// --------------------------------------------------------------------------

@implementation CPUProxy

- (instancetype) initWithCPU:(CPU *)cpu
{
    if (self = [super init]) {
        wrapper = new CpuWrapper();
        wrapper->cpu = cpu;
    }
    return self;
}

- (CPUInfo) getInfo { return wrapper->cpu->getInfo(); }
- (void) dump { wrapper->cpu->dumpState(); }

- (BOOL) tracing { return wrapper->cpu->tracingEnabled(); }
- (void) setTracing:(BOOL)b {
    if (b) wrapper->cpu->startTracing(); else wrapper->cpu->stopTracing(); }

- (uint16_t) pc { return wrapper->cpu->getPC_at_cycle_0(); }
- (void) setPC:(uint16_t)pc { wrapper->cpu->setPC_at_cycle_0(pc); }
- (void) setSP:(uint8_t)sp { wrapper->cpu->setSP(sp); }
- (void) setA:(uint8_t)a { wrapper->cpu->setA(a); }
- (void) setX:(uint8_t)x { wrapper->cpu->setX(x); }
- (void) setY:(uint8_t)y { wrapper->cpu->setY(y); }
- (void) setNflag:(BOOL)b { wrapper->cpu->setN(b); }
- (void) setZflag:(BOOL)b { wrapper->cpu->setZ(b); }
- (void) setCflag:(BOOL)b { wrapper->cpu->setC(b); }
- (void) setIflag:(BOOL)b { wrapper->cpu->setI(b); }
- (void) setBflag:(BOOL)b { wrapper->cpu->setB(b); }
- (void) setDflag:(BOOL)b { wrapper->cpu->setD(b); }
- (void) setVflag:(BOOL)b { wrapper->cpu->setV(b); }

- (BOOL) breakpoint:(uint16_t)addr { return wrapper->cpu->hardBreakpoint(addr); }
- (void) setBreakpoint:(uint16_t)addr { wrapper->cpu->setHardBreakpoint(addr); }
- (void) deleteBreakpoint:(uint16_t)addr { wrapper->cpu->deleteHardBreakpoint(addr); }
- (void) toggleBreakpoint:(uint16_t)addr { wrapper->cpu->toggleHardBreakpoint(addr); }

- (NSInteger) recordedInstructions { return
    wrapper->cpu->recordedInstructions(); }
- (RecordedInstruction) readRecordedInstruction {
    return wrapper->cpu->readRecordedInstruction(); }
- (RecordedInstruction) readRecordedInstruction:(NSInteger)previous {
    return wrapper->cpu->readRecordedInstruction((unsigned)previous); }

- (DisassembledInstruction) disassemble:(uint16_t)addr hex:(BOOL)h; {
    return wrapper->cpu->disassemble(addr, h); }
- (DisassembledInstruction) disassembleRecordedInstr:(RecordedInstruction)instr hex:(BOOL)h; {
    return wrapper->cpu->disassemble(instr, h); }

@end


// --------------------------------------------------------------------------
//                                   Memory
// --------------------------------------------------------------------------

@implementation MemoryProxy

- (instancetype) initWithMemory:(C64Memory *)mem
{
    if (self = [super init]) {
        wrapper = new MemoryWrapper();
        wrapper->mem = mem;
    }
    return self;
}

- (void) dump { wrapper->mem->dumpState(); }

- (MemoryType) peekSource:(uint16_t)addr { return wrapper->mem->getPeekSource(addr); }
- (MemoryType) pokeTarget:(uint16_t)addr { return wrapper->mem->getPokeTarget(addr); }

- (uint8_t) spypeek:(uint16_t)addr source:(MemoryType)source {
    return wrapper->mem->spypeek(addr, source); }
- (uint8_t) spypeek:(uint16_t)addr { return wrapper->mem->spypeek(addr); }
- (uint8_t) spypeekIO:(uint16_t)addr { return wrapper->mem->spypeekIO(addr); }

- (void) poke:(uint16_t)addr value:(uint8_t)value target:(MemoryType)target {
    wrapper->mem->c64->suspend();
    wrapper->mem->poke(addr, value, target);
    wrapper->mem->c64->resume(); }
- (void) poke:(uint16_t)addr value:(uint8_t)value {
    wrapper->mem->c64->suspend();
    wrapper->mem->poke(addr, value);
    wrapper->mem->c64->resume(); }
- (void) pokeIO:(uint16_t)addr value:(uint8_t)value {
    wrapper->mem->c64->suspend();
    wrapper->mem->pokeIO(addr, value);
    wrapper->mem->c64->resume(); }

@end

//
// CIA
//

@implementation CIAProxy

- (instancetype) initWithCIA:(CIA *)cia
{
    if (self = [super init]) {
        wrapper = new CiaWrapper();
        wrapper->cia = cia;
    }
    return self;
}

- (CIAInfo) getInfo { return wrapper->cia->getInfo(); }
- (void) dump { wrapper->cia->dumpState(); }

- (BOOL) tracing { return wrapper->cia->tracingEnabled(); }
- (void) setTracing:(BOOL)b { b ? wrapper->cia->startTracing() : wrapper->cia->stopTracing(); }

- (void) poke:(uint16_t)addr value:(uint8_t)value {
    wrapper->cia->c64->suspend();
    wrapper->cia->poke(addr, value);
    wrapper->cia->c64->resume();
}

@end

//
// VIC
//

@implementation VICProxy

- (instancetype) initWithVIC:(VIC *)vic
{
    if (self = [super init]) {
        wrapper = new VicWrapper();
        wrapper->vic = vic;
    }
    return self;
}

- (VICInfo) getInfo { return wrapper->vic->getInfo(); }
- (void) dump { wrapper->vic->dumpState(); }
- (SpriteInfo) getSpriteInfo:(NSInteger)sprite { return wrapper->vic->getSpriteInfo((unsigned)sprite); }

- (void *) screenBuffer { return wrapper->vic->screenBuffer(); }
- (NSColor *) color:(NSInteger)nr
{
    assert (0 <= nr && nr < 16);
    
    uint32_t color = wrapper->vic->getColor((unsigned)nr);
    uint8_t r = color & 0xFF;
    uint8_t g = (color >> 8) & 0xFF;
    uint8_t b = (color >> 16) & 0xFF;
    
	return [NSColor colorWithCalibratedRed:(float)r/255.0
                                     green:(float)g/255.0
                                      blue:(float)b/255.0
                                     alpha:1.0];
}
- (ColorScheme) colorScheme { return wrapper->vic->getColorScheme(); }
- (void) setColorScheme:(ColorScheme)scheme { wrapper->vic->setColorScheme(scheme); }

- (void) setMemoryBankAddr:(uint16_t)addr { wrapper->vic->setMemoryBankAddr(addr); }
- (void) setScreenMemoryAddr:(uint16_t)addr { wrapper->vic->setScreenMemoryAddr(addr); }
- (void) setCharacterMemoryAddr:(uint16_t)addr { wrapper->vic->setCharacterMemoryAddr(addr); }

- (void) setDisplayMode:(DisplayMode)mode { wrapper->vic->setDisplayMode(mode); }
- (void) setScreenGeometry:(ScreenGeometry)mode { wrapper->vic->setScreenGeometry(mode); }
- (void) setHorizontalRasterScroll:(uint8_t)offset { wrapper->vic->setHorizontalRasterScroll(offset & 0x07); }
- (void) setVerticalRasterScroll:(uint8_t)offset { wrapper->vic->setVerticalRasterScroll(offset & 0x07); }

- (void) setSpriteEnabled:(NSInteger)nr value:(BOOL)flag { wrapper->vic->setSpriteEnabled(nr, flag); }
- (void) toggleSpriteEnabled:(NSInteger)nr { wrapper->vic->toggleSpriteEnabled(nr); }
- (void) setSpriteX:(NSInteger)nr value:(int)x { wrapper->vic->setSpriteX(nr, x); }
- (void) setSpriteY:(NSInteger)nr value:(int)y { wrapper->vic->setSpriteY(nr, y); }
- (void) setSpriteStretchX:(NSInteger)nr value:(BOOL)flag { wrapper->vic->setSpriteStretchX((unsigned)nr, flag); }
- (void) toggleSpriteStretchX:(NSInteger)nr { wrapper->vic->spriteToggleStretchXFlag((unsigned)nr); }
- (void) setSpriteStretchY:(NSInteger)nr value:(BOOL)flag { return wrapper->vic->setSpriteStretchY((unsigned)nr, flag); }
- (void) toggleSpriteStretchY:(NSInteger)nr { wrapper->vic->spriteToggleStretchYFlag((unsigned)nr); }
- (void) setSpriteColor:(NSInteger)nr value:(int)c { wrapper->vic->setSpriteColor(nr, c); }
- (void) setSpritePriority:(NSInteger)nr value:(BOOL)flag { wrapper->vic->setSpritePriority((unsigned)nr, flag); }
- (void) toggleSpritePriority:(NSInteger)nr { wrapper->vic->toggleSpritePriority((unsigned)nr); }
- (void) setSpriteMulticolor:(NSInteger)nr value:(BOOL)flag { wrapper->vic->setSpriteMulticolor((unsigned)nr, flag); }
- (void) toggleSpriteMulticolor:(NSInteger)nr { wrapper->vic->toggleMulticolorFlag((unsigned)nr); }

- (void) setIrqOnSpriteSpriteCollision:(BOOL)value { wrapper->vic->setIrqOnSpriteSpriteCollision(value); }
- (void) toggleIrqOnSpriteSpriteCollision { wrapper->vic-> toggleIrqOnSpriteSpriteCollision(); }
- (void) setIrqOnSpriteBackgroundCollision:(BOOL)value { wrapper->vic->setIrqOnSpriteBackgroundCollision(value); }
- (void) toggleIrqOnSpriteBackgroundCollision { wrapper->vic->toggleIrqOnSpriteBackgroundCollision(); }

- (void) setRasterline:(uint16_t)line { wrapper->vic->setRasterline(line); }
- (void) setRasterInterruptLine:(uint16_t)line { wrapper->vic->setRasterInterruptLine(line); }
- (void) setRasterInterruptEnabled:(BOOL)b { wrapper->vic->setRasterInterruptEnable(b); }
- (void) toggleRasterInterruptFlag { wrapper->vic->toggleRasterInterruptFlag(); }

- (BOOL) hideSprites { return wrapper->vic->hideSprites(); }
- (void) setHideSprites:(BOOL)b { wrapper->vic->setHideSprites(b); }
- (BOOL) showIrqLines { return wrapper->vic->showIrqLines(); }
- (void) setShowIrqLines:(BOOL)b { wrapper->vic->setShowIrqLines(b); }
- (BOOL) showDmaLines { return wrapper->vic->showDmaLines(); }
- (void) setShowDmaLines:(BOOL)b { wrapper->vic->setShowDmaLines(b); }

@end


//
// SID
//

@implementation SIDProxy

- (instancetype) initWithSID:(SIDBridge *)sid
{
    if (self = [super init]) {
        wrapper = new SidBridgeWrapper();
        wrapper->sid = sid;
    }
    return self;
}

- (void) dump { wrapper->sid->dumpState(); }
- (SIDInfo) getInfo { return wrapper->sid->getInfo(); }
- (VoiceInfo) getVoiceInfo:(NSInteger)voice {
    return wrapper->sid->getVoiceInfo((unsigned)voice); }

- (BOOL) reSID { return wrapper->sid->getReSID(); }
- (void) setReSID:(BOOL)b { wrapper->sid->setReSID(b); }
- (BOOL) audioFilter { return wrapper->sid->getAudioFilter(); }
- (void) setAudioFilter:(BOOL)b { wrapper->sid->setAudioFilter(b); }
- (NSInteger) samplingMethod { return (NSInteger)(wrapper->sid->getSamplingMethod()); }
- (void) setSamplingMethod:(NSInteger)value { wrapper->sid->setSamplingMethod((SamplingMethod)value); }
- (NSInteger) chipModel { return (int)(wrapper->sid->getChipModel()); }
- (void) setChipModel:(NSInteger)value {wrapper->sid->setChipModel((SIDChipModel)value); }
- (uint32_t) sampleRate { return wrapper->sid->getSampleRate(); }
- (void) setSampleRate:(uint32_t)rate { wrapper->sid->setSampleRate(rate); }

- (NSInteger) ringbufferSize { return wrapper->sid->ringbufferSize(); }
- (float) ringbufferData:(NSInteger)offset {
    return wrapper->sid->ringbufferData(offset); }
- (double) fillLevel { return wrapper->sid->fillLevel(); }
- (NSInteger) bufferUnderflows { return wrapper->sid->bufferUnderflows; }
- (NSInteger) bufferOverflows { return wrapper->sid->bufferOverflows; }

- (void) readMonoSamples:(float *)target size:(NSInteger)n {
    wrapper->sid->readMonoSamples(target, n); }
- (void) readStereoSamples:(float *)target1 buffer2:(float *)target2 size:(NSInteger)n {
    wrapper->sid->readStereoSamples(target1, target2, n); }
- (void) readStereoSamplesInterleaved:(float *)target size:(NSInteger)n {
    wrapper->sid->readStereoSamplesInterleaved(target, n); }

- (void) rampUp { wrapper->sid->rampUp(); }
- (void) rampUpFromZero { wrapper->sid->rampUpFromZero(); }
- (void) rampDown { wrapper->sid->rampDown(); }

@end


//
// IEC bus
//

@implementation IECProxy

- (instancetype) initWithIEC:(IEC *)iec
{
    if (self = [super init]) {
        wrapper = new IecWrapper();
        wrapper->iec = iec;
    }
    return self;
}

- (void) dump { wrapper->iec->dumpState(); }
- (BOOL) tracing { return wrapper->iec->tracingEnabled(); }
- (void) setTracing:(BOOL)b { b ? wrapper->iec->startTracing() : wrapper->iec->stopTracing(); }
- (void) connectDrive { wrapper->iec->connectDrive(); }
- (void) disconnectDrive { wrapper->iec->disconnectDrive(); }
- (BOOL) driveIsConnected { return wrapper->iec->driveIsConnected; }
// - (BOOL) atnLine { return wrapper->iec->getAtnLine(); }
// - (BOOL) clockLine { return wrapper->iec->getClockLine(); }
// - (BOOL) dataLine { return wrapper->iec->getDataLine(); }

@end


//
// Keyboard
//

@implementation KeyboardProxy

- (instancetype) initWithKeyboard:(Keyboard *)keyboard
{
    if (self = [super init]) {
        wrapper = new KeyboardWrapper();
        wrapper->keyboard = keyboard;
    }
    return self;
}

- (void) dump { wrapper->keyboard->dumpState(); }

- (void) pressKeyAtRow:(NSInteger)row col:(NSInteger)col {
    wrapper->keyboard->pressKey(row, col); }
- (void) pressRestoreKey {
    wrapper->keyboard->pressRestoreKey(); }

- (void) releaseKeyAtRow:(NSInteger)row col:(NSInteger)col {
    wrapper->keyboard->releaseKey(row, col); }
- (void) releaseRestoreKey {
    wrapper->keyboard->releaseRestoreKey(); }
- (void) releaseAll { wrapper->keyboard->releaseAll(); }

- (BOOL) shiftLockIsPressed { return wrapper->keyboard->shiftLockIsPressed(); }
- (void) lockShift { wrapper->keyboard->pressShiftLockKey(); }
- (void) unlockShift { wrapper->keyboard->releaseShiftLockKey(); }

@end


//
// Control port
//

@implementation ControlPortProxy

- (instancetype) initWithJoystick:(ControlPort *)port
{
    if (self = [super init]) {
        wrapper = new ControlPortWrapper();
        wrapper->port = port;
    }
    return self;
}

- (void) dump { wrapper->port->dumpState(); }
- (void) trigger:(JoystickEvent)event { wrapper->port->trigger(event); }

@end


//
// Expansion port
//

@implementation ExpansionPortProxy

- (instancetype) initWithExpansionPort:(ExpansionPort *)expansionPort
{
    if (self = [super init]) {
        wrapper = new ExpansionPortWrapper();
        wrapper->expansionPort = expansionPort;
    }
    return self;
}

- (void) dump { wrapper->expansionPort->dumpState(); }
- (CartridgeType) cartridgeType { return wrapper->expansionPort->getCartridgeType(); }
- (BOOL) cartridgeAttached { return wrapper->expansionPort->getCartridgeAttached(); }
- (BOOL) hasBattery { return wrapper->expansionPort->hasBattery(); }
- (void) setBattery:(BOOL)value { wrapper->expansionPort->setBattery(value); }
- (BOOL) attachGeoRamCartridge:(NSInteger)capacity { return wrapper->expansionPort->attachGeoRamCartridge((uint32_t)capacity); }
- (void) pressFirstButton { wrapper->expansionPort->pressFirstButton(); }
- (void) pressSecondButton { wrapper->expansionPort->pressSecondButton(); }
- (void) releaseFirstButton { wrapper->expansionPort->releaseFirstButton(); }
- (void) releaseSecondButton { wrapper->expansionPort->releaseSecondButton(); }

@end


//
// 5,25" diskette
//

@implementation DiskProxy

- (instancetype) initWithDisk525:(Disk *)disk
{
    if (self = [super init]) {
        wrapper = new DiskWrapper();
        wrapper->disk = disk;
    }
    return self;
}

- (void) dump { wrapper->disk->dumpState(); }
- (BOOL)writeProtected { return wrapper->disk->isWriteProtected(); }
- (void)setWriteProtection:(BOOL)b { wrapper->disk->setWriteProtection(b); }
- (BOOL)modified { return wrapper->disk->isModified(); }
- (void)setModified:(BOOL)b { wrapper->disk->setModified(b); }
- (NSInteger)nonemptyHalftracks { return (NSInteger)wrapper->disk->nonemptyHalftracks(); }
- (void)analyzeTrack:(Track)t { wrapper->disk->analyzeTrack(t); }
- (void)analyzeHalftrack:(Halftrack)ht { wrapper->disk->analyzeHalftrack(ht); }
- (NSInteger)numErrors { return wrapper->disk->numErrors(); }
- (NSString *)errorMessage:(NSInteger)nr {
    std::string s = wrapper->disk->errorMessage((unsigned)nr);
    return [NSString stringWithUTF8String:s.c_str()]; }
- (NSInteger)firstErroneousBit:(NSInteger)nr {
    return wrapper->disk->firstErroneousBit((unsigned)nr); }
- (NSInteger)lastErroneousBit:(NSInteger)nr {
    return wrapper->disk->lastErroneousBit((unsigned)nr); }
- (SectorInfo)sectorInfo:(Sector)s { return wrapper->disk->sectorLayout(s); }
- (const char *)trackDataAsString { return wrapper->disk->trackDataAsString(); }
- (const char *)diskNameAsString { return wrapper->disk->diskNameAsString(); }
- (const char *)sectorHeaderAsString:(Sector)nr {
    return wrapper->disk->sectorHeaderAsString(nr); }
- (const char *)sectorDataAsString:(Sector)nr {
    return wrapper->disk->sectorDataAsString(nr); }

@end


//
// VIA
//

@implementation VIAProxy

- (instancetype) initWithVIA:(VIA6522 *)via
{
    if (self = [super init]) {
        wrapper = new Via6522Wrapper();
        wrapper->via = via;
    }
    return self;
}

- (void) dump { wrapper->via->dumpState(); }
- (BOOL) tracing { return wrapper->via->tracingEnabled(); }
- (void) setTracing:(BOOL)b { b ? wrapper->via->startTracing() : wrapper->via->stopTracing(); }

@end


//
// VC1541
//

@implementation VC1541Proxy

@synthesize wrapper, cpu, via1, via2, disk;

- (instancetype) initWithVC1541:(VC1541 *)vc1541
{
    if (self = [super init]) {
        wrapper = new Vc1541Wrapper();
        wrapper->vc1541 = vc1541;
        cpu = [[CPUProxy alloc] initWithCPU:&vc1541->cpu];
        via1 = [[VIAProxy alloc] initWithVIA:&vc1541->via1];
        via2 = [[VIAProxy alloc] initWithVIA:&vc1541->via2];
        disk = [[DiskProxy alloc] initWithDisk525:&vc1541->disk];
    }
    return self;
}

- (VIAProxy *) via:(NSInteger)num {
	switch (num) {
		case 1:
			return [self via1];
		case 2:
			return [self via2];
		default:
			assert(0);
			return NULL;
	}
}

- (void) dump { wrapper->vc1541->dumpState(); }
- (BOOL) tracing { return wrapper->vc1541->tracingEnabled(); }
- (void) setTracing:(BOOL)b { b ? wrapper->vc1541->startTracing() : wrapper->vc1541->stopTracing(); }

- (BOOL) redLED { return wrapper->vc1541->getRedLED(); }
- (BOOL) hasDisk { return wrapper->vc1541->hasDisk(); }
- (BOOL) hasModifiedDisk { return wrapper->vc1541->hasModifiedDisk(); }
- (void) ejectDisk { wrapper->vc1541->ejectDisk(); }
- (BOOL) writeProtected { return wrapper->vc1541->disk.isWriteProtected(); }
- (void) setWriteProtection:(BOOL)b { wrapper->vc1541->disk.setWriteProtection(b); }
- (BOOL) diskModified { return wrapper->vc1541->disk.isModified(); }
- (void) setDiskModified:(BOOL)b { wrapper->vc1541->disk.setModified(b); }
- (BOOL) sendSoundMessages { return wrapper->vc1541->soundMessagesEnabled(); }
- (void) setSendSoundMessages:(BOOL)b { wrapper->vc1541->setSendSoundMessages(b); }
- (Halftrack) halftrack { return wrapper->vc1541->getHalftrack(); }
- (void) setTrack:(Track)t { wrapper->vc1541->setTrack(t); }
- (void) setHalftrack:(Halftrack)ht { wrapper->vc1541->setHalftrack(ht); }
- (uint16_t) sizeOfCurrentHalftrack { return wrapper->vc1541->sizeOfCurrentHalftrack(); }
- (uint16_t) offset { return wrapper->vc1541->getOffset(); }
- (void) setOffset:(uint16_t)value { wrapper->vc1541->setOffset(value); }
- (uint8_t) readBitFromHead { return wrapper->vc1541->readBitFromHead(); }
- (void) writeBitToHead:(uint8_t)value { wrapper->vc1541->writeBitToHead(value); }

- (void) moveHeadUp { wrapper->vc1541->moveHeadUp(); }
- (void) moveHeadDown { wrapper->vc1541->moveHeadDown(); }
- (BOOL) isRotating { return wrapper->vc1541->isRotating(); }
- (void) rotateDisk { wrapper->vc1541->rotateDisk(); }
- (void) rotateBack { wrapper->vc1541->rotateBack(); }

- (BOOL) exportToD64:(NSString *)path { return wrapper->vc1541->exportToD64([path UTF8String]); }

@end


//
// Datasette
//

@implementation DatasetteProxy

- (instancetype) initWithDatasette:(Datasette *)datasette
{
    if (self = [super init]) {
        wrapper = new DatasetteWrapper();
        wrapper->datasette = datasette;
    }
    return self;
}

- (void) dump { wrapper->datasette->dumpState(); }
- (BOOL) hasTape { return wrapper->datasette->hasTape(); }
- (void) pressPlay { wrapper->datasette->pressPlay(); }
- (void) pressStop { wrapper->datasette->pressStop(); }
- (void) rewind { wrapper->datasette->rewind(); }
- (void) ejectTape { wrapper->datasette->ejectTape(); }
- (NSInteger) getType { return wrapper->datasette->getType(); }
- (long) durationInCycles { return wrapper->datasette->getDurationInCycles(); }
- (int) durationInSeconds { return wrapper->datasette->getDurationInSeconds(); }
- (NSInteger) head { return wrapper->datasette->getHead(); }
- (NSInteger) headInCycles { return wrapper->datasette->getHeadInCycles(); }
- (int) headInSeconds { return wrapper->datasette->getHeadInSeconds(); }
- (void) setHeadInCycles:(long)value { wrapper->datasette->setHeadInCycles(value); }
- (BOOL) motor { return wrapper->datasette->getMotor(); }
- (BOOL) playKey { return wrapper->datasette->getPlayKey(); }
@end


//
// C64
//

@implementation C64Proxy {
    AudioEngine *audioEngine;
}

@synthesize cpu, mem, vic, cia1, cia2, sid, keyboard, iec, expansionport, vc1541, datasette;
@synthesize port1, port2;

- (instancetype) init
{
	NSLog(@"C64Proxy::init");
	
    if (!(self = [super init]))
        return self;
    
    C64 *c64 = new C64();
    wrapper = new C64Wrapper();
    wrapper->c64 = c64;
	
    // Create sub proxys
    cpu = [[CPUProxy alloc] initWithCPU:&c64->cpu];
    // cpu = [[CPUProxy alloc] initWithCPU:&c64->floppy->cpu];
    mem = [[MemoryProxy alloc] initWithMemory:&c64->mem];
    vic = [[VICProxy alloc] initWithVIC:&c64->vic];
	cia1 = [[CIAProxy alloc] initWithCIA:&c64->cia1];
	cia2 = [[CIAProxy alloc] initWithCIA:&c64->cia2];
	sid = [[SIDProxy alloc] initWithSID:&c64->sid];
	keyboard = [[KeyboardProxy alloc] initWithKeyboard:&c64->keyboard];
    port1 = [[ControlPortProxy alloc] initWithJoystick:&c64->port1];
    port2 = [[ControlPortProxy alloc] initWithJoystick:&c64->port2];
    iec = [[IECProxy alloc] initWithIEC:&c64->iec];
    expansionport = [[ExpansionPortProxy alloc] initWithExpansionPort:&c64->expansionport];
	vc1541 = [[VC1541Proxy alloc] initWithVC1541:&c64->floppy];
    datasette = [[DatasetteProxy alloc] initWithDatasette:&c64->datasette];
    
    // Initialize audio interface
    audioEngine = [[AudioEngine alloc] initWithSID:sid];
    if (!audioEngine) {
        NSLog(@"WARNING: Failed to initialize AudioEngine");
    }

    return self;
}

- (struct C64Wrapper *)wrapper
{
    return wrapper;
}

- (void) kill
{
	assert(wrapper->c64 != NULL);
	NSLog(@"C64Proxy::kill");

	// Stop sound device
	[self disableAudio];
	
    // Delete emulator
    delete wrapper->c64;
	wrapper->c64 = NULL;
}

- (void) dump { wrapper->c64->dumpState(); }
- (BOOL) developmentMode { return wrapper->c64->developmentMode(); }


- (BOOL)mount:(ContainerProxy *)container {
    return wrapper->c64->mount([container wrapper]->container); }
- (BOOL)flash:(ContainerProxy *)container item:(NSInteger)item; {
    return wrapper->c64->flash([container wrapper]->container, (int)item); }
- (BOOL)flash:(ContainerProxy *)container {
    return wrapper->c64->flash([container wrapper]->container); }

- (BOOL) isBasicRom:(NSURL *)url {
    return ROMFile::isBasicRomFile([[url path] UTF8String]); }
- (BOOL) loadBasicRom:(NSURL *)url {
    return [self isBasicRom:url] && wrapper->c64->loadRom([[url path] UTF8String]); }
- (BOOL) isBasicRomLoaded {
    return wrapper->c64->mem.basicRomIsLoaded(); }
- (BOOL) isCharRom:(NSURL *)url {
    return ROMFile::isCharRomFile([[url path] UTF8String]); }
- (BOOL) loadCharRom:(NSURL *)url {
    return [self isCharRom:url] && wrapper->c64->loadRom([[url path] UTF8String]); }
- (BOOL) isCharRomLoaded {
    return wrapper->c64->mem.charRomIsLoaded(); }
- (BOOL) isKernalRom:(NSURL *)url {
    return ROMFile::isKernalRomFile([[url path] UTF8String]); }
- (BOOL) loadKernalRom:(NSURL *)url {
    return [self isKernalRom:url] && wrapper->c64->loadRom([[url path] UTF8String]); }
- (BOOL) isKernalRomLoaded {
    return wrapper->c64->mem.kernalRomIsLoaded(); }
- (BOOL) isVC1541Rom:(NSURL *)url {
    return ROMFile::isVC1541RomFile([[url path] UTF8String]); }
- (BOOL) loadVC1541Rom:(NSURL *)url {
    return [self isVC1541Rom:url] && wrapper->c64->loadRom([[url path] UTF8String]); }
- (BOOL) isVC1541RomLoaded {
    return wrapper->c64->floppy.mem.romIsLoaded(); }
- (BOOL) isRom:(NSURL *)url {
    return [self isBasicRom:url] || [self isCharRom:url] || [self isKernalRom:url] || [self isVC1541Rom:url]; }
- (BOOL) loadRom:(NSURL *)url {
    return [self loadBasicRom:url] || [self loadCharRom:url] || [self loadKernalRom:url] || [self loadVC1541Rom:url]; }

- (VC64Message)message { return wrapper->c64->getMessage(); }
- (void) putMessage:(VC64Message)msg { wrapper->c64->putMessage(msg); }
- (void) setListener:(const void *)sender function:(void(*)(const void *, int))func {
    wrapper->c64->setListener(sender, func);
}

- (void) powerUp { wrapper->c64->powerUp(); }
- (void) ping { wrapper->c64->ping(); }

- (BOOL) isRunnable { return wrapper->c64->isRunnable(); }
- (BOOL) isRunning { return wrapper->c64->isRunning(); }
- (BOOL) isHalted { return wrapper->c64->isHalted(); }
- (void) suspend { wrapper->c64->suspend(); }
- (void) resume { wrapper->c64->resume(); }
- (void) run { wrapper->c64->run(); }
- (void) halt { wrapper->c64->halt(); }

- (void) step { wrapper->c64->step(); }
- (void) stepOver { wrapper->c64->stepOver(); }

- (BOOL) isPAL { return wrapper->c64->isPAL(); }
- (void) setPAL { wrapper->c64->setPAL(); }
- (void) setPAL:(BOOL)b { if (b) [self setPAL]; else [self setNTSC]; }
- (BOOL) isNTSC { return wrapper->c64->isNTSC(); }
- (void) setNTSC { wrapper->c64->setNTSC(); }
- (void) setNTSC:(BOOL)b { if (b) [self setNTSC]; else [self setPAL]; }


- (BOOL) attachCartridgeAndReset:(CRTProxy *)c {
    return wrapper->c64->attachCartridgeAndReset((CRTFile *)([c wrapper]->container)); }
- (void) detachCartridgeAndReset { wrapper->c64->detachCartridgeAndReset(); }
- (BOOL) isCartridgeAttached { return wrapper->c64->isCartridgeAttached(); }
- (BOOL) insertDisk:(ArchiveProxy *)a {
    Archive *archive = (Archive *)([a wrapper]->container);
    return wrapper->c64->insertDisk(archive);
}
/*
- (BOOL) flushArchive:(ArchiveProxy *)a item:(NSInteger)nr {
    Archive *archive = (Archive *)([a wrapper]->container);
    return wrapper->c64->flushArchive(archive, (int)nr);
}
*/
- (BOOL) insertTape:(TAPProxy *)c {
    TAPFile *container = (TAPFile *)([c wrapper]->container);
    return wrapper->c64->insertTape(container);
}

- (NSInteger) mouseModel { return (NSInteger)wrapper->c64->getMouseModel(); }
- (void) setMouseModel:(NSInteger)model { wrapper->c64->setMouseModel((MouseModel)model); }
- (void) connectMouse:(NSInteger)toPort { wrapper->c64->connectMouse((unsigned)toPort); }
- (void) disconnectMouse { wrapper->c64->connectMouse(0); }
- (void) setMouseXY:(NSPoint)pos {
    wrapper->c64->mouse->setXY((int64_t)pos.x, (int64_t)pos.y);
}
- (void) setMouseLeftButton:(BOOL)pressed { wrapper->c64->mouse->leftButton = pressed; }
- (void) setMouseRightButton:(BOOL)pressed { wrapper->c64->mouse->rightButton = pressed;  }

- (BOOL) warp { return wrapper->c64->getWarp(); }
- (BOOL) alwaysWarp { return wrapper->c64->getAlwaysWarp(); }
- (void) setAlwaysWarp:(BOOL)b { wrapper->c64->setAlwaysWarp(b); }
- (BOOL) warpLoad { return wrapper->c64->getWarpLoad(); }
- (void) setWarpLoad:(BOOL)b { wrapper->c64->setWarpLoad(b); }

- (UInt64) cycles { return wrapper->c64->currentCycle(); }
- (UInt64) frames { return wrapper->c64->getFrame(); }

// Snapshot storage
- (void) disableAutoSnapshots { wrapper->c64->disableAutoSnapshots(); }
- (void) enableAutoSnapshots { wrapper->c64->enableAutoSnapshots(); }
- (void) suspendAutoSnapshots { wrapper->c64->suspendAutoSnapshots(); }
- (void) resumeAutoSnapshots { wrapper->c64->resumeAutoSnapshots(); }
- (NSInteger) snapshotInterval { return wrapper->c64->getSnapshotInterval(); }
- (void) setSnapshotInterval:(NSInteger)value { wrapper->c64->setSnapshotInterval(value); }
- (NSInteger) numAutoSnapshots { return wrapper->c64->numAutoSnapshots(); }
- (NSData *)autoSnapshotData:(NSInteger)nr {
    Snapshot *snapshot = wrapper->c64->autoSnapshot((unsigned)nr);
    return [NSData dataWithBytes: (void *)snapshot->header()
                          length: snapshot->sizeOnDisk()];
}
- (unsigned char *)autoSnapshotImageData:(NSInteger)nr {
    Snapshot *s = wrapper->c64->autoSnapshot((int)nr); return s ? s->getImageData() : NULL; }
- (NSInteger)autoSnapshotImageWidth:(NSInteger)nr {
    Snapshot *s = wrapper->c64->autoSnapshot((int)nr); return s ? s->getImageWidth() : 0; }
- (NSInteger)autoSnapshotImageHeight:(NSInteger)nr {
    Snapshot *s = wrapper->c64->autoSnapshot((int)nr); return s ? s->getImageHeight() : 0; }
- (time_t)autoSnapshotTimestamp:(NSInteger)nr {
    Snapshot *s = wrapper->c64->autoSnapshot((int)nr); return s ? s->getTimestamp() : 0; }
- (BOOL)restoreAutoSnapshot:(NSInteger)nr { return wrapper->c64->restoreAutoSnapshot((unsigned)nr); }
- (BOOL)restoreLatestAutoSnapshot { return wrapper->c64->restoreLatestAutoSnapshot(); }

- (NSInteger) numUserSnapshots { return wrapper->c64->numUserSnapshots(); }
- (NSData *)userSnapshotData:(NSInteger)nr {
    Snapshot *snapshot = wrapper->c64->userSnapshot((unsigned)nr);
    return [NSData dataWithBytes: (void *)snapshot->header()
                          length: snapshot->sizeOnDisk()];
}
- (unsigned char *)userSnapshotImageData:(NSInteger)nr {
    Snapshot *s = wrapper->c64->userSnapshot((int)nr); return s ? s->getImageData() : NULL; }
- (NSInteger)userSnapshotImageWidth:(NSInteger)nr {
    Snapshot *s = wrapper->c64->userSnapshot((int)nr); return s ? s->getImageWidth() : 0; }
- (NSInteger)userSnapshotImageHeight:(NSInteger)nr {
    Snapshot *s = wrapper->c64->userSnapshot((int)nr); return s ? s->getImageHeight() : 0; }
- (time_t)userSnapshotTimestamp:(NSInteger)nr {
    Snapshot *s = wrapper->c64->userSnapshot((int)nr); return s ? s->getTimestamp() : 0; }
- (BOOL)takeUserSnapshot { return wrapper->c64->takeUserSnapshot(); }
- (BOOL)restoreUserSnapshot:(NSInteger)nr { return wrapper->c64->restoreUserSnapshot((unsigned)nr); }
- (BOOL)restoreLatestUserSnapshot { return wrapper->c64->restoreLatestUserSnapshot(); }
- (void)deleteUserSnapshot:(NSInteger)nr { wrapper->c64->deleteUserSnapshot((unsigned)nr); }

// Audio hardware
- (BOOL) enableAudio {
    [sid rampUpFromZero];
    return [audioEngine startPlayback];
}

- (void) disableAudio {
    [sid rampDown];
    [audioEngine stopPlayback];
}

@end


//
// Container
//

@implementation ContainerProxy

- (instancetype) initWithContainer:(File *)container
{
    // NSLog(@"ContainerProxy::initWithContainer");

    if (container == nil) {
        return nil;
    }
    if (self = [super init]) {
        wrapper = new ContainerWrapper();
        wrapper->container = container;
    }
    return self;
}

+ (ContainerProxy *) makeWithContainer:(File *)container
{
    // NSLog(@"ContainerProxy::makeWithContainer");
    
    if (container == nil) {
        return nil;
    }
    return [[self alloc] initWithContainer:container];
}

- (ContainerWrapper *)wrapper { return wrapper; }
- (ContainerType)type { return wrapper->container->type(); }
- (NSString *)name { return [NSString stringWithUTF8String:wrapper->container->getName()]; }
- (NSInteger) sizeOnDisk { return wrapper->container->sizeOnDisk(); }

- (void) readFromBuffer:(const void *)buffer length:(NSInteger)length
{
    wrapper->container->readFromBuffer((const uint8_t *)buffer, length);
}

- (NSInteger) writeToBuffer:(void *)buffer
{
    return wrapper->container->writeToBuffer((uint8_t *)buffer);
}

- (void) dealloc
{
    // NSLog(@"ContainerProxy::dealloc");
    
    if (wrapper) {
        if (wrapper->container) delete wrapper->container;
        delete wrapper;
    }
}
@end


//
// SnapshotProxy
//

@implementation SnapshotProxy

+ (BOOL)isSupportedSnapshot:(const void *)buffer length:(NSInteger)length {
    return Snapshot::isSupportedSnapshot((uint8_t *)buffer, length);
}
+ (BOOL)isUnsupportedSnapshot:(const void *)buffer length:(NSInteger)length {
    return Snapshot::isUnsupportedSnapshot((uint8_t *)buffer, length);
}
+ (BOOL) isSupportedSnapshotFile:(NSString *)path {
    return Snapshot::isSupportedSnapshotFile([path UTF8String]);
}
+ (BOOL) isUnsupportedSnapshotFile:(NSString *)path {
    return Snapshot::isUnsupportedSnapshotFile([path UTF8String]);
}

+ (instancetype) make:(Snapshot *)snapshot
{
    if (snapshot == NULL) {
        return nil;
    }
    return [[self alloc] initWithContainer:snapshot];
}

+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    Snapshot *snapshot = Snapshot::makeSnapshotWithBuffer((uint8_t *)buffer, length);
    return [self make:snapshot];
}

+ (instancetype) makeWithFile:(NSString *)path
{
    Snapshot *snapshot = Snapshot::makeSnapshotWithFile([path UTF8String]);
    return [self make:snapshot];
}

+ (instancetype) makeWithC64:(C64Proxy *)c64proxy
{
    C64Wrapper *wrapper = [c64proxy wrapper];
    C64 *c64 = wrapper->c64;
    Snapshot *snapshot = c64->takeSnapshotSafe();
    return [self make:snapshot];
}

- (NSInteger)imageWidth
{
    Snapshot *snapshot = (Snapshot *)wrapper->container;
    return snapshot->getImageWidth();
}
- (NSInteger)imageHeight
{
    Snapshot *snapshot = (Snapshot *)wrapper->container;
    return snapshot->getImageHeight();
}
- (uint8_t *)imageData
{
    Snapshot *snapshot = (Snapshot *)wrapper->container;
    return snapshot->getImageData();
}

@end


//
// CRTProxy
//

@implementation CRTProxy

+ (CartridgeType) typeOfCRTBuffer:(const void *)buffer length:(NSInteger)length {
    return CRTFile::typeOfCRTBuffer((uint8_t *)buffer, length); }
+ (NSString *) typeNameOfCRTBuffer:(const void *)buffer length:(NSInteger)length {
    const char *str = CRTFile::typeNameOfCRTBuffer((uint8_t *)buffer, length);
    return [NSString stringWithUTF8String: str]; }
+ (BOOL) isSupportedCRTBuffer:(const void *)buffer length:(NSInteger)length {
    return CRTFile::isSupportedCRTBuffer((uint8_t *)buffer, length); }
+ (BOOL) isUnsupportedCRTBuffer:(const void *)buffer length:(NSInteger)length {
    return CRTFile::isUnsupportedCRTBuffer((uint8_t *)buffer, length); }
+ (BOOL) isCRTFile:(NSString *)path {
    return CRTFile::isCRTFile([path UTF8String]); }

+ (instancetype) make:(CRTFile *)container
{
    if (container == NULL) {
        return nil;
    }
    return [[self alloc] initWithContainer:container];
}

+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    CRTFile *container = CRTFile::makeCRTContainerWithBuffer((const uint8_t *)buffer, length);
    return [self make: container];
}

+ (instancetype) makeWithFile:(NSString *)path
{
    CRTFile *container = CRTFile::makeCRTContainerWithFile([path UTF8String]);
    return [self make: container];
}

- (NSString *)cartridgeName
{
    CRTFile *c = (CRTFile *)wrapper->container;
    return [NSString stringWithUTF8String:c->cartridgeName()];
}

- (CartridgeType)cartridgeType {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->cartridgeType();
}

- (NSString *)cartridgeTypeName {
    CRTFile *c = (CRTFile *)wrapper->container;
    return [NSString stringWithUTF8String:c->cartridgeTypeName()];
}

- (BOOL) isSupported {
    return Cartridge::isSupportedType([self cartridgeType]);
}

- (NSInteger)exromLine {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->exromLine();
}

- (NSInteger)gameLine {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->gameLine();
}

- (NSInteger)chipCount {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->chipCount();
}

- (NSInteger)typeOfChip:(NSInteger)nr; {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->chipType((unsigned)nr);
}

- (NSInteger)loadAddrOfChip:(NSInteger)nr; {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->chipAddr((unsigned)nr);
}

- (NSInteger)sizeOfChip:(NSInteger)nr; {
    CRTFile *c = (CRTFile *)wrapper->container;
    return c->chipSize((unsigned)nr);
}
@end


//
// TAPProxy
//

@implementation TAPProxy

+ (BOOL) isTAPFile:(NSString *)path
{
    return TAPFile::isTAPFile([path UTF8String]);
}

+ (instancetype) make:(TAPFile *)container
{
    if (container == NULL) {
        return nil;
    }
    return [[self alloc] initWithContainer:container];
}

+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    TAPFile *container = TAPFile::makeTAPContainerWithBuffer((const uint8_t *)buffer, length);
    return [self make: container];
}

+ (instancetype) makeWithFile:(NSString *)path
{
    TAPFile *container = TAPFile::makeTAPContainerWithFile([path UTF8String]);
    return [self make: container];
}

- (NSInteger)TAPversion {
    TAPFile *container = (TAPFile *)wrapper->container;
    return (NSInteger)container->TAPversion();
}
@end


//
// Archive
//

@implementation ArchiveProxy

+ (instancetype) make:(Archive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}

+ (instancetype) make
{
    Archive *archive = new Archive();
    return [self make: archive];
}

+ (instancetype) makeWithFile:(NSString *)path
{
    Archive *archive = Archive::makeArchiveWithFile([path UTF8String]);
    return [self make: archive];
}

- (NSInteger)numberOfItems {
    Archive *archive = (Archive *)([self wrapper]->container);
    return (NSInteger)archive->getNumberOfItems();
}
- (NSString *)nameOfItem:(NSInteger)item {
    Archive *archive = (Archive *)([self wrapper]->container);
    return [NSString stringWithUTF8String:archive->getNameOfItem((int)item)];
}
- (NSString *)unicodeNameOfItem:(NSInteger)item maxChars:(NSInteger)max {
    Archive *archive = (Archive *)([self wrapper]->container);
    const unsigned short *name = archive->getUnicodeNameOfItem((int)item, max);
    
    if (name == NULL)
        return NULL;
    
    unsigned numChars;
    for (numChars = 0; name[numChars] != 0; numChars++);
    
    return [NSString stringWithCharacters:name length:numChars];
}

- (NSInteger)sizeOfItem:(NSInteger)item
{
    Archive *archive = (Archive *)([self wrapper]->container);
    return archive->getSizeOfItem((int)item);
}
- (NSInteger)sizeOfItemInBlocks:(NSInteger)item
{
    Archive *archive = (Archive *)([self wrapper]->container);
    return archive->getSizeOfItemInBlocks((int)item);
}
- (NSString *)typeOfItem:(NSInteger)item
{
    Archive *archive = (Archive *)([self wrapper]->container);
    return [NSString stringWithUTF8String:archive->getTypeOfItem((int)item)];
}
- (NSInteger)destinationAddrOfItem:(NSInteger)item
{
    Archive *archive = (Archive *)([self wrapper]->container);
    return archive->getDestinationAddrOfItem((int)item);
}
- (NSString *)byteStream:(NSInteger)n offset:(NSInteger)offset num:(NSInteger)num
{
    Archive *archive = (Archive *)([self wrapper]->container);
    return [NSString stringWithUTF8String:archive->byteStream((unsigned)n, offset, num)];
}
@end


//
// T64Proxy
//

@implementation T64Proxy

+ (BOOL)isT64File:(NSString *)filename
{
    return T64Archive::isT64File([filename UTF8String]);
}
+ (instancetype) make:(T64Archive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    T64Archive *archive = T64Archive::makeT64ArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    T64Archive *archive = T64Archive::makeT64ArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
+ (instancetype) makeWithAnyArchive:(ArchiveProxy *)otherArchive
{
    Archive *other = (Archive *)([otherArchive wrapper]->container);
    T64Archive *archive = T64Archive::makeT64ArchiveWithAnyArchive(other);
    return [self make: archive];
}
@end


//
// PRGProxy
//

@implementation PRGProxy

+ (BOOL)isPRGFile:(NSString *)filename
{
    return PRGArchive::isPRGFile([filename UTF8String]);
}
+ (instancetype) make:(PRGArchive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    PRGArchive *archive = PRGArchive::makePRGArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    PRGArchive *archive = PRGArchive::makePRGArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
+ (instancetype) makeWithAnyArchive:(ArchiveProxy *)otherArchive
{
    Archive *other = (Archive *)([otherArchive wrapper]->container);
    PRGArchive *archive = PRGArchive::makePRGArchiveWithAnyArchive(other);
    return [self make: archive];
}
@end


//
// P00Proxy
//

@implementation P00Proxy

+ (BOOL)isP00File:(NSString *)filename
{
    return P00Archive::isP00File([filename UTF8String]);
}
+ (instancetype) make:(P00Archive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    P00Archive *archive = P00Archive::makeP00ArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    P00Archive *archive = P00Archive::makeP00ArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
+ (instancetype) makeWithAnyArchive:(ArchiveProxy *)otherArchive
{
    Archive *other = (Archive *)([otherArchive wrapper]->container);
    P00Archive *archive = P00Archive::makeP00ArchiveWithAnyArchive(other);
    return [self make: archive];
}
@end


//
// D64Proxy
//

@implementation D64Proxy

+ (BOOL)isD64File:(NSString *)filename
{
    return D64Archive::isD64File([filename UTF8String]);
}
+ (instancetype) make:(D64Archive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    D64Archive *archive = D64Archive::makeD64ArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    D64Archive *archive = D64Archive::makeD64ArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
+ (instancetype) makeWithAnyArchive:(ArchiveProxy *)otherArchive
{
    Archive *other = (Archive *)([otherArchive wrapper]->container);
    D64Archive *archive = D64Archive::makeD64ArchiveWithAnyArchive(other);
    return [self make: archive];
}
+ (instancetype) makeWithVC1541:(VC1541Proxy *)vc1541
{
    D64Archive *archive = [vc1541 wrapper]->vc1541->convertToD64();
    return [self make: archive];
}
@end


//
// PG64Proxy
//

@implementation G64Proxy

+ (BOOL)isG64File:(NSString *)filename
{
    return G64Archive::isG64File([filename UTF8String]);
}
+ (instancetype) make:(G64Archive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    G64Archive *archive = G64Archive::makeG64ArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    G64Archive *archive = G64Archive::makeG64ArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
@end


//
// NIBProxy
//

@implementation NIBProxy

+ (BOOL)isNIBFile:(NSString *)filename
{
    return NIBArchive::isNIBFile([filename UTF8String]);
}
+ (instancetype) make:(NIBArchive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    NIBArchive *archive = NIBArchive::makeNIBArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    NIBArchive *archive = NIBArchive::makeNIBArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
@end


//
// FileProxy
//

@implementation FileProxy

+ (instancetype) make:(FileArchive *)archive
{
    if (archive == NULL) return nil;
    return [[self alloc] initWithContainer:archive];
}
+ (instancetype) makeWithBuffer:(const void *)buffer length:(NSInteger)length
{
    FileArchive *archive = FileArchive::makeFileArchiveWithBuffer((const uint8_t *)buffer, length);
    return [self make: archive];
}
+ (instancetype) makeWithFile:(NSString *)path
{
    FileArchive *archive = FileArchive::makeFileArchiveWithFile([path UTF8String]);
    return [self make: archive];
}
@end

