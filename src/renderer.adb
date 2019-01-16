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

	procedure Fill(color : in Bitmap_Color) is
	begin
		Display.Hidden_Buffer(1).Set_Source(color);
		Display.Hidden_Buffer(1).Fill;
	end Fill;

	procedure DrawEnemy(id : in CellId) is
	begin
		-- TODO: to replace with bitmap drawing
		Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Red);
		Display.Hidden_Buffer(1).Fill_Circle(
			(
				((Integer(id) - 1) mod GRID_WIDTH) * CELL_SIZE + SPRITE_SIZE,
				((Integer(id) - 1) / GRID_WIDTH)   * CELL_SIZE + SPRITE_SIZE
			),
			SPRITE_SIZE
		);
	end DrawEnemy;

	procedure DrawPlayer(id : in CellId) is
	begin
		Display.Hidden_Buffer(1).Set_Source(HAL.Bitmap.Yellow);
		Display.Hidden_Buffer(1).Fill_Rect((
			(
				((Integer(id) - 1) mod GRID_WIDTH) * CELL_SIZE,
				((Integer(id) - 1) / GRID_WIDTH)   * CELL_SIZE
			),
			SPRITE_SIZE * 2,
			SPRITE_SIZE * 2
		));
	end DrawPlayer;

	procedure Flip is
	begin
		Display.Update_Layer (1, Copy_Back => True);
	end Flip;

end Renderer;
