extends Spatial

const SIZE = 256

func _ready():
	generate_island()
	

func generate_island():
	randomize()
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	var noise = OpenSimplexNoise.new()
	
	var plane_mesh =PlaneMesh.new()
	plane_mesh.size = Vector2(SIZE,SIZE)
	plane_mesh.subdivide_depth =SIZE*0.5
	plane_mesh.subdivide_width =SIZE *0.5
	
	noise.seed =randi()
	
	noise.octaves = 5#        Это Важно
	noise.period =90#         Это Важно
	
	surface_tool.create_from(plane_mesh,0)
	var array_mash = surface_tool.commit()
	data_tool.create_from_surface(array_mash,0)
	
	var custom_gradient = CustomGradientTexture.new()
	custom_gradient.gradient = Gradient.new()
	custom_gradient.type = CustomGradientTexture.GradientType.RADIAL
	custom_gradient.size = Vector2(SIZE+1,SIZE+1)
	
	
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		var data =custom_gradient.get_data()
		data.lock()
		var gradient_value =data.get_pixel(vertex.x+SIZE*0.5,vertex.z+SIZE*0.5).r *1.5
		
		
		var value = noise.get_noise_3d(vertex.x,vertex.y,vertex.z)
		
		data.unlock()
		
		value-=gradient_value
		
		vertex.y = value *60
		
		data_tool.set_vertex(i,vertex)
		
	for s in range(array_mash.get_surface_count()):
		array_mash.surface_remove(s)
		
	data_tool.commit_to_surface(array_mash)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_mash,0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	
	var material =SpatialMaterial.new()
	material.albedo_color = Color(0.0,0.3,0.1)
	
	mesh_instance.material_override = material
	mesh_instance.create_trimesh_collision()
	
	$IslandTerrain.add_child(mesh_instance)
	
	
