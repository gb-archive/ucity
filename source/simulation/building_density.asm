;###############################################################################
;
;    BitCity - City building game for Game Boy Color.
;    Copyright (C) 2016 Antonio Nino Diaz (AntonioND/SkyLyrac)
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;    Contact: antonio_nd@outlook.com
;
;###############################################################################

    INCLUDE "hardware.inc"
    INCLUDE "engine.inc"

;-------------------------------------------------------------------------------

    INCLUDE "room_game.inc"
    INCLUDE "tileset_info.inc"
    INCLUDE "building_density.inc"

;###############################################################################

    SECTION "Building Density Functions Bank 0",ROM0

;-------------------------------------------------------------------------------

CityTileDensity:: ; de = tile, returns d=population, e=energy

    push    de
    ld      b,BANK(CITY_TILE_DENSITY)
    call    rom_bank_push_set
    pop     de

IF CITY_TILE_DENSITY_ELEMENT_SIZE != 3
    FAIL "Fix this!"
ENDC

    ld      hl,CITY_TILE_DENSITY
    add     hl,de
    add     hl,de
    add     hl,de ; base + index * 3
    ld      a,[hl+]
    ld      d,a
    ld      e,[hl]

    push    de
    call    rom_bank_pop
    pop     de

    ret

;-------------------------------------------------------------------------------

CityTilePollution:: ; de = tile, returns d=pollution

    push    de
    ld      b,BANK(CITY_TILE_DENSITY)
    call    rom_bank_push_set
    pop     de

IF CITY_TILE_DENSITY_ELEMENT_SIZE != 3
    FAIL "Fix this!"
ENDC

    ld      hl,CITY_TILE_DENSITY+2 ; pollution level
    add     hl,de
    add     hl,de
    add     hl,de ; base + index * 3
    ld      d,[hl]

    push    de
    call    rom_bank_pop
    pop     de

    ret

;###############################################################################

CURTILE     SET 0
POPULATION  SET 0
ENERGY_COST SET 0
POLLUTION   SET 0

; Tile Add - Base tile of the building to add information of
;            Will only fill the building when the next one is added!
; Input pollution as a -128 to 127 value! Negative values are used for forests,
; parks, etc. Positive values for areas that pollute.
T_ADD : MACRO ; 1=Tile index, 2=Population, 3=Energy Cost, 4=Pollution

    IF (\1) < CURTILE ; check if going backwards and stop if so
        FAIL "ERROR : building_density.asm : Tile already in use!"
    ENDC

    ; Fill previous building
    IF (\1) > CURTILE ; The first call both are 0 and this has to be skipped
        REPT (\1) - CURTILE
            DB POPULATION, ENERGY_COST, 128+POLLUTION
        ENDR
    ENDC

    ; Set parameters for this building
CURTILE     SET (\1)
POPULATION  SET (\2)
ENERGY_COST SET (\3)
POLLUTION   SET (\4)

ENDM

;###############################################################################

    SECTION "Building Density Data",ROMX

;-------------------------------------------------------------------------------

IF CITY_TILE_DENSITY_ELEMENT_SIZE != 3
    FAIL "Fix this!"
ENDC

CITY_TILE_DENSITY:: ; 512 entries - Population, energy cost, pollution level

; Population is the whole population of the building, the others are per-tile

; Pollution base level is 128, lower values are clean areas and higher values
; are polluted areas. The macro used here takes the input value and adds 128 to
; it so that negative values can be used for clean areas and positive values
; can be used for areas that pollute. Note that the actual values are 0 to 255.

    T_ADD   T_GRASS__FOREST_TL, 0,0, -64
    T_ADD   T_GRASS__FOREST_TC, 0,0, -64
    T_ADD   T_GRASS__FOREST_TR, 0,0, -64
    T_ADD   T_GRASS__FOREST_CL, 0,0, -64
    T_ADD   T_GRASS,            0,0, -16
    T_ADD   T_GRASS__FOREST_CR, 0,0, -64
    T_ADD   T_GRASS__FOREST_BL, 0,0, -64
    T_ADD   T_GRASS__FOREST_BC, 0,0, -64
    T_ADD   T_GRASS__FOREST_BR, 0,0, -64
    T_ADD   T_GRASS__FOREST_CORNER_TL, 0,0, -64
    T_ADD   T_GRASS__FOREST_CORNER_TR, 0,0, -64
    T_ADD   T_GRASS__FOREST_CORNER_BL, 0,0, -64
    T_ADD   T_GRASS__FOREST_CORNER_BR, 0,0, -64
    T_ADD   T_FOREST,       0,0, -127
    T_ADD   T_GRASS_EXTRA,  0,0,  -16
    T_ADD   T_FOREST_EXTRA, 0,0, -127

    T_ADD   T_WATER__GRASS_TL, 0,0, -32
    T_ADD   T_WATER__GRASS_TC, 0,0, -32
    T_ADD   T_WATER__GRASS_TR, 0,0, -32
    T_ADD   T_WATER__GRASS_CL, 0,0, -32
    T_ADD   T_WATER,           0,0, -48
    T_ADD   T_WATER__GRASS_CR, 0,0, -32
    T_ADD   T_WATER__GRASS_BL, 0,0, -32
    T_ADD   T_WATER__GRASS_BC, 0,0, -32
    T_ADD   T_WATER__GRASS_BR, 0,0, -32
    T_ADD   T_WATER__GRASS_CORNER_TL, 0,0, -32
    T_ADD   T_WATER__GRASS_CORNER_TR, 0,0, -32
    T_ADD   T_WATER__GRASS_CORNER_BL, 0,0, -32
    T_ADD   T_WATER__GRASS_CORNER_BR, 0,0, -32
    T_ADD   T_WATER_EXTRA, 0,0, -64

    T_ADD   T_RESIDENTIAL, 0,1, 0
    T_ADD   T_COMMERCIAL,  0,1, 0
    T_ADD   T_INDUSTRIAL,  0,1, 0
    T_ADD   T_DEMOLISHED,  0,0, 0

    T_ADD   T_ROAD_TB,   0,0, 0 ; Road pollution is 0, it is calculated from the
    T_ADD   T_ROAD_TB_1, 0,0, 0 ; traffic level.
    T_ADD   T_ROAD_TB_2, 0,0, 0
    T_ADD   T_ROAD_TB_3, 0,0, 0
    T_ADD   T_ROAD_LR,   0,0, 0
    T_ADD   T_ROAD_LR_1, 0,0, 0
    T_ADD   T_ROAD_LR_2, 0,0, 0
    T_ADD   T_ROAD_LR_3, 0,0, 0
    T_ADD   T_ROAD_RB,   0,0, 0
    T_ADD   T_ROAD_LB,   0,0, 0
    T_ADD   T_ROAD_TR,   0,0, 0
    T_ADD   T_ROAD_TL,   0,0, 0
    T_ADD   T_ROAD_TRB,  0,0, 0
    T_ADD   T_ROAD_LRB,  0,0, 0
    T_ADD   T_ROAD_TLB,  0,0, 0
    T_ADD   T_ROAD_TLR,  0,0, 0
    T_ADD   T_ROAD_TLRB, 0,0, 0
    T_ADD   T_ROAD_TB_POWER_LINES, 0,1, 0
    T_ADD   T_ROAD_LR_POWER_LINES, 0,1, 0
    T_ADD   T_ROAD_TB_BRIDGE, 0,0, 0
    T_ADD   T_ROAD_LR_BRIDGE, 0,0, 0

    T_ADD   T_TRAIN_TB,   0,0, 0
    T_ADD   T_TRAIN_LR,   0,0, 0
    T_ADD   T_TRAIN_RB,   0,0, 0
    T_ADD   T_TRAIN_LB,   0,0, 0
    T_ADD   T_TRAIN_TR,   0,0, 0
    T_ADD   T_TRAIN_TL,   0,0, 0
    T_ADD   T_TRAIN_TRB,  0,0, 0
    T_ADD   T_TRAIN_LRB,  0,0, 0
    T_ADD   T_TRAIN_TLB,  0,0, 0
    T_ADD   T_TRAIN_TLR,  0,0, 0
    T_ADD   T_TRAIN_TLRB, 0,0, 0
    T_ADD   T_TRAIN_LR_ROAD, 0,0, 0
    T_ADD   T_TRAIN_TB_ROAD, 0,0, 0
    T_ADD   T_TRAIN_TB_POWER_LINES, 0,1, 0
    T_ADD   T_TRAIN_LR_POWER_LINES, 0,1, 0
    T_ADD   T_TRAIN_TB_BRIDGE, 0,0, 0
    T_ADD   T_TRAIN_LR_BRIDGE, 0,0, 0

    T_ADD   T_POWER_LINES_TB,   0,1, 0
    T_ADD   T_POWER_LINES_LR,   0,1, 0
    T_ADD   T_POWER_LINES_RB,   0,1, 0
    T_ADD   T_POWER_LINES_LB,   0,1, 0
    T_ADD   T_POWER_LINES_TR,   0,1, 0
    T_ADD   T_POWER_LINES_TL,   0,1, 0
    T_ADD   T_POWER_LINES_TRB,  0,1, 0
    T_ADD   T_POWER_LINES_LRB,  0,1, 0
    T_ADD   T_POWER_LINES_TLB,  0,1, 0
    T_ADD   T_POWER_LINES_TLR,  0,1, 0
    T_ADD   T_POWER_LINES_TLRB, 0,1, 0
    T_ADD   T_POWER_LINES_TB_BRIDGE, 0,1, 0
    T_ADD   T_POWER_LINES_LR_BRIDGE, 0,1, 0

    T_ADD   T_POLICE_DEPT, 1*9,1, 32
    T_ADD   T_FIRE_DEPT,   1*9,1, 16
    T_ADD   T_HOSPITAL,    2*9,1, 32

    T_ADD   T_PARK_SMALL,  2*1, 1, -127
    T_ADD   T_PARK_BIG,    2*9, 1, -127
    T_ADD   T_STADIUM,    3*15,20, 32

    T_ADD   T_SCHOOL,       2*6,5, 16
    T_ADD   T_HIGH_SCHOOL,  2*9,6, 16
    T_ADD   T_UNIVERSITY,  2*25,7, 16
    T_ADD   T_MUSEUM,      1*12,6, 16
    T_ADD   T_LIBRARY,      1*6,5, 16

    T_ADD   T_AIRPORT,   2*15,10, 64
    T_ADD   T_PORT,        1*9,8, 64
    T_ADD   T_PORT_WATER_L,  0,0, 16
    T_ADD   T_PORT_WATER_R,  0,0, 16
    T_ADD   T_PORT_WATER_D,  0,0, 16
    T_ADD   T_PORT_WATER_U,  0,0, 16

    T_ADD   T_POWER_PLANT_COAL,    1*16,0, 127 ; They don't have energetic cost,
    T_ADD   T_POWER_PLANT_OIL,     1*16,0, 112 ; power plants are generators!
    T_ADD   T_POWER_PLANT_WIND,     1*4,0, 0
    T_ADD   T_POWER_PLANT_SOLAR,   1*16,0, 0
    T_ADD   T_POWER_PLANT_NUCLEAR, 2*16,0, 0
    T_ADD   T_POWER_PLANT_FUSION,  3*16,0, 0

    T_ADD   T_RESIDENTIAL_S1_A, 6*1,2, 16
    T_ADD   T_RESIDENTIAL_S1_B, 7*1,2, 16
    T_ADD   T_RESIDENTIAL_S1_C, 7*1,2, 16
    T_ADD   T_RESIDENTIAL_S1_D, 8*1,2, 16

    T_ADD   T_RESIDENTIAL_S2_A, 8*4,3, 24
    T_ADD   T_RESIDENTIAL_S2_B, 9*4,3, 24
    T_ADD   T_RESIDENTIAL_S2_C, 9*4,3, 24
    T_ADD   T_RESIDENTIAL_S2_D, 10*4,3, 24

    T_ADD   T_RESIDENTIAL_S3_A, 10*9,5, 32
    T_ADD   T_RESIDENTIAL_S3_B, 11*9,5, 32
    T_ADD   T_RESIDENTIAL_S3_C, 11*9,5, 32
    T_ADD   T_RESIDENTIAL_S3_D, 12*9,5, 32

    T_ADD   T_COMMERCIAL_S1_A, 1*1,2, 32
    T_ADD   T_COMMERCIAL_S1_B, 1*1,2, 32
    T_ADD   T_COMMERCIAL_S1_C, 2*1,2, 32
    T_ADD   T_COMMERCIAL_S1_D, 2*1,2, 32

    T_ADD   T_COMMERCIAL_S2_A, 2*4,3, 48
    T_ADD   T_COMMERCIAL_S2_B, 2*4,3, 48
    T_ADD   T_COMMERCIAL_S2_C, 3*4,3, 48
    T_ADD   T_COMMERCIAL_S2_D, 3*4,3, 48

    T_ADD   T_COMMERCIAL_S3_A, 4*9,5, 64
    T_ADD   T_COMMERCIAL_S3_B, 4*9,5, 64
    T_ADD   T_COMMERCIAL_S3_C, 5*9,5, 64
    T_ADD   T_COMMERCIAL_S3_D, 5*9,5, 64

    T_ADD   T_INDUSTRIAL_S1_A, 1*1,2, 64
    T_ADD   T_INDUSTRIAL_S1_B, 2*1,2, 64
    T_ADD   T_INDUSTRIAL_S1_C, 2*1,2, 64
    T_ADD   T_INDUSTRIAL_S1_D, 2*1,2, 64

    T_ADD   T_INDUSTRIAL_S2_A, 3*4,6, 92
    T_ADD   T_INDUSTRIAL_S2_B, 3*4,6, 92
    T_ADD   T_INDUSTRIAL_S2_C, 4*4,6, 92
    T_ADD   T_INDUSTRIAL_S2_D, 4*4,6, 92

    T_ADD   T_INDUSTRIAL_S3_A, 5*9,10, 127
    T_ADD   T_INDUSTRIAL_S3_B, 5*9,10, 127
    T_ADD   T_INDUSTRIAL_S3_C, 5*9,10, 127
    T_ADD   T_INDUSTRIAL_S3_D, 6*9,10, 127

    T_ADD   512, 0,0,0 ; Fill array

;###############################################################################
