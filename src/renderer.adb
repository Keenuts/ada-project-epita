with STM32.Board;           use STM32.Board;

package body Renderer is

	-- sample a sprite
	-- X and Y belongs to [0; 1] interval
	-- Source must be a valid access
	function Sample_Sprite(
		Source		: in Sprite_Access;
		Width, Height	: in Positive;
		X, Y		: in Float
	) return UInt8
	is
		Px : Natural := Natural(Float'Floor(X * Float(Width)));
		Py : Natural := Natural(Float'Floor(Y * Float(Height)));
		I : Natural := Py * Width + Px;
	begin
		return UInt8(Source(unsigned(I)));
	end Sample_Sprite;

	procedure Load_Sprite(
		Src		: in Sprite_Access;
		Src_W, Src_H	: in Positive;
		Dst    		: in out Indexed_Bitmap;
		Dst_W, Dst_H	: in Positive)
	is
		Px, Py : Natural;
		X, Y : Float;
	begin
		for I in Dst'Range loop
			Px := I mod Dst_W;
			Py := I /   Dst_W;

			X := Float(Px) / Float(Dst_W);
			Y := Float(Py) / Float(Dst_H);

			Dst(I) := Sample_Sprite(Src, Src_W, Src_H, X, Y);
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
		Load_Sprite(
			ENEMY_SPRITE'Access,
			SPRITE_SIZE,
			SPRITE_SIZE,
			ENEMY_Indices,
			ENEMY_SPRITE_SIZE, ENEMY_SPRITE_SIZE
		);
		Load_Sprite(
			PLAYER_SPRITE'Access,
			SPRITE_SIZE,
			SPRITE_SIZE,
			PLAYER_Indices,
			PLAYER_SPRITE_SIZE,
			PLAYER_SPRITE_SIZE
		);
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

	procedure Draw_Enemy(X, Y : in RangedPos) is
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
	end Draw_Enemy;

	procedure Draw_Player(X, Y : in RangedPos) is
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
	end Draw_Player;

	-- Draw a particle at the given position
	procedure Draw_Particle(X, Y : in RangedPos) is
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
	end Draw_Particle;

	procedure Flip is
	begin
		STM32.DMA2D.DMA2D_Wait_Transfer;
		Display.Update_Layers;
	end Flip;

end Renderer;
