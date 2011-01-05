function AjaxSimulacrumCore(DatafileA, DatafileB) {
  var IFrameProc = null;
  var IFrameTick = null;
  var LastUpdate = [-1, -1];
  IFrameProc = document.createElement("IFRAME");
  IFrameProc.style.display = "none";
  IFrameProc.src = DatafileA;
  IFrameTick = document.createElement("IFRAME");
  IFrameTick.style.display = "none";
  IFrameTick.src = DatafileB;
  
  this.Start = function() {
    document.appendChild(IFrameProc);      
    document.appendChild(IFrameTick);      
    var Closure = this;
    this.UpdateInterval = setInterval(function(){Closure.PollForUpdates();}, 250);
  };

  this.PollForUpdates = function() {
    IFrameTick.contentWindow.location.reload(true);
    IFrameProc.contentWindow.location.reload(true);
  };
  
  this.CanUpdate = function (UpdateTick, Type) {
    var ReturnValue = UpdateTick > LastUpdate[Type];
    LastUpdate[Type] = UpdateTick;
    return ReturnValue;
  }
  
  this.SetInnerHTML = function(ElementID, NewInnerHTML) {
    document.getElementById(ElementID).innerHTML = NewInnerHTML;
  };
  
  this.SetValue = function(ElementID, NewValue) { 
    document.getElementById(ElementID).value = NewValue;
  };
  
  this.SetProperty = function(ElementID, PropertyName, NewValue) {
    document.getElementById(ElementID)[PropertyName] = NewValue;
  };
  
  this.CallFunction = function(FunctionName, Arguments) {
    document[FunctionName](Arguments);
  };
  
}