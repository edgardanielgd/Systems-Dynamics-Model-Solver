disp("Métodos Numéricos ==== Proyecto Final")
disp("\tMiguel Angel Puentes Cespedes")
disp("\tJhonatan Steven Rodríguez Ibañez")
disp("\tEdgar Daniel González Díaz\n")
opt = 1;

while( opt > 0 && opt < 4)

  disp(
    strcat(
      "MENU===\n",
      "1. Modelo depredador presa\n",
      "2. Modelo SIR\n",
      "3. Modelo product diffusion\n",
      "4. Salir\n"  
    )
  );

  opt = input("Digite una opcion: ");

  if( opt == 1)

    disp("METODO DEPREDADOR PRESA")

    pr = input("Digite la tasa de nacimientos de presa: ");
    pi = input("Digite la cantidad de presas iniciales: ");
    predr = input("Digite la tasa de depredación: ");
    prede = input("Digite la eficiencia de depredación: ");
    predi = input("Digite la cantidad de depredadores iniciales: ");
    preddeathr = input("Digite la tasa de muertes de depredadores: ");

    step = input("Digite el tamaño del paso a usar: ");
    max_t = input("Digite el tiempo de simulación máximo: ");

    niters = max_t / step;

    solver_type = input("Digite el tipo de solucionador a usar:\n1. Euler\n2.RK4\n3.RK45\nDigite una opcion: ");
    
    show_values = input("¿Desea ver la tabla de valores de Stock y tiempo?\n0.No\n1.Sí\nDigite una opcion: ");

    model = PredPreyModel(
      pr, pi, predr, prede, predi, preddeathr, step, solver_type
    );

    if show_values
      titles = "t\tPreys\tPredators";
      disp( titles );
    endif
    
    for i = 1: niters
      model.forwardStep();

      if show_values
        printf(
          "%.3f\t%.3f\t%.3f\n", 
          model.solver.lastVals(1),
          model.solver.lastVals(2),
          model.solver.lastVals(3)
        );
      endif
    
      if mod(i,10) == 0
        model.graphStocks();
      endif
    endfor
    

  elseif( opt == 2)

    disp("MODELO SIR")

    ti = input("Digite el total de individuos: ");
    infecr = input("Digite la tasa de infectividad: ");
    contr = input("Digite la tasa de contacto: ");
    tduracion = input("Digite el tiempo promedio de duración de enfermedad: ");

    step = input("Digite el tamaño del paso a usar: ");
    max_t = input("Digite el tiempo de simulación máximo: ");

    niters = max_t / step;

    solver_type = input("Digite el tipo de solucionador a usar:\n1. Euler\n2.RK4\n3.RK45\nDigite una opcion: ");
    
    show_values = input("¿Desea ver la tabla de valores de Stock y tiempo?\n0.No\n1.Sí\nDigite una opcion: ");

    model = SIRModel(
      ti, infecr, contr, tduracion, step, solver_type
    );

    if show_values
      titles = "t\tSusceptible\tInfected\tRecovered";
      disp( titles );
    endif
    
    for i = 1: niters
      model.forwardStep();

      if show_values
        printf(
          "%.3f\t%.3f\t%.3f\t%.3f\n", 
          model.solver.lastVals(1),
          model.solver.lastVals(2),
          model.solver.lastVals(3),
          model.solver.lastVals(4)
        );
      endif
    
      if mod(i,10) == 0
        model.graphStocks();
      endif
    endfor

  elseif( opt == 3)

    disp("MODELO NEW PRODUCT DIFFUSION")

    adEff = input("Digite la efectividad de la publicidad: ");
    salesF = input("Digite la fracción de ventas transmitidas voz a voz: ");
    contr = input("Digite la tasa de contacto: ");
    potCliIni = input("Digite la cantidad de clientes potenciales iniciales: ");
    cliIni = input("Digite la cantidad de clientes iniciales: ");

    step = input("Digite el tamaño del paso a usar: ");
    max_t = input("Digite el tiempo de simulación máximo: ");

    niters = max_t / step;

    solver_type = input("Digite el tipo de solucionador a usar:\n1. Euler\n2.RK4\n3.RK45\nDigite una opcion: ");
    
    show_values = input("¿Desea ver la tabla de valores de Stock y tiempo?\n0.No\n1.Sí\nDigite una opcion: ");

    model = ProductDiffusionModel(
      adEff, salesF, contr, potCliIni, cliIni, step, solver_type
    );

    if show_values
      titles = "t\tPotentialClients\tClients";
      disp( titles );
    endif
    
    for i = 1: niters
      model.forwardStep();

      if show_values
        printf(
          "%.3f\t%.3f\t%.3f\n", 
          model.solver.lastVals(1),
          model.solver.lastVals(2),
          model.solver.lastVals(3)
        );
      endif
    
      if mod(i,10) == 0
        model.graphStocks();
      endif
    endfor
  endif
endwhile

% PredPrey:
% 0.04, 100, 0.0003, 0.8, 30, 0.15, 0.1, 300, 1, 0

% SIR
% 1000, 0.05, 5, 15, 0.1, 150, 1, 0

% Product Diffusion
% 0.015, 0.011, 100, 10000, 0, 0.01, 10, 1, 0
