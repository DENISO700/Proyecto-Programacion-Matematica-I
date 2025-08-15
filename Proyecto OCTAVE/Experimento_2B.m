pkg load optim;

personas = {'carlos','ana','luis','sofia','denis'};
p = length(personas);
tareas = 18;

peso_tareas = [13,8,13,8,13,5,8,8,13,3,2,2,13,8,5,8,5,13];
esSenior = [1; 0; 0; 1; 1];

minCargaSenior = 27;
minCargaJunior = 20;

n_vars = p*tareas + 2;
idx_x = @(pp,tt) (pp-1)*tareas + tt;
idx_zmax = p*tareas + 1;
idx_zmin = p*tareas + 2;

f = zeros(n_vars,1);
f(idx_zmax) = 1;
f(idx_zmin) = -1;

A = [];
b = [];
ctype = '';

% 1) Cada tarea asignada a un solo desarrollador
for tt = 1:tareas
  row = zeros(1,n_vars);
  for pp = 1:p
    row(idx_x(pp,tt)) = 1;
  end
  A = [A; row; -row];
  b = [b; 1; -1];
  ctype = [ctype 'U' 'L'];
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

% 3) Relación con z_max y z_min
for pp = 1:p
  row = zeros(1,n_vars);
  for tt = 1:tareas
    row(idx_x(pp,tt)) = peso_tareas(tt);
  end

  % z_max >= carga_p
  row_zmax = row;
  row_zmax(idx_zmax) = -1;
  A = [A; row_zmax];
  b = [b; 0];
  ctype = [ctype 'U'];

  % z_min <= carga_p
  row_zmin = -row;
  row_zmin(idx_zmin) = 1;
  A = [A; row_zmin];
  b = [b; 0];
  ctype = [ctype 'U'];
end

lb = zeros(n_vars,1);
ub = ones(n_vars,1);
ub(idx_zmax:idx_zmin) = Inf;

vartype = repmat('I',1,p*tareas);
vartype = [vartype 'CC'];

sense = -1; % maximizar

[xopt, fval, status] = glpk(f, A, b, lb, ub, ctype, vartype, sense);

if status == 0
  fprintf('Solución óptima encontrada. Diferencia máxima de carga = %.2f\n', fval);
  cargas = zeros(p,1);

  for pp = 1:p
    fprintf('Persona %s asignada a tareas:', personas{pp});
    for tt = 1:tareas
      if xopt(idx_x(pp,tt)) > 0.9
        fprintf(' t%d', tt);
        cargas(pp) += peso_tareas(tt);
      end
    end
    fprintf(' | Carga total = %.2f\n', cargas(pp));
  end

  % --- Gráfico ---
  figure;
  bar(cargas, 'FaceColor', [0.2 0.6 0.8]);
  set(gca, 'XTickLabel', personas);
  xlabel('Personas');
  ylabel('Carga total');
  title('Distribución de carga por persona');
  grid on;

else
  fprintf('No se encontró solución óptima. Status: %d\n', status);
end

