with System.Semihosting;

package body Last_Chance_Handler is

    procedure Last_Chance_Handler (Msg : System.Address; Line : Integer) is
        pragma Unreferenced (Msg, Line);
    begin
        System.Semihosting.Put ("Stepbro, help me, i'm stuck!");
        loop
            null;
        end loop;
    end Last_Chance_Handler;

end Last_Chance_Handler;