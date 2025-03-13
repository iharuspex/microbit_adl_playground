with HAL.Time;
with HAL.I2C; use HAL.I2C;
with MicroBit.I2C;
--  with MicroBit.Display;
--  with MicroBit.Buttons; use MicroBit.Buttons;
with MicroBit.Time;
with MicroBit.Console;
with System.Semihosting;

--  with MMA8653;
--  with MicroBit.Accelerometer;

--  with SSD1306;
with LM75;
use LM75;
--  with SSD1306.Standard_Resolutions;

with Last_Chance_Handler;
pragma Unreferenced (Last_Chance_Handler);

procedure Microbit_Adl_Playground is

   HAL_Time : constant HAL.Time.Any_Delays := MicroBit.Time.HAL_Delay;

   Temp_Sensor : LM75_Sensor (MicroBit.I2C.Controller);

   --  Acc_Data : MMA8653.All_Axes_Data;

   T    : Temperature := 0.0;
   Hyst : Temperature := 0.0;

   procedure I2C_Scan is
      Status  : HAL.I2C.I2C_Status;
      D       : HAL.I2C.I2C_Data (1 .. 1);
      Address : HAL.I2C.I2C_Address;
   begin
      for I in 16#00# .. 16#FF# loop
         Address := HAL.I2C.I2C_Address (I);
         MicroBit.I2C.Controller.Master_Transmit (Address, D, Status);

         if Status = HAL.I2C.Ok then
            MicroBit.Console.Put_Line (I'Image);
         end if;
         HAL_Time.Delay_Milliseconds (100);
      end loop;
   end I2C_Scan;

begin

   if not MicroBit.I2C.Initialized then
      MicroBit.I2C.Initialize;
   end if;

   I2C_Scan;

   Temp_Sensor.Set_Address (16#3B#);
   --  Temp_Sensor.Get_Hysteresis (Hyst);

   System.Semihosting.Put ("Test");
   MicroBit.Console.Put_Line ("Test");

   loop
      --  Acc_Data := Microbit.Accelerometer.Data;
      Temp_Sensor.Read_Temperature (T);
      HAL_Time.Delay_Milliseconds (100);
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
