with Text_IO; use Text_IO;
with Ada.Calendar; use Ada.Calendar;

package body PlantaMonitor is
   protected body PlantaEnergia is

      --Declararemos ahora los procedimientos que se encargar�n de
      --aumentar, disminuir o mantener la producci�n.

      --Si se recibe un mensaje de aumentar produccion
      procedure aumentarProd is
      begin
         produccion:=produccion+1;
         Text_IO.Put("Se incremento la producci�n a " &produccion'Img);
         Text_IO.Put_Line(" a la planta " &idPlanta'Img);
      end aumentarProd;

      procedure disminuirProd is
      begin
         produccion:=produccion-1;
         Text_IO.Put("Se decremento la producci�n a " &produccion'Img);
         Text_IO.Put_Line(" a la planta " &idPlanta'Img);
      end disminuirProd;

      procedure mantenerProd is
      begin
         produccion:=produccion;
         Text_IO.Put_Line("Manteniendo produccion de la planta: " &idPlanta'Img);
      end mantenerProd;

      --Funci�n que nos asocia cada planta con un id
      procedure asociaID (id: in Integer) is
      begin
      idPlanta:=id;
      end asociaID;

      --Procedimiento para recuperar el valor de la producci�n en
      --un momento determinado
      procedure getProduccion(prod: out Integer) is
      begin
         prod:=produccion;
      end getProduccion;

      procedure getID (id: out Integer) is
      begin
         id:=idPlanta;
      end getID;


   end PlantaEnergia;
end PlantaMonitor;



