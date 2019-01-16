with BMP_Fonts;
with HAL.Bitmap;            use HAL.Bitmap;
with LCD_Std_Out;

package Renderer is
	-- GRID SIZE: number of cells to divide the screen in.
	GRID_HEIGHT : constant Integer := 8;
	GRID_WIDTH : constant Integer := 7;
	CELL_COUNT : constant Integer := GRID_WIDTH * GRID_HEIGHT;

	-- Type Definition
	type CellId is range 1 .. CELL_COUNT;

	procedure Initialize;

	--  Fills the backbuffer with the given color
	procedure Fill(color : in Bitmap_Color);

	-- Draw an enemy at the given position
	procedure DrawEnemy(id : in CellId);

	-- Draw an player at the given position
	procedure DrawPlayer(id : in CellId);

	-- Flips back and front buffers. (~ CommitChangedToDisplay)
	procedure Flip;

private

	-- Display constants
	SCREEN_WIDTH : constant Integer := 238;
	CELL_SIZE : constant Integer := SCREEN_WIDTH / GRID_WIDTH;

	-- sprite size in pixels
	SPRITE_SIZE : constant Integer := CELL_SIZE / 2;
	BACKGROUND_COLOR : constant Bitmap_Color := (Alpha => 255, others => 0);

end Renderer;
