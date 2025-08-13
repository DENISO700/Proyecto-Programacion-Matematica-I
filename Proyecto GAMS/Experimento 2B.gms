Set
    p /carlos, ana, luis, sofia, denis/
    t /t1*t18/
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
    M /30/
    peso(t);

* ==== PESOS DE LAS TAREAS ASIGNADOS CICLICAMENTE DESDE w ====

peso('t1')  = 13;
peso('t2')  = 2;
peso('t3')  = 13;
peso('t4')  = 5;
peso('t5')  = 8;
peso('t6')  = 13;
peso('t7')  = 13;
peso('t8')  = 2;
peso('t9')  = 3;
peso('t10') = 5;
peso('t11') = 8;
peso('t12') = 13;
peso('t13') = 13;
peso('t14') = 2;
peso('t15') = 3;
peso('t16') = 5;
peso('t17') = 8;
peso('t18') = 13;

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
    carga(p) =g= 27 * esSenior(p) + 20 * (1 - esSenior(p));

* Actualizamos cargas totales del equipo para que coincida con suma total de pesos
cargaMinEquipo..
    sum(p, carga(p)) =g= 121;  

cargaMaxEquipo..
    sum(p, carga(p)) =l= 146;  

z_def1(p,t)..
    z(p,t) =l= pt(t);

z_def2(p,t)..
    z(p,t) =l= M * x(p,t);

z_def3(p,t)..
    z(p,t) =g= pt(t) - M * (1 - x(p,t));

Model asignacionScrumB /objetivo, unaPersonaPorTarea, cargaPersona, cargaMinima, cargaMinEquipo, cargaMaxEquipo, definicionPesoTarea, z_def1, z_def2, z_def3/;

Solve asignacionScrumB using mip maximizing obj;

Display x.l, carga.l, pt.l, z.l, obj.l;

file tabla /'distribucion_B.txt'/;
put tabla;
put 'Distribución de tareas por persona (Caso B):' /;
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
