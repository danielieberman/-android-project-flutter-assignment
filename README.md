# hello_me

1.  The SnappingSheet uses the class SnappingSheetController for controlling the snapping of the sheet.
    In other words, you can control the attach position of the snappingSheet, as well as stop it from snapping,
    and you can also get information about the position and snapping of the sheet using the controller.

2.  We've got the snappingCurve which controls the snapping animation style,
    and the snappingDuration which controls.. well, the duration.

3.  Inkwell is limited to a material widget as a parent, whereas GestureDetector fits in any parent widget, or child if it has one.
    Inkwell has nice little ink animations on tap, short and long, on default, whereas GestureDetector does not.
