##################################################
#   Priority Modificatin for RouterOS v7.x+      #
##################################################
#             Version 1.0.0                      #
##################################################
# Author: Javier Alexis Toledano                 #
# Email: jatoledano@gmail.com                    #
##################################################
##################################################


:local traf;
:local gbdown;
:local gbup;
:local a;
:global uppriority;
:global downpriority;
:global prioridad;
:local localid ;
:local fillVal 0;
:global testArraydown {0,0};
:global testArrayUp {0,0};
:global longColasUp 0;
:global longColas 0;
:local rows 254;

:local j 1;

: foreach i in=[/queue simple find] do={
     :local name [/queue simple get $i name]
     if ($name != "Uplink" ) do={
      :set traf [/queue simple get $i  bytes];
      :set gbdown [:pick $traf ( [:find $traf "/"] +1) ([:len $traf]) ];
      :set gbup [:pick $traf 0 [:find $traf "/"] ] ;
      :do {
       :set ($testArraydown->($j-1)->0) $i;
       :set ($testArraydown->($j-1)->1) $gbdown;
       :set ($testArrayUp->($j-1)->0) $i;
       :set ($testArrayUp->($j-1)->1) $gbup;
       :set j ($j+1);
        } on-error= {
            :put "Error al rellenar los arreglos:";
       }
     }
}
:set longColas ($j-1);

:local B;
:local n [ :len $testArraydown ];
:local swapped;
do {
    :set swapped false;
    :for i from=1 to=($n-1) do={
        :if ($testArraydown ->($i-1)->1   >  $testArraydown ->$i->1 ) do={
            :set B ($testArraydown-> ($i - 1)) ;
            :set ($testArraydown->($i - 1)) ($testArraydown->$i);
            :set ($testArraydown->$i) $B;
            :set swapped true;
        }
    }
    :set n ($n - 1);
} while=($swapped);

:local B;
:local n [ :len $testArrayUp ];
:local swapped;
do {
    :set swapped false;
    :for i from=1 to=($n - 1) do={

        :if (  $testArrayUp ->($i-1)->1   >   $testArrayUp ->$i->1 ) do={
            :set B ($testArrayUp-> ($i - 1)) ;
            :set ($testArrayUp->($i - 1)) ($testArrayUp->$i);
            :set ($testArrayUp->$i) $B;
            :set swapped true;
        }
    }
    :set n ($n - 1);
} while=($swapped);


# A partir de aqui recorro el arreglo para cambiar la prioridad de bajada de las colas simples
# Tengo que encontrar cual es el primer valor con download bytes = 0 y a partir de ahi regenerar las prioridades desde 0 hasta este valor
:local encontrado true;
:local i 0;
do {
   if ($testArraydown->$i->1 >0) do={
    :set encontrado false;
  }  else={
      :set i ($i+1);
     }
 } while=($encontrado);

:local j;
:local resto;
:local n [ :len $testArraydown ];
:set j (($longColas -$i)/8);

:set resto (($n-$i)%8);
:if ($resto >0) do={:set j ($j+1) }


:set downpriority 1;
:local z 1;
:for x from=($n-1) to=$i step=-1 do={
   :set prioridad [/queue simple get ($testArraydown->$x->0)  priority ];
   :set uppriority    [:pick $prioridad  0 [:find $prioridad "/"]] ;
   /queue simple set ($testArraydown->$x->0) priority=([:tostr ($uppriority."/".$downpriority)]);
   :set z ($z+1);
   :if ($z > $j) do={
      :set z 1;
      :if ($downpriority < 8)  do={:set downpriority ($downpriority+1)}   else={:set downpriority 1}
    }
}

:local encontrado true;
:local i 0;
do {
   if ($testArrayUp->$i->1 >0) do={
    :set encontrado false;
  }  else={
      :set i ($i+1);
     }
 } while=($encontrado);


:local j;
:local resto;
:local n [ :len $testArrayUp ];
:set j  (($n -$i)/8);
:set resto (($n-$i)%8);
:if ($resto >0) do={:set j ($j+1) };

:set uppriority 1;
:local z 1;
:for x from=($n-1) to=($i) step=-1 do={
   :set prioridad [/queue simple get ($testArrayUp->$x->0)  priority ];
   :set downpriority [:pick $prioridad  ([:find $prioridad "/"] +1) ([:len $prioridad])] ;
   /queue simple set ($testArrayUp->$x->0) priority=([:tostr ($uppriority."/".$downpriority)]);
   :set z ($z+1);
   :if ($z > $j) do={
      :set z 1;
      :if ($uppriority < 8)  do={:set uppriority ($uppriority+1)}   else={:set uppriority 1}
    }

}
:return 0;



