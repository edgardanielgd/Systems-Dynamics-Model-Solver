 classdef DynVariable < handle

  properties
    valueEquation
    value
  endproperties

  methods
    function thisDynVar = DynVariable(
      valueEquation
    )
      thisDynVar.valueEquation = valueEquation;
      thisDynVar.value = 0;
    endfunction

    function value = recalculate( thisDynVar, takeValue = false, assign_value = false )

      if takeValue
        value = thisDynVar.value;
      else
        value = thisDynVar.valueEquation( );
      endif

      if assign_value
        thisDynVar.value = value;
      endif

    endfunction

    function setEquation( thisDynVar, equation )
      thisDynVar.valueEquation = equation;
    endfunction

    function setValue( thisDynVar, value )
      thisDynVar.value = value;
    endfunction

  endmethods
endclassdef