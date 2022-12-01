% https://cloud.anylogic.com/model/14482b77-2be0-4a80-bfb9-2f8c20ea627f?mode=SETTINGS

classdef ProductDiffusionModel < Model

  properties

  endproperties

  methods
    function thisModel = ProductDiffusionModel(
      adEffectiveness,
      salesFraction,
      contactRate,
      potentialClientsIni,
      clientsIni,
      step,
      solverType = 1
    )
      thisModel = thisModel@Model( step, solverType );

      # List of model's objects
      thisModel.parameters("adEffectiveness") = adEffectiveness;
      thisModel.parameters("salesFraction") = salesFraction;
      thisModel.parameters("contactRate") = contactRate;
      thisModel.parameters("potentialClientsIni") = potentialClientsIni;
      thisModel.parameters("clientsIni") = clientsIni;

      % Add flows
      thisModel.addFlow("sales", @thisModel.salesFunction );

      % Add dynamic variables

      thisModel.addDynVariable( "salesFromAd" , @thisModel.salesFromAdFunction );

      thisModel.addDynVariable( "salesFromWoM" , @thisModel.salesFromWoMFunction );

      % Add Stocks

      thisModel.addStock( "potentialClients",
        thisModel.parameters("potentialClientsIni"),
        @thisModel.potentialClientsStockFunction );
      thisModel.addStock( "clients",
        thisModel.parameters("clientsIni"),
        @thisModel.clientsStockFunction );

      thisModel.generateSolver();

    endfunction

    # IMPORTANT: Always pass model object as parameter to every function, since
    # we use anonymous functions which won't recognize "thisModel" object globarly

    % Static methods

    % Flows

    function retval = salesFunction( model )
      retval = model.getDynVariableValue("salesFromAd") + ...
      model.getDynVariableValue("salesFromWoM");
    endfunction

    % Dynamic Variables
    function retval = salesFromAdFunction(model )
      retval = model.getStockValue("potentialClients") * ...
      model.parameters("adEffectiveness");
    endfunction

    function retval = salesFromWoMFunction(model )
      retval = model.getStockValue("clients") * ...
      model.parameters("contactRate") * ...
      model.parameters("salesFraction") * ...
      (
        model.getStockValue("potentialClients") / ...
        (
          model.getStockValue("potentialClients") + ...
          model.getStockValue("clients")
        )
      );
    endfunction

    % Stocks
    function retval = potentialClientsStockFunction( model, takeValue = false )
      retval = -model.getFlowValue("sales", takeValue);
    endfunction

    function retval = clientsStockFunction( model, takeValue = false )
      retval = model.getFlowValue("sales", takeValue );
    endfunction


  endmethods

endclassdef