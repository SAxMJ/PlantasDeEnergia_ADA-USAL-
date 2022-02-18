package  PlantaMonitor is

   protected type PlantaEnergia is


      --Utilizaremos procedimientos para modificar los valores de la variable
      --producción porque de esta forma lo haremos mediante objeto protegido
      procedure aumentarProd;
      procedure disminuirProd;
      procedure mantenerProd;
      procedure asociaID(id: in Integer);
      procedure getProduccion(prod: out Integer);
      procedure getID(id: out Integer);

   private
      --Declaramos una variable id que se le asociará
      --a acada una de las tareas PlantaEnergía
      idPlanta:Integer;
      --Este será el valor inicial de producción de cada planta
      produccion:Integer:=15;

   end PlantaEnergia;
end PlantaMonitor;
