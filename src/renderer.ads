with BMP_Fonts;
with HAL.Bitmap;            use HAL.Bitmap;
with LCD_Std_Out;

with HAL; 		    use HAL;
with Interfaces.C; 	    use Interfaces.C;
with STM32.DMA2D;           use STM32.DMA2D;
with STM32.DMA2D_Bitmap;    use STM32.DMA2D_Bitmap;
-- with STM32.Board;           use STM32.Board;
-- with STM32.SDRAM;           use STM32.SDRAM;
-- with System;

package Renderer is
	-- Display constants for STM32f4-discovery
	SCREEN_WIDTH  : constant Integer := 238;
	SCREEN_HEIGHT : constant Integer := 320;

	SPRITE_SIZE : constant Positive := 8;
	type Sprite is array(unsigned) of aliased Interfaces.Unsigned_8;
	type Sprite_Access is not null access constant Sprite;

	ENEMY_SPRITE : aliased SPRITE;
	pragma Import (C, ENEMY_SPRITE, "sprite_enemy");
	PLAYER_SPRITE : aliased SPRITE;
	pragma Import (C, PLAYER_SPRITE, "sprite_player");

	-- ==================
	-- DMA sprite storage
	-- ==================
	-- The whole game use only the colors present in this palette
	COLOR_PALETTE : constant array(Uint8) of DMA2D_Color := (
		(  0,   0,   0,   0),
		(255, 255,   0,   0),
		(255,   0, 255,   0),
		(255,   0,   0, 255),
		others => (0, 0, 0, 0)
	);

	-- A sprite's size is the size on the screen. Does not represent the TGA size.
	-- Each sprite is stored in its own DMA buffer.
	type Indexed_Bitmap is array(Natural range <>) of UInt8 with Pack;
	BPP : constant Positive := 8;

	-- The size of the displayed enemy sprite in pixels
	ENEMY_SPRITE_SIZE : constant Positive := 32;
	ENEMY_Indices 	  : Indexed_Bitmap(0 .. ENEMY_SPRITE_SIZE ** 2 - 1);
	ENEMY_Buffer  	  : constant DMA2D_Buffer := (
		Color_Mode      => L8,
		Addr            => ENEMY_Indices(0)'Address,
		Width           => ENEMY_SPRITE_SIZE,
		Height          => ENEMY_SPRITE_SIZE,
		CLUT_Color_Mode => ARGB8888,
		CLUT_Addr       => COLOR_PALETTE(0)'Address
	);

	-- The size of the displayed player sprite in pixels
	PLAYER_SPRITE_SIZE : constant Positive := 32;
	PLAYER_Indices 	  : Indexed_Bitmap(0 .. PLAYER_SPRITE_SIZE ** 2 - 1);
	PLAYER_Buffer  	  : constant DMA2D_Buffer := (
		Color_Mode      => L8,
		Addr            => PLAYER_Indices(0)'Address,
		Width           => PLAYER_SPRITE_SIZE,
		Height          => PLAYER_SPRITE_SIZE,
		CLUT_Color_Mode => ARGB8888,
		CLUT_Addr       => COLOR_PALETTE(0)'Address
	);

	-- Type Definition
	type RangedPos is range 1 .. 100 with Default_Value => 1;
	RANGED_POS_LEN : constant Positive := Positive(RangedPos'Last - RangedPos'First);

	-- Initialize thr STM32 and loads sprites
	procedure Initialize;

	--  Fills the backbuffer with the given color
	procedure Fill(color : in Bitmap_Color);

	procedure Clear;

	-- Draw an enemy at the given position
	procedure Draw_Enemy(X, Y : in RangedPos);

	-- Draw an player at the given position
	procedure Draw_Player(X, Y : in RangedPos);

	-- Draw a particle at the given position
	procedure Draw_Particle(X, Y : in RangedPos);

	-- Flips back and front buffers. (~ CommitChangedToDisplay)
	procedure Flip;

	PARTICLE_SIZE : constant Positive := 5;
private
	BACKGROUND_COLOR : constant Bitmap_Color := (Alpha => 255, others => 0);

	function Sample_Sprite(
		Source		: in Sprite_Access;
		Width, Height	: in Positive;
		X, Y		: in Float
	) return UInt8;

	procedure Load_Sprite(
		Src		: in Sprite_Access;
		Src_W, Src_H	: in Positive;
		Dst    		: in out Indexed_Bitmap;
		Dst_W, Dst_H	: in Positive);


end Renderer;
