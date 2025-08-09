Set
    p /carlos, ana, luis, sofia, denis/
    t /t1*t12/
    w /1,2,3,5,8,13/;

Binary Variable
    x(p,t)
    y(t,w);

Positive Variable
    carga(p)
    pt(t)
    z(p,t);

Variable
    obj;

Parameter
    esSenior(p) /carlos 1, ana 0, luis 0, sofia 1, denis 1/
    M /20/;

Equation
    objetivo
    unaPersonaPorTarea(t)
    cargaPersona(p)
    cargaMinima(p)
    cargaMinEquipo
    cargaMaxEquipo
    tareaUnPeso(t)
    definicionPesoTarea(t)
    z_def1(p,t)
    z_def2(p,t)
    z_def3(p,t);

Parameter ptw(w);
ptw('1')=1; ptw('2')=2; ptw('3')=3; ptw('5')=5; ptw('8')=8; ptw('13')=13;

Scalar cargaMinTotal /87/;  
Scalar cargaMaxTotal /104.4/; 

tareaUnPeso(t)..
    sum(w, y(t,w)) =e= 1;

definicionPesoTarea(t)..
    pt(t) =e= sum(w, ptw(w) * y(t,w));

objetivo..
    obj =e= sum((p,t), z(p,t));

unaPersonaPorTarea(t)..
    sum(p, x(p,t)) =e= 1;

cargaPersona(p)..
    carga(p) =e= sum(t, z(p,t));

cargaMinima(p)..
    carga(p) =g= 18 * esSenior(p) + 13 * (1 - esSenior(p));

cargaMinEquipo..
    sum(t, pt(t)) =g= cargaMinTotal;

cargaMaxEquipo..
    sum(t, pt(t)) =l= cargaMaxTotal;

z_def1(p,t)..
    z(p,t) =l= pt(t);

z_def2(p,t)..
    z(p,t) =l= M * x(p,t);

z_def3(p,t)..
    z(p,t) =g= pt(t) - M * (1 - x(p,t));

Model asignacionScrum /objetivo, unaPersonaPorTarea, cargaPersona, cargaMinima, cargaMinEquipo, cargaMaxEquipo, tareaUnPeso, definicionPesoTarea, z_def1, z_def2, z_def3/;

Solve asignacionScrum using mip maximizing obj;

Display x.l, y.l, carga.l, pt.l, z.l, obj.l;

file tabla /'distribucion.txt'/;
put tabla;
put 'Distribución de tareas por persona:' /;
put 'Persona':12, 'Tarea':8, 'Peso':6, 'Asignado':10 /;
loop((p,t),
    if(x.l(p,t) = 1,
        loop(w,
            if(y.l(t,w) = 1,
                put p.tl:12, t.tl:8, w.tl:6:0, 'Sí':10 /;
            );
        );
    );
);

put / 'Carga total por persona:' /;
loop(p,
    put p.tl:12, carga.l(p):8:2 /;
);

