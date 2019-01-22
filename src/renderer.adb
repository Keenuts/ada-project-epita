with STM32.Board;           use STM32.Board;

package body Renderer is

	-- sample a sprite
	-- X and Y belongs to [0; 1] interval
	-- Img must be a valid access
	function Sample_Sprite(
		Img : in Sprite_Access;
		X : in Float;
		Y : in Float
	) return UInt8
	is
		Px : Natural := Natural(X * Float(SPRITE_SIZE));
		Py : Natural := Natural(Y * Float(SPRITE_SIZE));
		I : Natural := Py * SPRITE_SIZE + Px;
	begin
		return UInt8(Img(unsigned(I)));
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

			pragma Loop_Invariant (
				I >= 0 and then I < Size * Size and then
				Px >= 0 and then Px < Size and then
				X >= 0.0 and then X <= 1.0 and then
				Y >= 0.0 and then Y <= 1.0);

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

	procedure Clear is
	begin
		-- FIXME: choose background color
		Fill(HAL.Bitmap.Black);
	end Clear;

	procedure Fill(color : in Bitmap_Color) is
	begin
		Display.Hidden_Buffer(1).Set_Source(color);
		Display.Hidden_Buffer(1).Fill;
	end Fill;

	procedure DrawEnemy(id : in CellId) is
		X : Integer;
		Y : Integer;
		framebuffer : DMA2D_Buffer := To_DMA2D_Buffer(Display.Hidden_Buffer(1).all);
	begin
		Y := (Integer(id) - 1) / GRID_WIDTH;

		if Y mod 2 = 0 then
			X := GRID_WIDTH - ((Integer(id) - 1) mod GRID_WIDTH) - 1;
		else
			X := (Integer(id) - 1) mod GRID_WIDTH;
		end if;

		Y := Y * CELL_SIZE;
		X := X * CELL_SIZE;

		STM32.DMA2D.DMA2D_Copy_Rect(
			Src_Buffer  => ENEMY_Buffer,
			X_Src       => 0,
			Y_Src       => 0,
			Dst_Buffer  => framebuffer,
			X_Dst       => X,
			Y_Dst       => Y,
			Bg_Buffer   => STM32.DMA2D.Null_Buffer,
			X_Bg        => 0,
			Y_Bg        => 0,
			Width       => ENEMY_Buffer.Width,
			Height      => ENEMY_Buffer.Height,
			Synchronous => True
		);

		-- TODO: to replace with bitmap drawing
		-- Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Red);
		-- Display.Hidden_Buffer(1).Fill_Circle((X, Y), SPRITE_SIZE);
	end DrawEnemy;

	procedure DrawPlayer(X, Y : in RangedPos) is
		PY, PX : Float;
		framebuffer : DMA2D_Buffer := To_DMA2D_Buffer(Display.Hidden_Buffer(1).all);
	begin
		-- project to frustrum-space coordinates
		PX := Float(X) / Float(RangedPos'Last);
		PY := Float(Y) / Float(RangedPos'Last);

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
			Bg_Buffer   => STM32.DMA2D.Null_Buffer,
			X_Bg        => 0,
			Y_Bg        => 0,
			Width       => PLAYER_Buffer.Width,
			Height      => PLAYER_Buffer.Height,
			Synchronous => True
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
		Display.Update_Layers;
		-- Display.Update_Layer (1, Copy_Back => True);
	end Flip;

end Renderer;
