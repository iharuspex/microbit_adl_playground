package body LM75 is

    function Read_Register (This : LM75_Sensor'Class;
                            Addr : Register_Address) return UInt8;

    function Read_Register (This : LM75_Sensor'Class;
                            Addr : Register_Address) return UInt16;

    procedure Write_Register (This : LM75_Sensor'Class;
                              Addr : Register_Address;
                              Val  : UInt8);

    procedure Write_Register (This : LM75_Sensor'Class;
                              Addr : Register_Address;
                              Val  : UInt16);

    -- Temperature register
    -- Shift - 5
    ----------------------------------------------------
    -- MSB                        LSB
    --  7  6  5  4  3  2  1  0  | 7  6  5  4  3  2  1  0
    -- D10 D9 D8 D7 D6 D5 D4 D3 | D2 D1 D0 X  X  X  X  X
    ----------------------------------------------------
    ----------------------------------------------------
    -- Overtemperature shutdown threshold (Tos) and hysteresis (Thyst) registers
    -- Shift - 7
    ----------------------------------------------------
    -- MSB                        LSB
    -- 7  6  5  4  3  2  1  0  | 7  6  5  4  3  2  1  0
    -- D8 D7 D6 D5 D4 D3 D2 D1 | D0 X  X  X  X  X  X  X
    ----------------------------------------------------

    function Temp_To_Reg (T : Temperature; 
                          Scale : Float;
                          Shift : Natural) return UInt16;

    function Reg_To_Temp (Reg_Data : UInt16; 
                          Scale    : Float;
                          Shift    : Natural) return Temperature;

    -------------------
    -- Read_Register --
    ------------------- 

    function Read_Register (This : LM75_Sensor'Class;
                            Addr : Register_Address) return UInt8
    is
        Data   : I2C_Data (1 .. 1);
        Status : I2C_Status;
    begin
        This.Port.Mem_Read (Addr          => This.Address, 
                            Mem_Addr      => UInt16 (Addr), 
                            Mem_Addr_Size => Memory_Size_8b, 
                            Data          => Data, 
                            Status        => Status);

        if Status /= Ok then
        -- TODO: Error handling
            raise Program_Error;
        end if;
        
        return Data (Data'First);
    end Read_Register;

    -------------------
    -- Read_Register --
    ------------------- 

    function Read_Register (This : LM75_Sensor'Class;
                            Addr : Register_Address) return UInt16
    is
        Data   : I2C_Data (1 .. 2);
        Status : I2C_Status;
    begin
        This.Port.Mem_Read (Addr          => This.Address, 
                            Mem_Addr      => UInt16 (Addr), 
                            Mem_Addr_Size => Memory_Size_8b, 
                            Data          => Data, 
                            Status        => Status);

        if Status /= Ok then
        -- TODO: Error handling
            raise Program_Error;
        end if;

        return UInt16 (Data (2)) or Shift_Left (UInt16 (Data (1)), 8);
    end Read_Register;

    --------------------
    -- Write_Register --
    --------------------

    procedure Write_Register (This : LM75_Sensor'Class;
                              Addr : Register_Address;
                              Val  : UInt8)
    is
        Status : I2C_Status;
    begin
        This.Port.Mem_Write (Addr          => This.Address, 
                             Mem_Addr      => UInt16 (Addr), 
                             Mem_Addr_Size => Memory_Size_8b, 
                             Data          => (1 => Val), 
                             Status        => Status);

        if Status /= Ok then
            raise Program_Error;
        end if;
    end Write_Register;

    --------------------
    -- Write_Register --
    --------------------

    procedure Write_Register (This : LM75_Sensor'Class;
                              Addr : Register_Address;
                              Val  : UInt16)
    is
        Data : I2C_Data (1 .. 2);
        Status : I2C_Status;
    begin
        Data (1) := UInt8 (Shift_Right (Val, 8));
        Data (2) := UInt8 (Val and 16#FF#);

        This.Port.Mem_Write (Addr          => This.Address, 
                             Mem_Addr      => UInt16 (Addr), 
                             Mem_Addr_Size => Memory_Size_8b, 
                             Data          => Data, 
                             Status        => Status);

        if Status /= Ok then
            raise Program_Error;
        end if;
    end Write_Register;    

    -----------------
    -- Temp_To_Reg --
    -----------------

    function Temp_To_Reg (T : Temperature; 
                          Scale : Float;
                          Shift : Natural) return UInt16
    is
        Reg_Data : UInt16;
    begin
        Reg_Data := To_UInt16 ((Integer_16 (T / Scale)) * 2**Shift);
        return Reg_Data;
    end Temp_To_Reg;

    -----------------
    -- Reg_To_Temp --
    -----------------

    function Reg_To_Temp (Reg_Data : UInt16; 
                          Scale    : Float;
                          Shift    : Natural) return Temperature
    is
        T : Temperature;
    begin
        T := Float (To_Int16 (Reg_Data) / 2**Shift) * Scale;
        return T;
    end Reg_To_Temp;

    ----------
    -- Init --
    ----------

    procedure Init (This           : in out LM75_Sensor;
                    Device_Address : in I2C_Address := 16#90#) is
    begin
        This.Address := Device_Address;
    end Init;

    ---------------
    -- Configure --
    ---------------

    procedure Configure (This         : in out LM75_Sensor;
                         OpMode       : Device_Operation_Mode;
                         OS_Operation : OS_Operation_Mode;
                         OS_Polarity  : OS_Polarity_Mode;
                         OS_Fault_Num : OS_Fault_Queue_Size)
    is
        CONF : CONF_REG_Register;
    begin

        CONF.SHUTDOWN := OpMode'Enum_Rep;
        CONF.OS_COMP_INT := OS_Operation'Enum_Rep;
        CONF.OS_POL := OS_Polarity'Enum_Rep;
        CONF.OS_F_QUE := OS_Fault_Num'Enum_Rep;

        This.Write_Register (CONF_REG, To_UInt8 (CONF));

    end Configure;

    ------------------------
    -- Set_Operation_Mode --
    ------------------------

    procedure Set_Operation_Mode (This   : in out LM75_Sensor;
                                  OpMode : Device_Operation_Mode)
    is
        CONF : CONF_REG_Register;
    begin
        CONF := To_Reg (This.Read_Register(CONF_REG));

        CONF.SHUTDOWN := OpMode'Enum_Rep;

        This.Write_Register (CONF_REG, To_UInt8 (CONF));
    end Set_Operation_Mode;

    ------------------------
    -- Get_Operation_Mode --
    ------------------------

    function Get_Operation_Mode (This : in out LM75_Sensor) 
        return Device_Operation_Mode
    is
        CONF : CONF_REG_Register;
    begin
        CONF := To_Reg (This.Read_Register(CONF_REG));

        return Device_Operation_Mode'Enum_Val (CONF.SHUTDOWN);
    end Get_Operation_Mode;

    --------------------
    -- Set_Hysteresis --
    --------------------

    procedure Set_Hysteresis (This : in out LM75_Sensor;
                              Hyst : Temperature)
    is
        Hyst_Reg_Data : UInt16;
    begin
        Hyst_Reg_Data := Temp_To_Reg (Hyst, Tos_THys_Resolution, 7);
        This.Write_Register (THYST_REG, Hyst_Reg_Data);
    end Set_Hysteresis;

    ----------------------------
    -- Set_Shutdown_Threshold --
    ----------------------------

    procedure Set_Shutdown_Threshold (This : in out LM75_Sensor;
                                      Tos  : Temperature)
    is
        Tos_Reg_Data : UInt16;
    begin
        Tos_Reg_Data := Temp_To_Reg (Tos, Tos_THys_Resolution, 7);
        This.Write_Register (TOS_REG, Tos_Reg_Data);
    end Set_Shutdown_Threshold;

    --------------------
    -- Get_Hysteresis --
    --------------------

    procedure Get_Hysteresis (This : in out LM75_Sensor;
                              Hyst :    out Temperature) 
    is
        Hyst_Raw : UInt16;
    begin
        Hyst_Raw := This.Read_Register (THYST_REG);
        Hyst := Reg_To_Temp (Hyst_Raw, Tos_THys_Resolution, 7);
    end Get_Hysteresis;

    ----------------------------
    -- Get_Shutdown_Threshold --
    ----------------------------

    procedure Get_Shutdown_Threshold (This : in out LM75_Sensor;
                                      Tos  :    out Temperature) 
    is
        Tos_Raw : UInt16;
    begin
        Tos_Raw := This.Read_Register (TOS_REG);
        Tos := Reg_To_Temp (Tos_Raw, Tos_THys_Resolution, 7);
    end Get_Shutdown_Threshold;

    ----------------------
    -- Read_Temperature --
    ----------------------

    procedure Read_Temperature (This : in out LM75_Sensor;
                                Temp :    out Temperature) 
    is
        Temp_Raw : UInt16;
    begin
        Temp_Raw := This.Read_Register (TEMP_REG);
        Temp := Reg_To_Temp (Temp_Raw, Temp_Resolution, 5);
    end Read_Temperature;

end LM75;
