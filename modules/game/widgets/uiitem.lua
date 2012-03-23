function UIItem:onDragEnter(mousePos)
  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item then return false end

  self:setBorderWidth(1)

  self.parsed = false
  self.currentDragThing = item
  Mouse.setTargetCursor()
  return true
end

function UIItem:onDragLeave(droppedWidget, mousePos)
  if self:isVirtual() then return false end

  if not self.parsed then
    self.currentDragThing = nil
  end

  Mouse.restoreCursor()
  self:setBorderWidth(0)
  return true
end

function UIItem:onDrop(widget, mousePos)
  if self:isVirtual() then return false end

  if not widget or not widget.currentDragThing then return true end

  local pos = self.position
  local count = widget.currentDragThing:getCount()
  if widget.currentDragThing:isStackable() and count > 1 then
    widget.parsed = true
    local countWindow = createWidget('CountWindow', rootWidget)
    local spinbox = moveWindow:getChildById('spinbox')
    spinbox:setMaximum(count)
    spinbox:setMinimum(1)
    spinbox:setCurrentIndex(count)

    local okButton = moveWindow:getChildById('buttonOk')
    okButton.onClick = function()
      g_game.move(widget.currentDragThing, pos, spinbox:getCurrentIndex()) okButton:getParent():destroy()
      widget.currentDragThing = nil
    end
    moveWindow.onEnter = okButton.onClick
  else
    g_game.move(widget.currentDragThing, pos, 1)
  end

  self:setBorderWidth(0)
  return true
end

function UIItem:onHoverChange(hovered)
  if self:isVirtual() then return end

  local draggingWidget = g_ui.getDraggingWidget()
  if draggingWidget and self ~= draggingWidget then
    local gotMap = draggingWidget:getClassName() == 'UIMap'
    local gotItem = draggingWidget:getClassName() == 'UIItem' and not draggingWidget:isVirtual()
    if hovered and (gotItem or gotMap) then
      self:setBorderWidth(1)
    else
      self:setBorderWidth(0)
    end
  end
end

function UIItem:onMouseRelease(mousePosition, mouseButton)
  if self:isVirtual() then return false end

  local item = self:getItem()
  if not item or not self:containsPoint(mousePosition) then return false end
  return GameInterface.processMouseAction(mousePosition, mouseButton, nil, item, item, nil, item)
end

