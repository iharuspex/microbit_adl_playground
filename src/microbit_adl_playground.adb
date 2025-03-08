with MicroBit.Display;
with MicroBit.Buttons; use MicroBit.Buttons;
with MicroBit.Time;

procedure Microbit_Adl_Playground is
begin

   loop
      MicroBit.Display.Clear;

      if MicroBit.Buttons.State (Button_A) = Pressed then
         MicroBit.Display.Display ('A');
      elsif MicroBit.Buttons.State (Button_B) = Pressed then
         MicroBit.Display.Display ('B');
      end if;

      MicroBit.Time.Delay_Ms (200);
   end loop;

end Microbit_Adl_Playground;
