classdef Flow < handle

  properties
    valueEquation
    currentValue
  endproperties

  methods

    function thisFlow = Flow(
      valueEquation
    )
      thisFlow.valueEquation = valueEquation;
      thisFlow.currentValue = 0;
    endfunction

    function value = recalculate( thisFlow, takeValue = false, assignValue = false )
      if takeValue
        value = thisFlow.currentValue;
      else
        value = thisFlow.valueEquation( );
      endif

      if assignValue
        thisFlow.currentValue = value;
      endif
    endfunction

    function setEquation( thisFlow, equation )
      thisFlow.valueEquation = equation;
    endfunction

    function setValue( thisFlow, value )
      thisFlow.currentValue = value;
    endfunction

  endmethods
endclassdef