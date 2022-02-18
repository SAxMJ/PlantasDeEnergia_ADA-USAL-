with PlantaMonitor; use PlantaMonitor;
with Text_IO; use Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;
with Ada.Numerics.Float_Random;

procedure Main is


   --Para la generación de números aleatorios
   subtype aleatorioReactor is Integer range -3..3;
   package Aleatorio is new Ada.Numerics.Discrete_Random(aleatorioReactor);
   seed : Aleatorio.Generator;

   --Consumo Inicial=35
   consumoEnergiaCiudad:Integer:=35;

   --Creamos dos procedimientos, uno que obtiene el valor del consumo de la ciudad
   --y oro que modifica el valor del consumo de la ciudad

    procedure getConsumoCiudad(cons: out Integer) is
    	begin
         cons:=consumoEnergiaCiudad;
    	end getConsumoCiudad;

   procedure modificaConsumoCiudad(cons: in Integer) is
   	begin
      	consumoEnergiaCiudad:=consumoEnergiaCiudad+cons;
    	end modificaConsumoCiudad;




	-----------DECLARACIÓN DE LAS TAREAS-----------

   --Declararemos una tarea Sensor, esta tarea sensor
   --va a ocuparse de comprobar el estado de cada planta
   --Se pasa un puntero de la planta por eso el access
   task type TareaSensor (idPlanta:Integer; planta:access PlantaEnergia) is
  	 --Declaramos la posibilidad de recibir un mensaje desbloqueante
      entry compruebaEstadoPlanta(produccion: out Integer);

   end TareaSensor;


   task body TareaSensor is
      --A partir de aquí la tarea se va a estar repitiendo una y otra vez
      --de tal forma que cada vez que le llegue un mensaje que le diga que
      --compruebe el estado de la planta lo comprobará
      --tarPlan:TareaPlantas(idPlanta,planta);
	id:Integer;
   begin
	planta.getID(id);
      loop

         --Aquí estará esperando a que le llegue un mensaje para que compruebe el estado de la planta
         --cuando le llegue el mensaje, el valor
         accept compruebaEstadoPlanta(produccion: out Integer) do
            --Aqui estará el código que tendrá que ejecutarse cuando se reciba el mensaje de comprobar el estado
            --al ser un mensaje con valor out, se devolverá el valor en la variable producción. El procedimiento
            --del que lee el valor de la produccion tambien es out

            --Se simulan los 0.15s del retardo de lectura

	 planta.getProduccion(produccion);
         end compruebaEstadoPlanta;

      end loop;
   end TareaSensor;







   --TAREA DEL ACTUADOR, esta tarea se va a encargar
   --de hacer cosas para solucionar los problemas con las plantas,
   --que serán aumentarproduccion,disminuirproduccion o mantenerla, se le
   --pasará el puntero de las plantas y el id de la planta correspondiente

   task type TareaActuador (idPlanta:Integer; planta: access PlantaEnergia) is

   --Declaramos los mensajes que recibirá para mantener, incrementar o disminuir la producción
   	entry incrementaProduccion;
   	entry disminuyeProduccion;
   	entry mantenProduccion;

   end TareaActuador;

   task body TareaActuador is
   periodo:Duration:= 3.0;
   tiempo:Time;

   retardo: Duration:=0.15;
   begin
   --Bucle de la tarea que se repetirá contínuamente de forma que se quedará esperando a que
   --le llegue un mensaje indicándole qué debe hacer y una vez que lo reciba y lo haga vuelva
   --a quedar esperándo a recibir otro mensaje que le diga qué hacer
      Text_IO.Put_Line("Ya estoy aqui esperando un mensaje(TareaActuador)");
      tiempo:=periodo+Clock;

      delay until tiempo;
      loop

         select
            accept incrementaProduccion do
               begin
                  --Ejecutamos procedimiento que incrementa la produccion
                  --SIMULAMOS EL RETARDO!!
                  tiempo:=retardo+Clock;
         	  delay until tiempo;
		  planta.aumentarProd;
               end;
            end incrementaProduccion;
         or
            accept disminuyeProduccion do
               begin
                  --Ejecutamos procedimiento que disminuye la produccion
                  --SIMULAMOS EL RETARDO!!
                  tiempo:=retardo+Clock;
         	  delay until tiempo;
		  planta.disminuirProd;
               end;
            end disminuyeProduccion;
         or
            accept mantenProduccion do
               begin
                  	--Ejecutamos procedimiento que mantiene la produccion
			planta.mantenerProd;
               end;
            end mantenProduccion;
         or delay 5.0;
            --En caso de no recibir ninguno de los anteriores mensajes durante 5 segundos
            Text_IO.Put_Line("ALERTA MONITORIZACIÓN ENERGÍA PLANTA: " &idPlanta'Img);
	    delay 0.1;
         end select;
         tiempo:=periodo+Clock;
         delay until tiempo;
      end loop;
   end TareaActuador;





   --TAREACONSUMOCIUDAD encargada de realizar un consumo aleatorio cada 6 segundos
   task type TareaConsumoCiudad is
   end TareaConsumoCiudad;


   task body TareaConsumoCiudad is
      consum:aleatorioReactor;
      periodo:constant Duration:=6.0;
      sigIteracion:Time;

   begin
      --Reseteamos la semilla
      Aleatorio.Reset(seed);
      --La siguiente iteración (en este caso la primera) se producirá en función
      --del valor del reloj+el valor del periodo de tiempo
      sigIteracion:=Clock+periodo;
      delay until sigIteracion;

    loop
   --Reseteamos la semilla antes de generar un nuevo valor aleatorio
   	Aleatorio.reset(seed);
   	consum:=Aleatorio.Random(seed);

         modificaConsumoCiudad(consum);
         Text_IO.Put_Line("ConsumoDeCiudadModificado:" &consum'Img);
         --incrementamos el valor del perdiodo al valor de reloj anterior
        sigIteracion:=Clock+periodo;
   	delay until sigIteracion;
    end loop;
   end TareaConsumoCiudad;







    task type TareaMonitorizaConsumoProduccion (planta0: access PlantaEnergia;planta1: access PlantaEnergia;planta2: access PlantaEnergia) is
    end TareaMonitorizaConsumoProduccion;

    task body TareaMonitorizaConsumoProduccion is

    periodo:constant Duration:=1.0;
    sigIteration:Time;
    prodPlanta0:Integer;
    prodPlanta1:Integer;
    prodPlanta2:Integer;
    prodTotal:Integer;
    consumoCiudad:Integer;
      relacionConsumoProduccion:Integer;
      porcentajeConsumoProduccion:Float;
      floatRelacionConsumoProduccion:Float;
    begin
      sigIteration:=Clock+0.3;
      delay until sigIteration;
      	loop

         --Obtenemos la produccion de todas las plantas y el consumo de la ciudad
         planta0.getProduccion(prodPlanta0);
         planta1.getProduccion(prodPlanta1);
         planta2.getProduccion(prodPlanta2);
         getConsumoCiudad(consumoCiudad);
         --El valor de la produccion total es la suma de todas las plantas
         prodTotal:=prodPlanta0+prodPlanta1+prodPlanta2;


         --COMPROBAMOS AHORA LA RELACION ENTRE LA ENERGIA CONSUMIDA Y LA PRODUCIDA
         relacionConsumoProduccion:=prodTotal-consumoCiudad;

         floatRelacionConsumoProduccion:=Float(prodTotal-consumoCiudad);

         porcentajeConsumoProduccion:=(floatRelacionConsumoProduccion/Float(prodTotal))*10.0;


         if porcentajeConsumoProduccion>5.0 then
            Text_IO.Put("PELIGRO SOBRECARGA consumo: " &consumoCiudad'Img);
            Text_IO.Put_Line(" produccion: " &prodTotal'Img);
        elsif porcentajeConsumoProduccion<0.0 then
            Text_IO.Put("PELIGRO BAJADA consumo: " &consumoCiudad'Img);
            Text_IO.Put_Line(" produccion: " &prodTotal'Img);
      	else
            Text_IO.Put("Estable consumo: " &consumoCiudad'Img);
            Text_IO.Put_Line(" produccion: " &prodTotal'Img);
        end if;


         if relacionConsumoProduccion>3 then
            	--Actuar en las 3
            	planta0.disminuirProd;
            	planta1.disminuirProd;
            	planta2.disminuirProd;
         elsif relacionConsumoProduccion>=2 and relacionConsumoProduccion<=3 then
            --Actuar en 2
            --AHORA EN FUNCION DE LA PRODUCCION DE CADA PLANTA DISMINUIREMOS DE UNAS U OTRAS PLANTAS
           	 if prodPlanta0>=prodPlanta1 and prodPlanta1>=prodPlanta2 then
            	   planta0.disminuirProd;
            	   planta1.disminuirProd;
          	 elsif prodPlanta0>prodPlanta1 and prodPlanta2>prodPlanta1 then
               	   planta0.disminuirProd;
               	   planta2.disminuirProd;
            	 else
               	   planta1.disminuirProd;
                   planta2.disminuirProd;
            	 end if;

         elsif relacionConsumoProduccion>=1 and relacionConsumoProduccion<=2 then
            	--Actuamos solo en una
            	 if prodPlanta0>=prodPlanta1 and prodPlanta0>=prodPlanta2 then
            	   planta0.disminuirProd;
          	 elsif prodPlanta1>prodPlanta0 and prodPlanta1>prodPlanta2 then
               	   planta1.disminuirProd;
            	 else
                   planta2.disminuirProd;
            	end if;

         elsif relacionConsumoProduccion<0 and relacionConsumoProduccion>=-1 then

            	--Actuamos solo en una
            	 if prodPlanta0<=prodPlanta1 and prodPlanta0<=prodPlanta2 then
            	   planta0.aumentarProd;
          	 elsif prodPlanta1<prodPlanta0 and prodPlanta1<prodPlanta2 then
               	   planta1.aumentarProd;
            	 else
                   planta2.aumentarProd;
            	 end if;

         elsif relacionConsumoProduccion>=-3 and relacionConsumoProduccion<-1 then

            	 if prodPlanta0<=prodPlanta1 and prodPlanta1<=prodPlanta2 then
            	   planta0.aumentarProd;
            	   planta1.aumentarProd;
          	 elsif prodPlanta0<prodPlanta1 and prodPlanta2<prodPlanta1 then
               	   planta0.aumentarProd;
               	   planta2.aumentarProd;
            	 else
               	   planta1.aumentarProd;
                   planta2.aumentarProd;
               	 end if;

         --Menor que -3
         else
             planta0.aumentarProd;
             planta1.aumentarProd;
             planta2.aumentarProd;
         end if;

         sigIteration:=Clock+periodo;
         delay until sigIteration;
      end loop;

   end TareaMonitorizaConsumoProduccion;



   --TAREA DE LAS PLANTAS
   --ejecutaremos 3 tareas, una por cada planta
   task type TareaPlantas (idPlanta:Integer; planta: access PlantaEnergia) is
      --Mensaje que avisará a la tarea de las plantas que el sensor se ha creado
   end TareaPlantas;

   task body TareaPlantas is
      --Instanciaremos las tareas del sensor y del actuador para poder hacerles llamadas
      --En este punto las tareas se encontrarán detenidas esperando mensajes
      tarSen:TareaSensor(idPlanta,planta);
      tarAct:TareaActuador(idPlanta,planta);
      producc:Integer;

      retardoInicio:Duration:= 0.3;
      tiempo:Time;
      retardoBucle:Duration:=1.0;

   begin
      planta.asociaID(idPlanta);
      Text_IO.Put_Line("Soy la planta " &idPlanta'Img);

      --El instante de lanzado de la primera monitorización será a los
      --0.3 segundos de la iniciación del sensor
      tiempo:=retardoInicio+Clock;

      --En el bucle solicitaremos al sensor que compruebe la produccion y en
      --función de los resultados que obtengamos le diremos al actuador que haga
      --una cosa u otra.
      loop
      --Le enviamos un mensaje al sensor que lo desbloquea y nos devuelve por
      --el parámetro out de su mensaje el valor de la producciom
      tarSen.compruebaEstadoPlanta(producc);

         --Enviaremos un mensaje al actuador que le diga qué debe hacer
        if producc<5 then
            --La producción es baja y debe incrementarse, avisamos al actuador
            tarAct.incrementaProduccion;
        end if;

        if producc>30 then
            --La producción es alta y debe disminuirse, avisamos al actuador
            tarAct.disminuyeProduccion;
        end if;

       if producc>=5 and producc<=30 then
            --Su produccion es normal
            tarAct.mantenProduccion;
        end if;

         --Ahora esperamos 1 segundo para la siguiente monitorizacion

         tiempo:=retardoBucle+Clock;
         delay until tiempo;

      end loop;
   end TareaPlantas;

     -- EJECUCION DE LAS TAREAS DE CADA PLANTA
     planta0: aliased PlantaEnergia;
     tarPlant0:TareaPlantas(0,planta0'Access);
     planta1: aliased PlantaEnergia;
     tarPlant1:TareaPlantas(1,planta1'Access);
     planta2: aliased PlantaEnergia;
     tarPlant2:TareaPlantas(2,planta2'Access);

      --INSTANCIAMOS LA TAREA DE CONSUMO CIUDAD
      consumCiudad:TareaConsumoCiudad;
      --INSTANCIAMOS LA TAREA QUE MONITORIZA CONSUMO PRODUCCION
      tarMonConProd:TareaMonitorizaConsumoProduccion(planta0'Access,planta1'Access,planta2'Access);

   begin
   Text_IO.Put_Line("Se ejecutó todo");

end Main;
