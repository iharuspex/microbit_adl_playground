with HAL.Time;
with MicroBit.I2C;
--  with MicroBit.Display;
--  with MicroBit.Buttons; use MicroBit.Buttons;
with MicroBit.Time;
with System.Semihosting;

--  with MMA8653;
--  with MicroBit.Accelerometer;

--  with SSD1306;
with LM75; use LM75;
--  with SSD1306.Standard_Resolutions;

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);

procedure Microbit_Adl_Playground is

   HAL_Time : constant HAL.Time.Any_Delays := MicroBit.Time.HAL_Delay;

   Temp_Sensor : LM75_Sensor (MicroBit.I2C.Controller);

   --  Acc_Data : MMA8653.All_Axes_Data;

   T : Temperature := 0.0;

begin
   if not MicroBit.I2C.Initialized then
      MicroBit.I2C.Initialize;
   end if;

   Temp_Sensor.Init (16#48#);
   
   System.Semihosting.Put("ASS");

   loop
      --  Acc_Data := Microbit.Accelerometer.Data;
      Temp_Sensor.Read_Temperature (T);
   end loop;

   --  declare
   --     Screen : SSD1306.SSD1306_Screen ((128 * 32) / 8, 128, 32, MicroBit.I2C.Controller, MicroBit.MB_P16'Access, HAL_Time);
   --  begin
   --     Screen.Initialize (False);
   --     Screen.Turn_On;

   --     loop
   --        --  MicroBit.Time.Delay_Ms (200);
   --        HAL_Time.Delay_Milliseconds (200);
   --     end loop;
   --  end;

end Microbit_Adl_Playground;
