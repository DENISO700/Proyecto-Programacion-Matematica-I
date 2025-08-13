Set
    p /carlos, ana, luis, sofia, denis/
    t /t1*t12/
    w /1,2,3,5,8,13/;

Binary Variable
    x(p,t);  

Positive Variable
    carga(p)
    pt(t)    "peso fijo de la tarea t"
    z(p,t);

Variable
    obj;

Parameter
    esSenior(p) /carlos 1, ana 0, luis 0, sofia 1, denis 1/
    M /20/
    peso(t);

* --- Definición de pesos según Caso A ---
Table pesoTabla(t,*)
       valor
    t1   13
    t2    8
    t3   13
    t4    8
    t5   13
    t6    5
    t7    8
    t8    8
    t9   13
    t10   3
    t11   2
    t12   2;

* Cargamos valores desde la tabla
peso(t) = pesoTabla(t,"valor");

Equation
    objetivo
    unaPersonaPorTarea(t)
    cargaPersona(p)
    cargaMinima(p)
    cargaMinEquipo
    cargaMaxEquipo
    definicionPesoTarea(t)
    z_def1(p,t)
    z_def2(p,t)
    z_def3(p,t);

objetivo..
    obj =e= sum((p,t), z(p,t));

unaPersonaPorTarea(t)..
    sum(p, x(p,t)) =e= 1;

definicionPesoTarea(t)..
    pt(t) =e= peso(t);

cargaPersona(p)..
    carga(p) =e= sum(t, z(p,t));

cargaMinima(p)..
    carga(p) =g= 18 * esSenior(p) + 13 * (1 - esSenior(p));

cargaMinEquipo..
    sum(t, pt(t)) =g= 80;  

cargaMaxEquipo..
    sum(t, pt(t)) =l= 96;  

z_def1(p,t)..
    z(p,t) =l= pt(t);

z_def2(p,t)..
    z(p,t) =l= M * x(p,t);

z_def3(p,t)..
    z(p,t) =g= pt(t) - M * (1 - x(p,t));

Model asignacionScrum /all/;

Solve asignacionScrum using mip maximizing obj;

Display x.l, carga.l, pt.l, z.l, obj.l;

file tabla /'distribucion.txt'/;
put tabla;
put 'Distribución de tareas por persona:' /;
put 'Persona':12, 'Tarea':8, 'Peso':6, 'Asignado':10 /;
loop((p,t),
    if(x.l(p,t) = 1,
        put p.tl:12, t.tl:8, peso(t):6:0, 'Sí':10 /;
    );
);

put / 'Carga total por persona:' /;
loop(p,
    put p.tl:12, carga.l(p):8:2 /;
);
