pkg load optim

personas = {'carlos','ana','luis','sofia','denis'};
p = length(personas);
tareas = 12;

peso_tareas = [13,8,13,8,13,5,8,8,13,3,2,2];
esSenior = [1; 0; 0; 1; 1];

minCargaSenior = 18;
minCargaJunior = 13;

minCargaTotal = 80;
maxCargaTotal = 96;

n_vars = p * tareas;
idx_x = @(pp,tt) (pp-1)*tareas + tt;

f = zeros(n_vars,1);
for pp = 1:p
  for tt = 1:tareas
    f(idx_x(pp,tt)) = -peso_tareas(tt);
  end
end

A = [];
b = [];
ctype = '';

% 1) Cada tarea asignada a un solo desarrollador (igualdad traducida a dos desigualdades)
for tt = 1:tareas
  row = zeros(1,n_vars);
  for pp = 1:p
    row(idx_x(pp,tt)) = 1;
  end
  A = [A; row; -row];
  b = [b; 1; -1];
  ctype = [ctype 'L' 'U'];
end

% 2) Carga mínima por persona
for pp = 1:p
  row = zeros(1,n_vars);
  for tt = 1:tareas
    row(idx_x(pp,tt)) = peso_tareas(tt);
  end
  A = [A; -row];
  b = [b; -(minCargaSenior*esSenior(pp) + minCargaJunior*(1 - esSenior(pp)))];
  ctype = [ctype 'U'];
end

% 3) Carga total equipo mínimo y máximo
row_total = zeros(1,n_vars);
for pp = 1:p
  for tt = 1:tareas
    row_total(idx_x(pp,tt)) = peso_tareas(tt);
  end
end
A = [A; row_total; -row_total];
b = [b; maxCargaTotal; -minCargaTotal];
ctype = [ctype 'L' 'U'];

lb = zeros(n_vars,1);
ub = ones(n_vars,1);

vartype = repmat('I',1,n_vars);  % enteras para binarias

sense = -1; % maximizar

[xopt, fval, status] = glpk(f, A, b, lb, ub, ctype, vartype, sense);

if status == 0
  fprintf('Solución óptima encontrada. Objetivo = %.2f\n', -fval);
  for pp = 1:p
    carga_p = 0;
    fprintf('Persona %s asignada a tareas:', personas{pp});
    for tt = 1:tareas
      if xopt(idx_x(pp,tt)) > 0.9
        fprintf(' t%d', tt);
        carga_p += peso_tareas(tt);
      end
    end
    fprintf(' | Carga total = %.2f\n', carga_p);
  end
else
  fprintf('No se encontró solución óptima. Status: %d\n', status);
end


