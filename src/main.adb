------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board;           use STM32.Board;
with HAL.Bitmap;            use HAL.Bitmap;
pragma Warnings (Off, "referenced");
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with STM32.User_Button;     use STM32;
with BMP_Fonts;
with LCD_Std_Out;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Vec2; use Vec2;

procedure Main
is
    type Object is
        record
            Position : Vector;
            Speed : Vector;
            Size : Vector;
        end record;

    function IsColliding(A, B : Object) return Boolean is
    begin
        if A.Position.X + A.Size.X < B.Position.X then
            return false;
        end if;

        if A.Position.Y + A.Size.Y < B.Position.Y then
            return false;
        end if;

        if A.Position.X > B.Position.X + B.Size.X then
            return false;
        end if;

        if A.Position.Y > B.Position.Y + B.Size.Y then
            return false;
        end if;

        return true;
    end IsColliding;

    function CollideScreen(A : Object) return Object is
        O : Object;
    begin
        O := A;

        if O.Position.X > 240.0 - O.Size.X then
            O.Speed := Reflect(O.Speed, VECTOR_LEFT);
        elsif O.Position.X <= O.Size.X then
            O.Speed := Reflect(O.Speed, VECTOR_RIGHT);
        end if;

        if O.Position.Y > 315.0 - O.Size.X then
            O.Speed := Reflect(O.Speed, VECTOR_UP);
        elsif O.Position.Y <= O.Size.X then
            O.Speed := Reflect(O.Speed, VECTOR_DOWN);
        end if;

        return O;
    end CollideScreen;

    procedure InitializeObject(R : in Ada.Numerics.Float_Random.Generator; O : in out Object) is
    begin
        O.Position.X := Ada.Numerics.Float_Random.Random(R) * 239.0 + 1.0;
        O.Position.y := Ada.Numerics.Float_Random.Random(R) * 314.0 + 1.0;
        O.Speed.X := Ada.Numerics.Float_Random.Random(R) * 2.0 - 1.0;
        O.Speed.Y := Ada.Numerics.Float_Random.Random(R) * 2.0 - 1.0;

        O.Speed := Normalize(O.Speed) * 2.0;
        O.Size := ( X => 10.0, Y => 10.0);
    end InitializeObject;

    ObjectCount : constant Integer := 20;

    Gen : Ada.Numerics.Float_Random.Generator;
    BG : Bitmap_Color := (Alpha => 255, others => 0);

    Objects : array(0 .. ObjectCount - 1) of Object;
    Colors : array(0 .. 9) of Bitmap_Color := (
        HAL.Bitmap.Red, HAL.Bitmap.Coral, HAL.Bitmap.Aqua,
        HAL.Bitmap.Green, HAL.Bitmap.Gold, HAL.Bitmap.Teal,
        HAL.Bitmap.Blue, HAL.Bitmap.Olive, HAL.Bitmap.Purple,
        HAL.Bitmap.Brown
    );
begin
    for i in Integer range 0 .. ObjectCount - 1 loop
        InitializeObject(Gen, Objects(i));
    end loop;

    --  Initialize LCD
    Display.Initialize;
    Display.Initialize_Layer (1, ARGB_8888);

    --  Initialize touch panel
    Touch_Panel.Initialize;

    --  Initialize button
    User_Button.Initialize;

    LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
    LCD_Std_Out.Current_Background_Color := BG;

    --  Clear LCD (set background)
    Display.Hidden_Buffer (1).Set_Source (BG);
    Display.Hidden_Buffer (1).Fill;

    LCD_Std_Out.Clear_Screen;
    Display.Update_Layer (1, Copy_Back => True);

    loop
        if User_Button.Has_Been_Pressed then
            BG := HAL.Bitmap.Dark_Orange;
        end if;

        Display.Hidden_Buffer (1).Set_Source (BG);
        Display.Hidden_Buffer (1).Fill;

        for i in Integer range 0 .. ObjectCount - 1 loop
            Display.Hidden_Buffer(1).Set_Source(Colors(i mod 10));
            Display.Hidden_Buffer(1).Fill_Circle((
                    Integer(Objects(i).Position.X),
                    Integer(Objects(i).Position.Y)),
                Integer(Objects(i).Size.X));
            Objects(i) := CollideScreen(Objects(i));
            Objects(i).Position := Objects(i).Position + Objects(i).Speed;

            for j in Integer range 0 .. ObjectCount - 1 loop
                if j /= i then
                    if IsColliding(Objects(i), Objects(j)) then
                        swap(Objects(i).Speed, Objects(j).Speed);
                    end if;
                end if;
            end loop;
        end loop;


        --declare
        --    State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
        --    begin
        --        case State'Length is
        --        when 1 =>
        --            Ball_Pos := (State (State'First).X, State (State'First).Y);
        --        when others => null;
        --        end case;
        --    end;
        --  Update screen
        Display.Update_Layer (1, Copy_Back => True);
    end loop;
end Main;
