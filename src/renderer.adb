with STM32.Board;           use STM32.Board;

package body Renderer is

	-- sample a sprite
	-- X and Y belongs to [0; 1] interval
	-- Source must be a valid access
	function Sample_Sprite(
		Source : in Sprite_Access;
		X : in Float;
		Y : in Float
	) return UInt8
	is
		Px : Natural := Natural(Float'Floor(X * Float(SPRITE_SIZE)));
		Py : Natural := Natural(Float'Floor(Y * Float(SPRITE_SIZE)));
		I : Natural := Py * SPRITE_SIZE + Px;
	begin
		return UInt8(Source(unsigned(I)));
	end Sample_Sprite;

	procedure Load_Sprite(
		Source     : in Sprite_Access;
		Indices    : in out Indexed_Bitmap;
		Size 	   : in Positive)
	is
		Px, Py : Natural;
		X, Y : Float;
	begin
		for I in Indices'Range loop
			Px := I mod Size;
			Py := I / Size;

		 	X := Float(Px) / Float(Size);
		 	Y := Float(Py) / Float(Size);

			Indices(I) := Sample_Sprite(Source, X, Y);
		 end loop;
	end Load_Sprite;

	procedure Initialize is
	begin
		--  Initialize LCD
		Display.Initialize;
		Display.Initialize_Layer (1, ARGB_8888);
		LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
		LCD_Std_Out.Current_Background_Color := BACKGROUND_COLOR;

		-- Initialize sprites DMA-BUFs
		Load_Sprite(SPRITE_ENEMY'Access,  ENEMY_Indices,  ENEMY_SPRITE_SIZE);
		Load_Sprite(SPRITE_PLAYER'Access, PLAYER_Indices, PLAYER_SPRITE_SIZE);
	end Initialize;

	procedure Fill(color : in Bitmap_Color) is
	begin
		Display.Hidden_Buffer(1).Set_Source(color);
		Display.Hidden_Buffer(1).Fill;
	end Fill;

	procedure Clear is
	begin
		Fill(HAL.Bitmap.Black);
	end Clear;

	procedure DrawEnemy(X, Y : in RangedPos) is
		PY, PX : Float;
		framebuffer : DMA2D_Buffer := To_DMA2D_Buffer(Display.Hidden_Buffer(1).all);
	begin
		-- project to frustrum-space coordinates
		PX := Float(X) / Float(RANGED_POS_LEN);
		PY := Float(Y) / Float(RANGED_POS_LEN);

		-- transform to screen-space coordinates
		PX := PX * Float(SCREEN_WIDTH - ENEMY_SPRITE_SIZE);
		PY := PY * Float(SCREEN_HEIGHT - ENEMY_SPRITE_SIZE);

		STM32.DMA2D.DMA2D_Copy_Rect(
			Src_Buffer  => ENEMY_Buffer,
			X_Src       => 0,
			Y_Src       => 0,
			Dst_Buffer  => framebuffer,
			X_Dst       => Natural(PX),
			Y_Dst       => Natural(PY),
			Bg_Buffer   => framebuffer,
			X_Bg        => Natural(PX),
			Y_Bg        => Natural(PY),
			Width       => ENEMY_Buffer.Width,
			Height      => ENEMY_Buffer.Height,
			Synchronous => False
		);
	end DrawEnemy;

	procedure DrawPlayer(X, Y : in RangedPos) is
		PY, PX : Float;
		framebuffer : DMA2D_Buffer := To_DMA2D_Buffer(Display.Hidden_Buffer(1).all);
	begin
		-- project to frustrum-space coordinates
		PX := Float(X) / Float(RANGED_POS_LEN);
		PY := Float(Y) / Float(RANGED_POS_LEN);

		-- transform to screen-space coordinates
		PX := PX * Float(SCREEN_WIDTH - PLAYER_SPRITE_SIZE);
		PY := PY * Float(SCREEN_HEIGHT - PLAYER_SPRITE_SIZE);

		STM32.DMA2D.DMA2D_Copy_Rect(
			Src_Buffer  => PLAYER_Buffer,
			X_Src       => 0,
			Y_Src       => 0,
			Dst_Buffer  => framebuffer,
			X_Dst       => Natural(PX),
			Y_Dst       => Natural(PY),
			Bg_Buffer   => framebuffer,
			X_Bg        => Natural(PX),
			Y_Bg        => Natural(PY),
			Width       => PLAYER_Buffer.Width,
			Height      => PLAYER_Buffer.Height,
			Synchronous => False
		);
	end DrawPlayer;

	-- Draw a particle at the given position
	procedure DrawParticle(X, Y : in RangedPos) is
		PY, PX : Float;
	begin
		-- project to frustrum-space coordinates
		PX := Float(X) / Float(RangedPos'Last);
		PY := Float(Y) / Float(RangedPos'Last);

		-- transform to screen-space coordinates
		PX := PX * Float(SCREEN_WIDTH - PARTICLE_SIZE);
		PY := PY * Float(SCREEN_HEIGHT - PARTICLE_SIZE);

		Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Green);
		Display.Hidden_Buffer(1).Fill_Rect((
			( Natural(PX), Natural(PY) ),
			PARTICLE_SIZE,
			PARTICLE_SIZE
		));
		null;
	end DrawParticle;

	procedure Flip is
	begin
		STM32.DMA2D.DMA2D_Wait_Transfer;
		Display.Update_Layers;
	end Flip;

end Renderer;
