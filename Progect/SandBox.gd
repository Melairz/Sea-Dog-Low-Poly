extends Spatial

const SIZE = 1000
const ISLANDS_SIZE = 200
const ISLANDS = 10

var avalible_grid_slots = []

func _ready():
	generate_islands()
	
func generate_map_texture():
	var image = Image.new()
	image.create(SIZE+1,SIZE+1,false,Image.FORMAT_RGBA8)
	image.fill(Color(1.0,1.0,1.0,1.0))
	
	
	for x in int(SIZE / ISLANDS_SIZE):
		for y in int(SIZE / ISLANDS_SIZE):
			avalible_grid_slots.push_back(Vector2(x,y))
	
	for i in ISLANDS:
		var tex = CustomGradientTexture.new()
		tex.gradient = Gradient.new()
		tex.type = CustomGradientTexture.GradientType.RADIAL
		tex.size = Vector2(ISLANDS_SIZE,ISLANDS_SIZE)
		tex._update()
		
		
		var data = tex.get_data()
		data.lock()
		
		
		var index = int(rand_range(0,avalible_grid_slots.size()-1))
		var pos = avalible_grid_slots[index]
		avalible_grid_slots.remove(index)
		
		image.blend_rect(data,data.get_used_rect(),pos*ISLANDS_SIZE)
		
		data.unlock()
		
	return image
	



func generate_islands():
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
	noise.period =60#         Это Важно
	
	surface_tool.create_from(plane_mesh,0)
	var array_mash = surface_tool.commit()
	data_tool.create_from_surface(array_mash,0)	
	
	var image_map = generate_map_texture()	
	
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		image_map.lock()
		var gradient_value = image_map.get_pixel(vertex.x+SIZE*0.5,vertex.z+SIZE*0.5).r
		image_map.unlock()
		
		var value = noise.get_noise_3d(vertex.x,vertex.y,vertex.z)
		
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
	material.albedo_color = Color(0.0,0.3,0.0)
	
	mesh_instance.material_override = material
	mesh_instance.create_trimesh_collision()
	
	$IslandTerrain.add_child(mesh_instance)
	
	
