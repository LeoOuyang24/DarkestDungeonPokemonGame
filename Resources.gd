class_name Resources extends Object


#just a bunch of global useful functions

#highlight a control, it is assumed the control has a shader which allows for this
static func highlight(control:Control,color:Color, uniform:String = "outline_color") -> void:
	if control && control.material:
		control.material.set_shader_parameter(uniform, color)	

#resize a control, change its min size too so even if its in a container it gets affected
static func resize(size:Vector2,control:Control) -> void:
	if control:
		control.set_custom_minimum_size( size)
		control.set_size(size);
