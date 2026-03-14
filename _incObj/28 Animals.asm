; ===========================================================================
; ---------------------------------------------------------------------------
; Object 28 - Animals
; ---------------------------------------------------------------------------
animal_ground_routine_base	= objoff_30
animal_ground_x_vel		= objoff_32
animal_ground_y_vel		= objoff_34
animal_capsule			= objoff_3C

; Sprite_1188C:
Obj28:
	moveq	#0,d0
	move.b	routine(a0),d0
	move.w	Obj28_Index(pc,d0.w),d1
	jmp	Obj28_Index(pc,d1.w)
; ===========================================================================
; off_1189A:
Obj28_Index:	offsetTable
		offsetTableEntry.w Obj28_Init	;   0
		offsetTableEntry.w Obj28_Main	;   2
		offsetTableEntry.w Obj28_Walk	;   4
		offsetTableEntry.w Obj28_Fly	;   6
		offsetTableEntry.w Obj28_Walk	;   8
		offsetTableEntry.w Obj28_Walk	;  $A
		offsetTableEntry.w Obj28_Walk	;  $C
		offsetTableEntry.w Obj28_Fly	;  $E
		offsetTableEntry.w Obj28_Walk	; $10
		offsetTableEntry.w Obj28_Fly	; $12
		offsetTableEntry.w Obj28_Walk	; $14
		offsetTableEntry.w Obj28_Walk	; $16
		offsetTableEntry.w Obj28_Walk	; $18
		offsetTableEntry.w Obj28_Walk	; $1A
		offsetTableEntry.w Obj28_Prison	; $1C

; byte_118CE:
Obj28_ZoneAnimals:	zoneOrderedTable 1,2

zoneAnimals macro first,second
	zoneTableEntry.b (Obj28_Properties_first - Obj28_Properties) / 8
	zoneTableEntry.b (Obj28_Properties_second - Obj28_Properties) / 8
    endm
	; This table declares what animals will appear in the zone.
	; When an enemy is destroyed, a random animal is chosen from the 2 selected animals.
	; Note: you must also load the corresponding art in the PLCs.
	zoneAnimals.b Squirrel,	Flicky	; EHZ
	zoneAnimals.b Squirrel,	Flicky	; Zone 1
	zoneAnimals.b Squirrel,	Flicky	; WZ
	zoneAnimals.b Squirrel,	Flicky	; Zone 3
	zoneAnimals.b Monkey,	Eagle	; MTZ1,2
	zoneAnimals.b Monkey,	Eagle	; MTZ3
	zoneAnimals.b Monkey,	Eagle	; WFZ
	zoneAnimals.b Monkey,	Eagle	; HTZ
	zoneAnimals.b Mouse,	Seal	; HPZ
	zoneAnimals.b Mouse,	Seal	; Zone 9
	zoneAnimals.b Penguin,	Seal	; OOZ
	zoneAnimals.b Mouse,	Chicken	; MCZ
	zoneAnimals.b Bear,	Flicky	; CNZ
	zoneAnimals.b Rabbit,	Eagle	; CPZ
	zoneAnimals.b Pig,	Chicken	; DEZ
	zoneAnimals.b Penguin,	Flicky	; ARZ
	zoneAnimals.b Turtle,	Chicken	; SCZ
    zoneTableEnd

; word_118F0:
Obj28_Properties:

obj28decl macro	xvel,yvel,mappings,{INTLABEL}
Obj28_Properties___LABEL__: label *
	dc.w xvel
	dc.w yvel
	dc.l mappings
    endm
		; This table declares the speed and mappings of each animal.
Rabbit:		obj28decl -$200,-$400,Obj28_MapUnc_11EAC
Chicken:	obj28decl -$200,-$300,Obj28_MapUnc_11E1C
Penguin:	obj28decl -$180,-$300,Obj28_MapUnc_11EAC
Seal:		obj28decl -$140,-$180,Obj28_MapUnc_11E88
Pig:		obj28decl -$1C0,-$300,Obj28_MapUnc_11E64
Flicky:		obj28decl -$300,-$400,Obj28_MapUnc_11E1C
Squirrel:	obj28decl -$280,-$380,Obj28_MapUnc_11E40
Eagle:		obj28decl -$280,-$300,Obj28_MapUnc_11E1C
Mouse:		obj28decl -$200,-$380,Obj28_MapUnc_11E40
Monkey:		obj28decl -$2C0,-$300,Obj28_MapUnc_11E40
Turtle:		obj28decl -$140,-$200,Obj28_MapUnc_11E40
Bear:		obj28decl -$200,-$300,Obj28_MapUnc_11E40

; ===========================================================================
; loc_119BE:
Obj28_Init:
	addq.b	#2,routine(a0)

	; Taken from S1Fixed, RetroKoH
	jsr	(RandomNumber).l
	andi.w	#1,d0				; d0 = random 0 or 1 (determines which one of 2 possible animals)
	moveq	#0,d1
	move.b	(Current_Zone).w,d1
	add.w	d1,d1
	add.w	d0,d1
	lea	Obj28_ZoneAnimals(pc),a1
	move.b	(a1,d1.w),d0			; get type from index based on zone + random 0 or 1
	move.l	d0,d2				; copy animal type
	move.b	d2,animal_ground_routine_base(a0)
	lsl.w	#3,d0				; multiply by 8
	lea	Obj28_Properties(pc),a1
	adda.w	d0,a1				; jump to actual variables
	move.l	(a1)+,animal_ground_x_vel(a0)	; load horizontal and vertical speeds
	move.l	(a1)+,mappings(a0)		; load mappings

	; Determine which animal graphics to use
	move.w	#make_art_tile(ArtTile_ArtNem_Animal_1,0,0),d1
	btst	#0,d2				; is this the first animal?
	beq.s	+				; if yes, branch
	move.w	#make_art_tile(ArtTile_ArtNem_Animal_2,0,0),d1
+
	move.w	d1,art_tile(a0)
	bsr.w	Adjust2PArtPointer
	move.b	#$C,y_radius(a0)
	move.b	#1<<render_flags.level_fg,render_flags(a0)
	bset	#render_flags.x_flip,render_flags(a0)
	move.b	#6,priority(a0)
	move.b	#8,width_pixels(a0)
	move.b	#7,anim_frame_duration(a0)
	move.b	#2,mapping_frame(a0)
	move.w	#-$400,y_vel(a0)
	tst.b	objoff_38(a0)
	bne.s	+
	bsr.w	AllocateObject
	bne.w	DisplaySprite
	_move.b	#ObjID_Points,id(a1) ; load obj29
	move.w	x_pos(a0),x_pos(a1)
	move.w	y_pos(a0),y_pos(a1)
	move.w	objoff_3E(a0),d0
	lsr.w	#1,d0
	move.b	d0,mapping_frame(a1)
	bra.w	DisplaySprite
; ===========================================================================
+
	move.b	#$1C,routine(a0)
	clr.w	x_vel(a0)
	bra.w	DisplaySprite
; ===========================================================================
; loc_11ADE
Obj28_Main:
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.w	Obj28_Delete
	bsr.w	ObjectMoveAndFall
	tst.w	y_vel(a0)
	bmi.w	DisplaySprite

	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.w	DisplaySprite

	add.w	d1,y_pos(a0)
	move.w	animal_ground_x_vel(a0),x_vel(a0)
	move.w	animal_ground_y_vel(a0),y_vel(a0)
	move.b	#1,mapping_frame(a0)
	move.b	animal_ground_routine_base(a0),d0
	add.b	d0,d0
	addq.b	#4,d0
	move.b	d0,routine(a0)
	tst.b	objoff_38(a0)
	beq.w	DisplaySprite
	btst	#4,(Vint_runcount+3).w
	beq.w	DisplaySprite
	neg.w	x_vel(a0)
	bchg	#render_flags.x_flip,render_flags(a0)
	bra.w	DisplaySprite
; ===========================================================================
; loc_11B38
Obj28_Walk:
	bsr.w	ObjectMoveAndFall
	move.b	#1,mapping_frame(a0)
	tst.w	y_vel(a0)
	bmi.s	+
	move.b	#0,mapping_frame(a0)
	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.s	+
	add.w	d1,y_pos(a0)
	move.w	animal_ground_y_vel(a0),y_vel(a0)
+
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	Obj28_Delete
	bra.w	DisplaySprite
; ===========================================================================
; loc_11B74
Obj28_Fly:
	bsr.w	ObjectMove
	addi.w	#$18,y_vel(a0)
	tst.w	y_vel(a0)
	bmi.s	+

	jsr	(ObjCheckFloorDist).l
	tst.w	d1
	bpl.s	+
	add.w	d1,y_pos(a0)
	move.w	animal_ground_y_vel(a0),y_vel(a0)
+
	subq.b	#1,anim_frame_duration(a0)
	bpl.s	+
	move.b	#1,anim_frame_duration(a0)
	addq.b	#1,mapping_frame(a0)
	andi.b	#1,mapping_frame(a0)
+
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	Obj28_Delete
	bra.w	DisplaySprite
; ===========================================================================
; Decrement the animal capsule's animal count; much faster than the original
; method, which looped through the entire dynamic object RAM (RetroKoH)
; loc_11BD8:
Obj28_Delete:
	tst.w	animal_capsule(a0)		; did this animal spawn from a capsule?
	beq.w	DeleteObject			; if not, branch
	movea.w	animal_capsule(a0),a2		; a2=capsule
	subq.b	#1,capsule_animalcount(a2)	; decrement capsule's animal count
	bra.w	DeleteObject
; ===========================================================================
; loc_11BF4
Obj28_Prison:
	_btst	#render_flags.on_screen,render_flags(a0)
	_beq.s	Obj28_Delete
	subq.w	#1,objoff_36(a0)
	bne.w	DisplaySprite
	move.b	#2,routine(a0)
	move.b	#1,priority(a0)
	bra.w	DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj28_MapUnc_11E1C:	include "mappings/sprite/obj28_a.asm"
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj28_MapUnc_11E40:	include "mappings/sprite/obj28_b.asm"
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj28_MapUnc_11E64:	include "mappings/sprite/obj28_c.asm"
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj28_MapUnc_11E88:	include "mappings/sprite/obj28_d.asm"
; ---------------------------------------------------------------------------
; sprite mappings
; ---------------------------------------------------------------------------
Obj28_MapUnc_11EAC:	include "mappings/sprite/obj28_e.asm"