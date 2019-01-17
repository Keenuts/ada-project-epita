with STM32.Board;           use STM32.Board;

package body Renderer is

	procedure Initialize is
	begin
		--  Initialize LCD
		Display.Initialize;
		Display.Initialize_Layer (1, ARGB_8888);
		LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
		LCD_Std_Out.Current_Background_Color := BACKGROUND_COLOR;
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
	begin
		Y := (Integer(id) - 1) / GRID_WIDTH;

		if Y mod 2 = 0 then
			X := GRID_WIDTH - ((Integer(id) - 1) mod GRID_WIDTH) - 1;
			-- X := (Integer(id) - 1) mod GRID_WIDTH;
		else
			X := (Integer(id) - 1) mod GRID_WIDTH;
		end if;

		Y := Y * CELL_SIZE + SPRITE_SIZE;
		X := X * CELL_SIZE + SPRITE_SIZE;

		-- TODO: to replace with bitmap drawing
		Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Red);
		Display.Hidden_Buffer(1).Fill_Circle((X, Y), SPRITE_SIZE);
	end DrawEnemy;

	procedure DrawPlayer(X, Y : in RangedPos) is
		PY, PX : Float;
	begin
		-- project to frustrum-space coordinates
		PX := Float(X) / Float(RangedPos'Last);
		PY := Float(Y) / Float(RangedPos'Last);

		-- transform to screen-space coordinates
		PX := PX * Float(SCREEN_WIDTH - PLAYER_SIZE);
		PY := PY * Float(SCREEN_HEIGHT - PLAYER_SIZE);

		Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Yellow);
		Display.Hidden_Buffer(1).Fill_Rect((
			( Natural(PX), Natural(PY) ),
			PLAYER_SIZE,
			PLAYER_SIZE
		));
	end DrawPlayer;

	-- Draw a particle at the given position
	procedure DrawParticle(X, Y : in RangedPos) is
	begin
		null;
	end DrawParticle;

	procedure Flip is
	begin
		Display.Update_Layer (1, Copy_Back => True);
	end Flip;

end Renderer;
